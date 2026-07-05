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
  while [ "$path" != "/" ] && [[ "$path" == */ ]]; do
    path="${path%/}"
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
  local project_root="$REPO_ROOT/projects/$PROJECT_ID"
  local target

  local gitignore="$REPO_ROOT/.gitignore"
  [ -f "$gitignore" ] || return 0

  local has_project_target="no"
  for target in "$@"; do
    case "$target" in
      "$project_root"|"$project_root"/*)
        has_project_target="yes"
        break
        ;;
    esac
  done
  [ "$has_project_target" = "yes" ] || return 0

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

  local project_rel="projects/$PROJECT_ID"
  local exception
  local project_wide_unignore="no"
  if grep -qxF "!$project_rel/**" "$gitignore"; then
    project_wide_unignore="yes"
  fi

  local exceptions="
# project SSoT scaffold
!$project_rel/"

  for target in "$@"; do
    case "$target" in
      "$project_root"|"$project_root"/*) ;;
      *) continue ;;
    esac

    local rel="${target#$REPO_ROOT/}"

    if [ "$rel" = "$project_rel" ]; then
      exceptions="$exceptions
!$project_rel/**"
      project_wide_unignore="yes"
    else
      local current="$project_rel"
      local part
      local rest="${rel#$project_rel/}"

      IFS='/' read -r -a parts <<< "$rest"
      for part in "${parts[@]}"; do
        [ -n "$part" ] || continue
        if [ "$project_wide_unignore" = "yes" ]; then
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
  done

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

project_ssot_layer1_path() {
  local target="$1"

  case "$target" in
    */02-project-internal) printf '%s\n' "${target%/02-project-internal}/01-project-ssot" ;;
    *) printf '%s\n' "$target/01-project-ssot" ;;
  esac
}

write_project_work_items_base() {
  local dest="$1"
  local project_path="$2"
  local issue_folder="30-work-items/issues"
  local task_folder="30-work-items/tasks"

  if [ -n "$project_path" ]; then
    issue_folder="$project_path/30-work-items/issues"
    task_folder="$project_path/30-work-items/tasks"
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

ensure_project_ssot_surface_dirs() {
  local target="$1"

  mkdir -p \
    "$target/00-layer-index" \
    "$target/01-branch-policy" \
    "$target/30-work-items/tasks" \
    "$target/30-work-items/issues" \
    "$target/30-work-items/runbooks" \
    "$target/30-work-items/handoff" \
    "$target/30-work-items/coverage" \
    "$target/30-work-items/silo-template/evidence" \
    "$target/40-runtime-sets" \
    "$target/50-pr-review" \
    "$target/60-feedback-update/feedback/active" \
    "$target/60-feedback-update/feedback/applied" \
    "$target/60-feedback-update/feedback/closed"
}

write_project_ssot_surface_templates() {
  local target="$1"
  local layer1="$2"
  local layer1_from_work_path
  local work_from_layer1_path
  local work_self_path="."

  case "$target" in
    */02-project-internal)
      layer1_from_work_path="../01-project-ssot"
      work_from_layer1_path="../02-project-internal"
      ;;
    *)
      layer1_from_work_path="01-project-ssot"
      work_from_layer1_path=".."
      ;;
  esac

  write_setup_file "$target/00-layer-index/README.md" "# Layer Index

이 폴더는 프로젝트 SSoT 안에서 1~3계층 자료의 위치와 소유 경계를 찾기 위한 빈 색인입니다.

## 계층별 위치

