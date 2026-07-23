---
name: projects-setup
description: 새 프로젝트 workspace에 Project SSoT/Project Work SSoT scaffold, source/silo/shared-runtime 공간, silo project config 등록 필요 항목을 셋업해야 할 때 사용합니다.
---

# 프로젝트 셋업

이 스킬은 실제 프로젝트가 시작될 때 1계층 Project SSoT를 `<workspace>/<projectName>/01-project-ssot/`에 만들고, 2계층 Project Work SSoT scaffold를 준비합니다. 3계층 Silo Local / Test Evidence / Temporary Feedback의 실제 저장 위치는 root project scaffold 정본에 만들지 않고, 별도 silo workspace, PR 본문, 또는 project별 외부 evidence 위치로 분리합니다.

현재 `my_ochestrator`의 `main-v3/main`에는 실제 프로젝트 실데이터가 없으며, 이 스킬은 생성 규칙과 절차만 정의합니다.

## 원칙

- `<workspace>/<projectName>/01-project-ssot/`는 프로젝트 연결 정보와 Project SSoT 기준 자료의 입구입니다.
- 1계층 Project SSoT에는 project registry와 repo/source 위치, project contract, 기능/사용자 흐름별 요구사항과 runtime/DB/API/auth 계약, decision/ADR, project-level 운영 기준, 2계층 위치 index를 둡니다. repo/source 연결은 `project-registry.md`, runtime/DB/API/auth 계약은 `10-requirements/`, 아키텍처 선택과 근거는 `50-decisions/`이 소유합니다.
- 2계층 Project Work SSoT에는 1계층 요구사항을 구현하기 위한 L 기준, issue, task, QA, runbook, coverage, handoff 같은 실제 작업 운영 산출물을 둡니다.
- task/issue/QA 원문, silo local 로그, 단일 task mock data/test input, 단일 PR 임시 판단은 1계층에 두지 않습니다.
- `<workspace>/<projectName>/02-project-work-ssot/`는 2계층 Project Work SSoT입니다. 이전 `projects/<project-id>/02-project-internal/`은 호환 경로 이름으로만 남아 있을 수 있습니다. 이 안의 issue, task, QA, coverage 산출물은 0계층 `system/`이나 1계층 기준 정보로 복사하지 않습니다.
- `setup.sh --create-project-ssot`은 최소 Project SSoT/Project Work SSoT scaffold를 생성합니다. 작업 대시보드는 DataviewJS와 Obsidian Base를 기본 viewer 계약으로 포함하고, 기능 task 생성 전 확인할 1계층 `AGENTS.md`를 함께 만듭니다.
- `setup.sh --create-project-ssot`은 secret 값, credential 파일, 3계층 Silo Local 실데이터 공간을 만들지 않습니다. secret 계약이 필요하면 실제 값 없이 project registry/config의 참조나 gitignore된 local README/example 수준으로만 둡니다.
- `setup.sh --create-project-ssot`은 `system/config/silo-projects.yaml`에 프로젝트 항목을 자동 추가하지 않습니다. local config 초안 생성은 `./setup.sh --init-config --yes`, 실제 프로젝트 항목 등록은 아래 config 등록 규칙을 기준으로 별도 수동 변경으로 처리합니다.
- root scaffold 정본에는 `03-silo-local/`을 기본 생성물로 두지 않습니다. `30-work-items/silo-template/`은 사일로 시작 양식일 뿐 3계층 실제 local/evidence 저장소가 아닙니다.
- `github-project-intake`가 수집하는 `architecture/`, `issues/`, `ownership/`, `images/`, `metrics/`, `evidence/` 같은 evidence pack 주제 폴더는 현재 기본 scaffold가 아닙니다. 필요하면 project 정책이 정한 2계층 Project Work SSoT 하위 확장, 3계층 사일로/로컬 evidence, PR 본문, 또는 외부 evidence 위치로 명시하고, 기본 scaffold 추가는 별도 반복 필요가 확인된 뒤 후보로 다룹니다.
- `system/config/silo-projects.yaml`은 로컬 설정입니다. secret 값은 쓰지 않고, repo URL, 보호 브랜치, 사일로 대상 여부, DB 사용 여부, DB schema 정본/요약/적용 경로 같은 운영 값만 기록합니다.
- DB를 사용하는 프로젝트는 등록/setup 단계에서 DB schema 정본 위치 또는 schema 요약 위치를 project registry/config 또는 Project SSoT에 기록합니다. Docker, compose, migration, startup script로 DB가 자동 생성되거나 갱신되면 schema 적용 경로도 함께 기록합니다.
- 기존 `project-ssot-bootstrap` 역할은 이 스킬에 흡수되었습니다.

