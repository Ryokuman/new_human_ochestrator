#!/usr/bin/env bash
set -euo pipefail

compatible_main=""
if [ "${1:-}" = "--compatible-main" ]; then
  [ -n "${2:-}" ] || { printf 'COMPATIBLE_MAIN_REQUIRED\n' >&2; exit 20; }
  compatible_main="$2"
  shift 2
fi

remote="${1:-origin}"
branch="$(git branch --show-current)"

modern_main=false
[[ "$branch" =~ ^(main-v[0-9]+|workspace-[^/]+|project-[^/]+)/main$ ]] && modern_main=true
compatible_project_main=false
if [ -n "$compatible_main" ] && [ "$branch" = "$compatible_main" ] && [[ "$branch" =~ ^project-[^/]+$|^project/[^/]+$ ]]; then
  compatible_project_main=true
fi

if [ "$modern_main" != true ] && [ "$compatible_project_main" != true ]; then
  printf 'NON_MAIN_BRANCH=%s\n' "$branch" >&2
  exit 20
fi

if [ -n "$(git status --porcelain)" ]; then
  printf 'DIRTY_MAIN=%s\n' "$branch" >&2
  exit 21
fi

if ! git fetch --no-tags "$remote" "$branch"; then
  printf 'REMOTE_REF_UNAVAILABLE=%s/%s\n' "$remote" "$branch" >&2
  exit 22
fi

if ! git show-ref --verify --quiet "refs/remotes/$remote/$branch"; then
  printf 'REMOTE_REF_UNAVAILABLE=%s/%s\n' "$remote" "$branch" >&2
  exit 22
fi

read -r behind ahead < <(git rev-list --left-right --count "$remote/$branch...HEAD")

if [ "$ahead" -gt 0 ] && [ "$behind" -gt 0 ]; then
  printf 'DIVERGED=%s/%s behind=%s ahead=%s\n' "$remote" "$branch" "$behind" "$ahead" >&2
  exit 24
fi

if [ "$ahead" -gt 0 ]; then
  printf 'LOCAL_MAIN_AHEAD=%s/%s ahead=%s\n' "$remote" "$branch" "$ahead" >&2
  exit 23
fi

if [ "$behind" -gt 0 ]; then
  git merge --ff-only "$remote/$branch"
fi

read -r final_behind final_ahead < <(git rev-list --left-right --count "$remote/$branch...HEAD")
[ "$final_behind" -eq 0 ] && [ "$final_ahead" -eq 0 ]

printf 'BASE_REMOTE=%s\n' "$remote"
printf 'BASE_BRANCH=%s\n' "$branch"
printf 'BASE_SHA=%s\n' "$(git rev-parse HEAD)"
