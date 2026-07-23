#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

work_dir="$TMP_DIR/local/demo"
lease="$SCRIPT_DIR/writer-lease.sh"

bash "$lease" acquire "$work_dir" writer-a >/dev/null
bash "$lease" check "$work_dir" writer-a >/dev/null
bash "$lease" renew "$work_dir" writer-a >/dev/null
[ "$(sed -n '1p' "$work_dir/.writer-lease/owner")" = "writer-a" ]
[ -s "$work_dir/.writer-lease/acquired_at" ]
[ -s "$work_dir/.writer-lease/renewed_at" ]

set +e
bash "$lease" acquire "$work_dir" writer-b >/dev/null 2>&1
conflict_status=$?
bash "$lease" release "$work_dir" writer-b >/dev/null 2>&1
wrong_owner_status=$?
set -e
[ "$conflict_status" -eq 31 ]
[ "$wrong_owner_status" -eq 32 ]

bash "$lease" release "$work_dir" writer-a >/dev/null
[ ! -e "$work_dir/.writer-lease" ]

race_dir="$TMP_DIR/local/race"
set +e
bash "$lease" acquire "$race_dir" writer-a >/dev/null 2>&1 &
pid_a=$!
bash "$lease" acquire "$race_dir" writer-b >/dev/null 2>&1 &
pid_b=$!
wait "$pid_a"
status_a=$?
wait "$pid_b"
status_b=$?
set -e

if [ "$status_a" -eq 0 ]; then
  [ "$status_b" -eq 31 ]
  winner=writer-a
else
  [ "$status_a" -eq 31 ]
  [ "$status_b" -eq 0 ]
  winner=writer-b
fi

bash "$lease" check "$race_dir" "$winner" >/dev/null
bash "$lease" release "$race_dir" "$winner" >/dev/null

printf 'workspace local writer lease test passed\n'