## 기본 구조

```text
<workspace>/
├── <projectName>/
│   ├── 01-project-ssot/
│   │   ├── project-registry.md
│   │   ├── AGENTS.md
│   │   ├── work-ssot-index.md
│   │   ├── 10-requirements/
│   │   │   └── README.md
│   │   └── 50-decisions/
│   └── 02-project-work-ssot/
│       ├── README.md
│       ├── 00-layer-index/
│       ├── .obsidian/
│       ├── 00-dashboard/
│       │   ├── kanban.md
│       │   ├── work-filter.md
│       │   ├── work-items.base
│       │   └── work-views.md
│       ├── 01-branch-policy/
│       ├── 10-dictionary/
│       ├── 20-level-criteria/
│       ├── 30-work-items/
│       │   ├── tasks/
│       │   │   ├── _templates/TASK-template.md
│       │   │   ├── todo/
│       │   │   ├── in_progress/
│       │   │   ├── blocked/
│       │   │   ├── review/
│       │   │   └── done/
│       │   ├── coverage/
│       │   └── silo-template/
│       ├── 40-runtime-sets/
│       ├── 50-pr-review/
│       ├── 60-feedback-update/
│       └── templates/
│           ├── pr-description.md
│           ├── run-report.md
│           ├── silo-goal.md
│           └── work-filter-dashboard.md
├── sources/
├── silos/
└── shared-runtime/
```

`01-project-ssot/`에는 범용 `references/`를 만들지 않습니다. runtime/DB/API/auth 계약과 정본 위치는 이를 사용하는 `10-requirements/` 문서에, 아키텍처 선택과 근거는 `50-decisions/`에, repo/source 연결은 `project-registry.md`에 기록합니다. Task/Issue/PR와 실행 증거는 2계층 Project Work SSoT, 3계층 사일로 또는 PR 본문이 소유합니다.
`02-project-work-ssot/templates/work-filter-dashboard.md`는 별도 tracked source가 아니라 `setup.sh`가 tracked `system/templates/project-ssot/00-dashboard/work-filter.md`를 target `templates/` 아래로 복사해 생성합니다.
실제 Task는 `todo`, `in_progress`, `blocked`, `review`, `done` 중 frontmatter `status`와 같은 이름의 직계 하위 디렉터리에 둡니다. 상태 변경은 파일 이동과 `status`, `updated` 갱신을 한 변경 단위로 처리하고 `ruby system/20-skills/projects-setup/scripts/validate-task-status-paths.rb <tasks-directory>`로 검증합니다. `00-dashboard/kanban.md`는 읽기 전용 DataviewJS 칸반이며 별도 Kanban 플러그인을 요구하지 않습니다.
`03-silo-local/` 같은 3계층 실제 local/evidence 디렉터리는 이 기본 구조에 포함하지 않습니다. 필요한 경우 task 실행 시 별도 silo workspace나 PR evidence 위치에서 만들고, 반복 가능한 항목만 2계층 issue/task 또는 0계층 공통 규칙 후보로 승격합니다.

이전 호환 target인 `projects/<project-id>/02-project-internal/`을 직접 지정하면 `02-project-internal/` target과 sibling `01-project-ssot/` 기준 파일을 생성합니다. project root `README.md`와 `00-secrets/README.md`는 지원 안내 파일로 생성될 수 있지만 최종 smoke 필수 확인 대상은 아닙니다. `03-silo-local/`은 기본 생성물이 아닙니다.

## 절차

1. 계층을 판정합니다. 공통 규칙 변경이면 `main-branch-update-flow`, 특정 프로젝트 자료면 Project SSoT, Project Work SSoT, 또는 project 브랜치에서 처리합니다.
2. project 기준 브랜치는 목표 모델인 `project-{projectName}/main`을 우선 사용합니다. `project-{projectName}` 자체는 namespace이며 브랜치로 만들지 않습니다. 마이그레이션 전 호환 `project-{projectName}` 또는 기존 slash 기반 `project/<project-id>` 브랜치가 있으면 전환/호환 필요 항목으로 표시하고, 어느 브랜치가 현재 기준인지 확인합니다.
3. `project-id`, 표시 이름, repo URL, default branch, 보호 브랜치, `allowed_for_silo`, `role`, 상위 제품 repo host 역할, 기능 submodule 소유권, BE/FE submodule 경로, harness library 정책, 제품별 scenario/adapter 위치, DB 사용 여부, DB schema 정본/요약/적용 경로를 확인합니다.
4. `<workspace>/<projectName>/`가 이미 있거나 `silo-projects.yaml`에 같은 id가 있으면 중단하고 병합/갱신 여부를 확인합니다.
5. `02-project-work-ssot` scaffold는 `setup.sh`로 생성합니다. 이전 `02-project-internal`은 호환 경로로만 해석합니다.
   이전 `projects/<project-id>/` 아래 target을 쓰면 `setup.sh`가 해당 Project Work SSoT 경로만 git 추적 가능하도록 `.gitignore` 예외를 함께 보정합니다.

