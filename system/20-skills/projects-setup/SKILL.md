---
name: projects-setup
description: 새 프로젝트를 root orchestrator의 projects 구조에 등록하거나 기존 프로젝트에 프로젝트 SSoT scaffold, 사일로 로컬 공간, silo project config를 셋업해야 할 때 사용합니다.
---

# Projects Setup

이 스킬은 새 프로젝트를 1계층 `projects/<project-id>/`에 등록하고, 2계층 Project Internal SSoT와 3계층 Silo Local 공간을 한 번에 준비합니다.

## 원칙

- `projects/<project-id>/`는 프로젝트 연결 정보와 프로젝트 의존 운영 자료의 입구입니다.
- `02-project-internal/`은 실제 project SSoT입니다. 이 안의 issue, task, QA, coverage 산출물은 0계층 `system/`으로 복사하지 않습니다.
- `setup.sh --create-project-ssot`은 최소 project SSoT scaffold를 생성합니다. 작업 대시보드는 DataviewJS와 Obsidian Base를 기본 viewer 계약으로 포함하고, 기능 task 생성 전 확인할 `00-dashboard/project-contract.md`를 함께 만듭니다.
- `system/config/silo-projects.yaml`은 로컬 설정입니다. secret 값은 쓰지 않고, repo URL, 보호 브랜치, 사일로 대상 여부, DB 사용 여부, DB schema 정본/요약/적용 경로 같은 운영 값만 기록합니다.
- DB를 사용하는 프로젝트는 등록/setup 단계에서 DB schema 정본 위치 또는 schema 요약 위치를 project registry/config 또는 project SSoT에 기록합니다. Docker, compose, migration, startup script로 DB가 자동 생성되거나 갱신되면 schema 적용 경로도 함께 기록합니다.
- 기존 `project-ssot-bootstrap` 역할은 이 스킬에 흡수되었습니다.

## 기본 구조

```text
projects/<project-id>/
├── README.md
├── 00-secrets/
│   └── README.md
├── 02-project-internal/
│   ├── README.md
│   ├── 00-dashboard/
│   │   ├── project-contract.md
│   │   ├── project-overview.md
│   │   ├── work-filter.md
│   │   ├── work-items.base
│   │   └── work-views.md
│   ├── 10-dictionary/
│   │   └── project-dictionary.md
│   ├── 20-issues/
│   ├── 30-tasks/
│   ├── 50-decisions/
│   ├── 70-handoff/
│   └── 90-coverage/
└── 03-silo-local/
    ├── README.md
    └── pr-description-template.md
```

## 절차

1. 계층을 판정합니다. 공통 규칙 변경이면 `main-branch-update-flow`, 특정 프로젝트 자료면 프로젝트 SSoT 또는 project 브랜치에서 처리합니다.
2. `project-id`, 표시 이름, repo URL, default branch, 보호 브랜치, `allowed_for_silo`, `role`, 상위 제품 repo host 역할, 기능 submodule 소유권, BE/FE submodule 경로, harness library 정책, 제품별 scenario/adapter 위치, DB 사용 여부, DB schema 정본/요약/적용 경로를 확인합니다.
3. `projects/<project-id>/`가 이미 있거나 `silo-projects.yaml`에 같은 id가 있으면 중단하고 병합/갱신 여부를 확인합니다.
4. `02-project-internal` scaffold는 `setup.sh`로 생성합니다.
   `projects/<project-id>/` 아래 target을 쓰면 `setup.sh`가 해당 project SSoT 경로만 git 추적 가능하도록 `.gitignore` 예외를 함께 보정합니다.

```bash
./setup.sh --create-project-ssot \
  --project-id sample-project \
  --project-name "Sample Project" \
  --target projects/sample-project/02-project-internal \
  --yes
```

5. `00-dashboard/project-contract.md`를 채웁니다. 최소한 제품 정의, 현재 버전 목표/비목표, 핵심 사용자 플로우, repo 역할, task 생성 전 필수 참조, 추정 금지 정보를 확인된 값으로 적습니다. 확인되지 않은 항목은 빈 heading으로 방치하지 않고 `project contract 누락` 또는 `사용자 확인 필요`로 표시합니다.
6. `projects/<project-id>/README.md`, `00-secrets/README.md`, `03-silo-local/README.md`, `03-silo-local/pr-description-template.md`를 생성합니다.
7. `system/config/silo-projects.yaml`이 없으면 `./setup.sh --init-config --yes`로 local config 초안을 만듭니다. 있으면 기존 구조를 보존하고 `projects:` 항목에 새 프로젝트만 추가합니다.
8. 변경 후 `git diff --stat`, 생성 파일 목록, config 등록 항목, project contract 작성/누락 항목을 보고합니다.

## 필수 프로젝트 설명 산출물

모든 project SSoT에는 프로젝트 전반 설명과 dictionary가 있어야 합니다.

