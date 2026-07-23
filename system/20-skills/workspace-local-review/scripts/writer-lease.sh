#!/usr/bin/env bash
set -euo pipefail

action="${1:-}"
work_dir="${2:-}"
writer_id="${3:-}"

if [ -z "$action" ] || [ -z "$work_dir" ] || [ -z "$writer_id" ]; then
  printf '사용법: writer-lease.sh <acquire|check|renew|release> <local 작업 절대경로> <writer-id>\n' >&2
  exit 30
fi

case "$work_dir" in
  /*) ;;
  *) printf 'ABSOLUTE_WORK_DIR_REQUIRED=%s\n' "$work_dir" >&2; exit 30 ;;
esac

if [[ ! "$writer_id" =~ ^[A-Za-z0-9._:-]+$ ]]; then
  printf 'INVALID_WRITER_ID=%s\n' "$writer_id" >&2
  exit 30
fi

lease_dir="$work_dir/.writer-lease"
owner_file="$lease_dir/owner"
acquired_file="$lease_dir/acquired_at"
renewed_file="$lease_dir/renewed_at"

timestamp() {
  date -u '+%Y-%m-%dT%H:%M:%SZ'
}

current_owner() {
  if [ -f "$owner_file" ]; then
    sed -n '1p' "$owner_file"
  else
    printf '<initializing>'
  fi
}

require_owner() {
  if [ ! -d "$lease_dir" ]; then
    printf 'LEASE_NOT_FOUND=%s\n' "$lease_dir" >&2
    exit 33
  fi

  local owner
  owner="$(current_owner)"
  if [ "$owner" != "$writer_id" ]; then
    printf 'LEASE_OWNER_MISMATCH=expected:%s actual:%s\n' "$writer_id" "$owner" >&2
    exit 32
  fi
}

case "$action" in
  acquire)
    mkdir -p "$work_dir"
    if mkdir "$lease_dir" 2>/dev/null; then
      now="$(timestamp)"
      printf '%s\n' "$writer_id" > "$owner_file"
      printf '%s\n' "$now" > "$acquired_file"
      printf '%s\n' "$now" > "$renewed_file"
    else
      owner="$(current_owner)"
      if [ "$owner" != "$writer_id" ]; then
        printf 'LEASE_CONFLICT=owner:%s\n' "$owner" >&2
        exit 31
      fi
    fi
    ;;
  check)
    require_owner
    ;;
  renew)
    require_owner
    timestamp > "$renewed_file"
    ;;
  release)
    require_owner
    rm -f "$owner_file" "$acquired_file" "$renewed_file"
    rmdir "$lease_dir"
    ;;
  *)
    printf 'UNKNOWN_ACTION=%s\n' "$action" >&2
    exit 30
    ;;
esac

printf 'LEASE_ACTION=%s\n' "$action"
printf 'LEASE_PATH=%s\n' "$lease_dir"
printf 'WRITER_ID=%s\n' "$writer_id"
