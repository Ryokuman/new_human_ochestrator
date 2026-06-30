#!/bin/sh
set -eu

repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$repo_root"

current_branch=$(git branch --show-current 2>/dev/null || true)
legacy_main_v2_fork_point=b1516c8c3e5b94cd8b413debeedee2ed8e061445
remote_name=

case "$current_branch" in
  main | develop)
    echo "Ponytail is only enabled on main-v2 or branches derived from main-v2." >&2
    exit 1
    ;;
esac

is_shallow_repository() {
  [ "$(git rev-parse --is-shallow-repository 2>/dev/null || echo false)" = "true" ]
}

select_remote() {
  branch_remote=$(git config --get "branch.$current_branch.remote" 2>/dev/null || true)

  if [ -n "$branch_remote" ] && git remote get-url "$branch_remote" >/dev/null 2>&1; then
    remote_name=$branch_remote
    return 0
  fi

  if git remote get-url origin >/dev/null 2>&1; then
    remote_name=origin
    return 0
  fi

  remote_name=$(git remote | sed -n '1p')
  [ -n "$remote_name" ]
}

remote_ref() {
  echo "refs/remotes/$remote_name/$1"
}

ensure_head_history() {
  is_shallow_repository || return 0
  [ -n "$remote_name" ] || return 0

  git fetch --quiet --deepen=100000 --no-tags "$remote_name" >/dev/null 2>&1 ||
    git fetch --quiet --unshallow --no-tags "$remote_name" >/dev/null 2>&1 || true
}

ensure_main_v2_ref() {
  [ -n "$remote_name" ] || return 0
  if is_shallow_repository; then
    git fetch --quiet --deepen=100000 --no-tags "$remote_name" "main-v2:$(remote_ref main-v2)" >/dev/null 2>&1 ||
      git fetch --quiet --unshallow --no-tags "$remote_name" "main-v2:$(remote_ref main-v2)" >/dev/null 2>&1 || true
  else
    git fetch --quiet --no-tags "$remote_name" "main-v2:$(remote_ref main-v2)" >/dev/null 2>&1 || true
  fi
}

ensure_main_ref() {
  [ -n "$remote_name" ] || return 0
  if is_shallow_repository; then
    git fetch --quiet --deepen=100000 --no-tags "$remote_name" "main:$(remote_ref main)" >/dev/null 2>&1 ||
      git fetch --quiet --unshallow --no-tags "$remote_name" "main:$(remote_ref main)" >/dev/null 2>&1 || true
  else
    git fetch --quiet --no-tags "$remote_name" "main:$(remote_ref main)" >/dev/null 2>&1 || true
  fi
}

has_main_ref() {
  git rev-parse --verify main >/dev/null 2>&1 ||
    { [ -n "$remote_name" ] && git rev-parse --verify "$(remote_ref main)" >/dev/null 2>&1; }
}

first_parent_has_main_v2_only_commit() {
  main_v2_ref=$1

  for commit in $(git rev-list --first-parent HEAD 2>/dev/null || true); do
    if git merge-base --is-ancestor "$commit" "$main_v2_ref" &&
      ! is_in_main_lineage "$commit"; then
      return 0
    fi
  done

  return 1
}

is_in_main_lineage() {
  commit=$1

  if [ -n "$remote_name" ] && git rev-parse --verify "$(remote_ref main)" >/dev/null 2>&1; then
    git merge-base --is-ancestor "$commit" "$(remote_ref main)"
    return $?
  fi

  if git rev-parse --verify main >/dev/null 2>&1 &&
    git merge-base --is-ancestor "$commit" main; then
    return 0
  fi

  return 1
}

is_main_v2_lineage() {
  main_v2_ref=$1

  git rev-parse --verify "$main_v2_ref" >/dev/null 2>&1 || return 1

  if git merge-base --is-ancestor "$main_v2_ref" HEAD; then
    if has_main_ref && is_in_main_lineage "$main_v2_ref"; then
      return 1
    fi
    if ! first_parent_has_main_v2_only_commit "$main_v2_ref"; then
      return 1
    fi
    return 0
  fi

  shared_base=$(git merge-base "$main_v2_ref" HEAD 2>/dev/null || true)

  [ -n "$shared_base" ] || return 1
  [ "$shared_base" != "$legacy_main_v2_fork_point" ] || return 1
  has_main_ref || return 1
  first_parent_has_main_v2_only_commit "$main_v2_ref" || return 1
  ! is_in_main_lineage "$shared_base"
}

select_remote || true
ensure_head_history
ensure_main_v2_ref
ensure_main_ref

if [ "$current_branch" = "main-v2" ] &&
  [ -n "$remote_name" ] &&
  git rev-parse --verify "$(remote_ref main-v2)" >/dev/null 2>&1 &&
  ! git merge-base --is-ancestor "$(remote_ref main-v2)" HEAD; then
  echo "Ponytail is only enabled on the verified main-v2 branch or branches derived from main-v2." >&2
  exit 1
fi

if [ -n "$remote_name" ] && git rev-parse --verify "$(remote_ref main-v2)" >/dev/null 2>&1; then
  if is_main_v2_lineage "$(remote_ref main-v2)"; then
    exit 0
  fi
elif is_main_v2_lineage main-v2; then
  exit 0
fi

echo "Ponytail is only enabled on main-v2 or branches derived from main-v2." >&2
exit 1
