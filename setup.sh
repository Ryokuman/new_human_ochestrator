#!/usr/bin/env bash

set -eo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
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
PROJECT_FOLDER_RESULT=""
PROJECT_LAYER1_RESULT=""
PROJECT_WORK_RESULT=""
QUICKSTART="no"
WORKSPACE_ROOT=""
ADVANCED="no"
CODEX_AGENTS_ACTION=""
CODEX_OVERRIDE_ACTION=""
CODEX_HOME_BACKUP_DIR=""

usage() {
  cat <<'USAGE'
사용법:
  ./setup.sh
  ./setup.sh --quickstart --project-name <name>
  ./setup.sh --all
  ./setup.sh --repo-skills --using-superpowers --superpowers-workflow --agent-browser --compound-engineering
  ./setup.sh --init-config
  ./setup.sh --init-user-layer
  ./setup.sh --create-project-ssot --project-id <id> --target <dir>

옵션:
  --all                    기본 환경 전체를 설치합니다. project SSoT scaffold 제외.
  --quickstart             기본 작업 환경과 프로젝트 workspace 구조를 생성합니다.
  --advanced               개별 설치/생성 항목 선택 메뉴를 표시합니다.
  --none                   setup 없이 종료합니다.
  --repo-skills            이 저장소의 repo skill을 설치합니다.
  --using-superpowers      obra/superpowers의 using-superpowers를 설치합니다.
  --superpowers-workflow   필요한 Superpowers workflow skill을 설치합니다.
  --agent-browser          agent-browser CLI/browser runtime과 skill을 설치합니다.
  --compound-engineering   Compound Engineering skill을 설치합니다.
  --init-config            예시 파일에서 local config 파일을 생성합니다.
  --init-user-layer        workspace의 user-layer/와 Codex 전역 AGENTS를 준비합니다.
  --create-project-ssot    project SSoT scaffold를 생성합니다.
  --project-id <id>        --create-project-ssot에 사용할 project id입니다.
  --project-name <name>    project 표시 이름입니다. --quickstart에서는 project id 기본값으로도 씁니다.
  --target <dir>           --create-project-ssot 대상 디렉터리입니다.
  --workspace-root <dir>   --quickstart workspace root입니다. 기본값은 이 repo의 부모 디렉터리입니다.
  --force                  허용된 setup 생성 local 파일을 덮어씁니다.
  --yes, -y                마지막 확인 질문을 생략합니다. 기존 Codex 전역 파일 충돌 승인은 생략하지 않습니다.
  --help, -h               이 도움말을 표시합니다.

환경 변수:
  CODEX_HOME               기본값은 ~/.codex입니다.
  CODEX_SKILLS_DIR         기본값은 $CODEX_HOME/skills입니다.
  SUPERPOWERS_REF          기본값은 main입니다.
  AGENT_BROWSER_REF        기본값은 main입니다.
  AGENT_BROWSER_SKIP_RUNTIME
                           1이면 CLI/browser runtime 없이 skill 파일만 설치합니다.
  COMPOUND_ENGINEERING_REF 기본값은 main입니다.
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
    "init-user-layer"
  )
}

parse_args() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --all) select_all ;;
      --quickstart) QUICKSTART="yes"; add_selection "repo-skills"; add_selection "init-config"; add_selection "init-user-layer"; add_selection "create-project-ssot" ;;
      --advanced) ADVANCED="yes" ;;
      --none) SELECTED=(); ASSUME_YES="yes"; NO_INSTALL="yes"; return 0 ;;
      --repo-skills) add_selection "repo-skills" ;;
      --using-superpowers) add_selection "using-superpowers" ;;
      --superpowers-workflow) add_selection "superpowers-workflow" ;;
      --agent-browser) add_selection "agent-browser" ;;
      --compound-engineering) add_selection "compound-engineering" ;;
      --init-config) add_selection "init-config" ;;
      --init-user-layer) add_selection "init-user-layer" ;;
      --create-project-ssot) add_selection "create-project-ssot" ;;
      --project-id) PROJECT_ID="${2:-}"; [ -n "$PROJECT_ID" ] || fail "--project-id requires a value"; shift ;;
      --project-name) PROJECT_NAME="${2:-}"; [ -n "$PROJECT_NAME" ] || fail "--project-name requires a value"; shift ;;
      --target) PROJECT_SSOT_TARGET="${2:-}"; [ -n "$PROJECT_SSOT_TARGET" ] || fail "--target requires a value"; shift ;;
      --workspace-root) WORKSPACE_ROOT="${2:-}"; [ -n "$WORKSPACE_ROOT" ] || fail "--workspace-root requires a value"; shift ;;
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

  if [ "$ADVANCED" != "yes" ]; then
    QUICKSTART="yes"
    add_selection "repo-skills"
    add_selection "init-config"
    add_selection "init-user-layer"
    add_selection "create-project-ssot"
    return 0
  fi

  cat <<'PROMPT'
실행할 셋업 항목을 선택하세요. 여러 개는 쉼표나 공백으로 구분하고, 기본 환경 전체 실행은 all, 실행 안 함은 none을 입력합니다.
project SSoT 반복 구조는 all에 포함되지 않습니다. 필요하면 7번을 직접 선택합니다.

1. repo 내부 skill
2. using-superpowers
3. Superpowers 작업 보조 묶음
4. agent-browser
5. compound-engineering
6. config 초안 생성
7. project workspace 구조 생성
8. User Layer 디렉터리 준비
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
      8) add_selection "init-user-layer" ;;
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
  if [ "$QUICKSTART" = "yes" ]; then
    info "빠른 시작:"
    info "  - Codex repo skill 설치"
    info "  - local config/Codex 전역 AGENTS/User Layer 디렉터리 생성"
    info "  - 프로젝트 workspace 구조 생성"
  else
    info "실행 대상:"
    local item
    for item in "${SELECTED[@]}"; do
      info "  - $item"
    done
    info ""
    if has_skill_selection; then
      info "스킬 설치 위치: $SKILLS_DIR"
    fi
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

render_codex_home_agents() {
  local workspace="$1"
  local template="$REPO_ROOT/system/templates/codex-home/AGENTS.template.md"
  local rendered="$TMP_ROOT/codex-home-AGENTS.md"
  local escaped_system_path escaped_user_path

  workspace="$(absolute_setup_path "$workspace")"
  [ -f "$template" ] || fail "Codex home AGENTS template not found: $template"
  escaped_system_path="$(printf '%s' "$REPO_ROOT/AGENTS.md" | sed 's/[\\&|]/\\&/g')"
  escaped_user_path="$(printf '%s' "$workspace/user-layer/AGENTS.md" | sed 's/[\\&|]/\\&/g')"
  sed \
    -e "s|<system-agents-path>|$escaped_system_path|g" \
    -e "s|<user-layer-agents-path>|$escaped_user_path|g" \
    "$template" > "$rendered"
  printf '%s\n' "$rendered"
}

prompt_codex_agents_conflict() {
  local target="$1"
  local answer

  cat <<PROMPT
기존 Codex 전역 AGENTS가 있습니다: $target
New-Human 전역 프롬프트를 설치하려면 기존 파일을 교체해야 합니다.

1. 기존 파일을 백업하고 교체합니다. (추천)
2. 기존 파일을 삭제하고 교체합니다.
3. 셋업을 중지합니다.
PROMPT
  printf '> '
  if ! IFS= read -r answer; then
    fail "기존 Codex 전역 AGENTS 처리에는 사용자 승인이 필요합니다"
  fi

  case "$answer" in
    1) CODEX_AGENTS_ACTION="backup-replace" ;;
    2) CODEX_AGENTS_ACTION="delete-replace" ;;
    3) info "Codex 전역 AGENTS를 변경하지 않고 셋업을 중지합니다."; exit 0 ;;
    *) fail "unknown Codex AGENTS selection: $answer" ;;
  esac
}

prompt_codex_override_conflict() {
  local target="$1"
  local answer

  cat <<PROMPT
기존 Codex 전역 override가 있습니다: $target
이 파일이 남아 있으면 새 AGENTS.md보다 우선하므로 삭제해야 합니다.

1. 기존 override를 백업하고 삭제합니다. (추천)
2. 기존 override를 즉시 삭제합니다.
3. 셋업을 중지합니다.
PROMPT
  printf '> '
  if ! IFS= read -r answer; then
    fail "기존 Codex 전역 override 처리에는 사용자 승인이 필요합니다"
  fi

  case "$answer" in
    1) CODEX_OVERRIDE_ACTION="backup-delete" ;;
    2) CODEX_OVERRIDE_ACTION="delete" ;;
    3) info "Codex 전역 파일을 변경하지 않고 셋업을 중지합니다."; exit 0 ;;
    *) fail "unknown Codex override selection: $answer" ;;
  esac
}