```bash
./setup.sh --create-project-ssot \
  --project-id sample-project \
  --project-name "Sample Project" \
  --target ../sample-project/02-project-work-ssot \
  --yes
```

6. 1계층 `AGENTS.md`와 `10-requirements/`를 채웁니다. `AGENTS.md`에는 최소한 제품 정의, 현재 버전 목표/비목표, 핵심 사용자 플로우, 데이터 저장과 동기화 경계, repo 역할, task 생성 전 필수 참조, 추정 금지 정보를 확인된 값으로 적습니다. 기능/사용자 흐름별 요구사항 정본은 `10-requirements/` 아래 문서로 나누고, 확인되지 않은 항목은 빈 heading으로 방치하지 않고 `project contract 누락` 또는 `사용자 확인 필요`로 표시합니다.
7. decision/ADR 위치와 2계층 Project Work SSoT 위치 index를 생성하거나 참조합니다.
8. `<workspace>/<projectName>/01-project-ssot/`, `<workspace>/<projectName>/02-project-work-ssot/`, `<workspace>/sources/`, `<workspace>/silos/`, `<workspace>/shared-runtime/` 생성 결과를 확인합니다.
   `02-project-work-ssot/templates/pr-description.md`는 `system/40-pr-review-loop/06-pr-template.md`의 중앙 PR 본문 템플릿을 기준으로 생성됩니다.
9. `03-silo-local/` 같은 3계층 실제 local/evidence 디렉터리가 root project scaffold 기본 생성물로 생기지 않았는지 확인합니다.
10. `system/config/silo-projects.yaml`이 없으면 `./setup.sh --init-config --yes`로 local config 초안을 만듭니다. 이 명령은 예시 파일을 복사할 뿐 프로젝트 항목을 자동 추가하지 않습니다.
11. local config 등록이 필요하면 기존 구조를 보존하고 `projects:` 항목에 새 프로젝트만 수동으로 추가합니다. 같은 id가 이미 있으면 덮어쓰지 않고 병합/갱신 여부를 확인합니다.
12. 변경 후 `git diff --stat`, 생성 파일 목록, 3계층 실제 local/evidence 디렉터리 미생성 여부, config 초안 생성 여부, config 수동 등록 필요 항목, project contract 작성/누락 항목, decision/ADR 위치, Project Work SSoT 위치 index를 보고합니다.

## 필수 프로젝트 설명 산출물

모든 Project SSoT에는 프로젝트 전반 설명, project contract, 기능/사용자 흐름별 요구사항 위치, decision/ADR 위치, 2계층 Project Work SSoT 위치 index가 있어야 합니다. Project Work SSoT에는 dictionary, L 기준 위치, 작업 대시보드가 있어야 합니다.

`AGENTS.md`는 기능 task 생성 전 확인하는 1계층 Project SSoT 기준 정보이며, 제품 정의, 현재 버전 목표/비목표, 핵심 사용자 플로우, 데이터 저장과 동기화 경계, repo 역할, 추정 금지 정보를 담습니다. `10-requirements/`는 기능/사용자 흐름별 요구사항 정본을 담는 1계층 Project SSoT 위치입니다. `project-overview.md`는 프로젝트 상태와 운영 경계 요약이고, 실제 운영 첫 화면은 `work-filter.md` 또는 `work-views.md`처럼 issue/task를 필터링할 수 있는 2계층 Project Work SSoT 작업 목록입니다.

`AGENTS.md`에는 최소 아래 항목을 둡니다.

- 제품 정의
- 현재 버전 목표와 비목표
- 핵심 사용자 플로우
- 데이터 저장과 동기화 경계
- repo 역할과 금지선
- task 생성 전 필수 참조
- task 작성 규칙
- 추정 금지 정보

