#!/bin/sh
set -eu

guard_script=$(CDPATH= cd -- "$(dirname -- "$0")/../hooks" && pwd)/ponytail-branch-guard.sh
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

run_git() {
  git -C "$tmp_dir/repo" "$@"
}

mkdir "$tmp_dir/repo"
run_git init -q -b main
run_git config user.name "Ponytail Test"
run_git config user.email "ponytail-test@example.invalid"
run_git remote add my_ochestrator https://example.invalid/repo.git

printf 'root\n' >"$tmp_dir/repo/file.txt"
run_git add file.txt
run_git commit -q -m "root main"
main_commit=$(run_git rev-parse HEAD)
run_git update-ref refs/remotes/my_ochestrator/main "$main_commit"

run_git checkout -q -b main-v2
printf 'main-v2 base\n' >>"$tmp_dir/repo/file.txt"
run_git commit -q -am "main-v2 only base"
main_v2_base=$(run_git rev-parse HEAD)

run_git checkout -q -b project/dynamos
printf 'project dynamos\n' >>"$tmp_dir/repo/file.txt"
run_git commit -q -am "project dynamos work"
run_git update-ref refs/remotes/my_ochestrator/project/dynamos "$(run_git rev-parse HEAD)"
run_git branch --set-upstream-to=my_ochestrator/project/dynamos project/dynamos >/dev/null

run_git checkout -q main-v2
printf 'new main-v2 tip\n' >>"$tmp_dir/repo/file.txt"
run_git commit -q -am "new main-v2 tip"
run_git update-ref refs/remotes/my_ochestrator/main-v2 "$(run_git rev-parse HEAD)"

run_git checkout -q project/dynamos
run_git branch -D main-v2 >/dev/null

if run_git rev-parse --verify refs/remotes/origin/main-v2 >/dev/null 2>&1; then
  echo "test fixture should not have origin/main-v2" >&2
  exit 1
fi

if run_git rev-parse --verify main-v2 >/dev/null 2>&1; then
  echo "test fixture should not have local main-v2" >&2
  exit 1
fi

if [ "$(run_git merge-base refs/remotes/my_ochestrator/main-v2 HEAD)" != "$main_v2_base" ]; then
  echo "test fixture did not create stale main-v2-derived branch" >&2
  exit 1
fi

(
  cd "$tmp_dir/repo"
  "$guard_script"
)