preflight_codex_home_agents() {
  local workspace="${WORKSPACE_ROOT:-$(dirname "$REPO_ROOT")}"
  local rendered agents_target override_target

  workspace="$(absolute_setup_path "$workspace")"
  rendered="$(render_codex_home_agents "$workspace")"
  agents_target="$CODEX_HOME/AGENTS.md"
  override_target="$CODEX_HOME/AGENTS.override.md"

  if [ -d "$agents_target" ] && [ ! -L "$agents_target" ]; then
    fail "Codex 전역 AGENTS 경로가 디렉터리입니다: $agents_target"
  fi
  if [ -d "$override_target" ] && [ ! -L "$override_target" ]; then
    fail "Codex 전역 override 경로가 디렉터리입니다: $override_target"
  fi

  if [ -f "$agents_target" ] && [ ! -L "$agents_target" ] && cmp -s "$agents_target" "$rendered"; then
    CODEX_AGENTS_ACTION="keep"
  elif [ -e "$agents_target" ] || [ -L "$agents_target" ]; then
    prompt_codex_agents_conflict "$agents_target"
  else
    CODEX_AGENTS_ACTION="create"
  fi

  if [ -e "$override_target" ] || [ -L "$override_target" ]; then
    prompt_codex_override_conflict "$override_target"
  else
    CODEX_OVERRIDE_ACTION="none"
  fi
}

ensure_codex_home_backup_dir() {
  if [ -n "$CODEX_HOME_BACKUP_DIR" ]; then
    return 0
  fi

  local base="$CODEX_HOME/backups/new-human-setup/$(date +%Y%m%d%H%M%S)"
  local candidate="$base"
  local suffix=1
  while [ -e "$candidate" ]; do
    candidate="$base-$suffix"
    suffix=$((suffix + 1))
  done
  mkdir -p "$candidate"
  CODEX_HOME_BACKUP_DIR="$candidate"
}

backup_codex_home_file() {
  local source="$1"
  ensure_codex_home_backup_dir
  mv "$source" "$CODEX_HOME_BACKUP_DIR/$(basename "$source")"
  info "기존 Codex 파일 백업: $source -> $CODEX_HOME_BACKUP_DIR/$(basename "$source")"
}

install_codex_home_agents() {
  local workspace="${WORKSPACE_ROOT:-$(dirname "$REPO_ROOT")}"
  local rendered agents_target override_target

  workspace="$(absolute_setup_path "$workspace")"
  rendered="$(render_codex_home_agents "$workspace")"
  agents_target="$CODEX_HOME/AGENTS.md"
  override_target="$CODEX_HOME/AGENTS.override.md"
  mkdir -p "$CODEX_HOME"

  case "$CODEX_AGENTS_ACTION" in
    backup-replace) backup_codex_home_file "$agents_target" ;;
    delete-replace) rm -f "$agents_target" ;;
    create|keep) ;;
    *) fail "Codex 전역 AGENTS 사전 확인 결과가 없습니다" ;;
  esac

  case "$CODEX_OVERRIDE_ACTION" in
    backup-delete) backup_codex_home_file "$override_target" ;;
    delete) rm -f "$override_target" ;;
    none) ;;
    *) fail "Codex 전역 override 사전 확인 결과가 없습니다" ;;
  esac

  if [ "$CODEX_AGENTS_ACTION" != "keep" ]; then
    cp "$rendered" "$agents_target"
    info "Codex 전역 AGENTS 설치: $agents_target"
  else
    info "Codex 전역 AGENTS 이미 최신 상태: $agents_target"
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
  local prefix=""
  local IFS="/"
  local part
  local joined
  local index
  local -a parts=()
  local -a normalized=()

  [ -n "$path" ] || fail "path must not be empty"

  case "$path" in
    /*)
      prefix="/"
      path="${path#/}"
      ;;
  esac

  read -r -a parts <<< "$path"
  for part in "${parts[@]}"; do
    case "$part" in
      ""|.)
        ;;
      ..)
        if [ ${#normalized[@]} -gt 0 ]; then
          index=$((${#normalized[@]} - 1))
          if [ "${normalized[$index]}" != ".." ]; then
            unset 'normalized[$index]'
            normalized=("${normalized[@]}")
          elif [ -z "$prefix" ]; then
            normalized+=("$part")
          fi
        elif [ -z "$prefix" ]; then
          normalized+=("$part")
        fi
        ;;
      *)
        normalized+=("$part")
        ;;
    esac
  done

  joined="${normalized[*]}"
  if [ "$prefix" = "/" ]; then
    [ -n "$joined" ] && printf '/%s\n' "$joined" || printf '/\n'
  else
    [ -n "$joined" ] && printf '%s\n' "$joined" || printf '.\n'
  fi
}

absolute_setup_path() {
  local path="$1"

  path="$(normalize_setup_path "$path")"
  case "$path" in
    /*) printf '%s\n' "$path" ;;
    *) normalize_setup_path "$(pwd -P)/$path" ;;
  esac
}

physical_setup_path() {
  local path="$1"
  local probe="$path"
  local suffix=""
  local base

  path="$(normalize_setup_path "$path")"
  probe="$path"

  while [ ! -e "$probe" ] && [ "$probe" != "/" ]; do
    suffix="/$(basename "$probe")$suffix"
    probe="$(dirname "$probe")"
  done

  if [ -d "$probe" ]; then
    base="$(cd "$probe" && pwd -P)"
  else
    base="$(cd "$(dirname "$probe")" && pwd -P)/$(basename "$probe")"
  fi

  normalize_setup_path "$base$suffix"
}

project_folder_from_work_target() {
  local target="$1"

  case "$target" in
    */02-project-work-ssot) printf '%s\n' "${target%/02-project-work-ssot}" ;;
    */02-project-internal) printf '%s\n' "${target%/02-project-internal}" ;;
    *) printf '%s\n' "$target" ;;
  esac
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

read_pr_description_template() {
  local template="$REPO_ROOT/system/40-pr-review-loop/06-pr-template.md"

  [ -f "$template" ] || fail "PR 본문 템플릿을 찾을 수 없습니다: $template"

  awk '
    /^```markdown$/ {
      in_template = 1
      next
    }
    in_template && /^```$/ {
      found = 1
      exit
    }
    in_template {
      print
    }
    END {
      if (!found) {
        exit 1
      }
    }
  ' "$template" || fail "PR 본문 템플릿 markdown 블록을 읽을 수 없습니다: $template"
}

enable_user_layer_git_tracking() {
  local gitignore="$REPO_ROOT/.gitignore"
  local tmp="$gitignore.tmp.$$"
  local line
  local removed="no"

  [ -f "$gitignore" ] || return 0

  while IFS= read -r line || [ -n "$line" ]; do
    if [ "$line" = "/user-layer/" ]; then
      removed="yes"
      continue
    fi
    printf '%s\n' "$line"
  done < "$gitignore" > "$tmp"

  if [ "$removed" = "yes" ]; then
    mv "$tmp" "$gitignore"
    info "User Layer Git 제외 해제: $gitignore"
  else
    rm -f "$tmp"
  fi
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

  exceptions="$exceptions
!$project_rel/README.md
!$project_rel/00-secrets/
$project_rel/00-secrets/*
!$project_rel/00-secrets/README.md"

  while IFS= read -r exception; do
    [ -n "$exception" ] || continue
    grep -qxF "$exception" "$gitignore" || printf '%s\n' "$exception" >> "$gitignore"
  done <<EOF
$exceptions
EOF
  info "추가됨: $gitignore project workspace target 예외"
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
    */02-project-work-ssot) printf '%s\n' "${target%/02-project-work-ssot}/01-project-ssot" ;;
    */02-project-internal) printf '%s\n' "${target%/02-project-internal}/01-project-ssot" ;;
    *) printf '%s\n' "$target/01-project-ssot" ;;
  esac
}

default_workspace_root() {
  dirname "$REPO_ROOT"
}

normalize_project_id() {
  local value="$1"
  value="$(printf '%s\n' "$value" | tr '[:upper:]' '[:lower:]')"
  value="$(printf '%s\n' "$value" | sed 's/[^a-z0-9._-]/-/g; s/--*/-/g; s/^-//; s/-$//')"
  [ -n "$value" ] || fail "project name must contain at least one letter or number"
  printf '%s\n' "$value"
}