기능 task 템플릿과 사일로 `goal.md` 템플릿에는 `Project Contract 확인 결과`, `단계별 구현 계획`, `Pseudo Code`, `범위 drift 후보` 섹션을 둡니다. task 템플릿은 task-writer의 정식 task 필수 구조와 맞게 `배경`, `목표`, `criteria별 테스트 계약`, `자동 검증 범위`, `Pre-QA Gate`, `사용자 승인 또는 외부 의존성 blocker`, `후속 project QA gate`, `실행 불가 또는 대체 증거`, `Coverage Target 또는 Evidence Target`, `금지선`, `관련 repo/branch/silo`, `feedback/follow-up 후보`, `필요한 runtime/run set`, `PR 본문 필수 항목`도 포함합니다. `Pseudo Code`는 TypeScript/JavaScript 같은 실제 구현 코드 블록이 아니라 파일별 대표 함수 골격형으로 쓰게 안내합니다. 각 파일마다 대표 함수와 보조 함수가 어떤 입력/의존성을 받고 조회, 검증, 가공, 조건 분기, 반복, 저장, 반환을 어떻게 수행하는지 코드에 가깝게 보여야 합니다. 파일명, 함수명, API query, DB mutation, op 이름(`D/L/C/R`) 같은 식별자는 원문 그대로 쓸 수 있지만 설명 문장은 한국어로 쓰게 합니다. 단, 선언적 config, prop, default, value 한두 곳만 수정하고 별도 분기·가공·조회·저장 흐름이 없으면 `Pseudo Code`를 생략하고 대상 파일, 설정 key, 기존값 또는 누락 상태, 목표값, 회귀 검증을 변경 계약에 적게 합니다. 로직 변경이나 여러 파일 실행 흐름은 이 예외로 분류하지 않습니다. task 작성자가 project contract 위치와 확인한 항목, 누락 항목을 남기지 않으면 기능 task를 사일로 실행 대상으로 넘기지 않습니다. 실제 task mock data와 test input은 1계층 Project SSoT가 아니라 task 문서, Project Work SSoT/runbook, 또는 사일로 `goal.md`에 둡니다.

`setup.sh --create-project-ssot`이 생성하는 사일로 goal 템플릿은 `30-work-items/silo-template/goal.md`와 `templates/silo-goal.md` 모두에서 0계층 `system/30-silo-system/02-silo-goal.md`의 필수 항목을 받을 수 있어야 합니다. 최소한 원본 task/issue SSoT와 2계층 Project Work SSoT 경로, 사일로 유형, 역할 책임, Runtime Set 결정 근거, 테스트 report/window, criteria별 테스트 계약, 초기 DB 목데이터, 테스트 입력, 원본 task Output/Acceptance/Test Plan, Codex review 호출 여부, agent-browser 기준, PR 본문 필수 항목, Evidence 위치를 포함합니다. 이 항목은 실제 프로젝트 값이 아니라 사일로 실행자가 빠뜨리지 않도록 비워 둔 입력 위치입니다.

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

`00-dashboard/work-filter.md`에는 최소 아래 필터와 표시 컬럼을 둡니다.

- 종류: issue/task
- 상태: todo, in_progress, blocked, review, done, closed 등 실제 문서에 있는 상태
- 레벨: `level_target`
- 태그: `tags` 또는 파일 태그
- 담당 사일로/브랜치/PR: `owner_silo`, `branch`, `pr`
- 가설 요약: `hypothesis_attempt_count`, `hypothesis_limit_status`, `dashboard_flags`
- 실패 이력: `had_failed_run`, `resolved_by_hypothesis`
- 실패 이력 컬럼: `failed_run_count`, `resolved_attempt_no`, `latest_failed_report`, `latest_retry_report`, `blocked_reason`, `latest_resolution_summary`
- 날짜: `updated`, `created`, `closed`, `file.mtime`
- 검색어

`work-filter.md`는 `dashboardScope.paths`를 읽습니다. 기본값은 `30-work-items/issues/`, `30-work-items/tasks/`이고, 파일을 복제해 `ops/30-work-items/issues/`, `ops/30-work-items/tasks/`, `be/30-work-items/tasks/`, `fe/30-work-items/tasks/`처럼 경로를 바꾸면 프로젝트 안에 여러 작업 대시보드를 둘 수 있습니다. setup scaffold의 `templates/work-filter-dashboard.md`는 별도 tracked source template이 아니라 `setup.sh`가 tracked `system/templates/project-ssot/00-dashboard/work-filter.md`를 target `templates/` 아래로 복사해 만드는 대시보드 복제용 생성물입니다.

