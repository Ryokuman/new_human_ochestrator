#!/usr/bin/env bash

set -eo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
SKILLS_DIR="${CODEX_SKILLS_DIR:-$CODEX_HOME/skills}"
TMP_ROOT=""

SUPERPOWERS_REPO="obra/superpowers"
SUPERPOWERS_REF="${SUPERPOWERS_REF:-main}"
AGENT_BROWSER_REPO="vercel-labs/agent-browser"
AGENT_BROWSER_REF="${AGENT_BROWSER_REF:-main}"
COMPOUND_ENGINEERING_REPO="EveryInc/compound-engineering-plugin"
COMPOUND_ENGINEERING_REF="${COMPOUND_ENGINEERING_REF:-main}"

USING_SUPERPOWERS_SKILLS=(
  "using-superpowers"
)

SUPERPOWERS_WORKFLOW_SKILLS=(
  "receiving-code-review"
  "requesting-code-review"
  "verification-before-completion"
  "test-driven-development"
  "systematic-debugging"
  "using-git-worktrees"
  "writing-plans"
  "writing-skills"
  "dispatching-parallel-agents"
  "finishing-a-development-branch"
)

SELECTED=()
ASSUME_YES="no"
NO_INSTALL="no"
FORCE_WRITE="no"
PROJECT_ID=""
PROJECT_NAME=""
PROJECT_SSOT_TARGET=""

usage() {
  cat <<'USAGE'
Usage:
  ./setup.sh
  ./setup.sh --all
  ./setup.sh --repo-skills --using-superpowers --superpowers-workflow --agent-browser --compound-engineering
  ./setup.sh --init-config
  ./setup.sh --create-project-ssot --project-id <id> --target <dir>

Options:
  --all                    Run every setup group.
  --none                   Exit without setup.
  --repo-skills            Install this repository's repo skills.
  --using-superpowers      Install using-superpowers from obra/superpowers.
  --superpowers-workflow   Install the required Superpowers workflow skills.
  --agent-browser          Install agent-browser CLI/browser runtime and skill.
  --compound-engineering   Install Compound Engineering skills.
  --init-config            Create local config files from examples.
  --create-project-ssot    Create a project SSoT scaffold.
  --project-id <id>        Project id for --create-project-ssot.
  --project-name <name>    Project display name. Defaults to project id.
  --target <dir>           Target directory for --create-project-ssot.
  --force                  Overwrite setup-generated local files when allowed.
  --yes, -y                Skip the final confirmation.
  --help, -h               Show this help.

Environment:
  CODEX_HOME               Defaults to ~/.codex.
  CODEX_SKILLS_DIR         Defaults to $CODEX_HOME/skills.
  SUPERPOWERS_REF          Defaults to main.
  AGENT_BROWSER_REF        Defaults to main.
  AGENT_BROWSER_SKIP_RUNTIME
                           Set to 1 to install only the skill file, not the CLI/browser runtime.
  COMPOUND_ENGINEERING_REF Defaults to main.
USAGE
}

info() {
  printf '%s\n' "$*"
}

fail() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

cleanup() {
  if [ -n "$TMP_ROOT" ] && [ -d "$TMP_ROOT" ]; then
    rm -rf "$TMP_ROOT"
  fi
}
trap cleanup EXIT

contains_selection() {
  local needle="$1"
  local item
  for item in "${SELECTED[@]}"; do
    [ "$item" = "$needle" ] && return 0
  done
  return 1
}

has_skill_selection() {
  contains_selection "repo-skills" || contains_selection "using-superpowers" || contains_selection "superpowers-workflow" || contains_selection "agent-browser" || contains_selection "compound-engineering"
}

add_selection() {
  local item="$1"
  contains_selection "$item" || SELECTED+=("$item")
}

select_all() {
  SELECTED=(
    "repo-skills"
    "using-superpowers"
    "superpowers-workflow"
    "agent-browser"
    "compound-engineering"
    "init-config"
  )
}