`00-dashboard/`에는 project contract, project overview, 작업 필터 대시보드를 함께 둡니다. `project-contract.md`는 기능 task 생성 전 확인하는 제품 정의, 현재 버전 목표/비목표, 핵심 사용자 플로우, repo 역할, 추정 금지 정보입니다. `project-overview.md`는 프로젝트 상태와 운영 경계 요약이고, 실제 운영 첫 화면은 `work-filter.md` 또는 `work-views.md`처럼 issue/task를 필터링할 수 있는 작업 목록입니다.

`00-dashboard/project-contract.md`에는 최소 아래 항목을 둡니다.

- 제품 정의
- 현재 버전 목표와 비목표
- 핵심 사용자 플로우
- repo 역할과 금지선
- task 생성 전 필수 참조
- task 작성 규칙
- 추정 금지 정보

기능 task 템플릿과 사일로 `goal.md` 템플릿에는 `Project Contract 확인 결과` 섹션을 둡니다. task 작성자가 project contract 위치와 확인한 항목, 누락 항목을 남기지 않으면 기능 task를 사일로 실행 대상으로 넘기지 않습니다.

`00-dashboard/project-overview.md`에는 최소 아래 항목을 둡니다.

- 프로젝트 목적
- 주요 사용자/운영자
- repo/SSoT 위치
- 상위 제품 repo host 역할
- 기능 submodule 소유권과 BE/FE submodule 경로
- harness library 정책과 제품별 scenario/adapter 위치
- DB 사용 여부
- DB schema 정본 위치 또는 schema 요약 위치
- Docker/compose/migration/startup script의 schema 적용 경로
- 주요 workflow
- 검증/배포/운영 경계
- 금지선/주의사항

`00-dashboard/work-filter.md`에는 최소 아래 필터를 둡니다.

- 종류: issue/task
- 상태: todo, in_progress, blocked, review, done, closed 등 실제 문서에 있는 상태
- 레벨: `level_target`
- 태그: `tags` 또는 파일 태그
- 날짜: `updated`, `created`, `closed`, `file.mtime`
- 검색어

`work-filter.md`는 `dashboardScope.paths`를 읽습니다. 기본값은 `20-issues/`, `30-tasks/`이고, 파일을 복제해 `ops/20-issues/`, `ops/30-tasks/`, `be/30-tasks/`, `fe/30-tasks/`처럼 경로를 바꾸면 프로젝트 안에 여러 작업 대시보드를 둘 수 있습니다.

`00-dashboard/work-items.base`와 `00-dashboard/work-views.md`는 Obsidian 기본 Base view/filter를 쓰는 사용자를 위한 대체 화면입니다. Base에는 전체 즉석 필터, 진행 중 Task, 완료 Task, 열린 Issue view를 기본으로 둡니다. setup은 target이 현재 repo/vault 아래에 있으면 해당 Project SSoT 경로로 Base 필터를 제한하고, 외부 target이면 해당 SSoT를 vault root로 여는 전제의 로컬 `20-issues/`, `30-tasks/` 필터를 생성합니다.

작업 대시보드는 실제 issue/task만 보여야 하므로 `20-issues/ISSUE-template.md`, `30-tasks/TASK-template.md` 같은 live 폴더 안 템플릿 파일은 필터 결과에서 제외합니다.

작업 대시보드가 비지 않으려면 setup scaffold가 만드는 issue/task 템플릿에 최소 frontmatter가 있어야 합니다.

- issue: `type: issue`, `id`, `issueID`, `issueTitle`, `title`, `status`, `severity`, `updated`
- task: `type: task`, `id`, `taskID`, `taskTitle`, `title`, `status`, `priority`, `updated`

`id`와 `title`은 기존 문서 호환 필드이고, 새 문서는 `issueID`/`issueTitle`, `taskID`/`taskTitle`을 우선 사용합니다. 파일명이나 H1에 식별자를 합치지 않고, 대시보드는 ID와 제목을 별도 컬럼으로 보여줍니다.

생성되는 task 템플릿은 병렬 task 독립성 계약을 포함해야 합니다. 병렬로 생성하거나 실행할 task는 sibling task 완료를 Output, Acceptance Criteria, Test Plan의 전제로 두지 않고, 인증/데이터/화면/backend 의존성이 있으면 agent가 통제할 수 있는 대체 검증 경로와 실제 사용자 경로의 차이를 적습니다. 여러 sibling task 완료를 전제로 하는 최종 통합 E2E는 개별 task acceptance가 아니라 별도 QA gate, integration task, 또는 후속 project 검증으로 분리합니다. 단일 task의 화면 동작 자체가 산출물이면 E2E 또는 agent-browser acceptance를 유지합니다.

DataviewJS 대시보드를 쓰려면 Obsidian community plugin `dataview`를 설치하고 DataviewJS 실행을 허용해야 합니다. scaffold는 `.obsidian/community-plugins.json`에 `dataview`를 선언하고, Base 대체 뷰를 위해 `work-items.base`를 함께 생성합니다.