`00-dashboard/work-items.base`와 `00-dashboard/work-views.md`는 Obsidian 기본 Base view/filter를 쓰는 사용자를 위한 대체 화면입니다. Base에는 전체 즉석 필터, 진행 중 Task, 실패 이력 Task, 완료 Task, 열린 Issue view를 기본으로 둡니다. setup은 target이 현재 repo/vault 아래에 있으면 해당 Project SSoT 경로로 Base 필터를 제한하고, 외부 target이면 해당 SSoT를 vault root로 여는 전제의 로컬 issue 경로와 `tasks/{todo,in_progress,blocked,review,done}/`를 각각 명시한 필터를 생성합니다.
`00-dashboard/kanban.md`는 `todo`, `in_progress`, `blocked`, `review`, `done` 순서의 고정 열에서 Task ID, 제목, 우선순위, 담당 사일로, 수정일을 보여주고 원문 Task로 연결합니다. 칸반에서 직접 상태를 변경하지 않습니다.
run report 템플릿은 `30-work-items/coverage/RUN-REPORT-template.md`와 `templates/run-report.md`에 생성합니다. 두 템플릿은 `had_failed_run`, `resolved_by_hypothesis`, `failed_run_count`, `resolved_attempt_no`, `latest_failed_report`, `latest_retry_report`, `linked_task`, `blocked_reason`, `latest_resolution_summary`를 포함해야 합니다.

`20-level-criteria/`에는 프로젝트의 단계별 채점 기준, runner 계약, report 위치, evidence 위치를 기록합니다. setup scaffold는 `README.md`와 `LEVEL-CRITERIA-template.md`를 생성하고, 실제 프로젝트별 L 기준 문서는 이 위치에서 작성합니다.

작업 대시보드는 실제 issue/task만 보여야 하므로 `30-work-items/issues/ISSUE-template.md`, `30-work-items/tasks/_templates/TASK-template.md` 같은 템플릿 파일은 필터 결과에서 제외합니다.

작업 대시보드가 비지 않으려면 setup scaffold가 만드는 issue/task 템플릿에 최소 frontmatter가 있어야 합니다.

- issue: `type: issue`, `id`, `issueID`, `issueTitle`, `title`, `status`, `severity`, `level_target`, `updated`
- task: `type: task`, `id`, `taskID`, `taskTitle`, `title`, `status`, `priority`, `level_target`, `created`, `updated`, `closed`, `had_failed_run`, `resolved_by_hypothesis`, `failed_run_count`, `resolved_attempt_no`, `latest_failed_report`, `latest_retry_report`, `blocked_reason`, `latest_resolution_summary`

`id`와 `title`은 기존 문서 호환 필드이고, 새 문서는 `issueID`/`issueTitle`, `taskID`/`taskTitle`을 우선 사용합니다. 파일명이나 H1에 식별자를 합치지 않고, 대시보드는 ID와 제목을 별도 컬럼으로 보여줍니다.

생성되는 task 템플릿은 task-writer의 정식 task 필수 구조와 `parallel_independence_contract` frontmatter, `병렬 task 독립성 계약` 본문 섹션을 포함해야 합니다. 병렬로 생성하거나 실행할 task는 sibling task 완료를 Output, Acceptance Criteria, Test Plan의 전제로 두지 않고, 인증/데이터/화면/backend 의존성이 있으면 agent가 통제할 수 있는 대체 검증 경로와 실제 사용자 경로의 차이를 적습니다. 여러 sibling task 완료를 전제로 하는 최종 통합 E2E는 개별 task acceptance가 아니라 별도 QA gate, integration task, 또는 후속 project 검증으로 분리합니다. 단일 task의 화면 동작 자체가 산출물이면 E2E 또는 agent-browser acceptance를 유지합니다. 필요한 runtime/run set과 PR 본문 필수 항목도 task 계약에 남기고, provider별 절차, L 단계 이름, fixture/harness 구현 방식, merge 전 세부 QA gate는 Project Work SSoT/runbook 또는 task 계약을 참조합니다. 1계층 Project SSoT에는 반복 가능한 정본 위치와 하위 SSoT 인덱스만 둡니다.

DataviewJS 대시보드를 쓰려면 Obsidian community plugin `dataview`를 설치하고 DataviewJS 실행을 허용해야 합니다. scaffold는 `.obsidian/community-plugins.json`에 `dataview`를 선언하고, Base 대체 뷰를 위해 `work-items.base`를 함께 생성합니다.