parse_args() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --all) select_all ;;
      --none) SELECTED=(); ASSUME_YES="yes"; NO_INSTALL="yes"; return 0 ;;
      --repo-skills) add_selection "repo-skills" ;;
      --using-superpowers) add_selection "using-superpowers" ;;
      --superpowers-workflow) add_selection "superpowers-workflow" ;;
      --agent-browser) add_selection "agent-browser" ;;
      --compound-engineering) add_selection "compound-engineering" ;;
      --init-config) add_selection "init-config" ;;
      --create-project-ssot) add_selection "create-project-ssot" ;;
      --project-id) PROJECT_ID="${2:-}"; [ -n "$PROJECT_ID" ] || fail "--project-id requires a value"; shift ;;
      --project-name) PROJECT_NAME="${2:-}"; [ -n "$PROJECT_NAME" ] || fail "--project-name requires a value"; shift ;;
      --target) PROJECT_SSOT_TARGET="${2:-}"; [ -n "$PROJECT_SSOT_TARGET" ] || fail "--target requires a value"; shift ;;
      --force) FORCE_WRITE="yes" ;;
      --yes|-y) ASSUME_YES="yes" ;;
      --help|-h) usage; exit 0 ;;
      *) fail "unknown option: $1" ;;
    esac
    shift
  done
}

prompt_selection() {
  [ "$NO_INSTALL" = "yes" ] && return 0
  [ ${#SELECTED[@]} -gt 0 ] && return 0

  cat <<'PROMPT'
실행할 셋업 항목을 선택하세요. 여러 개는 쉼표나 공백으로 구분하고, 전체 실행은 all, 실행 안 함은 none을 입력합니다.

1. repo 내부 skill
2. using-superpowers
3. Superpowers 작업 보조 묶음
4. agent-browser
5. compound-engineering
6. config 초안 생성
7. project SSoT 반복 구조 생성
PROMPT

  printf '> '
  local answer
  IFS= read -r answer
  answer="${answer:-none}"

  case "$answer" in
    all|ALL|a|A)
      select_all
      return 0
      ;;
    none|NONE|n|N|"")
      SELECTED=()
      return 0
      ;;
  esac

  answer="${answer//,/ }"
  local token
  for token in $answer; do
    case "$token" in
      1) add_selection "repo-skills" ;;
      2) add_selection "using-superpowers" ;;
      3) add_selection "superpowers-workflow" ;;
      4) add_selection "agent-browser" ;;
      5) add_selection "compound-engineering" ;;
      6) add_selection "init-config" ;;
      7) add_selection "create-project-ssot" ;;
      *) fail "unknown selection: $token" ;;
    esac
  done
}

confirm_selection() {
  if [ ${#SELECTED[@]} -eq 0 ]; then
    info "선택된 스킬 묶음이 없습니다. 설치하지 않고 종료합니다."
    exit 0
  fi

  info ""
  info "실행 대상:"
  local item
  for item in "${SELECTED[@]}"; do
    info "  - $item"
  done
  info ""
  if has_skill_selection; then
    info "스킬 설치 위치: $SKILLS_DIR"
  fi

  [ "$ASSUME_YES" = "yes" ] && return 0

  printf '계속할까요? [y/N] '
  local answer
  IFS= read -r answer
  case "$answer" in
    y|Y|yes|YES) ;;
    *) info "취소했습니다."; exit 0 ;;
  esac
}

ensure_tmp() {
  if [ -z "$TMP_ROOT" ]; then
    TMP_ROOT="$(mktemp -d)"
  fi
}

ensure_tools() {
  if contains_selection "using-superpowers" || contains_selection "superpowers-workflow" || contains_selection "agent-browser" || contains_selection "compound-engineering"; then
    command -v curl >/dev/null 2>&1 || fail "curl is required"
    command -v tar >/dev/null 2>&1 || fail "tar is required"
  fi

  if contains_selection "repo-skills" || contains_selection "using-superpowers" || contains_selection "superpowers-workflow" || contains_selection "agent-browser" || contains_selection "compound-engineering"; then
    mkdir -p "$SKILLS_DIR"
  fi
}