ensure_quickstart_workspace_dirs() {
  [ "$QUICKSTART" = "yes" ] || return 0

  mkdir -p \
    "$WORKSPACE_ROOT/.obsidian/snippets" \
    "$WORKSPACE_ROOT/local" \
    "$WORKSPACE_ROOT/sources" \
    "$WORKSPACE_ROOT/silos" \
    "$WORKSPACE_ROOT/shared-runtime"

  write_setup_file "$WORKSPACE_ROOT/.obsidian/community-plugins.json" "[
  \"dataview\"
]"

  write_setup_file "$WORKSPACE_ROOT/.obsidian/core-plugins.json" "[
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

  write_obsidian_appearance "$WORKSPACE_ROOT/.obsidian/appearance.json"
  copy_setup_file "$REPO_ROOT/system/templates/project-ssot/.obsidian/snippets/readable-markdown-width.css" "$WORKSPACE_ROOT/.obsidian/snippets/readable-markdown-width.css"

  info "workspace Obsidian 단일 vault 설정 준비됨: $WORKSPACE_ROOT/.obsidian"
  info "workspace Local 검수 공간 준비됨: $WORKSPACE_ROOT/local"
  info "workspace 생성됨: $WORKSPACE_ROOT/sources"
  info "workspace 생성됨: $WORKSPACE_ROOT/silos"
  info "workspace 생성됨: $WORKSPACE_ROOT/shared-runtime"
}

ensure_quickstart_workspace_root() {
  [ "$QUICKSTART" = "yes" ] || return 0

  ensure_quickstart_path_outside_repo "$WORKSPACE_ROOT" "workspace root"
}

