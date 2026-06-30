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

normalize_setup_path() {
  local path="$1"
  while [[ "$path" == *"/./"* ]]; do
    path="${path//\/.\///}"
  done
  printf '%s\n' "$path"
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

ensure_project_ssot_gitignore() {
  local target="$1"
  local project_root="$REPO_ROOT/projects/$PROJECT_ID"

  case "$target" in
    "$project_root"|"$project_root"/*) ;;
    *) return 0 ;;
  esac

  local gitignore="$REPO_ROOT/.gitignore"
  [ -f "$gitignore" ] || return 0

  if grep -qx 'projects/' "$gitignore"; then
    local tmp="$gitignore.tmp.$$"
    while IFS= read -r line || [ -n "$line" ]; do
      if [ "$line" = "projects/" ]; then
        printf '%s\n' 'projects/*'
      else
        printf '%s\n' "$line"
      fi
    done < "$gitignore" > "$tmp"
    mv "$tmp" "$gitignore"
    info "갱신됨: $gitignore"
  fi

  local rel="${target#$REPO_ROOT/}"
  local project_rel="projects/$PROJECT_ID"
  local exception
  local exceptions

  if [ "$rel" = "$project_rel" ]; then
    exceptions="
# project SSoT scaffold
!$project_rel/
!$project_rel/**"
  else
    local current="$project_rel"
    local part
    local rest="${rel#$project_rel/}"
    exceptions="
# project SSoT scaffold
!$project_rel/"

    IFS='/' read -r -a parts <<< "$rest"
    for part in "${parts[@]}"; do
      [ -n "$part" ] || continue
      if [ "$current" != "$project_rel" ] && grep -qxF "!$current/**" "$gitignore"; then
        exceptions="$exceptions
!$current/$part/"
      else
        exceptions="$exceptions
$current/*
!$current/$part/"
      fi
      current="$current/$part"
    done

    exceptions="$exceptions
!$rel/**"
  fi

  exceptions="$exceptions
$rel/.env
$rel/.env.*
!$rel/.env.example
$rel/**/.env
$rel/**/.env.*
!$rel/**/.env.example
$rel/.DS_Store
$rel/**/.DS_Store
$rel/local/
$rel/.worktrees/
$rel/**/local/
$rel/**/.worktrees/
$rel/secret/
$rel/secrets/
$rel/credentials/
$rel/credential/
$rel/vault/
$rel/private/
$rel/**/secret/
$rel/**/secrets/
$rel/**/credentials/
$rel/**/credential/
$rel/**/vault/
$rel/**/private/
$rel/**/*.pem
$rel/**/*.key
$rel/**/*.p12
$rel/**/*.pfx
$rel/**/*.log
$rel/**/*.sqlite
$rel/**/*.sqlite3
$rel/**/*.db
$rel/**/*.dump
$rel/**/*.har
$rel/**/*.trace
$rel/**/*.webm
$rel/**/*.mp4
$rel/**/*.mov"

  while IFS= read -r exception; do
    [ -n "$exception" ] || continue
    grep -qxF "$exception" "$gitignore" || printf '%s\n' "$exception" >> "$gitignore"
  done <<EOF
$exceptions
EOF
  info "추가됨: $gitignore project SSoT target 예외"
}

write_obsidian_appearance() {
  local dest="$1"
  local snippet="readable-markdown-width"

  mkdir -p "$(dirname "$dest")"
  if [ ! -e "$dest" ]; then
    printf '%s\n' "{
  \"enabledCssSnippets\": [
    \"$snippet\"
  ]
}" > "$dest"
    info "생성됨: $dest"
    return 0
  fi

  command -v python3 >/dev/null 2>&1 || fail "python3 is required to update existing Obsidian appearance.json"

  python3 - "$dest" "$snippet" <<'PY'
import json
import sys

path, snippet = sys.argv[1], sys.argv[2]

with open(path, encoding="utf-8") as handle:
    data = json.load(handle)

if not isinstance(data, dict):
    data = {}

snippets = data.get("enabledCssSnippets")
if not isinstance(snippets, list):
    snippets = []

if snippet not in snippets:
    snippets.append(snippet)

data["enabledCssSnippets"] = snippets