download_repo() {
  local repo="$1"
  local ref="$2"
  local slug="${repo//\//-}-${ref}"
  local target="$TMP_ROOT/$slug"

  if [ -d "$target" ]; then
    printf '%s\n' "$target"
    return 0
  fi

  local archive="$TMP_ROOT/$slug.tar.gz"
  local extract="$TMP_ROOT/$slug.extract"
  mkdir -p "$extract"

  printf '다운로드: https://github.com/%s (%s)\n' "$repo" "$ref" >&2
  curl -fsSL "https://github.com/$repo/archive/refs/heads/$ref.tar.gz" -o "$archive"
  tar -xzf "$archive" -C "$extract"

  local top
  top="$(find "$extract" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
  [ -n "$top" ] || fail "failed to extract $repo@$ref"
  mv "$top" "$target"
  printf '%s\n' "$target"
}

backup_existing_skill() {
  local dest="$1"
  [ -e "$dest" ] || return 0

  local backup="${dest}.backup.$(date +%Y%m%d%H%M%S)"
  info "기존 스킬 백업: $dest -> $backup"
  mv "$dest" "$backup"
}

install_skill_dir() {
  local source_dir="$1"
  local name
  name="$(basename "$source_dir")"

  [ -f "$source_dir/SKILL.md" ] || fail "missing SKILL.md: $source_dir"

  local dest="$SKILLS_DIR/$name"
  backup_existing_skill "$dest"
  cp -R "$source_dir" "$dest"
  info "설치됨: $name"
}

install_repo_skills() {
  local repo_skills="$REPO_ROOT/system/20-skills"
  [ -d "$repo_skills" ] || fail "repo skills not found: $repo_skills"

  info ""
  info "repo 내부 skill 설치"
  local skill
  while IFS= read -r skill; do
    install_skill_dir "$skill"
  done < <(find "$repo_skills" -mindepth 1 -maxdepth 1 -type d -exec test -f '{}/SKILL.md' ';' -print | sort)
}

install_superpowers_subset() {
  local label="$1"
  shift
  local root
  root="$(download_repo "$SUPERPOWERS_REPO" "$SUPERPOWERS_REF")"

  info ""
  info "$label"
  local skill
  for skill in "$@"; do
    install_skill_dir "$root/skills/$skill"
  done
}

install_agent_browser() {
  info ""
  info "agent-browser 설치"

  if [ "${AGENT_BROWSER_SKIP_RUNTIME:-0}" = "1" ]; then
    info "AGENT_BROWSER_SKIP_RUNTIME=1 이므로 CLI/browser runtime 설치를 건너뜁니다."
  else
    if command -v npm >/dev/null 2>&1; then
      if ! command -v agent-browser >/dev/null 2>&1; then
        info "agent-browser CLI 설치"
        npm install -g agent-browser
      else
        info "agent-browser CLI 이미 설치됨: $(command -v agent-browser)"
      fi

      info "agent-browser browser runtime 설치"
      agent-browser install
    else
      info "npm이 없어 agent-browser CLI 설치를 건너뜁니다."
    fi
  fi

  local root
  root="$(download_repo "$AGENT_BROWSER_REPO" "$AGENT_BROWSER_REF")"
  install_skill_dir "$root/skills/agent-browser"
}

install_compound_engineering() {
  local root
  root="$(download_repo "$COMPOUND_ENGINEERING_REPO" "$COMPOUND_ENGINEERING_REF")"

  info ""
  info "compound-engineering skill 설치"
  local skills_root="$root/plugins/compound-engineering/skills"
  [ -d "$skills_root" ] || fail "Compound Engineering skills not found: $skills_root"

  local skill
  while IFS= read -r skill; do
    install_skill_dir "$skill"
  done < <(find "$skills_root" -mindepth 1 -maxdepth 1 -type d -exec test -f '{}/SKILL.md' ';' -print | sort)
}

