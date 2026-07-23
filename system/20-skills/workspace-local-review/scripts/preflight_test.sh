#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

remote_repo="$TMP_DIR/remote.git"
seed_repo="$TMP_DIR/seed"
work_repo="$TMP_DIR/work"
branch="workspace-demo/main"

git init --bare "$remote_repo" >/dev/null
git init -b "$branch" "$seed_repo" >/dev/null
git -C "$seed_repo" config user.name Test
git -C "$seed_repo" config user.email test@example.com
printf 'initial\n' > "$seed_repo/note.md"
printf 'local/\n' > "$seed_repo/.gitignore"
git -C "$seed_repo" add note.md .gitignore
git -C "$seed_repo" commit -m initial >/dev/null
git -C "$seed_repo" remote add origin "$remote_repo"
git -C "$seed_repo" push -u origin "$branch" >/dev/null
git -C "$seed_repo" branch project-demo
git -C "$seed_repo" push origin project-demo >/dev/null
git -C "$seed_repo" branch project/demo
git -C "$seed_repo" push origin project/demo >/dev/null
git clone --branch "$branch" "$remote_repo" "$work_repo" >/dev/null
git -C "$work_repo" config user.name Test
git -C "$work_repo" config user.email test@example.com

run_status() {
  local expected="$1"
  shift
  set +e
  "$@" >/dev/null 2>&1
  local actual=$?
  set -e
  [ "$actual" -eq "$expected" ] || {
    printf 'expected exit %s, got %s: %s\n' "$expected" "$actual" "$*" >&2
    exit 1
  }
}

git -C "$work_repo" -c advice.detachedHead=false status >/dev/null
(cd "$work_repo" && "$SCRIPT_DIR/preflight.sh" origin >/dev/null)

git -C "$work_repo" switch -c project-demo origin/project-demo >/dev/null
run_status 20 bash -c "cd '$work_repo' && '$SCRIPT_DIR/preflight.sh' origin"
(cd "$work_repo" && "$SCRIPT_DIR/preflight.sh" --compatible-main project-demo origin >/dev/null)
run_status 20 bash -c "cd '$work_repo' && '$SCRIPT_DIR/preflight.sh' --compatible-main project-other origin"
git -C "$work_repo" switch "$branch" >/dev/null

git -C "$work_repo" switch -c project/demo origin/project/demo >/dev/null
run_status 20 bash -c "cd '$work_repo' && '$SCRIPT_DIR/preflight.sh' origin"
(cd "$work_repo" && "$SCRIPT_DIR/preflight.sh" --compatible-main project/demo origin >/dev/null)
run_status 20 bash -c "cd '$work_repo' && '$SCRIPT_DIR/preflight.sh' --compatible-main project/other origin"
git -C "$work_repo" switch "$branch" >/dev/null

git -C "$work_repo" switch -c workspace-demo/topic >/dev/null
run_status 20 bash -c "cd '$work_repo' && '$SCRIPT_DIR/preflight.sh' origin"
git -C "$work_repo" switch "$branch" >/dev/null

printf 'dirty\n' >> "$work_repo/note.md"
run_status 21 bash -c "cd '$work_repo' && '$SCRIPT_DIR/preflight.sh' origin"
git -C "$work_repo" restore note.md

printf 'untracked\n' > "$work_repo/outside-local.md"
run_status 21 bash -c "cd '$work_repo' && '$SCRIPT_DIR/preflight.sh' origin"
rm "$work_repo/outside-local.md"

mkdir -p "$work_repo/local/review"
printf 'ignored review\n' > "$work_repo/local/review/_review.md"
(cd "$work_repo" && "$SCRIPT_DIR/preflight.sh" origin >/dev/null)

run_status 22 bash -c "cd '$work_repo' && '$SCRIPT_DIR/preflight.sh' missing"

printf 'ahead\n' >> "$work_repo/note.md"
git -C "$work_repo" add note.md
git -C "$work_repo" commit -m ahead >/dev/null
run_status 23 bash -c "cd '$work_repo' && '$SCRIPT_DIR/preflight.sh' origin"
git -C "$work_repo" reset --hard "origin/$branch" >/dev/null

printf 'behind\n' >> "$seed_repo/note.md"
git -C "$seed_repo" add note.md
git -C "$seed_repo" commit -m behind >/dev/null
git -C "$seed_repo" push origin "$branch" >/dev/null
(cd "$work_repo" && "$SCRIPT_DIR/preflight.sh" origin >/dev/null)
[ "$(git -C "$work_repo" rev-parse HEAD)" = "$(git -C "$seed_repo" rev-parse HEAD)" ]

printf 'local divergence\n' >> "$work_repo/note.md"
git -C "$work_repo" add note.md
git -C "$work_repo" commit -m local-divergence >/dev/null
printf 'remote divergence\n' >> "$seed_repo/note.md"
git -C "$seed_repo" add note.md
git -C "$seed_repo" commit -m remote-divergence >/dev/null
git -C "$seed_repo" push origin "$branch" >/dev/null
run_status 24 bash -c "cd '$work_repo' && '$SCRIPT_DIR/preflight.sh' origin"

printf 'workspace local preflight test passed\n'