with open(path, "w", encoding="utf-8") as handle:
    json.dump(data, handle, ensure_ascii=False, indent=2)
    handle.write("\n")
PY

  info "갱신됨: $dest"
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
    displayName: 호환 ID
  taskID:
    displayName: Task ID
  taskTitle:
    displayName: Task 제목
  issueID:
    displayName: Issue ID
  issueTitle:
    displayName: Issue 제목
  title:
    displayName: 호환 제목
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
      - taskID
      - taskTitle
      - issueID
      - issueTitle
      - id
      - title
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
      - taskID
      - taskTitle
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
      - taskID
      - taskTitle
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
      - issueID
      - issueTitle
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
    PROJECT_SSOT_TARGET="$REPO_ROOT/projects/$PROJECT_ID/02-project-internal"
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
  target="$(normalize_setup_path "$target")"

  info ""
  info "project SSoT 반복 구조 생성"
  info "project id: $PROJECT_ID"
  info "target: $target"
  local project_vault_path
  project_vault_path="$(project_ssot_vault_path "$target")"
  ensure_project_ssot_gitignore "$target"

  mkdir -p \
    "$target/.obsidian" \
    "$target/.obsidian/snippets" \
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

## Obsidian 전제

- 작업 대시보드 \`00-dashboard/work-filter.md\`는 Dataview community plugin과 DataviewJS 활성화를 전제로 합니다.
- \`00-dashboard/work-items.base\`는 Obsidian Base 뷰를 쓰는 대체 화면입니다.
- \`.obsidian/snippets/readable-markdown-width.css\`는 Markdown 편집/미리보기 영역을 넓게 쓰기 위한 기본 CSS snippet입니다.
- 이 scaffold는 \`.obsidian/community-plugins.json\`에 \`dataview\`를 기본 선언합니다. 실제 플러그인 설치와 DataviewJS 허용은 Obsidian 앱에서 확인합니다.

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

  write_setup_file "$target/.obsidian/community-plugins.json" "[
  \"dataview\"
]"

  write_setup_file "$target/.obsidian/core-plugins.json" "[
  \"file-explorer\",
  \"global-search\",
  \"graph\",
  \"backlink\",
  \"canvas\",
  \"outgoing-link\",
  \"tag-pane\",
  \"page-preview\",
  \"daily-notes\",
  \"templates\",
  \"note-composer\",
  \"command-palette\",
  \"slash-command\",
  \"editor-status\",
  \"bookmarks\",
  \"properties\",
  \"bases\"
]"

  write_obsidian_appearance "$target/.obsidian/appearance.json"
  copy_setup_file "$REPO_ROOT/system/templates/project-ssot/.obsidian/snippets/readable-markdown-width.css" "$target/.obsidian/snippets/readable-markdown-width.css"

  write_setup_file "$target/00-dashboard/project-overview.md" "# $PROJECT_NAME 현황

## 작업 대시보드

- 기능 task 생성 전 계약: [[project-contract|project contract]]
- 즉석 멀티필터: [[work-filter|작업 멀티필터]]
- Obsidian Base 뷰: [[work-views|작업 필터]]
- 대시보드 복제 템플릿: [[../templates/work-filter-dashboard|작업 대시보드 템플릿]]

## 현재 상태

- status: draft

## 정본 참조

- repo/source 위치:
- 상위 제품 repo host 역할:
- 기능 submodule 소유권:
- BE submodule 경로:
- FE submodule 경로:
- harness library 정책:
- 제품별 scenario/adapter 위치:
- DB 사용 여부:
- DB schema 정본 위치:
- DB schema 요약 위치:
- DB schema 적용 경로:
- API/auth/session contract 위치:
- harness/runtime DB 계약 위치:

## 활성 Issue

## 활성 Task

## 다음 행동
"

  write_setup_file "$target/00-dashboard/project-contract.md" "# $PROJECT_NAME project contract

이 문서는 기능 task를 만들기 전에 먼저 확인하는 project-level 계약입니다.

task 고유 구현 계약, seed row, test input, PR 상태는 각 task 문서와 사일로 \`goal.md\`에 둡니다.

## 제품 정의

## 현재 버전 목표

## 현재 버전 비목표

## 핵심 사용자 플로우

## 데이터 저장과 동기화 경계

- 로컬 저장:
- 서버 저장:
- 외부 서비스 동기화:
- LLM/API 호출 결과 저장 여부:
- 오프라인/재시도/충돌 처리 기준:

## repo 역할

| 대상 | 역할 | 금지 |
|---|---|---|
| 제품 repo |  |  |
| BE/API |  |  |
| FE/page |  |  |
| harness/runtime |  |  |
| project SSoT |  | 제품 소스코드 복사 |

## task 생성 전 필수 참조

| 항목 | 정본 위치 |
|---|---|
| project SSoT root |  |
| 운영 개요 | \`00-dashboard/project-overview.md\` |
| DB schema 기준 |  |
| API/auth/session 계약 |  |
| 디자인 source 또는 style contract |  |
| runtime/harness 계약 |  |

## task 작성 규칙

1. task를 쓰기 전에 이 project contract를 먼저 확인합니다.
2. task에는 목표, 비목표, 초기 DB mock data, test input, BE 계약, FE 계약, 검증 계획을 분리해서 씁니다.
3. 기능 task에는 단계별 구현 계획과 한국어 자연어 절차 중심의 pseudo code를 포함합니다.
4. pseudo code는 TypeScript/JavaScript 같은 실제 구현 코드 블록이나 완성된 함수 구현이 아니라 한국어 단계 목록으로 씁니다.
5. 파일명, 함수명, API query, DB mutation, op 이름(\`D/L/C/R\`) 같은 식별자는 원문 그대로 쓸 수 있지만 절차 설명은 한국어로 씁니다.
6. pseudo code에서 목표 밖 화면, 버튼, endpoint, table mutation, submodule, E2E 범위가 보이면 \`범위 drift 후보\`로 표시합니다.

## 추정 금지 정보

- 제품 정의, 현재 버전 목표/비목표, 핵심 사용자 플로우
- 데이터 저장과 동기화 경계
- 현재 schema에 없는 테이블, 컬럼, FK
- 정본 위치가 없는 API/auth/session/runtime/design 계약
- 제품 repo, submodule, harness 역할

위 정보가 필요하지만 정본이 없으면 task 본문에서 임시로 만들지 않고 \`project contract 누락\` 또는 \`project SSoT 계약 누락\`으로 표시합니다.
"

  copy_setup_file "$REPO_ROOT/system/templates/project-ssot/00-dashboard/work-filter.md" "$target/00-dashboard/work-filter.md"
  write_project_work_items_base "$target/00-dashboard/work-items.base" "$project_vault_path"
  copy_setup_file "$REPO_ROOT/system/templates/project-ssot/00-dashboard/work-views.md" "$target/00-dashboard/work-views.md"
  copy_setup_file "$REPO_ROOT/system/templates/project-ssot/00-dashboard/work-filter.md" "$target/templates/work-filter-dashboard.md"

  write_setup_file "$target/10-dictionary/README.md" "# Dictionary

프로젝트 용어, 고유명사, 내부 약어, 공통 승격 후보를 기록합니다.
"

  write_setup_file "$target/10-dictionary/project-dictionary.md" "# Project Dictionary

| 용어/고유명사/내부 약어 | 뜻 | 사용 맥락 | 예시 | 출처 또는 확인 상태 | 프로젝트 전용/공통 승격 후보 |
|---|---|---|---|---|---|
"

  write_setup_file "$target/20-issues/ISSUE-template.md" "---
type: issue
id: ISSUE-0000
issueID: ISSUE-0000
issueTitle: 이슈 제목
title: 이슈 제목
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
taskID: TASK-0000
taskTitle: 태스크 제목
title: 태스크 제목
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

해당 task가 독립적으로 증명할 수 있는 산출물만 적습니다. 병렬 sibling task 완료를 전제로 삼지 않습니다.

## Project Contract 확인 결과

기능 task인 경우 project contract 위치, 확인한 제품 정의/목표/비목표/핵심 플로우/데이터 저장·동기화 경계/repo 역할, 누락 항목을 적습니다.

## 단계별 구현 계획

기능 task인 경우에만 작성합니다. 비기능 task, coverage task, 문서 task에는 기계적으로 요구하지 않습니다.

## Pseudo Code

기능 task인 경우 파일/함수/API/DB mutation/화면 상태 변화가 드러나는 한국어 단계 목록으로 작성합니다. TypeScript/JavaScript 같은 실제 구현 코드 블록이나 완성된 함수 구현을 쓰지 않습니다. 코드 식별자, API query, 파일명, op 이름(\`D/L/C/R\`)은 원문을 유지할 수 있습니다.

## 범위 drift 후보

Pseudo Code에서 task 목표 밖 화면, 버튼, endpoint, table mutation, submodule, E2E 범위가 보이면 적습니다.

## Acceptance Criteria

병렬로 생성하거나 실행할 task라면 sibling task 완료를 완료 조건으로 두지 않습니다.

## Test Plan

인증, 데이터, 화면, backend 의존성이 있으면 seed data, dev-auth, fixture session, contract mock, harness, Docker fixture DB 같은 독립 검증 경로를 적습니다.
여러 sibling task 완료를 전제로 하는 최종 통합 E2E는 개별 task acceptance가 아니라 별도 QA gate, integration task, 또는 후속 harness 검증으로 분리합니다. 단일 task의 화면 동작 자체가 산출물이면 E2E 또는 agent-browser acceptance를 유지합니다.

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
issueID: ISSUE-0000
issueTitle: 이슈 제목
title: 이슈 제목
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
taskID: TASK-0000
taskTitle: 태스크 제목
title: 태스크 제목
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

해당 task가 독립적으로 증명할 수 있는 산출물만 적습니다. 병렬 sibling task 완료를 전제로 삼지 않습니다.

## Project Contract 확인 결과

기능 task인 경우 project contract 위치, 확인한 제품 정의/목표/비목표/핵심 플로우/데이터 저장·동기화 경계/repo 역할, 누락 항목을 적습니다.

## 단계별 구현 계획

기능 task인 경우에만 작성합니다. 비기능 task, coverage task, 문서 task에는 기계적으로 요구하지 않습니다.

## Pseudo Code

기능 task인 경우 파일/함수/API/DB mutation/화면 상태 변화가 드러나는 한국어 단계 목록으로 작성합니다. TypeScript/JavaScript 같은 실제 구현 코드 블록이나 완성된 함수 구현을 쓰지 않습니다. 코드 식별자, API query, 파일명, op 이름(\`D/L/C/R\`)은 원문을 유지할 수 있습니다.

## 범위 drift 후보

Pseudo Code에서 task 목표 밖 화면, 버튼, endpoint, table mutation, submodule, E2E 범위가 보이면 적습니다.

## Acceptance Criteria

병렬로 생성하거나 실행할 task라면 sibling task 완료를 완료 조건으로 두지 않습니다.

## Test Plan

인증, 데이터, 화면, backend 의존성이 있으면 seed data, dev-auth, fixture session, contract mock, harness, Docker fixture DB 같은 독립 검증 경로를 적습니다.
여러 sibling task 완료를 전제로 하는 최종 통합 E2E는 개별 task acceptance가 아니라 별도 QA gate, integration task, 또는 후속 harness 검증으로 분리합니다. 단일 task의 화면 동작 자체가 산출물이면 E2E 또는 agent-browser acceptance를 유지합니다.

## Coverage Target
"

  write_setup_file "$target/templates/silo-goal.md" "# Silo Goal

## 목표

## 필요한 repo

## 보호 브랜치

## 작업 브랜치

## 금지선

## Project Contract 확인 결과

기능 task인 경우 project contract 위치, 확인한 제품 정의/목표/비목표/핵심 플로우/데이터 저장·동기화 경계/repo 역할, 누락 항목을 적습니다.

## 단계별 구현 계획

기능 task인 경우에만 작성합니다.

## Pseudo Code

기능 task인 경우 파일/함수/API/DB mutation/화면 상태 변화가 드러나는 한국어 단계 목록으로 작성합니다. TypeScript/JavaScript 같은 실제 구현 코드 블록이나 완성된 함수 구현을 쓰지 않습니다. 코드 식별자, API query, 파일명, op 이름(\`D/L/C/R\`)은 원문을 유지할 수 있습니다.

## 범위 drift 후보

Pseudo Code에서 task 목표 밖 화면, 버튼, endpoint, table mutation, submodule, E2E 범위가 보이면 적습니다.

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