copy_setup_file() {
  local source="$1"
  local dest="$2"

  [ -f "$source" ] || fail "missing template: $source"
  mkdir -p "$(dirname "$dest")"

  if [ -e "$dest" ] && [ "$FORCE_WRITE" != "yes" ]; then
    info "이미 있음: $dest"
    return 0
  fi

  cp "$source" "$dest"
  info "생성됨: $dest"
}

write_setup_file() {
  local dest="$1"
  local content="$2"

  mkdir -p "$(dirname "$dest")"
  if [ -e "$dest" ] && [ "$FORCE_WRITE" != "yes" ]; then
    info "이미 있음: $dest"
    return 0
  fi

  printf '%s\n' "$content" > "$dest"
  info "생성됨: $dest"
}

project_ssot_vault_path() {
  local target="$1"

  case "$target" in
    "$REPO_ROOT"/*) printf '%s\n' "${target#"$REPO_ROOT/"}" ;;
    *) printf '%s\n' "" ;;
  esac
}

write_project_work_items_base() {
  local dest="$1"
  local project_path="$2"
  local issue_folder="20-issues"
  local task_folder="30-tasks"

  if [ -n "$project_path" ]; then
    issue_folder="$project_path/20-issues"
    task_folder="$project_path/30-tasks"
  fi

  write_setup_file "$dest" "filters:
  and:
    - file.ext == \"md\"
    - file.name != \"ISSUE-template\"
    - file.name != \"ISSUE-template.md\"
    - file.name != \"TASK-template\"
    - file.name != \"TASK-template.md\"
    - or:
        - file.inFolder(\"$issue_folder\")
        - file.inFolder(\"$task_folder\")
properties:
  id:
    displayName: ID
  type:
    displayName: 타입
  status:
    displayName: 상태
  priority:
    displayName: 우선순위
  severity:
    displayName: 중요도
  level_target:
    displayName: 레벨
  file.tags:
    displayName: 태그
  created:
    displayName: 생성일
  updated:
    displayName: 수정일
  closed:
    displayName: 종료일
  file.mtime:
    displayName: 파일수정일
views:
  - type: table
    name: 전체 - 즉석 필터
    order:
      - id
      - type
      - status
      - priority
      - severity
      - level_target
      - file.tags
      - updated
      - file.mtime
  - type: table
    name: 진행 중 Task
    filters:
      and:
        - type == \"task\"
        - '[\"todo\", \"in_progress\", \"blocked\", \"review\"].contains(status)'
    order:
      - id
      - status
      - priority
      - level_target
      - file.tags
      - updated
  - type: table
    name: 완료 Task
    filters:
      and:
        - type == \"task\"
        - status == \"done\"
    order:
      - id
      - status
      - priority
      - level_target
      - file.tags
      - closed
      - updated
  - type: table
    name: 열린 Issue
    filters:
      and:
        - type == \"issue\"
        - '[\"todo\", \"in_progress\", \"blocked\", \"review\", \"open\"].contains(status)'
    order:
      - id
      - status
      - severity
      - level_target
      - file.tags
      - updated"
}

init_config() {
  info ""
  info "config 초안 생성"
  copy_setup_file "$REPO_ROOT/system/config/silo-runtime.env.example" "$REPO_ROOT/system/config/silo-runtime.env"
  copy_setup_file "$REPO_ROOT/system/config/silo-projects.example.yaml" "$REPO_ROOT/system/config/silo-projects.yaml"
  copy_setup_file "$REPO_ROOT/system/config/shared-runtime-registry.example.yaml" "$REPO_ROOT/system/config/shared-runtime-registry.yaml"
}

prompt_project_ssot_args() {
  contains_selection "create-project-ssot" || return 0

  if [ -z "$PROJECT_ID" ]; then
    if [ "$ASSUME_YES" = "yes" ]; then
      fail "--create-project-ssot with --yes requires --project-id"
    fi
    printf 'project id를 입력하세요: '
    IFS= read -r PROJECT_ID
  fi

  [ -n "$PROJECT_ID" ] || fail "project id is required"
  if ! [[ "$PROJECT_ID" =~ ^[a-zA-Z0-9][a-zA-Z0-9._-]*$ ]]; then
    fail "project id must use letters, numbers, dot, underscore, or dash"
  fi

  if [ -z "$PROJECT_NAME" ]; then
    PROJECT_NAME="$PROJECT_ID"
  fi

  if [ -z "$PROJECT_SSOT_TARGET" ]; then
    PROJECT_SSOT_TARGET="$REPO_ROOT/projects/$PROJECT_ID/ssot"
    if [ "$ASSUME_YES" != "yes" ]; then
      printf 'project SSoT target [%s]: ' "$PROJECT_SSOT_TARGET"
      local answer
      IFS= read -r answer
      [ -n "$answer" ] && PROJECT_SSOT_TARGET="$answer"
    fi
  fi
}

create_project_ssot() {
  prompt_project_ssot_args

  local target="$PROJECT_SSOT_TARGET"
  case "$target" in
    /*) ;;
    *) target="$REPO_ROOT/$target" ;;
  esac

  info ""
  info "project SSoT 반복 구조 생성"
  info "project id: $PROJECT_ID"
  info "target: $target"
  local project_vault_path
  project_vault_path="$(project_ssot_vault_path "$target")"

  mkdir -p \
    "$target/00-dashboard" \
    "$target/10-dictionary" \
    "$target/20-issues" \
    "$target/30-tasks" \
    "$target/50-decisions" \
    "$target/70-handoff" \
    "$target/90-coverage" \
    "$target/templates"

  write_setup_file "$target/README.md" "# $PROJECT_NAME Project SSoT

이 폴더는 $PROJECT_NAME 프로젝트 내부 운영 SSoT입니다.

## 폴더

- \`00-dashboard/\`: 현재 상태, 활성 issue/task, 다음 행동
- \`10-dictionary/\`: 프로젝트 용어, 고유명사, 내부 약어, 공통 승격 후보
- \`20-issues/\`: 문제, 원인 가설, 영향, 연결 task
- \`30-tasks/\`: 실제 수행 가능한 작업 단위
- \`50-decisions/\`: 프로젝트 결정과 ADR
- \`70-handoff/\`: 세션 종료와 인수인계
- \`90-coverage/\`: L 기준, runner 계약, report 위치
- \`templates/\`: 반복 문서 양식
"

  write_setup_file "$target/00-dashboard/project-overview.md" "# $PROJECT_NAME 현황

## 작업 대시보드

- 즉석 멀티필터: [[work-filter|작업 멀티필터]]
- Obsidian Base 뷰: [[work-views|작업 필터]]

## 현재 상태

- status: draft

## 활성 Issue

## 활성 Task

## 다음 행동
"

  copy_setup_file "$REPO_ROOT/system/templates/project-ssot/00-dashboard/work-filter.md" "$target/00-dashboard/work-filter.md"
  write_project_work_items_base "$target/00-dashboard/work-items.base" "$project_vault_path"
  copy_setup_file "$REPO_ROOT/system/templates/project-ssot/00-dashboard/work-views.md" "$target/00-dashboard/work-views.md"

  write_setup_file "$target/10-dictionary/README.md" "# Dictionary

프로젝트 용어, 고유명사, 내부 약어, 공통 승격 후보를 기록합니다.
"

  write_setup_file "$target/20-issues/ISSUE-template.md" "---
type: issue
id: ISSUE-0000
status: todo
severity: p0
updated:
---

# 이슈 제목

## ID

ISSUE-0000

## 제목

사람이 읽는 문제 이름을 적습니다.

## 문제

## 영향

## 원인 가설

## 연결 Task

## 상태
"

  write_setup_file "$target/30-tasks/TASK-template.md" "---
type: task
id: TASK-0000
status: todo
priority: p0
updated:
---

# 태스크 제목

## ID

TASK-0000

## 제목

사람이 읽는 작업 목표나 문제 이름을 적습니다.

## Output

## Acceptance Criteria

## Test Plan

## Coverage Target

## 사용자 처리 명령

## 실행 로그
"

  write_setup_file "$target/50-decisions/README.md" "# Decisions

프로젝트 결정과 ADR을 기록합니다.
"

  write_setup_file "$target/70-handoff/README.md" "# Handoff

세션 종료, 진행 상태, 다음 작업자를 위한 인수인계를 기록합니다.
"

  write_setup_file "$target/90-coverage/README.md" "# Coverage

L 기준, runner 계약, report/evidence 위치를 기록합니다.
"

  write_setup_file "$target/templates/issue.md" "---
type: issue
id: ISSUE-0000
status: todo
severity: p0
updated:
---

# 이슈 제목

## ID

ISSUE-0000

## 제목

사람이 읽는 문제 이름을 적습니다.

## 문제

## 영향

## 원인 가설

## 연결 Task
"

  write_setup_file "$target/templates/task.md" "---
type: task
id: TASK-0000
status: todo
priority: p0
updated:
---

# 태스크 제목

## ID

TASK-0000

## 제목

사람이 읽는 작업 목표나 문제 이름을 적습니다.

## Output

## Acceptance Criteria

## Test Plan

## Coverage Target
"

  write_setup_file "$target/templates/silo-goal.md" "# Silo Goal

## 목표

## 필요한 repo

## 보호 브랜치

## 작업 브랜치

## 금지선

## 검증 기준

## PR 본문 필수 항목
"

  write_setup_file "$target/templates/pr-description.md" "# PR Description

## 무엇을 했는가

## 변경 상세

## 검증

## 리뷰 gate

## SSoT 승격 후보

## 승격하지 않을 항목

## 남은 위험
"

  write_setup_file "$target/templates/feedback.md" "# 피드백 기록

## 원문

## 피드백 유형

## 적용 범위

## 수정할 규칙

## 다음 루프 적용 방식
"
}

print_summary() {
  info ""
  info "확인:"
  local expected=()

  if contains_selection "repo-skills"; then
    while IFS= read -r skill; do
      expected+=("$(basename "$skill")")
    done < <(find "$REPO_ROOT/system/20-skills" -mindepth 1 -maxdepth 1 -type d -exec test -f '{}/SKILL.md' ';' -print | sort)
  fi
  contains_selection "using-superpowers" && expected+=("${USING_SUPERPOWERS_SKILLS[@]}")
  contains_selection "superpowers-workflow" && expected+=("${SUPERPOWERS_WORKFLOW_SKILLS[@]}")
  contains_selection "agent-browser" && expected+=("agent-browser")
  if contains_selection "compound-engineering"; then
    expected+=("ce-setup" "ce-work" "ce-code-review" "ce-commit-push-pr")
  fi

  if [ ${#expected[@]} -eq 0 ]; then
    info "  스킬 설치 항목 없음"
  fi

  local name
  local missing=0
  for name in "${expected[@]}"; do
    if [ -f "$SKILLS_DIR/$name/SKILL.md" ]; then
      info "  ok  $name"
    else
      info "  누락 $name"
      missing=$((missing + 1))
    fi
  done

  if [ "$missing" -eq 0 ]; then
    info ""
    info "완료: 선택한 셋업 항목 실행이 끝났습니다. 스킬을 설치했다면 새 Codex 세션을 시작하면 반영됩니다."
  else
    info ""
    info "완료: 일부 스킬이 누락됐습니다. 위 누락 항목과 네트워크/권한 상태를 확인하세요."
  fi
}

main() {
  parse_args "$@"
  prompt_selection
  confirm_selection
  ensure_tmp
  ensure_tools

  contains_selection "repo-skills" && install_repo_skills
  contains_selection "using-superpowers" && install_superpowers_subset "using-superpowers 설치" "${USING_SUPERPOWERS_SKILLS[@]}"
  contains_selection "superpowers-workflow" && install_superpowers_subset "Superpowers 작업 보조 묶음 설치" "${SUPERPOWERS_WORKFLOW_SKILLS[@]}"
  contains_selection "agent-browser" && install_agent_browser
  contains_selection "compound-engineering" && install_compound_engineering
  contains_selection "init-config" && init_config
  contains_selection "create-project-ssot" && create_project_ssot

  print_summary
}

main "$@"