ensure_quickstart_path_outside_repo() {
  local path="$1"
  local label="$2"
  local physical_path

  case "$path" in
    "$REPO_ROOT"|"$REPO_ROOT"/*)
      fail "quickstart $label must be outside this 0-layer repo: $path"
      ;;
  esac

  physical_path="$(physical_setup_path "$path")"
  case "$physical_path" in
    "$REPO_ROOT"|"$REPO_ROOT"/*)
      fail "quickstart $label must be outside this 0-layer repo: $path"
      ;;
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
        - file.inFolder(\"$task_folder/todo\")
        - file.inFolder(\"$task_folder/in_progress\")
        - file.inFolder(\"$task_folder/blocked\")
        - file.inFolder(\"$task_folder/review\")
        - file.inFolder(\"$task_folder/done\")
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
  owner_silo:
    displayName: 담당 사일로
  branch:
    displayName: 브랜치
  pr:
    displayName: PR
  promotion_status:
    displayName: 승격 상태
  hypothesis_attempt_count:
    displayName: 가설 시도 수
  hypothesis_limit_status:
    displayName: 가설 상태
  had_failed_run:
    displayName: 실패 이력
  resolved_by_hypothesis:
    displayName: 가설 해결
  failed_run_count:
    displayName: 실패 수
  resolved_attempt_no:
    displayName: 해결 시도
  latest_failed_report:
    displayName: 최근 실패
  latest_retry_report:
    displayName: 재시도
  blocked_reason:
    displayName: 차단 사유
  latest_resolution_summary:
    displayName: 해결 요약
  dashboard_flags:
    displayName: 대시보드 플래그
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
      - owner_silo
      - branch
      - pr
      - promotion_status
      - hypothesis_attempt_count
      - hypothesis_limit_status
      - had_failed_run
      - resolved_by_hypothesis
      - failed_run_count
      - resolved_attempt_no
      - latest_failed_report
      - latest_retry_report
      - blocked_reason
      - latest_resolution_summary
      - dashboard_flags
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
      - owner_silo
      - branch
      - pr
      - hypothesis_attempt_count
      - hypothesis_limit_status
      - had_failed_run
      - resolved_by_hypothesis
      - failed_run_count
      - resolved_attempt_no
      - latest_failed_report
      - latest_retry_report
      - blocked_reason
      - latest_resolution_summary
      - file.tags
      - updated
  - type: table
    name: 실패 이력 Task
    filters:
      and:
        - type == \"task\"
        - had_failed_run == true
    order:
      - taskID
      - taskTitle
      - status
      - owner_silo
      - branch
      - pr
      - hypothesis_attempt_count
      - hypothesis_limit_status
      - had_failed_run
      - resolved_by_hypothesis
      - failed_run_count
      - resolved_attempt_no
      - latest_failed_report
      - latest_retry_report
      - blocked_reason
      - latest_resolution_summary
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
      - owner_silo
      - branch
      - pr
      - hypothesis_attempt_count
      - hypothesis_limit_status
      - had_failed_run
      - resolved_by_hypothesis
      - failed_run_count
      - resolved_attempt_no
      - latest_failed_report
      - latest_retry_report
      - blocked_reason
      - latest_resolution_summary
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
    "$target/20-level-criteria" \
    "$target/30-work-items/tasks/_templates" \
    "$target/30-work-items/tasks/todo" \
    "$target/30-work-items/tasks/in_progress" \
    "$target/30-work-items/tasks/blocked" \
    "$target/30-work-items/tasks/review" \
    "$target/30-work-items/tasks/done" \
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
    */02-project-work-ssot)
      layer1_from_work_path="../01-project-ssot"
      work_from_layer1_path="../02-project-work-ssot"
      ;;
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
| 1계층 | project registry, project contract, 기능/사용자 흐름별 요구사항, decision/ADR, 정본 위치, 반복 운영 기준 | \`$layer1_from_work_path/\` |
| 2계층 | task, issue, QA, coverage, runbook | \`$work_self_path/\` |
| 3계층 | silo local 발견, 실험 로그, PR 전 임시 상태 | 별도 silo workspace 또는 PR 본문/evidence. 기본 scaffold 내부에는 생성하지 않음 |

## 공통 승격 후보

반복 가능한 운영 규칙이 보이면 실제 내용을 여기에 복사하지 말고, 승격 후보와 출처만 기록합니다.
"

  write_setup_file "$layer1/README.md" "# $PROJECT_NAME Project SSoT

이 폴더는 1계층 Project SSoT 기준 정보 위치입니다.

## 포함 항목

- project registry
- project contract
- 기능/사용자 흐름별 요구사항
- decision/ADR
- runtime/DB/API/auth 계약과 정본 위치: \`10-requirements/\`
- 아키텍처 선택과 근거: \`50-decisions/\`
- repo/source 연결: \`project-registry.md\`
- 2계층 Project Work SSoT 위치 index
"

  write_setup_file "$layer1/project-registry.md" "# Project Registry

프로젝트 정본 위치와 연결 repo를 찾기 위한 1계층 registry입니다. 실제 task 준비 상태나 단일 구현 계약은 task/runbook/silo로 내립니다.

## 정본 위치

| 항목 | 위치 | 확인 상태 |
|---|---|---|
| project SSoT root |  |  |
| Project Work SSoT | \`$work_from_layer1_path/\` |  |
| project contract | \`AGENTS.md\` |  |
| 기능/사용자 흐름별 요구사항 | \`10-requirements/\` |  |
| source repo |  |  |
| fork/submodule/external clone |  |  |
| DB schema 정본 |  |  |
| API/auth/session 계약 |  |  |
| runtime/harness 계약 |  |  |
"

  write_setup_file "$layer1/AGENTS.md" "# $PROJECT_NAME project contract

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
| 기능/사용자 흐름별 요구사항 | \`10-requirements/\` |
| DB schema 기준 |  |
| API/auth/session 계약 |  |
| 디자인 source 또는 style contract |  |
| runtime/harness 계약 |  |

## task 작성 규칙

1. task를 쓰기 전에 이 project contract를 먼저 확인합니다.
2. task에는 목표, 비목표, 초기 DB mock data, test input, BE 계약, FE 계약, 검증 계획을 분리해서 씁니다.
3. 기능 task에는 단계별 구현 계획과 파일별 대표 함수 골격형 pseudo code를 포함합니다. 단, 선언적 config, prop, default, value 한두 곳만 수정하고 별도 분기·가공·조회·저장 흐름이 없으면 pseudo code를 생략하고 변경 계약으로 대체할 수 있습니다.
4. pseudo code는 TypeScript/JavaScript 같은 실제 구현 코드 블록이나 완성된 함수 구현이 아니라, 각 파일의 대표 함수와 보조 함수가 어떤 입력/의존성을 받고 조회, 검증, 가공, 조건 분기, 반복, 저장, 반환을 어떻게 수행하는지 코드에 가깝게 씁니다.
5. 파일명, 함수명, API query, DB mutation, op 이름(\`D/L/C/R\`) 같은 식별자는 원문 그대로 쓸 수 있지만 설명 문장은 한국어로 씁니다.
6. pseudo code에서 목표 밖 화면, 버튼, endpoint, table mutation, submodule, E2E 범위가 보이면 \`범위 drift 후보\`로 표시합니다. 단순 config 변경 예외에는 대상 파일, 설정 key, 기존값 또는 누락 상태, 목표값, 회귀 검증을 적고 로직 변경이나 여러 파일 실행 흐름을 숨기지 않습니다.

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
- L 기준: \`$work_from_layer1_path/20-level-criteria/\`
- task: \`$work_from_layer1_path/30-work-items/tasks/\`
- issue: \`$work_from_layer1_path/30-work-items/issues/\`
- runbook: \`$work_from_layer1_path/30-work-items/runbooks/\`
- coverage: \`$work_from_layer1_path/30-work-items/coverage/\`
"

  write_setup_file "$layer1/50-decisions/README.md" "# Decisions and ADR

프로젝트 장기 decision/ADR은 1계층 Project SSoT인 이 폴더에 기록합니다.

task 실행 중 임시 판단이나 단일 PR 판단은 3계층 사일로 또는 PR 본문에 남기고, 장기 유지가 필요한 경우에만 이 위치로 정리합니다.
"

  write_setup_file "$layer1/10-requirements/README.md" "# Requirements

이 폴더는 1계층 Project SSoT의 기능/사용자 흐름별 요구사항 정본 위치입니다.

## 작성 기준

- 기능 요구사항과 사용자 흐름 요구사항은 여러 issue/task가 구현 근거로 참조할 수 있게 이 위치에 둡니다.
- 요구사항을 구현하기 위한 issue, task, QA, runbook, coverage 원문은 \`$work_from_layer1_path/\` 아래 2계층 Project Work SSoT에 둡니다.
- 단일 task mock data, test input, PR 임시 판단, silo local 로그는 이 위치에 쓰지 않습니다.
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

  write_setup_file "$target/20-level-criteria/README.md" "# Level Criteria

프로젝트의 L 기준 생성/관리 위치입니다.

## 역할

- 단계별 채점 기준
- runner 계약
- report 위치
- evidence 위치

## 파일

- \`LEVEL-CRITERIA-template.md\`: 프로젝트별 L 기준 문서 템플릿
"

  write_setup_file "$target/20-level-criteria/LEVEL-CRITERIA-template.md" "---
type: level_criteria
id: LEVEL-CRITERIA-0000
title: L 기준 제목
status: draft
target_level:
runner_contract:
report_path:
evidence_path:
updated:
---

# L 기준 제목

## 적용 범위

## 단계별 채점 기준

| level | 통과 기준 | 실패 기준 | 필수 evidence |
|---|---|---|---|

## Runner 계약

## Report 위치

## Evidence 위치

## 갱신 이력
"

  write_setup_file "$target/30-work-items/README.md" "# Work Items

실행 가능한 project 내부 work item의 빈 구조입니다.

## 하위 폴더

- \`tasks/\`: \`todo\`, \`in_progress\`, \`blocked\`, \`review\`, \`done\` 상태별 Task. 실제 Task의 직계 상위 디렉터리와 frontmatter \`status\`는 일치해야 함
- \`tasks/_templates/TASK-template.md\`: 새 Task 작성 템플릿. 생성한 Task는 \`tasks/todo/\`에서 시작함
- \`issues/\`: 문제, 원인 가설, 영향
- \`runbooks/\`: 반복 실행 절차
- \`handoff/\`: 세션 인수인계
- \`coverage/\`: coverage 기준과 결과 색인
- \`silo-template/\`: task silo 시작 템플릿과 evidence 위치
"

  local task_status
  for task_status in todo in_progress blocked review done; do
    write_setup_file "$target/30-work-items/tasks/$task_status/.gitkeep" ""
  done

  write_setup_file "$target/30-work-items/tasks/_templates/TASK-template.md" "---
type: task
id: TASK-0000
taskID: TASK-0000
taskTitle: 태스크 제목
title: 태스크 제목
parent_issue:
status: todo
priority: p0
level_target:
owner_silo:
branch:
output:
acceptance_criteria: []
test_plan: []
coverage_target:
verification_plan: []
approval_required: false
pr:
promotion_status: draft
hypothesis_chain: []
hypothesis_attempt_limit: 3
hypothesis_attempt_count: 0
hypothesis_limit_status: within-limit
had_failed_run: false
resolved_by_hypothesis: false
failed_run_count: 0
resolved_attempt_no:
latest_failed_report:
latest_retry_report:
blocked_reason:
latest_resolution_summary:
dashboard_flags: []
mode: exploratory
build_assumption:
learn_summary:
promoted_spec_candidate:
follow_up_task_candidates: []
runtime_set:
parallel_independence_contract:
  sibling_task_dependency_allowed: false
  integration_gate_required_for_sibling_e2e: true
  alternative_verification_required_for_external_dependency: true
created:
updated:
closed:
---

# 태스크 제목

## ID

TASK-0000

## 제목

태스크 제목

## 배경

요청, 발견 사항, 현재 상태, 왜 지금 처리하는지 적습니다.

## 목표

이 task가 독립적으로 끝내야 할 사용자 또는 운영 목적을 적습니다.

## Output

## 병렬 task 독립성 계약

- sibling task 완료를 Output, Acceptance Criteria, Test Plan의 전제로 두지 않습니다.
- 인증, 데이터, 화면, backend 의존성이 있으면 agent가 통제할 수 있는 대체 검증 경로와 실제 사용자 경로의 차이를 Test Plan에 적습니다.
- 여러 sibling task 완료를 전제로 하는 최종 통합 E2E는 별도 QA gate, integration task, 또는 후속 project 검증으로 분리합니다.
- 단일 task의 화면 동작 자체가 산출물이면 E2E 또는 agent-browser acceptance를 유지합니다.

## Project Contract 확인 결과

## 단계별 구현 계획

## Pseudo Code

일반 기능 task는 파일별 대표 함수 골격형으로 작성합니다. 아래 단순 config 변경 계약을 사용하는 경우 이 섹션을 비웁니다.

## 단순 config 변경 계약

선언적 config, prop, default, value 한두 곳만 수정하고 별도 분기·가공·조회·저장 흐름이 없을 때만 작성합니다. 로직 변경이나 여러 파일 실행 흐름은 이 예외로 분류하지 않습니다. 일반 기능 task는 이 섹션을 비우고 Pseudo Code를 작성합니다.

- 대상 파일:
- 설정 key:
- 기존값 또는 누락 상태:
- 목표값:
- 회귀 검증:

## 범위 drift 후보

## Acceptance Criteria

## Test Plan

## criteria별 테스트 계약

## 초기 DB 목데이터

## 테스트 입력

## 자동 검증 범위

자동 검증이 보장하는 것과 보장하지 못하는 것을 분리합니다.

## Pre-QA Gate

사용자 화면, 설치, 서버 실행, 앱 다운로드 가능 상태가 acceptance에 포함되면 적습니다.

## 사용자 승인 또는 외부 의존성 blocker

## 후속 project QA gate

## 실행 불가 또는 대체 증거

runner, E2E, agent-browser, 외부 도구를 실행할 수 없을 때 사유, 대체 증거, 남은 수동 확인 범위를 적습니다.

## Coverage Target 또는 Evidence Target

## 금지선

## 관련 repo/branch/silo

## feedback/follow-up 후보

## Runtime Set

task.runtime_set:

## PR 본문 필수 항목

## 실패 이력

- had_failed_run:
- resolved_by_hypothesis:
- failed_run_count:
- resolved_attempt_no:
- latest_failed_report:
- latest_retry_report:
- blocked_reason:
- latest_resolution_summary:

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
level_target:
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

  write_setup_file "$target/30-work-items/coverage/RUN-REPORT-template.md" "---
type: run-report
id: RUN-REPORT-0000
run_id: RUN-0000
target_id:
target_name:
status:
passed_level:
completed_stage:
had_failed_run: false
resolved_by_hypothesis: false
failed_run_count: 0
resolved_attempt_no:
latest_failed_report:
latest_retry_report:
linked_task:
blocked_reason:
latest_resolution_summary:
updated:
---

# 실행 리포트

## 실행 대상

- run_id:
- target_id:
- target_name:

## 최신 결과

- status:
- passed_level:
- completed_stage:

## 실패 이력

- had_failed_run:
- resolved_by_hypothesis:
- failed_run_count:
- resolved_attempt_no:
- latest_failed_report:
- latest_retry_report:
- linked_task:
- blocked_reason:
- latest_resolution_summary:

## 실패 체인
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

## 원본 task/issue SSoT

- 원본 task/issue 경로:
- 2계층 Project Work SSoT 경로:
- 소비하는 work data: task / issue / QA / runbook / coverage / work dashboard / Run Set

root \`main-v3/main\`에는 project work 실데이터가 없을 수 있습니다. 원본은 project SSoT 또는 Project Work SSoT의 정본 위치를 참조합니다.

## 사일로 유형

- 유형: 일반 사일로 / 테스트 사일로

## 필요한 repo

## 보호 브랜치

## 작업 브랜치

## 역할 책임

- 개발자:
- QA:
- 리뷰:

## 금지선

## Project Contract 확인 결과

## 단계별 구현 계획

## Pseudo Code

일반 기능 task는 파일별 대표 함수 골격형으로 작성합니다. 아래 단순 config 변경 계약을 사용하는 경우 이 섹션을 비웁니다.

## 단순 config 변경 계약

선언적 config, prop, default, value 한두 곳만 수정하고 별도 분기·가공·조회·저장 흐름이 없을 때만 작성합니다. 로직 변경이나 여러 파일 실행 흐름은 이 예외로 분류하지 않습니다. 일반 기능 task는 이 섹션을 비우고 Pseudo Code를 작성합니다.

- 대상 파일:
- 설정 key:
- 기존값 또는 누락 상태:
- 목표값:
- 회귀 검증:

## 범위 drift 후보

## Runtime Set

run_set.required_runtime_set:

## Runtime Set 결정 근거

- 확인 우선순위: run_set.required_runtime_set -> task.runtime_set -> qa_or_runbook.runtime_set -> project.common_runtime_set -> runtime 정의 누락
- 선택한 runtime set id:
- branch:
- commit:
- port:
- health check 결과:
- 더 높은 우선순위가 없다는 확인:

## 테스트 report/window

테스트 사일로인 경우 report 위치와 execution window 또는 scheduler 기준을 적습니다.

## criteria별 테스트 계약

각 acceptance criteria를 unit, integration, runner, E2E, agent-browser, manual 중 하나 이상의 검증 방법과 연결합니다.

## 초기 DB 목데이터

테스트 시작 전에 seed로 있어야 하는 데이터, 필요한 이유, 연결 criteria, 재실행 오염 방지 방식을 적습니다. schema 정본 위치가 없으면 제품 구조를 추정하지 않고 \`project SSoT schema 계약 누락\`으로 분류합니다.

## 테스트 입력

실행 중 사용자, runner, harness, API client가 넣는 액션과 payload를 적습니다. 실행 후에 생기는 값은 초기 DB 목데이터가 아니라 테스트 입력으로 분류합니다.

## 원본 task Output/Acceptance/Test Plan

- Output:
- Acceptance Criteria:
- Test Plan:

## 검증 기준

자동 검증이 보장하는 것과 실제 사용자 설치/로그인/네트워크 경로처럼 보장하지 못하는 것을 분리합니다.

## Codex review

- PR 생성 직후 수동 \`@codex review\` 호출 여부:
- 생략 사유:

## agent-browser 기준

브라우저 확인이 필요한 경우 실행 기준, 실행 불가 사유, 대체 증거, 남은 수동 확인 범위를 적습니다.

## PR 본문 필수 항목

- 무엇을 했는가
- 변경 상세
- 검증
- Codex review 호출/결과
- feedback/follow-up 후보
- 처리하지 않고 남긴 항목
- 남은 위험

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

write_project_root_index() {
  local project_root="$1"

  mkdir -p "$project_root/00-secrets"

  write_setup_file "$project_root/README.md" "# $PROJECT_NAME Project SSoT Index

이 파일은 \`projects/$PROJECT_ID/\`의 얇은 입구 색인입니다.

프로젝트 내부 상세 task, issue, QA, coverage 원문은 이 파일에 쓰지 않습니다.

## 위치

| 항목 | 위치 |
|---|---|
| 1계층 Project SSoT | \`01-project-ssot/\` |
| 2계층 Project Work SSoT | \`02-project-internal/\` |
| secret/credential 안내 | \`00-secrets/README.md\` |
| 3계층 silo local/evidence | root scaffold 기본 생성물이 아니며 별도 silo workspace, PR 본문, 또는 project별 외부 evidence 위치 |

## 쓰기 전 확인

1. project contract와 기능/사용자 흐름별 요구사항은 \`01-project-ssot/\`에서 확인합니다.
2. task, issue, QA, runbook, coverage는 \`02-project-internal/\` 아래 위치를 확인합니다.
3. 실제 secret, token, password, credential 값은 이 저장소에 기록하지 않습니다.
4. 제품 소스코드는 이 폴더에 복사하지 않고 repo, fork, submodule, external clone, 또는 project registry 참조로 둡니다.
5. 3계층 silo local/evidence 실제 디렉터리는 이 root scaffold에 만들지 않고, task 실행 시 별도 위치에서 다룹니다.
"

  write_setup_file "$project_root/00-secrets/README.md" "# Secret and Credential Boundary

이 폴더는 secret, token, password, credential 값을 저장하는 곳이 아닙니다.

## 기록 가능한 것

- 어떤 secret provider나 로컬 설정 파일을 참조해야 하는지에 대한 안내
- 접근 권한이 필요한 범위
- secret 값을 쓰지 않는 설정 절차

## 금지

- 실제 secret 값
- token, password, private key, credential 원문
- production 데이터 또는 계정 정보
"
}

init_config() {
  info ""
  info "config 초안 생성"
  copy_setup_file "$REPO_ROOT/system/config/silo-runtime.env.example" "$REPO_ROOT/system/config/silo-runtime.env"
  copy_setup_file "$REPO_ROOT/system/config/silo-projects.example.yaml" "$REPO_ROOT/system/config/silo-projects.yaml"
  copy_setup_file "$REPO_ROOT/system/config/silo-secrets.example.yaml" "$REPO_ROOT/system/config/silo-secrets.yaml"
  copy_setup_file "$REPO_ROOT/system/config/shared-runtime-registry.example.yaml" "$REPO_ROOT/system/config/shared-runtime-registry.yaml"
  copy_setup_file "$REPO_ROOT/system/config/public-export-manifest.example.yaml" "$REPO_ROOT/system/config/public-export-manifest.yaml"
}

validate_workspace_agents_router() {
  local workspace="$1"
  local router_template="$REPO_ROOT/system/templates/workspace/AGENTS.template.md"
  local physical_workspace

  workspace="$(absolute_setup_path "$workspace")"
  physical_workspace="$(physical_setup_path "$workspace")"
  case "$physical_workspace" in
    "$REPO_ROOT"|"$REPO_ROOT"/*) fail "Workspace AGENTS router는 0계층 repo 내부이거나 그 symlink에 생성할 수 없습니다: $workspace" ;;
  esac

  [ -f "$router_template" ] || fail "Workspace AGENTS router template not found: $router_template"
  [ ! -L "$workspace/AGENTS.md" ] || fail "Workspace AGENTS router는 symlink일 수 없습니다: $workspace/AGENTS.md"
  [ ! -e "$workspace/AGENTS.md" ] || [ -f "$workspace/AGENTS.md" ] \
    || fail "Workspace AGENTS router는 일반 파일이어야 합니다: $workspace/AGENTS.md"
}

ensure_workspace_agents_router() {
  local workspace="$1"
  local router_template="$REPO_ROOT/system/templates/workspace/AGENTS.template.md"
  local rendered_router stripped_router escaped_system_path

  workspace="$(absolute_setup_path "$workspace")"
  validate_workspace_agents_router "$workspace"
  mkdir -p "$workspace"

  rendered_router="$TMP_ROOT/workspace-agents-router.md"
  stripped_router="$TMP_ROOT/workspace-agents-existing.md"
  escaped_system_path="$(printf '%s' "$REPO_ROOT/AGENTS.md" | sed 's/[\\&|]/\\&/g')"
  sed "s|<system-agents-path>|$escaped_system_path|g" "$router_template" > "$rendered_router"

  if [ ! -f "$workspace/AGENTS.md" ]; then
    cp "$rendered_router" "$workspace/AGENTS.md"
  else
    awk '
      /<!-- new-human-workspace-router:start -->/ { skip = 1; next }
      /<!-- new-human-workspace-router:end -->/ { skip = 0; next }
      !skip { print }
    ' "$workspace/AGENTS.md" > "$stripped_router"
    cp "$stripped_router" "$workspace/AGENTS.md"
    printf '\n\n' >> "$workspace/AGENTS.md"
    cat "$rendered_router" >> "$workspace/AGENTS.md"
  fi
}

init_user_layer() {
  local workspace="${WORKSPACE_ROOT:-$(dirname "$REPO_ROOT")}"
  local target template_root physical_target user_dir_path user_file_path
  workspace="$(absolute_setup_path "$workspace")"
  target="$workspace/user-layer"
  template_root="$REPO_ROOT/system/templates/user-layer"

  [ -f "$template_root/AGENTS.template.md" ] || fail "User Layer template not found: $template_root/AGENTS.template.md"
  [ -f "$template_root/feedback.template.md" ] || fail "User Layer template not found: $template_root/feedback.template.md"
  [ -f "$template_root/update-session.template.md" ] || fail "User Layer template not found: $template_root/update-session.template.md"

  [ ! -L "$target" ] || fail "User Layer 고정 위치는 symlink일 수 없습니다: $target"
  [ ! -e "$target" ] || [ -d "$target" ] || fail "User Layer 고정 위치는 디렉터리여야 합니다: $target"
  physical_target="$(physical_setup_path "$target")"
  case "$physical_target" in
    "$REPO_ROOT"|"$REPO_ROOT"/*) fail "User Layer는 0계층 repo 내부이거나 그 symlink에 생성할 수 없습니다: $target" ;;
  esac

  for user_dir_path in \
    "$target/feedback" \
    "$target/feedback/active" \
    "$target/feedback/applied" \
    "$target/feedback/closed" \
    "$target/update-sessions"; do
    [ ! -L "$user_dir_path" ] || fail "User Layer 내부 정본 경로는 symlink일 수 없습니다: $user_dir_path"
    [ ! -e "$user_dir_path" ] || [ -d "$user_dir_path" ] \
      || fail "User Layer 내부 정본 디렉터리 경로가 일반 파일입니다: $user_dir_path"
  done

  for user_file_path in \
    "$target/AGENTS.md" \
    "$target/feedback/feedback.template.md" \
    "$target/update-sessions/update-session.template.md"; do
    [ ! -L "$user_file_path" ] || fail "User Layer 내부 정본 경로는 symlink일 수 없습니다: $user_file_path"
    [ ! -e "$user_file_path" ] || [ -f "$user_file_path" ] \
      || fail "User Layer 내부 정본 파일 경로가 디렉터리입니다: $user_file_path"
  done

  validate_workspace_agents_router "$workspace"
  install_codex_home_agents
  ensure_workspace_agents_router "$workspace"

  mkdir -p "$target/feedback/active" "$target/feedback/applied" "$target/feedback/closed" "$target/update-sessions"

  if [ ! -f "$target/AGENTS.md" ]; then
    cp "$template_root/AGENTS.template.md" "$target/AGENTS.md"
  fi
  cp "$template_root/feedback.template.md" "$target/feedback/feedback.template.md"
  cp "$template_root/update-session.template.md" "$target/update-sessions/update-session.template.md"

  info "User Layer User SSoT directory prepared: $target"
  info "Workspace AGENTS router prepared: $workspace/AGENTS.md"
  info "실제 퍼스널리티와 Feedback은 이 1계층 디렉터리가 소유합니다."
}

prompt_project_ssot_args() {
  contains_selection "create-project-ssot" || return 0

  if [ "$QUICKSTART" = "yes" ]; then
    if [ -z "$PROJECT_NAME" ]; then
      if [ "$ASSUME_YES" = "yes" ]; then
        fail "--quickstart with --yes requires --project-name"
      fi
      printf '프로젝트 이름: '
      IFS= read -r PROJECT_NAME
    fi

    [ -n "$PROJECT_NAME" ] || fail "project name is required"

    if [ -z "$PROJECT_ID" ]; then
      PROJECT_ID="$(normalize_project_id "$PROJECT_NAME")"
    fi

    if [ -z "$WORKSPACE_ROOT" ]; then
      WORKSPACE_ROOT="$(default_workspace_root)"
    else
      case "$WORKSPACE_ROOT" in
        /*) ;;
        *) WORKSPACE_ROOT="$REPO_ROOT/$WORKSPACE_ROOT" ;;
      esac
    fi
    WORKSPACE_ROOT="$(normalize_setup_path "$WORKSPACE_ROOT")"
    ensure_quickstart_workspace_root

    if [ -z "$PROJECT_SSOT_TARGET" ]; then
      PROJECT_SSOT_TARGET="$WORKSPACE_ROOT/$PROJECT_ID/02-project-work-ssot"
    else
      case "$PROJECT_SSOT_TARGET" in
        /*) ;;
        *) PROJECT_SSOT_TARGET="$REPO_ROOT/$PROJECT_SSOT_TARGET" ;;
      esac
      PROJECT_SSOT_TARGET="$(normalize_setup_path "$PROJECT_SSOT_TARGET")"
    fi
    ensure_quickstart_path_outside_repo "$PROJECT_SSOT_TARGET" "project target"
  fi

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
    PROJECT_SSOT_TARGET="$(default_workspace_root)/$PROJECT_ID/02-project-work-ssot"
    if [ "$ASSUME_YES" != "yes" ]; then
      printf 'project workspace target [%s]: ' "$PROJECT_SSOT_TARGET"
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
  PROJECT_FOLDER_RESULT="$(project_folder_from_work_target "$target")"
  PROJECT_LAYER1_RESULT="$layer1_target"
  PROJECT_WORK_RESULT="$target"

  local workspace_router_root
  if [ -n "$WORKSPACE_ROOT" ]; then
    workspace_router_root="$WORKSPACE_ROOT"
  else
    case "$PROJECT_FOLDER_RESULT" in
      */projects/"$PROJECT_ID") workspace_router_root="${PROJECT_FOLDER_RESULT%/projects/$PROJECT_ID}" ;;
      *) workspace_router_root="$(dirname "$PROJECT_FOLDER_RESULT")" ;;
    esac
  fi
  if [ "$(physical_setup_path "$workspace_router_root")" = "$REPO_ROOT" ] \
    && [[ "$PROJECT_FOLDER_RESULT" == "$REPO_ROOT/projects/"* ]]; then
    info "기존 0계층 root AGENTS를 legacy projects router로 사용합니다: $REPO_ROOT/AGENTS.md"
  else
    ensure_workspace_agents_router "$workspace_router_root"
  fi

  info ""
  info "project workspace 구조 생성"
  info "project id: $PROJECT_ID"
  if [ "$QUICKSTART" = "yes" ]; then
    info "프로젝트 폴더: $PROJECT_FOLDER_RESULT"
  else
    info "target: $target"
    info "1계층 target: $layer1_target"
  fi
  local project_vault_path
  local layer1_from_work_path
  project_vault_path="$(project_ssot_vault_path "$target")"
  case "$target" in
    */02-project-work-ssot) layer1_from_work_path="../01-project-ssot" ;;
    */02-project-internal) layer1_from_work_path="../01-project-ssot" ;;
    *) layer1_from_work_path="01-project-ssot" ;;
  esac
  ensure_quickstart_workspace_dirs
  ensure_project_ssot_gitignore "$target" "$layer1_target"

  local project_root=""
  case "$target" in
    */projects/"$PROJECT_ID"/02-project-internal)
      project_root="${target%/02-project-internal}"
      ;;
  esac

  mkdir -p \
    "$layer1_target/50-decisions" \
    "$target/.obsidian" \
    "$target/.obsidian/snippets" \
    "$target/00-dashboard" \
    "$target/10-dictionary" \
    "$target/templates"

  ensure_project_ssot_surface_dirs "$target"
  mkdir -p "$layer1_target/10-requirements" "$layer1_target/50-decisions"
  [ -n "$project_root" ] && write_project_root_index "$project_root"

  write_setup_file "$target/README.md" "# $PROJECT_NAME Project Work SSoT

이 폴더는 $PROJECT_NAME 프로젝트의 task, issue, QA, runbook, handoff를 관리하는 2계층 Project Work SSoT입니다.

## Obsidian 전제

- 작업 대시보드 \`00-dashboard/work-filter.md\`는 Dataview community plugin과 DataviewJS 활성화를 전제로 합니다.
- \`00-dashboard/work-items.base\`는 Obsidian Base 뷰를 쓰는 대체 화면입니다.
- \`.obsidian/snippets/readable-markdown-width.css\`는 Markdown 편집/미리보기 영역에 \`90%\` 폭을 적용하기 위한 기본 CSS snippet입니다.
- 이 scaffold는 \`.obsidian/community-plugins.json\`에 \`dataview\`를 기본 선언합니다. 실제 플러그인 설치와 DataviewJS 허용은 Obsidian 앱에서 확인합니다.

## 폴더

- \`00-dashboard/\`: 현재 상태, 활성 issue/task, 다음 행동
- \`00-layer-index/\`: 1~3계층 자료 위치와 소유 경계 색인
- \`01-branch-policy/\`: project/source/harness 기준 브랜치와 PR target
- \`10-dictionary/\`: 프로젝트 용어, 고유명사, 내부 약어, 공통 승격 후보
- \`$layer1_from_work_path/project-registry.md\`: 1계층 project 정본 위치와 repo 연결 색인
- \`$layer1_from_work_path/AGENTS.md\`: 기능 task 작성 전 1계층 계약 확인 gate
- \`$layer1_from_work_path/10-requirements/\`: 기능/사용자 흐름별 요구사항 정본
- \`20-level-criteria/\`: 단계별 채점 기준, runner 계약, report/evidence 위치
- \`30-work-items/\`: task/issue/runbook/handoff/coverage/silo template
- \`30-work-items/coverage/RUN-REPORT-template.md\`: run report 실패 이력 기록 템플릿
- \`40-runtime-sets/\`: runtime set 정의와 선택 우선순위
- \`$layer1_from_work_path/50-decisions/\`: 1계층 프로젝트 결정과 ADR
- \`50-pr-review/\`: PR review gate와 test evidence
- \`60-feedback-update/\`: feedback active/applied/closed 상태 관리
- \`templates/\`: 반복 문서 양식
- \`templates/run-report.md\`: run report 대시보드/coverage 기록 복제 템플릿
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

- 기능 task 생성 전 계약: \`$layer1_from_work_path/AGENTS.md\`
- Task 칸반: [[kanban|Task 칸반]]
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

  copy_setup_file "$REPO_ROOT/system/templates/project-ssot/00-dashboard/kanban.md" "$target/00-dashboard/kanban.md"
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
level_target:
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
parent_issue:
status: todo
priority: p0
parallel_independence_contract:
  sibling_task_dependency_allowed: false
  integration_gate_required_for_sibling_e2e: true
  alternative_verification_required_for_external_dependency: true
created:
level_target:
owner_silo:
branch:
output:
acceptance_criteria: []
test_plan: []
coverage_target:
verification_plan: []
approval_required: false
pr:
promotion_status: draft
hypothesis_chain: []
hypothesis_attempt_limit: 3
hypothesis_attempt_count: 0
hypothesis_limit_status: within-limit
had_failed_run: false
resolved_by_hypothesis: false
failed_run_count: 0
resolved_attempt_no:
latest_failed_report:
latest_retry_report:
blocked_reason:
latest_resolution_summary:
dashboard_flags: []
mode: exploratory
build_assumption:
learn_summary:
promoted_spec_candidate:
follow_up_task_candidates: []
runtime_set:
updated:
closed:
---

# 태스크 제목

## ID

TASK-0000

## 제목

사람이 읽는 작업 목표나 문제 이름을 적습니다.

## 배경

요청, 발견 사항, 현재 상태, 왜 지금 처리하는지 적습니다.

## 목표

이 task가 독립적으로 끝내야 할 사용자 또는 운영 목적을 적습니다.

## Output

해당 task가 독립적으로 증명할 수 있는 산출물만 적습니다. 병렬 sibling task 완료를 전제로 삼지 않습니다.

## 병렬 task 독립성 계약

- sibling task 완료를 Output, Acceptance Criteria, Test Plan의 전제로 두지 않습니다.
- 인증, 데이터, 화면, backend 의존성이 있으면 agent가 통제할 수 있는 대체 검증 경로와 실제 사용자 경로의 차이를 Test Plan에 적습니다.
- 여러 sibling task 완료를 전제로 하는 최종 통합 E2E는 별도 QA gate, integration task, 또는 후속 project 검증으로 분리합니다.
- 단일 task의 화면 동작 자체가 산출물이면 E2E 또는 agent-browser acceptance를 유지합니다.

## Project Contract 확인 결과

기능 task인 경우 project contract 위치, 확인한 제품 정의/목표/비목표/핵심 플로우/데이터 저장·동기화 경계/repo 역할, 누락 항목을 적습니다.

## 초기 DB 목데이터

## 테스트 입력

## 단계별 구현 계획

기능 task인 경우에만 작성합니다. 비기능 task, coverage task, 문서 task에는 기계적으로 요구하지 않습니다.

## Pseudo Code

기능 task인 경우 파일별 대표 함수 골격형으로 작성합니다. 각 파일의 대표 함수와 보조 함수가 어떤 입력/의존성을 받고 조회, 검증, 가공, 조건 분기, 반복, 저장, 반환을 어떻게 수행하는지 코드에 가깝게 보여야 합니다. TypeScript/JavaScript 같은 실제 구현 코드 블록이나 완성된 함수 구현을 쓰지 않습니다. 코드 식별자, API query, 파일명, op 이름(\`D/L/C/R\`)은 원문을 유지할 수 있습니다. 단, 선언적 config, prop, default, value 한두 곳만 수정하고 별도 분기·가공·조회·저장 흐름이 없으면 이 섹션을 비우고 아래 \`단순 config 변경 계약\`에 대상 파일, 설정 key, 기존값 또는 누락 상태, 목표값, 회귀 검증을 적습니다. 로직 변경이나 여러 파일 실행 흐름은 이 예외로 분류하지 않습니다.

## 단순 config 변경 계약

위 예외 조건을 만족할 때만 작성하고 Pseudo Code는 비웁니다. 일반 기능 task는 이 섹션을 비웁니다.

- 대상 파일:
- 설정 key:
- 기존값 또는 누락 상태:
- 목표값:
- 회귀 검증:

## 범위 drift 후보

Pseudo Code에서 task 목표 밖 화면, 버튼, endpoint, table mutation, submodule, E2E 범위가 보이면 적습니다.

## Acceptance Criteria

병렬로 생성하거나 실행할 task라면 sibling task 완료를 완료 조건으로 두지 않습니다.

## Test Plan

인증, 데이터, 화면, backend 의존성이 있으면 seed data, dev-auth, fixture session, contract mock, harness, Docker fixture DB 같은 독립 검증 경로를 적습니다.
여러 sibling task 완료를 전제로 하는 최종 통합 E2E는 개별 task acceptance가 아니라 별도 QA gate, integration task, 또는 후속 harness 검증으로 분리합니다. 단일 task의 화면 동작 자체가 산출물이면 E2E 또는 agent-browser acceptance를 유지합니다.

## criteria별 테스트 계약

각 acceptance criteria를 unit, integration, runner, E2E, agent-browser, manual 중 하나 이상의 검증 방법과 연결합니다.

## 초기 DB 목데이터

테스트 시작 전에 DB에 seed로 존재해야 하는 상태만 적습니다. 실제 task mock data와 test input은 이 task 또는 2계층 Project Work SSoT/runbook에 둡니다.

## 테스트 입력

UI, API, harness, runner가 실행 중 넣는 값과 액션을 적습니다.

## 자동 검증 범위

자동 검증이 보장하는 것과 보장하지 못하는 것을 분리합니다.

## Pre-QA Gate

사용자 화면, 설치, 서버 실행, 앱 다운로드 가능 상태가 acceptance에 포함되면 적습니다.

## 사용자 승인 또는 외부 의존성 blocker

agent가 통제하지 못하는 승인, 계정, 네트워크, 외부 서비스, 런타임 설정을 적습니다.

## 후속 project QA gate

단일 task 밖 통합 E2E, project QA, harness 검증으로 넘길 항목을 적습니다.

## 실행 불가 또는 대체 증거

runner, E2E, agent-browser, 외부 도구를 실행할 수 없을 때 사유, 대체 증거, 남은 수동 확인 범위를 적습니다.

## Coverage Target 또는 Evidence Target

## 금지선

보호 브랜치, destructive action, secret/credential, scope drift 금지선을 적습니다.

## 관련 repo/branch/silo

관련 repo, branch base, 작업 브랜치, silo 유형과 위치를 적습니다.

## feedback/follow-up 후보

공통 규칙 승격 후보, project SSoT 갱신 후보, 후속 task/issue 후보를 분리합니다.

## Runtime Set

task.runtime_set:

## PR 본문 필수 항목

## 실패 이력

- had_failed_run:
- resolved_by_hypothesis:
- failed_run_count:
- resolved_attempt_no:
- latest_failed_report:
- latest_retry_report:
- blocked_reason:
- latest_resolution_summary:

## 실행 로그
"

  write_setup_file "$target/templates/run-report.md" "---
type: run-report
id: RUN-REPORT-0000
run_id: RUN-0000
target_id:
target_name:
status:
passed_level:
completed_stage:
had_failed_run: false
resolved_by_hypothesis: false
failed_run_count: 0
resolved_attempt_no:
latest_failed_report:
latest_retry_report:
linked_task:
blocked_reason:
latest_resolution_summary:
updated:
---

# 실행 리포트

## 실행 대상

- run_id:
- target_id:
- target_name:

## 최신 결과

- status:
- passed_level:
- completed_stage:

## 실패 이력

- had_failed_run:
- resolved_by_hypothesis:
- failed_run_count:
- resolved_attempt_no:
- latest_failed_report:
- latest_retry_report:
- linked_task:
- blocked_reason:
- latest_resolution_summary:

## 실패 체인
"

  write_setup_file "$target/templates/silo-goal.md" "# Silo Goal

## 목표

## 원본 task/issue SSoT

- 원본 task/issue 경로:
- 2계층 Project Work SSoT 경로:
- 소비하는 work data: task / issue / QA / runbook / coverage / work dashboard / Run Set

root \`main-v3/main\`에는 project work 실데이터가 없을 수 있습니다. 원본은 project SSoT 또는 Project Work SSoT의 정본 위치를 참조합니다.

## 사일로 유형

- 유형: 일반 사일로 / 테스트 사일로

## 필요한 repo

## 보호 브랜치

## 작업 브랜치

## 역할 책임

- 개발자:
- QA:
- 리뷰:

## 금지선

## Project Contract 확인 결과

기능 task인 경우 project contract 위치, 확인한 제품 정의/목표/비목표/핵심 플로우/데이터 저장·동기화 경계/repo 역할, 누락 항목을 적습니다.

## 단계별 구현 계획

기능 task인 경우에만 작성합니다.

## Pseudo Code

기능 task인 경우 파일별 대표 함수 골격형으로 작성합니다. 각 파일의 대표 함수와 보조 함수가 어떤 입력/의존성을 받고 조회, 검증, 가공, 조건 분기, 반복, 저장, 반환을 어떻게 수행하는지 코드에 가깝게 보여야 합니다. TypeScript/JavaScript 같은 실제 구현 코드 블록이나 완성된 함수 구현을 쓰지 않습니다. 코드 식별자, API query, 파일명, op 이름(\`D/L/C/R\`)은 원문을 유지할 수 있습니다. 단, 선언적 config, prop, default, value 한두 곳만 수정하고 별도 분기·가공·조회·저장 흐름이 없으면 이 섹션을 비우고 아래 \`단순 config 변경 계약\`에 대상 파일, 설정 key, 기존값 또는 누락 상태, 목표값, 회귀 검증을 적습니다. 로직 변경이나 여러 파일 실행 흐름은 이 예외로 분류하지 않습니다.

## 단순 config 변경 계약

위 예외 조건을 만족할 때만 작성하고 Pseudo Code는 비웁니다. 일반 기능 task는 이 섹션을 비웁니다.

- 대상 파일:
- 설정 key:
- 기존값 또는 누락 상태:
- 목표값:
- 회귀 검증:

## 범위 drift 후보

Pseudo Code에서 task 목표 밖 화면, 버튼, endpoint, table mutation, submodule, E2E 범위가 보이면 적습니다.

## Runtime Set

run_set.required_runtime_set:

## Runtime Set 결정 근거

- 확인 우선순위: run_set.required_runtime_set -> task.runtime_set -> qa_or_runbook.runtime_set -> project.common_runtime_set -> runtime 정의 누락
- 선택한 runtime set id:
- branch:
- commit:
- port:
- health check 결과:
- 더 높은 우선순위가 없다는 확인:

## 테스트 report/window

테스트 사일로인 경우 report 위치와 execution window 또는 scheduler 기준을 적습니다.

## criteria별 테스트 계약

각 acceptance criteria를 unit, integration, runner, E2E, agent-browser, manual 중 하나 이상의 검증 방법과 연결합니다.

## 초기 DB 목데이터

테스트 시작 전에 seed로 있어야 하는 데이터, 필요한 이유, 연결 criteria, 재실행 오염 방지 방식을 적습니다. schema 정본 위치가 없으면 제품 구조를 추정하지 않고 \`project SSoT schema 계약 누락\`으로 분류합니다.

## 테스트 입력

실행 중 사용자, runner, harness, API client가 넣는 액션과 payload를 적습니다. 실행 후에 생기는 값은 초기 DB 목데이터가 아니라 테스트 입력으로 분류합니다.

## 원본 task Output/Acceptance/Test Plan

- Output:
- Acceptance Criteria:
- Test Plan:

## 검증 기준

자동 검증이 보장하는 것과 실제 사용자 설치/로그인/네트워크 경로처럼 보장하지 못하는 것을 분리합니다.

## Codex review

- PR 생성 직후 수동 \`@codex review\` 호출 여부:
- 생략 사유:

## agent-browser 기준

브라우저 확인이 필요한 경우 실행 기준, 실행 불가 사유, 대체 증거, 남은 수동 확인 범위를 적습니다.

## PR 본문 필수 항목

- 무엇을 했는가
- 변경 상세
- 검증
- Codex review 호출/결과
- feedback/follow-up 후보
- 처리하지 않고 남긴 항목
- 남은 위험

## Evidence 위치

\`evidence/\` 아래에 실행 증거를 둡니다.
"

  local pr_description_template
  pr_description_template="$(read_pr_description_template)"
  write_setup_file "$target/templates/pr-description.md" "$pr_description_template"

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

  if contains_selection "create-project-ssot"; then
    info ""
    info "Project SSoT 생성 파일 확인:"

    local target="$PROJECT_WORK_RESULT"
    local layer1_target="$PROJECT_LAYER1_RESULT"

    if [ -z "$target" ] || [ -z "$layer1_target" ]; then
      info "  누락 project SSoT target 확인 정보"
      missing=$((missing + 1))
    else
      local project_expected=(
        "$target/README.md"
        "$target/00-layer-index/README.md"
        "$target/00-dashboard/project-overview.md"
        "$target/00-dashboard/kanban.md"
        "$target/00-dashboard/work-filter.md"
        "$target/00-dashboard/work-items.base"
        "$target/00-dashboard/work-views.md"
        "$target/10-dictionary/project-dictionary.md"
        "$target/30-work-items/tasks/_templates/TASK-template.md"
        "$target/30-work-items/issues/ISSUE-template.md"
        "$target/30-work-items/silo-template/goal.md"
        "$target/40-runtime-sets/README.md"
        "$target/50-pr-review/README.md"
        "$target/60-feedback-update/README.md"
        "$target/templates/pr-description.md"
        "$layer1_target/README.md"
        "$layer1_target/project-registry.md"
        "$layer1_target/AGENTS.md"
        "$layer1_target/work-ssot-index.md"
        "$layer1_target/10-requirements/README.md"
        "$layer1_target/50-decisions/README.md"
      )

      local path
      for path in "${project_expected[@]}"; do
        if [ -f "$path" ]; then
          info "  ok  $path"
        else
          info "  누락 $path"
          missing=$((missing + 1))
        fi
      done
    fi
  fi

  if [ "$missing" -eq 0 ]; then
    info ""
    info "완료: 선택한 셋업 항목 실행이 끝났습니다. 스킬을 설치했다면 새 Codex 세션을 시작하면 반영됩니다."
  else
    info ""
    info "완료: 일부 스킬이 누락됐습니다. 위 누락 항목과 네트워크/권한 상태를 확인하세요."
  fi

  if [ "$QUICKSTART" = "yes" ]; then
    info ""
    info "빠른 시작 결과:"
    info "  프로젝트 기준 정보: $PROJECT_LAYER1_RESULT"
    info "  작업 관리: $PROJECT_WORK_RESULT"
    info "  제품 소스코드: $WORKSPACE_ROOT/sources"
    info "  task 실행 공간: $WORKSPACE_ROOT/silos"
    info "  공유 runtime: $WORKSPACE_ROOT/shared-runtime"
    info "  Obsidian Vault: $WORKSPACE_ROOT"
    info "  최초 1회 Obsidian에서 위 workspace 폴더를 Vault로 등록한 뒤 Local 검수 링크를 사용하세요."
  fi
}

main() {
  parse_args "$@"
  prompt_selection
  prompt_project_ssot_args
  confirm_selection
  ensure_tmp
  contains_selection "init-user-layer" && preflight_codex_home_agents
  ensure_tools

  contains_selection "repo-skills" && install_repo_skills
  contains_selection "using-superpowers" && install_superpowers_subset "using-superpowers 설치" "${USING_SUPERPOWERS_SKILLS[@]}"
  contains_selection "superpowers-workflow" && install_superpowers_subset "Superpowers 작업 보조 묶음 설치" "${SUPERPOWERS_WORKFLOW_SKILLS[@]}"
  contains_selection "agent-browser" && install_agent_browser
  contains_selection "compound-engineering" && install_compound_engineering
  contains_selection "init-config" && init_config
  contains_selection "init-user-layer" && init_user_layer
  contains_selection "create-project-ssot" && create_project_ssot

  enable_user_layer_git_tracking
  print_summary
}

main "$@"