`10-dictionary/project-dictionary.md`에는 프로젝트에서 쓰는 용어, 고유명사, 내부 약어, runner 용어, coverage 용어를 기록합니다. 최소 필드는 아래와 같습니다.

| 필드 | 설명 |
|---|---|
| 용어/고유명사/내부 약어 | 프로젝트에서 실제 쓰는 이름 |
| 뜻 | 처음 보는 사람이 이해할 수 있는 정의 |
| 사용 맥락 | 어느 workflow, repo, runner, 화면, 문서에서 쓰는지 |
| 예시 | 실제 표현이나 page/item 예시 |
| 출처 또는 확인 상태 | source 문서, PR, 사용자 확인, 추정 여부 |
| 프로젝트 전용인지 공통 승격 후보인지 | project-local 용어인지, root `main-v3/main` 공통 규칙 후보인지 |

PR 본문 `명사 설명`에 반복해서 등장한 용어는 project dictionary 승격 후보로 남깁니다. 여러 프로젝트에서 반복되거나 에이전트 공통 행동 규칙에 영향을 주는 용어만 root `main-v3/main` 공통 dictionary 또는 관련 system 문서 승격 후보로 분리합니다.

Project dictionary 파일을 새로 만들거나 기존 dictionary에 용어를 추가/수정/삭제하는 PR은 PR 본문에 `새로 추가된 단어` 섹션을 둡니다.

- `명사 설명`은 해당 PR을 이해하기 위한 즉시 설명입니다.
- `새로 추가된 단어`는 project dictionary SSoT에 실제 추가/수정/삭제된 용어 목록입니다.
- 최소 컬럼은 `변경 유형`, `용어`, `뜻`, `사용 맥락`, `프로젝트 전용/공통 후보`, `dictionary 위치`입니다.
- 신규 추가만 있으면 `변경 유형`을 `추가`로 적고, 수정/삭제가 있으면 같은 컬럼에 `수정` 또는 `삭제`로 표시합니다.
- PR에서 설명한 용어가 장기 재사용될 용어라면 dictionary 승격 후보 또는 실제 dictionary 변경으로 이어져야 합니다.

## config 등록 규칙

`system/config/silo-projects.yaml` 프로젝트 항목은 local config를 별도로 등록할 때 최소 아래 필드를 포함합니다. `setup.sh --create-project-ssot`은 이 항목을 자동 생성하지 않습니다.

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
- secret provider, credential 경로, 실제 secret 값은 Project SSoT 또는 local config에 계약만 적고 값을 기록하지 않습니다.
- 공용 서비스는 `allowed_for_silo: false`와 `service_policy.owner: main-orchestrator`를 명시합니다.
- 동일 id가 이미 있으면 덮어쓰지 않습니다.

## 검증

아래 smoke 검증은 `setup.sh --quickstart`가 현재 자동 생성하는 Project SSoT/Project Work SSoT scaffold와 workspace 지원 디렉터리를 실제 파일/디렉터리 기준으로 확인합니다. 이 명령이 성공했다고 해서 `system/config/silo-projects.yaml` 등록 중복, project root 안내 문서, `00-secrets/`, `03-silo-local/` 같은 smoke 밖 수동 산출물까지 검증된 것으로 보고하지 않습니다.