`10-dictionary/project-dictionary.md`에는 프로젝트에서 쓰는 용어, 고유명사, 내부 약어, runner 용어, coverage 용어를 기록합니다. 최소 필드는 아래와 같습니다.

| 필드 | 설명 |
|---|---|
| 용어/고유명사/내부 약어 | 프로젝트에서 실제 쓰는 이름 |
| 뜻 | 처음 보는 사람이 이해할 수 있는 정의 |
| 사용 맥락 | 어느 workflow, repo, runner, 화면, 문서에서 쓰는지 |
| 예시 | 실제 표현이나 page/item 예시 |
| 출처 또는 확인 상태 | source 문서, PR, 사용자 확인, 추정 여부 |
| 프로젝트 전용인지 공통 승격 후보인지 | project-local 용어인지, root `main-v2` 공통 규칙 후보인지 |

PR 본문 `명사 설명`에 반복해서 등장한 용어는 project dictionary 승격 후보로 남깁니다. 여러 프로젝트에서 반복되거나 에이전트 공통 행동 규칙에 영향을 주는 용어만 root `main-v2` 공통 dictionary 또는 관련 system 문서 승격 후보로 분리합니다.

Project dictionary 파일을 새로 만들거나 기존 dictionary에 용어를 추가/수정/삭제하는 PR은 PR 본문에 `새로 추가된 단어` 섹션을 둡니다.

- `명사 설명`은 해당 PR을 이해하기 위한 즉시 설명입니다.
- `새로 추가된 단어`는 project dictionary SSoT에 실제 추가/수정/삭제된 용어 목록입니다.
- 최소 컬럼은 `변경 유형`, `용어`, `뜻`, `사용 맥락`, `프로젝트 전용/공통 후보`, `dictionary 위치`입니다.
- 신규 추가만 있으면 `변경 유형`을 `추가`로 적고, 수정/삭제가 있으면 같은 컬럼에 `수정` 또는 `삭제`로 표시합니다.
- PR에서 설명한 용어가 장기 재사용될 용어라면 dictionary 승격 후보 또는 실제 dictionary 변경으로 이어져야 합니다.

## config 등록 규칙

`system/config/silo-projects.yaml` 프로젝트 항목은 최소 아래 필드를 포함합니다.

```yaml
- id: sample-project
  name: Sample Project
  repo_url: git@github.com:ORG/sample-project.git
  default_branch: main
  protected_branches:
    - main
  allowed_for_silo: true
  role: app
  repo_ownership:
    product_host_role:
    feature_submodule_owner:
    be_submodule_path:
    fe_submodule_path:
    harness_library_policy:
    scenario_adapter_location:
    notes:
      - task 계약이 BE/FE 독립 submodule을 요구하면 상위 제품 repo host 역할과 submodule 소유권을 기록합니다.
  db:
    uses_db: false
    schema_canonical_path:
    schema_summary_path:
    schema_apply_path:
    notes:
      - DB를 사용하면 schema 정본/요약/적용 경로를 기록합니다.
  notes:
    - projects-setup으로 등록했습니다.
```

- `repo_url`에 token, password, 개인 access key를 넣지 않습니다.
- secret provider, credential 경로, 실제 secret 값은 `00-secrets/README.md`에 계약만 적고 값을 기록하지 않습니다.
- 공용 서비스는 `allowed_for_silo: false`와 `service_policy.owner: main-orchestrator`를 명시합니다.
- 동일 id가 이미 있으면 덮어쓰지 않습니다.

## 검증

```bash
bash -n setup.sh
tmp="$(mktemp -d)"
./setup.sh --create-project-ssot --project-id sample --target "$tmp/sample-ssot" --yes
test -f "$tmp/sample-ssot/README.md"
```

생성 후 확인할 것:

- `projects/<project-id>/README.md`
- `projects/<project-id>/00-secrets/README.md`
- `projects/<project-id>/02-project-internal/00-dashboard/project-overview.md`
- `projects/<project-id>/02-project-internal/00-dashboard/work-filter.md`
- `projects/<project-id>/02-project-internal/00-dashboard/work-items.base`
- `projects/<project-id>/02-project-internal/00-dashboard/work-views.md`
- `projects/<project-id>/02-project-internal/10-dictionary/project-dictionary.md`
- `projects/<project-id>/03-silo-local/pr-description-template.md`
- `system/config/silo-projects.yaml`의 프로젝트 id 중복 없음

## 금지

- project issue, task, QA, coverage run/report 원문을 0계층 `system/`에 복사하지 않습니다.
- secret, token, password, credential 값을 문서나 config에 기록하지 않습니다.
- 보호 브랜치에서 직접 제품 코드 작업을 시작하지 않습니다.
- setup scaffold 생성 실패를 무시하고 완료로 보고하지 않습니다. 실패하면 경로/권한/기존 파일 충돌을 분리해 보고합니다.