| 계층 | 목적 | 위치 |
|---|---|---|
| 1계층 | project registry, project contract, decision/ADR, 정본 위치, 반복 운영 기준 | \`$layer1_from_work_path/\` |
| 2계층 | task, issue, QA, coverage, runbook | \`$work_self_path/\` |
| 3계층 | silo local 발견, 실험 로그, PR 전 임시 상태 |  |

## 공통 승격 후보

반복 가능한 운영 규칙이 보이면 실제 내용을 여기에 복사하지 말고, 승격 후보와 출처만 기록합니다.
"

  write_setup_file "$layer1/README.md" "# $PROJECT_NAME Project SSoT

이 폴더는 1계층 Project SSoT 기준 정보 위치입니다.

## 포함 항목

- project registry
- project contract
- decision/ADR
- runtime/DB/API/auth 참조
- 2계층 Project Work SSoT 위치 index
"

  write_setup_file "$layer1/project-registry.md" "# Project Registry

프로젝트 정본 위치와 연결 repo를 찾기 위한 1계층 registry입니다. 실제 task 준비 상태나 단일 구현 계약은 task/runbook/silo로 내립니다.

## 정본 위치

| 항목 | 위치 | 확인 상태 |
|---|---|---|
| project SSoT root |  |  |
| Project Work SSoT | \`$work_from_layer1_path/\` |  |
| project contract | \`project-contract.md\` |  |
| source repo |  |  |
| fork/submodule/external clone |  |  |
| DB schema 정본 |  |  |
| API/auth/session 계약 |  |  |
| runtime/harness 계약 |  |  |
"

  write_setup_file "$layer1/project-contract.md" "# $PROJECT_NAME project contract

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
| project SSoT root | \`.\` |
| Project Work SSoT | \`$work_from_layer1_path/\` |
| 운영 개요 | \`$work_from_layer1_path/00-dashboard/project-overview.md\` |
| DB schema 기준 |  |
| API/auth/session 계약 |  |
| 디자인 source 또는 style contract |  |
| runtime/harness 계약 |  |

## task 작성 규칙

1. task를 쓰기 전에 이 project contract를 먼저 확인합니다.
2. task에는 목표, 비목표, 초기 DB mock data, test input, BE 계약, FE 계약, 검증 계획을 분리해서 씁니다.
3. 기능 task에는 단계별 구현 계획과 파일별 대표 함수 골격형 pseudo code를 포함합니다.
4. pseudo code는 TypeScript/JavaScript 같은 실제 구현 코드 블록이나 완성된 함수 구현이 아니라, 각 파일의 대표 함수와 보조 함수가 어떤 입력/의존성을 받고 조회, 검증, 가공, 조건 분기, 반복, 저장, 반환을 어떻게 수행하는지 코드에 가깝게 씁니다.
5. 파일명, 함수명, API query, DB mutation, op 이름(\`D/L/C/R\`) 같은 식별자는 원문 그대로 쓸 수 있지만 설명 문장은 한국어로 씁니다.
6. pseudo code에서 목표 밖 화면, 버튼, endpoint, table mutation, submodule, E2E 범위가 보이면 \`범위 drift 후보\`로 표시합니다.

## 추정 금지 정보

- 제품 정의, 현재 버전 목표/비목표, 핵심 사용자 플로우
- 데이터 저장과 동기화 경계
- 현재 schema에 없는 테이블, 컬럼, FK
- 정본 위치가 없는 API/auth/session/runtime/design 계약
- 제품 repo, submodule, harness 역할

위 정보가 필요하지만 정본이 없으면 task 본문에서 임시로 만들지 않고 \`project contract 누락\` 또는 \`project SSoT 계약 누락\`으로 표시합니다.
"

  write_setup_file "$layer1/work-ssot-index.md" "# Project Work SSoT Index

## 2계층 위치

- Project Work SSoT: \`$work_from_layer1_path/\`
- task: \`$work_from_layer1_path/30-work-items/tasks/\`
- issue: \`$work_from_layer1_path/30-work-items/issues/\`
- runbook: \`$work_from_layer1_path/30-work-items/runbooks/\`
- coverage: \`$work_from_layer1_path/30-work-items/coverage/\`
"

  write_setup_file "$layer1/50-decisions/README.md" "# Decisions and ADR

프로젝트 장기 decision/ADR은 1계층 Project SSoT인 이 폴더에 기록합니다.

task 실행 중 임시 판단이나 단일 PR 판단은 3계층 사일로 또는 PR 본문에 남기고, 장기 유지가 필요한 경우에만 이 위치로 정리합니다.
"

  write_setup_file "$target/01-branch-policy/README.md" "# Branch Policy

프로젝트 기준 브랜치와 작업 브랜치 규칙을 기록하는 빈 템플릿입니다.

## 기준 브랜치

| 대상 | branch base | PR target/base | 비고 |
|---|---|---|---|
| project SSoT |  |  |  |
| source repo |  |  |  |
| harness repo |  |  |  |

## 금지선

- 보호 브랜치 직접 commit/push 금지:
- destructive action 승인 gate:
- secret/credential 기록 금지:
"

  write_setup_file "$target/30-work-items/README.md" "# Work Items

실행 가능한 project 내부 work item의 빈 구조입니다.

## 하위 폴더

- \`tasks/\`: 독립 수행 가능한 task
- \`issues/\`: 문제, 원인 가설, 영향
- \`runbooks/\`: 반복 실행 절차
- \`handoff/\`: 세션 인수인계
- \`coverage/\`: coverage 기준과 결과 색인
- \`silo-template/\`: task silo 시작 템플릿과 evidence 위치
"

  write_setup_file "$target/30-work-items/tasks/TASK-template.md" "---
type: task
id: TASK-0000
taskID: TASK-0000
taskTitle: 태스크 제목
title: 태스크 제목
status: todo
priority: p0
runtime_set:
updated:
---

# 태스크 제목

## Output

## Project Contract 확인 결과

## 초기 DB 목데이터

## 테스트 입력

## 단계별 구현 계획

## Pseudo Code

## 범위 drift 후보

## Acceptance Criteria

## Test Plan

## Coverage Target

## Runtime Set

task.runtime_set:

## 실행 로그
"

  write_setup_file "$target/30-work-items/issues/ISSUE-template.md" "---
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

## 문제

## 영향

## 원인 가설

## 연결 Task

## Evidence
"

  write_setup_file "$target/30-work-items/runbooks/RUNBOOK-template.md" "---
type: runbook
id: RUNBOOK-0000
title: 런북 제목
status: draft
runtime_set:
updated:
---

# 런북 제목

## 목적

## 실행 전 조건

## 실행 절차

## 검증

## Runtime Set

qa_or_runbook.runtime_set:
"

  write_setup_file "$target/30-work-items/handoff/HANDOFF-template.md" "---
type: handoff
id: HANDOFF-0000
title: 인수인계 제목
status: draft
updated:
---

# 인수인계 제목

## 현재 상태

## 완료된 것

## 아직 안 된 것

## 위험

## 다음 행동
"

  write_setup_file "$target/30-work-items/coverage/COVERAGE-template.md" "---
type: coverage
id: COVERAGE-0000
title: 커버리지 제목
status: draft
updated:
---

# 커버리지 제목

## 기준

## 대상

## 확인 결과

## Evidence 위치
"

  write_setup_file "$target/30-work-items/silo-template/goal.md" "# Silo Goal Template

## 목표

## 필요한 repo

## 보호 브랜치

## 작업 브랜치

## 금지선

## Project Contract 확인 결과

## 단계별 구현 계획

## Pseudo Code

## 범위 drift 후보

## Runtime Set

run_set.required_runtime_set:

## 검증 기준

## PR 본문 필수 항목

## Evidence 위치

\`evidence/\` 아래에 실행 증거를 둡니다.
"

  write_setup_file "$target/40-runtime-sets/README.md" "# Runtime Sets

프로젝트 runtime set 정의와 선택 우선순위를 기록하는 빈 템플릿입니다.

## Runtime Set 결정 우선순위

1. run_set.required_runtime_set
2. task.runtime_set
3. qa_or_runbook.runtime_set
4. project.common_runtime_set
5. missing_definition

## project.common_runtime_set

프로젝트 전체 공통 runtime set이 있으면 여기에 id를 적습니다.

## 정의 목록

| runtime_set | 목적 | 필수 도구 | 환경 변수 | 검증 명령 |
|---|---|---|---|---|
"

  write_setup_file "$target/40-runtime-sets/runtime-resolution.md" "# Runtime Set Resolution

## 우선순위

1. run_set.required_runtime_set
2. task.runtime_set
3. qa_or_runbook.runtime_set
4. project.common_runtime_set
5. missing_definition

## project.common_runtime_set

## 정의 목록

| runtime_set | 목적 | 필수 도구 | 환경 변수 | 검증 명령 |
|---|---|---|---|---|
"

  write_setup_file "$target/50-pr-review/README.md" "# PR Review

프로젝트 PR review gate와 evidence를 기록하는 빈 템플릿입니다.

## 기본 gate

- PR target/base:
- 리뷰 목표:
- Codex review 호출 가능 여부:
- codex-review pass 기준:

## PR 본문 필수 항목

- 무엇을 했는가
- 검증
- feedback/follow-up 후보
- 남은 위험
"

  write_setup_file "$target/60-feedback-update/README.md" "# Feedback Update

운영 중 발견한 feedback의 상태별 빈 구조입니다.

## 상태

- \`feedback/active/\`: 아직 판단 중인 feedback
- \`feedback/applied/\`: task/spec/rule에 반영된 feedback
- \`feedback/closed/\`: 폐기 또는 종료된 feedback
"
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
  local layer1_target
  layer1_target="$(project_ssot_layer1_path "$target")"
  layer1_target="$(normalize_setup_path "$layer1_target")"

  info ""
  info "project SSoT 반복 구조 생성"
  info "project id: $PROJECT_ID"
  info "target: $target"
  info "1계층 target: $layer1_target"
  local project_vault_path
  local layer1_from_work_path
  project_vault_path="$(project_ssot_vault_path "$target")"
  case "$target" in
    */02-project-internal) layer1_from_work_path="../01-project-ssot" ;;
    *) layer1_from_work_path="01-project-ssot" ;;
  esac
  ensure_project_ssot_gitignore "$target" "$layer1_target"

  mkdir -p \
    "$layer1_target/50-decisions" \
    "$layer1_target/references" \
    "$target/.obsidian" \
    "$target/.obsidian/snippets" \
    "$target/00-dashboard" \
    "$target/10-dictionary" \
    "$target/templates"

  ensure_project_ssot_surface_dirs "$target"
  mkdir -p "$layer1_target/50-decisions" "$layer1_target/references"

  write_setup_file "$target/README.md" "# $PROJECT_NAME Project SSoT

이 폴더는 $PROJECT_NAME 프로젝트 내부 운영 SSoT입니다.

## Obsidian 전제

- 작업 대시보드 \`00-dashboard/work-filter.md\`는 Dataview community plugin과 DataviewJS 활성화를 전제로 합니다.
- \`00-dashboard/work-items.base\`는 Obsidian Base 뷰를 쓰는 대체 화면입니다.
- \`.obsidian/snippets/readable-markdown-width.css\`는 Markdown 편집/미리보기 영역을 넓게 쓰기 위한 기본 CSS snippet입니다.
- 이 scaffold는 \`.obsidian/community-plugins.json\`에 \`dataview\`를 기본 선언합니다. 실제 플러그인 설치와 DataviewJS 허용은 Obsidian 앱에서 확인합니다.

## 폴더

- \`00-dashboard/\`: 현재 상태, 활성 issue/task, 다음 행동
- \`00-layer-index/\`: 1~3계층 자료 위치와 소유 경계 색인
- \`01-branch-policy/\`: project/source/harness 기준 브랜치와 PR target
- \`10-dictionary/\`: 프로젝트 용어, 고유명사, 내부 약어, 공통 승격 후보
- \`$layer1_from_work_path/project-registry.md\`: 1계층 project 정본 위치와 repo 연결 색인
- \`$layer1_from_work_path/project-contract.md\`: 기능 task 작성 전 1계층 계약 확인 gate
- \`30-work-items/\`: task/issue/runbook/handoff/coverage/silo template
- \`40-runtime-sets/\`: runtime set 정의와 선택 우선순위
- \`$layer1_from_work_path/50-decisions/\`: 1계층 프로젝트 결정과 ADR
- \`50-pr-review/\`: PR review gate와 test evidence
- \`60-feedback-update/\`: feedback active/applied/closed 상태 관리
- \`templates/\`: 반복 문서 양식
"

  write_project_ssot_surface_templates "$target" "$layer1_target"

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

- 기능 task 생성 전 계약: \`$layer1_from_work_path/project-contract.md\`
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

기능 task인 경우 파일별 대표 함수 골격형으로 작성합니다. 각 파일의 대표 함수와 보조 함수가 어떤 입력/의존성을 받고 조회, 검증, 가공, 조건 분기, 반복, 저장, 반환을 어떻게 수행하는지 코드에 가깝게 보여야 합니다. TypeScript/JavaScript 같은 실제 구현 코드 블록이나 완성된 함수 구현을 쓰지 않습니다. 코드 식별자, API query, 파일명, op 이름(\`D/L/C/R\`)은 원문을 유지할 수 있습니다.

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

기능 task인 경우 파일별 대표 함수 골격형으로 작성합니다. 각 파일의 대표 함수와 보조 함수가 어떤 입력/의존성을 받고 조회, 검증, 가공, 조건 분기, 반복, 저장, 반환을 어떻게 수행하는지 코드에 가깝게 보여야 합니다. TypeScript/JavaScript 같은 실제 구현 코드 블록이나 완성된 함수 구현을 쓰지 않습니다. 코드 식별자, API query, 파일명, op 이름(\`D/L/C/R\`)은 원문을 유지할 수 있습니다.

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

## feedback/follow-up 후보

## 처리하지 않고 남긴 항목

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