```bash
set -e
bash -n setup.sh
tmp="$(mktemp -d)"
./setup.sh --quickstart --project-name sample --workspace-root "$tmp" --yes
test -f "$tmp/sample/01-project-ssot/project-registry.md"
test -f "$tmp/sample/01-project-ssot/AGENTS.md"
test -f "$tmp/sample/01-project-ssot/work-ssot-index.md"
test -f "$tmp/sample/01-project-ssot/10-requirements/README.md"
test -d "$tmp/sample/01-project-ssot/50-decisions"
test ! -e "$tmp/sample/01-project-ssot/references"
test -f "$tmp/sample/02-project-work-ssot/README.md"
test -f "$tmp/sample/02-project-work-ssot/00-layer-index/README.md"
test -f "$tmp/sample/02-project-work-ssot/01-branch-policy/README.md"
test -f "$tmp/sample/02-project-work-ssot/00-dashboard/project-overview.md"
test -f "$tmp/sample/02-project-work-ssot/00-dashboard/kanban.md"
test -f "$tmp/sample/02-project-work-ssot/00-dashboard/work-filter.md"
test -f "$tmp/sample/02-project-work-ssot/00-dashboard/work-items.base"
test -f "$tmp/sample/02-project-work-ssot/00-dashboard/work-views.md"
test -f "$tmp/sample/02-project-work-ssot/10-dictionary/project-dictionary.md"
for status in todo in_progress blocked review done; do
  test -d "$tmp/sample/02-project-work-ssot/30-work-items/tasks/$status"
done
test -f "$tmp/sample/02-project-work-ssot/30-work-items/tasks/_templates/TASK-template.md"
ruby system/20-skills/projects-setup/scripts/validate-task-status-paths.rb "$tmp/sample/02-project-work-ssot/30-work-items/tasks"
test -f "$tmp/sample/02-project-work-ssot/30-work-items/coverage/RUN-REPORT-template.md"
test -f "$tmp/sample/02-project-work-ssot/30-work-items/silo-template/goal.md"
test -d "$tmp/sample/02-project-work-ssot/30-work-items/silo-template/evidence"
test -f "$tmp/sample/02-project-work-ssot/40-runtime-sets/README.md"
test -f "$tmp/sample/02-project-work-ssot/40-runtime-sets/runtime-resolution.md"
test -f "$tmp/sample/02-project-work-ssot/50-pr-review/README.md"
test -f "$tmp/sample/02-project-work-ssot/60-feedback-update/README.md"
test -f "$tmp/sample/02-project-work-ssot/templates/run-report.md"
test -f "$tmp/sample/02-project-work-ssot/templates/silo-goal.md"
test -f "$tmp/sample/02-project-work-ssot/templates/pr-description.md"
test -f "$tmp/sample/02-project-work-ssot/templates/work-filter-dashboard.md"
cmp -s system/templates/project-ssot/00-dashboard/work-filter.md "$tmp/sample/02-project-work-ssot/templates/work-filter-dashboard.md"
test -f "$tmp/sample/02-project-work-ssot/.obsidian/community-plugins.json"
test -f "$tmp/sample/02-project-work-ssot/.obsidian/core-plugins.json"
test -f "$tmp/sample/02-project-work-ssot/.obsidian/appearance.json"
test -f "$tmp/sample/02-project-work-ssot/.obsidian/snippets/readable-markdown-width.css"
test -d "$tmp/sources"
test -d "$tmp/silos"
test -d "$tmp/shared-runtime"
```

필수 생성물 검증 범위:

- 자동 smoke 검증 범위는 위 `test` 명령에 명시된 1계층 Project SSoT와 2계층 Project Work SSoT scaffold입니다.
- `system/config/silo-projects.yaml`의 프로젝트 id 중복 여부는 `--init-config` 또는 실제 등록 작업에서 별도로 확인합니다. 현재 repo의 local config를 오염시키지 않도록 임시 repo에서 `--init-config`를 실행하거나, 기존 config가 있으면 중복 id를 직접 대조합니다.
- project root 안내 문서, `00-secrets/`, `03-silo-local/` 같은 지원/로컬 안내 산출물을 필수 완료 조건으로 삼는 작업은 생성 여부를 별도 `test -f`로 확인하거나 `setup.sh` scaffold 정책을 먼저 확장합니다.
- 검증 목록에 새 필수 생성물을 추가할 때는 같은 섹션의 smoke 명령에 자동 검증을 함께 추가하거나, smoke 밖 수동 확인 대상으로 명시합니다.

local config 초안까지 검증해야 하는 작업이면 repo checkout 안에서 아래를 별도로 확인합니다.

```bash
./setup.sh --init-config --yes
test -f system/config/silo-projects.yaml
rg -n '^projects:' system/config/silo-projects.yaml
```

현재 브랜치의 기본 구조가 project root 안내, secret 경계, 3계층 silo local 안내 생성을 요구한다면 아래를 별도 policy gate로 확인합니다. 이 test가 실패하면 검증을 줄이지 말고 `setup.sh` scaffold 정책 또는 skill의 기본 구조 요구 중 하나를 먼저 정정합니다.

```bash
test -f "$tmp/sample/README.md"
test -f "$tmp/sample/00-secrets/README.md"
test -f "$tmp/sample/03-silo-local/pr-description-template.md"
```

`setup.sh --create-project-ssot`의 최종 summary에서 `Project SSoT 생성 파일 확인:` 아래 핵심 생성 파일이 `ok`로 표시되는지 함께 확인합니다. 이 summary는 실제 `--target`과 파생된 1계층 target을 기준으로 검증합니다.

위 임시 target scaffold에서 확인할 것:

- `<workspace>/<projectName>/01-project-ssot/AGENTS.md`
- `<workspace>/<projectName>/01-project-ssot/project-registry.md`
- `<workspace>/<projectName>/01-project-ssot/work-ssot-index.md`
- `<workspace>/<projectName>/02-project-work-ssot/00-layer-index/README.md`
- `<workspace>/<projectName>/02-project-work-ssot/00-dashboard/project-overview.md`
- `<workspace>/<projectName>/02-project-work-ssot/00-dashboard/kanban.md`
- `<workspace>/<projectName>/02-project-work-ssot/00-dashboard/work-filter.md`
- `<workspace>/<projectName>/02-project-work-ssot/00-dashboard/work-items.base`
- `<workspace>/<projectName>/02-project-work-ssot/00-dashboard/work-views.md`
- `<workspace>/<projectName>/02-project-work-ssot/01-branch-policy/README.md`
- `<workspace>/<projectName>/02-project-work-ssot/.obsidian/community-plugins.json`
- `<workspace>/<projectName>/02-project-work-ssot/.obsidian/core-plugins.json`
- `<workspace>/<projectName>/02-project-work-ssot/.obsidian/appearance.json`
- `<workspace>/<projectName>/02-project-work-ssot/.obsidian/snippets/readable-markdown-width.css`
- `<workspace>/<projectName>/02-project-work-ssot/10-dictionary/project-dictionary.md`
- `<workspace>/<projectName>/02-project-work-ssot/30-work-items/tasks/_templates/TASK-template.md`
- `<workspace>/<projectName>/02-project-work-ssot/30-work-items/tasks/{todo,in_progress,blocked,review,done}/`
- Task 파일의 직계 상위 디렉터리와 frontmatter `status` 일치
- `<workspace>/<projectName>/02-project-work-ssot/30-work-items/coverage/RUN-REPORT-template.md`
- `<workspace>/<projectName>/02-project-work-ssot/30-work-items/silo-template/goal.md`
- `<workspace>/<projectName>/02-project-work-ssot/30-work-items/silo-template/goal.md`의 원본 task/issue SSoT, Runtime Set 결정 근거, criteria별 테스트 계약, Codex review, agent-browser 기준 입력 위치
- `<workspace>/<projectName>/02-project-work-ssot/40-runtime-sets/README.md`
- `<workspace>/<projectName>/02-project-work-ssot/40-runtime-sets/runtime-resolution.md`
- `<workspace>/<projectName>/02-project-work-ssot/50-pr-review/README.md`
- `<workspace>/<projectName>/02-project-work-ssot/60-feedback-update/README.md`
- `<workspace>/<projectName>/02-project-work-ssot/templates/run-report.md`
- `<workspace>/<projectName>/02-project-work-ssot/templates/silo-goal.md`
- `<workspace>/<projectName>/02-project-work-ssot/templates/silo-goal.md`의 원본 task/issue SSoT, Runtime Set 결정 근거, criteria별 테스트 계약, Codex review, agent-browser 기준 입력 위치
- `<workspace>/<projectName>/02-project-work-ssot/templates/pr-description.md`
- `<workspace>/<projectName>/02-project-work-ssot/templates/work-filter-dashboard.md`
- `<workspace>/<projectName>/02-project-work-ssot/templates/work-filter-dashboard.md`가 `system/templates/project-ssot/00-dashboard/work-filter.md`와 동일한 복사본인지
- `<workspace>/sources/`
- `<workspace>/silos/`
- `<workspace>/shared-runtime/`
- 3계층 silo local/evidence 디렉터리가 root project scaffold 기본 생성물로 생기지 않았는지
- local config를 수동 등록했다면 `system/config/silo-projects.yaml`의 프로젝트 id 중복 없음

현재 `setup.sh --create-project-ssot` smoke 검증은 지정한 Project Work SSoT target과 sibling `01-project-ssot/` 생성물을 확인합니다. `projects/<project-id>/README.md`와 `00-secrets/README.md`는 지원 안내 파일로 생성될 수 있지만 현재 기본 smoke 확인 대상은 아닙니다. `03-silo-local/pr-description-template.md`는 기본 생성물로 요구하지 않습니다.

## 금지

- project issue, task, QA, coverage run/report 원문을 0계층 `system/`이나 1계층 Project SSoT 기준 정보에 복사하지 않습니다.
- secret, token, password, credential 값을 문서나 config에 기록하지 않습니다.
- 보호 브랜치에서 직접 제품 코드 작업을 시작하지 않습니다.
- setup scaffold 생성 실패를 무시하고 완료로 보고하지 않습니다. 실패하면 경로/권한/기존 파일 충돌을 분리해 보고합니다.
