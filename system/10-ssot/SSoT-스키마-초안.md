# SSoT 스키마 초안

## 목적

SSoT는 메인 오케스트레이터와 모든 사일로가 공유하는 상태와 규칙의 원본입니다.

SSoT는 다음을 저장해야 합니다.

- 사용자별 상태를 저장하지 않는 공통 판단 기준과 User Layer 연계 규칙
- 프로젝트 등록과 SSoT 위치
- 프로젝트별 shared runtime registry/status 위치
- project contract와 decision/ADR 위치
- 2계층 Project Work SSoT 위치 index
- 계층별 저장 위치
- 사일로 생성 정책
- PR 리뷰와 승격 판단 정책
- 사용자 피드백/퍼스널리티 갱신을 User Layer 정본으로 라우팅하는 schema, template, guard rule

## 권장 구조

0계층 SSoT는 프로젝트별 운영 구조를 직접 담지 않고, 여러 프로젝트에 공통으로 적용할 규칙과 템플릿을 둡니다.

현재 `my_ochestrator`의 `main-v3/main`에는 실제 프로젝트 실데이터가 없습니다. 아래 구조는 실제 프로젝트가 시작된 뒤 만들 1계층 Project SSoT와 2계층 Project Work SSoT의 기준 스키마입니다.

```text
ssot/
├── context.md
├── layer-policy.md
├── user-layer-routing/
│   ├── 공통-판단-기준.md
│   ├── 응답-보고-규칙.md
│   └── user-layer-연계-가드.md
├── projects/
│   └── <project-id>/
│       ├── project-registry.md
│       ├── ssot-location.md
│       ├── repo-links.md
│       ├── protected-branches.md
│       ├── shared-runtime-registry.md
│       ├── service-policy.md
│       ├── AGENTS.md
│       ├── decisions/
│       └── work-ssot-index.md
├── templates/
│   ├── 이슈.md
│   ├── 태스크.md
│   ├── 사일로.md
│   ├── PR-description.md
│   └── 피드백.md
└── decisions/
```

1계층 Project SSoT는 실제 프로젝트가 시작된 뒤 생기는 프로젝트 기준 정보입니다. `setup.sh --create-project-ssot`의 현재 정본 scaffold에서는 target이 `02-project-internal`로 끝날 때 sibling 경로인 `../01-project-ssot/`을 1계층 위치로 만듭니다. 그 외 target이면 `<target>/01-project-ssot/`을 1계층 위치로 만듭니다.

```text
projects/<project-id>/
└── 01-project-ssot/
    ├── README.md
    ├── project-registry.md
    ├── AGENTS.md
    ├── work-ssot-index.md
    ├── 10-requirements/
    │   ├── README.md
    │   └── 기능 또는 사용자 흐름별 요구사항
    └── 50-decisions/
        └── ADR 또는 decision 기록
```

2계층 Project Work SSoT는 1계층 기능 요구사항을 구현하기 위한 task/issue/QA/runbook/coverage처럼 실제 작업 운영 자료를 담습니다. `setup.sh --create-project-ssot`의 현재 정본 scaffold에서는 `projects/<project-id>/02-project-internal/`을 호환 경로 이름으로 쓰며, 의미상 이 경로가 2계층 Project Work SSoT입니다.

```text
project-work-ssot/
├── 00-layer-index/
│   └── README.md
├── 00-dashboard/
│   ├── project-overview.md
│   ├── kanban.md
│   ├── work-filter.md
│   ├── work-items.base
│   └── work-views.md
├── 01-branch-policy/
│   └── README.md
├── .obsidian/
│   ├── community-plugins.json
│   ├── core-plugins.json
│   ├── appearance.json
│   └── snippets/
│       └── readable-markdown-width.css
├── 10-dictionary/
│   ├── README.md
│   └── project-dictionary.md
├── 20-level-criteria/
│   ├── README.md
│   └── LEVEL-CRITERIA-template.md
├── 30-work-items/
│   ├── issues/
│   │   └── 이슈 관리
│   ├── tasks/
│   │   ├── _templates/
│   │   │   └── TASK-template.md
│   │   ├── todo/
│   │   ├── in_progress/
│   │   ├── blocked/
│   │   ├── review/
│   │   └── done/
│   ├── runbooks/
│   ├── handoff/
│   ├── coverage/
│   │   └── RUN-REPORT-template.md
│   └── silo-template/
│       ├── goal.md
│       └── evidence/
├── 40-runtime-sets/
│   ├── README.md
│   └── runtime-resolution.md
├── 50-pr-review/
│   └── README.md
├── 60-feedback-update/
│   ├── README.md
│   └── feedback/
│       ├── active/
│       ├── applied/
│       └── closed/
└── templates/
    ├── run-report.md
    ├── silo-goal.md
    ├── pr-description.md
    └── work-filter-dashboard.md
```

이 구조는 `setup.sh --create-project-ssot`이 생성하는 Project Work SSoT 기본 운영 폴더와 핵심 파일을 보여주는 대표 구조입니다. 전체 생성 파일 목록은 `setup.sh` 생성 흐름과 각 target에 생성되는 README, template 파일을 기준으로 확인합니다. 최소 필수 구성은 작업 대시보드, issue/task/runbook/handoff/coverage, runtime set 정의, PR review gate, feedback 상태 관리입니다. 프로젝트 특성에 따라 QA, coverage, runbook, report, handoff 영역을 더 둘 수 있습니다. 기능/사용자 흐름별 요구사항과 decision/ADR은 1계층 Project SSoT 기준 정보에 두고, 그 요구사항을 구현하기 위한 issue/task와 task 실행 중 임시 판단이나 단일 PR 판단은 2계층 Project Work SSoT, 3계층 사일로, 또는 PR 본문에 둡니다.

기본 scaffold는 `30-work-items/tasks/_templates/TASK-template.md`와 함께 `30-work-items/coverage/RUN-REPORT-template.md`, `templates/run-report.md`를 생성합니다. 실제 Task는 `todo`, `in_progress`, `blocked`, `review`, `done` 중 frontmatter `status`와 같은 이름의 직계 하위 디렉터리에 둡니다. 상태를 바꿀 때는 파일 이동과 `status`, `updated` 갱신을 한 변경 단위로 처리합니다. 두 run report 템플릿은 `had_failed_run`, `resolved_by_hypothesis`, `failed_run_count`, `resolved_attempt_no`, `latest_failed_report`, `latest_retry_report`, `linked_task`, `blocked_reason`, `latest_resolution_summary`를 포함해야 합니다.

0계층 `system/`은 위 구조가 필요하다는 규칙, `setup.sh` 생성 흐름, 공통 템플릿 조각만 관리합니다. `system/templates/project-ssot/`에는 `setup.sh`가 복사하는 파일 템플릿만 두고, 프로젝트별 값이 들어가거나 생성 시점에 조립되는 파일은 `setup.sh --create-project-ssot`이 target Project SSoT 또는 Project Work SSoT에 만듭니다. 특정 프로젝트의 기능/사용자 흐름별 요구사항 원문은 1계층 Project SSoT에 두고, 그 요구사항을 구현하기 위한 실제 태스크, 이슈, QA 원문, L runner 결과, page 목록, coverage report, runbook, 대시보드/보고서 내용은 Project Work SSoT에 둡니다. 0계층에는 어느 원문도 복사하지 않습니다.

`projects/`는 제품 소스코드 저장소가 아닙니다. `projects/`에는 Project SSoT, registry, repo 연결 정보, 보호 브랜치, service policy, 2계층 위치 index처럼 프로젝트 운영 상태를 찾기 위한 기준 자료만 둡니다.

실제 제품 소스코드는 `.gitignore`된 `sources/` 같은 외부/로컬 소스 위치, 별도 repo/worktree, fork, submodule, external clone에 둡니다.

task 계약이 BE/FE 독립 git submodule을 요구하면 상위 제품 repo를 BE와 FE의 두 gitlink를 둔 submodule host로만 기록합니다. 상위 제품 repo 변경은 `.gitmodules`, gitlink, 빌드/보안 제외 설정 같은 host 연결 변경으로 제한하고, 제품 BE/FE 구현 변경은 각 독립 submodule repo의 task branch와 PR에서 관리합니다. BE/FE/page/harness-scenario를 단일 기능 repo로 묶는 것은 task 계약이 그렇게 명시한 경우에만 허용합니다. Project SSoT에는 기능 repo/submodule의 소유권, 기준 브랜치, PR target, 상위 제품 repo에서 허용되는 최소 변경 범위를 참조로 남기고, task별 구현 계약은 Project Work SSoT에 둡니다.

`vite-harness` 계열 repo는 재사용 하네스 라이브러리로 분류합니다. task별 제품 시나리오, seed, demo, adapter는 하네스 원본 repo에 두지 않고 task 계약이 지정한 기능 submodule repo 또는 Project Work SSoT에 둡니다. 0계층 SSoT는 이 분리 원칙과 참조 필드만 정의하며, 특정 제품의 시나리오 원문은 저장하지 않습니다.

여러 task silo가 함께 참조하는 runtime checkout은 shared runtime으로 분리할 수 있습니다. shared runtime은 workspace root 아래 공용 실행 repo 묶음이며, task silo가 직접 소유하지 않고 참조합니다. 새 기본 경로 후보는 `<workspace>/shared-runtime/<runtime-name>/`입니다. 이전 다중 프로젝트 workspace나 호환 설정에서는 `shared-runtime/<project-id>/<runtime-name>/`을 사용할 수 있습니다. 프로젝트별 실제 runtime 구성과 registry/status는 Project SSoT, project registry/config, Project Work SSoT 참조, 또는 gitignore된 local config에 둡니다.

프로젝트별 test evidence는 coverage 판단 근거이므로 Project Work SSoT 내부에 보존할 수 있습니다. 단, test evidence 원본이 대용량 영상, trace, runner output, 제품 소스코드인 경우에는 Project Work SSoT에 위치와 요약을 남기고 원본은 프로젝트 정책에 맞는 외부/로컬 저장 위치에 둡니다.

## 주요 엔티티

## Project SSoT와 Project Work SSoT 최소 필수 구성

Project SSoT를 만들거나 점검할 때는 프로젝트별 실제 내용과 무관하게 아래 기준 정보가 있어야 합니다.

| 필수 구성 | 역할 | 저장 계층 |
|---|---|---|
| project registry | 프로젝트 id, 이름, repo/source 위치, 보호 브랜치, config 참조를 관리한다. | 1계층 Project SSoT |
| project contract | 제품 정의, 현재 버전 목표/비목표, 핵심 사용자 플로우, 데이터 경계, repo 역할, 추정 금지 정보를 관리한다. | 1계층 Project SSoT |
| 기능/사용자 흐름별 요구사항 | 기능 요구사항, 사용자 흐름 요구사항, acceptance 기준처럼 여러 task가 구현 근거로 삼는 요구사항 정본을 관리한다. | 1계층 Project SSoT |
| decision/ADR | 장기 유지할 프로젝트 의사결정과 채택/폐기 근거를 관리한다. | 1계층 Project SSoT |
| runtime / DB / API / auth 계약 | 실제 값이 아니라 정본 위치, 적용 경로, 접근 정책을 해당 기능 또는 사용자 흐름의 `10-requirements/` 문서에서 관리한다. | 1계층 Project SSoT |
| 2계층 위치 index | task/issue/QA/runbook/coverage가 어디에 있는지 연결한다. | 1계층 Project SSoT |

Project Work SSoT를 만들거나 점검할 때는 아래 일곱 가지 구조가 있어야 합니다.

| 필수 구성 | 역할 | 저장 계층 |
|---|---|---|
| 이슈 생성/관리 | 1계층 요구사항을 구현하거나 검증하는 과정에서 발견한 문제, 원인 가설, 영향, 연결 Task를 추적한다. | 2계층 Project Work SSoT |
| 태스크 생성/관리 | 1계층 요구사항을 실제 수행 가능한 작업 단위로 내리고 상태, 완료 조건, 검증 결과를 추적한다. | 2계층 Project Work SSoT |
| L 기준 생성/관리 | 프로젝트의 단계별 채점 기준, runner 계약, report 위치를 명시한다. | 2계층 Project Work SSoT |
| 대시보드 | 사람이 현재 상태, 활성 Task, 활성 Issue, 다음 행동을 한 화면에서 필터링해 확인한다. | 2계층 Project Work SSoT |
| runtime set 정의 | task, QA, runbook이 참조할 runtime set 선택 우선순위와 공통 runtime set 후보를 관리한다. | 2계층 Project Work SSoT |
| PR review gate | PR target/base, 리뷰 목표, Codex review 호출 가능 여부, test evidence 기준을 기록한다. | 2계층 Project Work SSoT |
| feedback 상태 관리 | 운영 중 발견한 feedback을 active, applied, closed 상태로 분리해 추적한다. | 2계층 Project Work SSoT |

0계층 `system/`은 위 구조가 필요하다는 규칙, 템플릿, `setup.sh` 셋업 흐름만 관리합니다. 현재 scaffold 기준으로 특정 프로젝트의 기능 요구사항 원문은 `01-project-ssot/` 아래 1계층에 두고, 실제 Task, Issue, QA 원문, L runner 결과, page 목록, report 내용은 `02-project-internal/` 아래 2계층 Project Work SSoT에 둡니다.

Project Work SSoT의 `00-dashboard/`는 단순 설명 문서만 두지 않습니다. 기본 scaffold는 아래 일곱 파일을 생성해야 합니다.

- `project-overview.md`: 프로젝트 목적, 위치, 운영 경계, 다음 행동을 설명합니다.
- `kanban.md`: `todo`, `in_progress`, `blocked`, `review`, `done`을 고정 열로 보여주는 읽기 전용 DataviewJS Task 칸반입니다. 별도 Kanban 플러그인은 요구하지 않습니다.
- `work-filter.md`: issue/task를 종류, 상태, 레벨, 태그, 날짜, 검색어로 즉석 필터링하는 DataviewJS 대시보드입니다.
- `work-items.base`: Obsidian Base에서 사용할 기본 table view와 저장된 view입니다. setup은 target이 현재 repo/vault 아래에 있으면 해당 Project SSoT 경로로 Base 필터를 제한하고, 외부 target이면 해당 SSoT를 vault root로 여는 전제의 로컬 issue 경로와 `tasks/{todo,in_progress,blocked,review,done}/` 필터를 생성합니다.
- `work-views.md`: Obsidian Base 사용법과 `work-items.base` embed를 둔 안내 문서입니다.
- `.obsidian/community-plugins.json`: DataviewJS 대시보드를 위한 `dataview` community plugin 선언입니다. 실제 플러그인 설치와 DataviewJS 허용은 Obsidian 앱에서 확인합니다.
- `templates/work-filter-dashboard.md`: 같은 프로젝트 안에서 BE, FE, ops처럼 경로별 작업 대시보드를 추가할 때 복제하는 템플릿입니다. 별도 tracked source가 아니라 `setup.sh`가 tracked `system/templates/project-ssot/00-dashboard/work-filter.md`를 target `templates/` 아래로 복사해 생성합니다.

Project Work SSoT의 `20-level-criteria/`는 L 기준 생성/관리 위치입니다. 기본 scaffold는 `README.md`와 `LEVEL-CRITERIA-template.md`를 생성하고, 템플릿에는 단계별 채점 기준, runner 계약, report 위치, evidence 위치를 적을 수 있어야 합니다.

대시보드의 기본 첫 화면은 `project-overview.md`의 정적 표가 아니라 `kanban.md`, `work-filter.md`, `work-views.md`처럼 실제 Task 흐름과 issue/task 목록을 확인할 수 있는 작업 화면이어야 합니다. 프로젝트 설명은 overview에 두되, 운영자가 지금 볼 화면은 칸반과 필터 가능한 작업 대시보드로 연결합니다.

`work-filter.md`는 frontmatter의 `dashboardScope.paths`를 기준으로 수집 경로를 정합니다. 기본값은 `30-work-items/issues/`, `30-work-items/tasks/`입니다. 한 프로젝트 안에서 여러 작업 흐름을 분리해야 하면 대시보드 파일을 복제하고 `dashboardTitle`, `dashboardScope.paths`만 바꿉니다. 예를 들어 한 프로젝트의 BE와 FE가 별도 source/workflow를 갖는다면 각각 `be/30-work-items/tasks/`, `fe/30-work-items/tasks/` 또는 프로젝트가 정한 경로를 scope로 둔 대시보드를 만들 수 있습니다. 같은 task/issue 풀을 공유하고 싶으면 별도 대시보드를 만들지 않고 기본 대시보드를 사용합니다. 기본 대시보드는 실패 이력이 있는 task를 `had_failed_run`, `resolved_by_hypothesis`로 필터링하고 최근 실패/재시도/차단 사유를 `latest_failed_report`, `latest_retry_report`, `blocked_reason`, `latest_resolution_summary` 컬럼으로 보여야 합니다.

기본 dashboard는 task schema의 모든 원문 필드를 무조건 넓은 표로 펼치지 않습니다. 실행 소유권과 추적 위치는 `owner_silo`, `branch`, `pr`, `promotion_status`를 필터 또는 표시 컬럼으로 제공하고, 가설 원문인 `hypothesis_chain`은 상세 문서에 남깁니다. dashboard에는 `hypothesis_attempt_count`, `hypothesis_limit_status`, `dashboard_flags`처럼 스캔 가능한 요약 필드를 표시하거나 필터로 제공합니다. 실패 이력은 `had_failed_run`, `resolved_by_hypothesis`, `failed_run_count`, `resolved_attempt_no`, `latest_resolution_summary`를 필터 또는 표시 컬럼으로 제공합니다.

대시보드는 실제 작업 항목만 집계해야 합니다. `30-work-items/issues/ISSUE-template.md`, `30-work-items/tasks/_templates/TASK-template.md`처럼 템플릿 위치에 있는 파일은 frontmatter가 있더라도 작업 목록에서 제외합니다.

필터 대시보드가 동작하려면 issue/task 문서에 최소 frontmatter가 있어야 합니다.

- issue: `type: issue`, `id`, `issueID`, `issueTitle`, `title`, `status`, `severity`, `updated`
- task: `type: task`, `id`, `taskID`, `taskTitle`, `title`, `status`, `priority`, `created`, `updated`, `closed`

파일명과 문서 제목은 사람이 읽는 이름을 우선하고, 식별자와 제목은 frontmatter에서 분리합니다. 새 issue는 `issueID`와 `issueTitle`, 새 task는 `taskID`와 `taskTitle`을 우선 사용합니다. `id`와 `title`은 기존 문서 호환 필드로 유지합니다. 대시보드는 ID와 제목을 별도 컬럼으로 보여야 합니다.

위 목록은 대시보드가 비지 않기 위한 최소 표시 필드입니다. `setup.sh --create-project-ssot`의 task scaffold는 이 최소 표시 필드에 더해 아래 Task 스키마의 필수/권장 구조화 필드를 포함해야 합니다.

### Issue

버그, 문제, 개선 필요점입니다.

Issue는 0계층 SSoT나 1계층 Project SSoT가 아니라 2계층 Project Work SSoT에 저장합니다.

필드:

- id
- issueID
- issueTitle
- title
- source
- status
- severity
- evidence
- reproduction
- affected_projects
- related_tasks
- promoted_from_silo
- promotion_status
- updated: 생성일이 아니라 이슈 상태, 증거, 재현 정보, 연결 Task가 마지막으로 수정된 날짜입니다. `created`가 있으면 최초 생성일은 `created`로 분리합니다.

### Task

실제로 수행 가능한 작업 단위입니다.

Task는 0계층 SSoT나 1계층 Project SSoT가 아니라 2계층 Project Work SSoT에 저장합니다.

`main-v3/main`에서는 Task가 처음부터 완전한 계약일 필요가 없습니다. 작은 build 실험으로 시작하고, 실행 후 관찰한 learn 결과를 acceptance criteria, test plan, follow-up spec으로 승격할 수 있습니다.

Task 문서의 제목은 사람이 읽는 작업 목표나 문제 이름으로 작성합니다. `TASK-NNNN` 또는 `TASK-NNNNN` 같은 식별자는 제목에 합치지 않고 별도 `ID` 섹션이나 `id` 필드에 둡니다. 이렇게 해야 대시보드와 문서 목록에서 작업 의미와 식별자를 각각 안정적으로 읽을 수 있습니다.

모든 task 명세서는 읽고 실행 범위를 파악하는 시간이 기본 5분을 넘지 않도록 작성합니다. 최대 허용치는 7분입니다. 7분을 넘길 분량이면 task를 분할하거나, 상단에 5분 이내로 읽을 수 있는 실행 요약, 금지선, acceptance criteria, test plan을 먼저 둡니다.

Task frontmatter 필드는 운영 부담과 대시보드 필요도를 기준으로 `필수`, `권장`, `확장`으로 나눕니다. `setup.sh --create-project-ssot`가 만드는 `30-work-items/tasks/_templates/TASK-template.md`와 `templates/task.md`는 필수 필드와 권장 필드를 기본 frontmatter에 포함해야 합니다. 확장 필드는 task 본문, 실행 report, PR 본문, 또는 필요 시 frontmatter로 승격할 수 있으며 모든 scaffold에 기계적으로 요구하지 않습니다.

필수 필드:

- id
- taskID
- taskTitle
- title
- parent_issue
- status
- priority
- mode: `contract` 또는 `exploratory`
- output
- acceptance_criteria
- test_plan
- verification_plan
- updated

권장 필드:

- owner_silo
- branch
- coverage_target
- approval_required
- pr
- promotion_status
- hypothesis_chain
- hypothesis_attempt_limit: 기본값 `3`
- hypothesis_attempt_count
- hypothesis_limit_status: `within-limit`, `limit-reached`, `user-judgment-needed`
- had_failed_run: `true` 또는 `false`
- resolved_by_hypothesis: `true` 또는 `false`
- failed_run_count
- resolved_attempt_no
- latest_failed_report
- latest_retry_report
- blocked_reason
- latest_resolution_summary
- dashboard_flags: 예: `had_failed_run`, `resolved_by_hypothesis`, `needs-user-judgment`
- build_assumption
- learn_summary
- promoted_spec_candidate
- follow_up_task_candidates

확장 필드:

- runtime_set
- created
- closed
- related_issue
- related_requirements
- repo_links
- source_refs
- evidence_refs
- review_status
- assignee_hint
- external_tracker
- tags
- level_target

확장 필드는 프로젝트별 runner, 외부 tracker, source repo 구조, Obsidian 필터 요구가 있을 때 추가합니다. `level_target`, `tags`, `created`, `closed`처럼 대시보드에 유용한 필드도 모든 task scaffold의 필수 계약으로 두지는 않습니다. 단, 특정 프로젝트 대시보드가 해당 필드를 필터로 사용한다면 Project Work SSoT의 task 템플릿에서 권장 필드로 올릴 수 있습니다.

Task 기본 필드에는 `owner`와 `files_touched`를 두지 않습니다. 담당 실행 단위는 `owner_silo`, `branch`, `pr`, 또는 관련 repo/branch/silo 섹션으로 추적합니다. 실제 변경 파일 목록은 task 작성 시점에 예측해야 하는 계약이 아니라 구현 결과이므로 PR 본문, 변경 요약, 리뷰 evidence에서 기록합니다.

dashboard는 `owner_silo`, `branch`, `pr`를 task 담당자 필드가 아니라 실행 단위와 review 위치를 찾는 추적 필드로 봅니다. `hypothesis_chain`은 긴 실행 기록이므로 dashboard 표에는 직접 펼치지 않고, `hypothesis_attempt_count`, `hypothesis_limit_status`, `dashboard_flags`, 실패 이력 요약 필드로 압축해 보여줍니다.

병렬로 생성하거나 실행할 task는 sibling task 완료를 `output`, `acceptance_criteria`, `test_plan`의 전제로 삼지 않습니다. 개별 task output은 해당 task가 독립적으로 증명할 수 있는 산출물로 제한합니다. 인증, 데이터, 화면, backend 의존성이 있으면 agent가 통제할 수 있는 대체 검증 경로와 실제 사용자 경로의 차이를 `verification_plan` 또는 `test_plan`에 명시합니다. 여러 sibling task 완료를 전제로 하는 최종 통합 E2E는 개별 task acceptance가 아니라 별도 QA gate, integration task, 또는 후속 project 검증으로 분리합니다. 단일 task의 화면 동작 자체가 산출물이면 E2E 또는 agent-browser acceptance를 유지합니다.

기능 task와 사일로는 human check를 기본 완료 경로로 삼지 않습니다. 먼저 agent가 criteria별로 `test command`, `DB query`, `browser test evidence`, 실행 URL/명령, 로그, report 위치처럼 직접 실행하거나 관찰 가능한 test evidence를 묶고, 사람이 볼 항목은 최종 승인, UX 판단, 로컬 재현, 실제 계정/기기 접근처럼 agent-verifiable test evidence로 대체할 수 없는 범위로 제한합니다. provider별 QA 절차, 특정 fixture 값, task 고유 목데이터와 테스트 입력은 0계층이나 1계층 Project SSoT에 쓰지 않고 2계층 Project Work SSoT 또는 해당 task 계약에 둡니다.

기능 task의 `Pseudo Code`는 TypeScript/JavaScript 같은 실제 구현 코드 블록이나 완성된 함수 구현이 아니라 파일별 대표 함수 골격형입니다. 각 파일마다 대표 함수와 보조 함수가 어떤 입력/의존성을 받고 조회, 검증, 가공, 조건 분기, 반복, 저장, 반환을 어떻게 수행하는지 코드에 가깝게 보여야 합니다. 파일명, 함수명, API query, DB mutation, op 이름(`D/L/C/R`) 같은 코드 식별자는 원문 그대로 쓸 수 있지만 설명 문장은 한국어로 씁니다. 실제 변경이 선언적 config, prop, default, value 한두 곳 수정이고 별도 분기·가공·조회·저장 흐름이 없으면 `Pseudo Code`를 생략할 수 있습니다. 이때 대상 파일, 설정 key, 기존값 또는 누락 상태, 목표값, 회귀 검증을 `단순 config 변경 계약`에 적습니다. 로직 변경이나 여러 파일의 실행 흐름은 단순 config 변경으로 보지 않습니다. 이 규칙은 task 본문과 사일로 `goal.md`에 모두 적용합니다.

`hypothesis_chain`은 일반 사일로와 탐색형 task의 task 내부 summary 역할을 하며, 사일로 실행으로 검증한 가설을 시간순으로 누적합니다. 실패한 가설은 새 task를 자동 생성하지 않고 먼저 이 체인에 남깁니다. 하나의 task에서 가설 시도는 최대 3회이며, 3회 이후에는 자동 재시도 대신 사용자 판단이 필요합니다. 테스트 사일로에는 `hypothesis_chain`을 적용하지 않습니다.

`mode: exploratory`인 task는 `hypothesis_chain`을 `Build -> Learn -> Spec` 기록으로 사용합니다. 이 경우 실패는 즉시 중단 사유가 아니라 학습 결과이며, 반복 가능하거나 소유권이 분리되는 문제만 새 task/spec 후보로 승격합니다.

실행 중 실패 report가 생성된 뒤 가설을 세워 해결한 경우, 최종 상태가 `pass`가 되더라도 실패 이력을 숨기지 않습니다. task에는 `had_failed_run: true`, `resolved_by_hypothesis: true`, `failed_run_count`, `resolved_attempt_no`, `latest_failed_report`, `latest_retry_report`, `latest_resolution_summary`를 남기고, 막힌 상태라면 `blocked_reason`을 함께 남깁니다. 일반 사일로의 `hypothesis_chain`에는 아래 항목을 시도별로 기록합니다.

- attempt_no
- failed_run_id 또는 failed_report
- failed_level 또는 failed_stage
- failure_observation
- root_cause_hypothesis
- evidence_checked
- action_taken
- retry_run_id 또는 retry_report
- result: `success`, `partial`, `failed`
- next_decision

테스트 사일로 실행 중 실패 report가 생성된 뒤 원인 후보를 확인해 해결한 경우, 원인 후보와 확인 근거는 task 내부 `hypothesis_chain`이 아니라 run report의 failure section, test evidence, Issue/Task 또는 follow-up task 승격 후보에 기록합니다. `resolved_by_hypothesis`는 기존 대시보드 필드명이며 테스트 사일로의 `Hypothesis Chain` 사용을 뜻하지 않습니다.

사용자가 실행 결과를 볼 때는 “최종 pass”와 “중간 실패를 가설로 해결한 pass”를 구분할 수 있어야 합니다. 따라서 project dashboard나 run report dashboard는 최소한 `had_failed_run`, `resolved_by_hypothesis`, `failed_run_count`, `resolved_attempt_no`, `latest_failed_report`, `latest_retry_report`, `blocked_reason`, `latest_resolution_summary`를 필터 또는 표시 컬럼으로 제공해야 합니다.

`is_failed`는 최신 상태만 의미하는 필드로 쓰지 않습니다. 최신 상태는 기존 `status`를 사용하고, 실패 이력은 `had_failed_run`으로 표현합니다. 이렇게 해야 `status: pass`이면서도 과거 실패가 있었던 대상을 필터링할 수 있습니다.

### Operating Hypothesis

0계층 운영 방식에 대한 가설입니다.

Operating Hypothesis는 Project SSoT나 Project Work SSoT가 아니라 `system/60-operating-hypotheses/`에 저장합니다. task 처리 방식, 전체 구현 플랜 수립 방식, 정보 취합 방식, 사일로/PR/review loop 운영 방식이 왜 선택됐고 어떤 병목을 만들었는지 추적합니다.

Task 내부 `hypothesis_chain`이 실행 중 실패와 재시도 가설을 다룬다면, Operating Hypothesis는 그보다 상위에서 에이전트 운영 방식 자체의 가설을 다룹니다.

필드:

- hypothesis_id
- hypothesis_name
- status: `draft`, `active`, `closed`, `discarded`
- started_at
- closed_at
- operating_hypothesis
- rationale
- gathered_information
- previous_method_problem
- expected_bottlenecks
- applied_workflow
- applied_scope
- execution_result
- observed_bottlenecks
- human_check_points
- keep_next
- discard_next
- updated_system_docs
- updated_skills
- updated_agent_prompts
- follow_up_operating_hypotheses

새 operating hypothesis는 task 처리 순서, task 작성 방식, 사일로 생성 방식, PR review loop 방식, submodule/monorepo/external clone 운영 방식, human check 병목을 줄이기 위한 test evidence 수집 방식, 전체 프로젝트 구현 플랜 수립 방식이 바뀔 때 작성합니다.

operating hypothesis는 사후 합리화가 아니라 실행 전 가설과 예상 병목을 먼저 쓰고, 실행 후 결과물과 실제 병목을 이어 붙이는 로그입니다. 프로젝트 기능 요구사항은 여기에 복사하지 않고 1계층 Project SSoT에 두며, 그 기능을 구현하기 위한 개별 issue/task 원문은 2계층 Project Work SSoT에 둡니다.

### User Layer

User Layer는 1계층 User SSoT이며 사용자별 유저 퍼스널리티와 Feedback의 정본입니다. 실제 데이터는 workspace의 `user-layer/` 디렉터리가 소유합니다.

고정 구조:

- `AGENTS.md`: 검증과 사용자 승인을 마친 유저 퍼스널리티 정본
- `feedback/active/`: 일반 세션에서 기록한 열린 Feedback
- `feedback/applied/`: User Layer 또는 다른 SSoT 반영이 끝난 Feedback
- `feedback/closed/`: 기각, 중복, 일회성 또는 다른 계층으로 라우팅되어 종료된 Feedback
- `update-sessions/`: 후보 퍼스널리티, 검증 시나리오, 검증 결과와 승인 기록

User Layer에는 User Hypothesis 상태 필드를 두지 않습니다. Operating Hypothesis와 Task `hypothesis_chain`은 별도 기존 기록으로 유지합니다.

### Silo

특정 이슈나 태스크를 맡은 동적 작업 단위입니다.

Silo 상태는 Project Work SSoT 또는 silo local workspace에 저장합니다. 0계층에는 생성 정책만 둡니다.

Silo는 제품 소스코드 자체가 아니라 task 실행 단위입니다.

Silo는 `goal.md`, scope, 실행 상태, local finding, 임시 검증 결과, PR 전 작업 상태를 담습니다. 제품 repo/source workspace는 사일로가 필요할 때 clone하거나 연결하는 별도 대상이며, 사일로와 개념적으로 분리합니다.

Silo는 산출물 성격에 따라 테스트 사일로와 일반 사일로로 구분합니다.

- 테스트 사일로: lifecycle/e2e/runtime/탐색 검증처럼 보고서가 주 산출물인 임시 실행 환경입니다. 종료 시 개별 보고서와 evidence를 2계층 Project Work SSoT의 task/runbook/QA/coverage 위치, 또는 해당 Project Work SSoT/프로젝트 정책이 명시한 외부 evidence 위치에 승격한 뒤 삭제할 수 있습니다. 여러 테스트 사일로를 묶어 실행하는 execution window가 끝나면 개별 보고서를 묶어 전체 사일로 보고서와 Issue/Task 승격 후보를 만듭니다.
- 일반 사일로: 구현/수정/문서/repair/conflict/PR 작업처럼 변경/PR/patch/evidence가 주 산출물인 작업 환경입니다. 자동 삭제를 기본값으로 삼지 않고 PR/patch 대응 관계, merge 상태, 미커밋 변경, 원격 상태, worktree 상태를 확인한 뒤 정리합니다.

여러 page나 task를 한 번에 다루는 묶음은 사일로가 아니라 실행 순서를 관리하는 scheduler 또는 execution window입니다. `1 page = 1 test silo`가 정해진 실행에서는 10개씩 순차 실행하더라도 실행 단위는 page별 test silo이며, 10개 묶음 자체를 하나의 사일로로 취급하지 않습니다.

필드:

- id
- type: `test-silo` 또는 `general-silo`
- source_issue_or_task
- scope
- branch
- status
- report_location
- evidence_location
- execution_window_report
- cleanup_gate
- cleanup_status
- hypothesis_try
- hypothesis_result: `success`, `partial`, `failed`
- hypothesis_evidence
- next_hypothesis_candidate
- had_failed_run
- resolved_by_hypothesis
- failure_chain_report
- known_context
- local_findings
- local_tasks
- pr
- patch_mapping
- merge_state
- promoted_items
- discarded_items
- feedback_updates

### Run Set

Run Set은 특정 실행에서 다룰 대상 목록, 제외 기준, 순서, 실행 창 크기, L 기준을 묶은 실행 입력입니다.

Run Set은 사일로가 아닙니다. Run Set은 어떤 사일로들을 어떤 순서로 만들고 실행할지 정하는 입력이며, 정식 사일로 실행 전에 확정되어야 합니다.

필드:

- id
- project_id
- target_type: `page`, `task`, `issue`, `workflow` 중 하나
- target_level 또는 target_goal
- target_items
- excluded_items
- exclusion_reason
- order_policy
- execution_window_size
- silo_granularity: 예: `1-page-1-silo`
- required_runtime_set
- evidence_contract
- stop_gate
- created_by
- approved_by 또는 user_confirmed
- status

Run Set이 없으면 lifecycle, run, E2E, 다건 테스트 사일로 실행을 시작하지 않습니다. 실행 전제가 빠진 상태에서 runner나 browser smoke를 직접 돌린 결과는 정식 사일로 실행 결과가 아니라 preflight 또는 폐기 후보 산출물로 분리합니다.

### Run Report Dashboard

Run Report Dashboard는 실행 대상의 최신 결과와 실패 이력 해결 흐름을 사람이 필터링해서 볼 수 있는 프로젝트별 대시보드입니다.

최소 컬럼:

- run_id
- target_id 또는 page_id
- target_name 또는 page_name
- status
- passed_level 또는 completed_stage
- had_failed_run
- resolved_by_hypothesis
- failed_run_count
- resolved_attempt_no
- latest_failed_report
- latest_retry_report
- linked_task
- latest_resolution_summary

필수 필터:

- `status`
- `passed_level` 또는 `completed_stage`
- `had_failed_run`
- `resolved_by_hypothesis`
- `linked_task`
- `target_id/page_id`
- `target_name/page_name`

execution window가 끝났을 때 `100개 중 3개 실패 후 원인 후보 확인으로 해결, 최종 100 pass` 같은 결과가 나오면, 대시보드는 최종 pass 100개와 별도로 `had_failed_run=true`, `resolved_by_hypothesis=true`인 3개를 바로 볼 수 있어야 합니다. 이 3개는 task 내부 `hypothesis_chain`이 아니라 run report의 failure section, test evidence, Issue/Task 또는 follow-up task 승격 후보로 연결되어야 합니다.

### 위험 실행 전제 확인

위험 실행 전제 확인은 사용자 명령이 시스템 안에서 실행 가능한 형태로 변환되었는지 확인하는 하위 gate입니다.

`main-v3/main`에서는 이 gate를 모든 작업에 강제하지 않습니다. lifecycle, run, E2E, 다건 테스트, production/data/destructive 위험이 있는 실행에만 적용합니다. 저위험 prototype이나 로컬 fixture 작성은 누락 정의가 있어도 합리적 가정으로 먼저 실행하고, 누락 정의는 learn 결과로 기록합니다.

사용자가 실행 문제를 지적할 때 핵심 질문은 "왜 사용자 명령이 시스템 안에서 실행 가능한 형태로 전달되지 않았는가"입니다. 이는 단순한 잘못 인정이 아니라 진짜 원인을 찾아 제거하기 위한 분석 단위입니다.

필수 확인 항목:

- 요청 계층
- 실행 대상
- Run Set 존재 여부
- Runtime Set 존재 여부와 health gate
- 사일로 유형
- 사일로 root와 `goal.md` 생성 기준
- L별 evidence 기준
- 제외 기준
- destructive boundary
- 실행 후 report/test evidence 승격 위치

누락 시 중단 규칙은 lifecycle, run, E2E, 다건 테스트, production/data/destructive 위험 실행에만 강제합니다. 이 경우 정식 실행을 시작하지 않고 `누락된 정의`, `실행하면 위험한 이유`, `사용자에게 물어볼 항목`을 보고합니다.

### Shared Runtime

여러 task silo가 함께 참조하는 장기 runtime checkout입니다.

Shared Runtime은 0계층 SSoT가 아니라 1계층 Project SSoT의 registry/status 또는 2계층 Project Work SSoT 참조에서 관리합니다. 0계층 `system/`은 생성/삭제 규칙과 템플릿만 둡니다.

필드:

- project_id
- runtime_set
- runtime_name
- runtime_kind
- role
- workspace_path
- repo_remote
- branch
- commit
- purpose
- ports
- env_file_policy
- requires_health_check
- health_check.command 또는 health_check.url
- owner
- last_checked
- linked_tasks
- status

### PR Record

사일로가 만든 PR과 메인 오케스트레이터 리뷰 결과입니다.

필드:

- pr_id
- branch
- silo_id
- linked_issue
- linked_task
- summary
- verification
- codex_review
- review_rounds
- promoted_to_ssot
- not_promoted
- user_feedback
- merge_decision

`codex_review`에는 계층별 target/base에 맞춰 생성된 PR의 Codex 리뷰 실행 여부, 리뷰 대상 diff, 발견한 major/critical 위험, 수정 여부, 재리뷰 결과, 15분 응답 timeout, 실패 또는 생략 사유를 기록합니다.

## 승격 상태

사일로에서 발견한 이슈나 태스크는 아래 상태 중 하나를 가집니다.

| 상태 | 의미 |
|---|---|
| `local-only` | 사일로 내부에서만 처리하거나 폐기 |
| `candidate` | feedback/follow-up 후보 |
| `promoted` | 메인 이슈/태스크로 승격됨 |
| `rejected` | 승격하지 않기로 결정 |
| `merged-as-fix` | 별도 메인 태스크 없이 PR 수정으로 해결 |

## 사일로 정리 상태

테스트 사일로와 일반 사일로는 정리 기준이 다릅니다.

| 상태 | 적용 유형 | 의미 |
|---|---|---|
| `report-promoted` | 테스트 사일로 | 개별 보고서와 evidence가 2계층 Project Work SSoT 또는 해당 Project Work SSoT/프로젝트 정책이 명시한 외부 evidence 위치에 승격됨 |
| `execution-window-reported` | 테스트 사일로 | 여러 개별 보고서를 묶은 전체 사일로 보고서와 Issue/Task 승격 후보가 작성됨 |
| `deleted` | 테스트 사일로 | 보고서/evidence 승격 gate와 dirty status 확인 뒤 사일로 디렉터리 삭제 완료 |
| `preserved` | 일반 사일로 | PR/patch, 검증, merge/cleanup 상태 확인 결과 보존 필요 |
| `cleanup-candidate` | 일반 사일로 | PR/patch 대응 관계와 clean 상태가 확인되어 삭제 후보로 보고됨 |
| `cleanup-blocked` | 일반 사일로 | 미커밋 변경, ahead commit, 원격 상태 불명확, repair/conflict 동등성 미확인 등으로 삭제 금지 |

테스트 사일로 삭제 전에는 보고서/evidence 승격 gate와 dirty status 확인이 필수입니다. 일반 사일로에는 테스트 사일로 삭제 규칙을 적용하지 않습니다. destructive action, upload/import, production mutation은 사일로 유형과 관계없이 별도 승인이 필요합니다.

## 사일로 출력 종료 상태

사일로 출력 문서의 `종료 상태`는 사일로가 사람 또는 메인 오케스트레이터에게 어떤 단계로 반환됐는지를 나타냅니다. 정리 가능 여부는 위의 `사일로 정리 상태`로 별도 판정합니다.

| 상태 | 적용 유형 | 의미 |
|---|---|---|
| `report-promoted` | 테스트 사일로 | 개별 보고서와 evidence가 SSoT 또는 지정 위치에 승격됨 |
| `execution-window-reported` | 테스트 사일로 | 여러 개별 보고서를 묶은 전체 사일로 보고서와 Issue/Task 승격 후보가 작성됨 |
| `deleted` | 테스트 사일로 | 보고서/evidence 승격 gate와 dirty status 확인 뒤 사일로 디렉터리 삭제 완료 |
| `codex-review-pass` | PR 일반 사일로 | PR 유형별 target/base에서 `codex-pr-review-loop` 기준 최신 head에 대한 P2 이상 actionable 지적 없음 또는 모두 근거 있는 `수비 가능`으로 기록됨 |
| `user-review-pending` | PR 일반 사일로 | 브랜치별 리뷰 gate 종결 후 사용자 재리뷰 대기 |
| `pr-opened` | PR 일반 사일로 | PR 생성 완료, 메인 리뷰 대기 |
| `needs-rework` | 일반 사일로 | 메인 리뷰 또는 사용자 피드백으로 재작업 필요 |
| `merged` | 일반 사일로 | PR 머지 완료 |
| `blocked` | 공통 | 사일로 단독으로 해결 불가 |
| `abandoned` | 공통 | scope 변경 또는 중복으로 폐기 |

출력 종료 상태와 정리 상태는 같은 축이 아닙니다. 같은 운영 의미를 갖는 경우에는 아래 canonical 이름을 함께 씁니다.

| 출력 종료 상태 | 정리 상태 | 관계 |
|---|---|---|
| `report-promoted` | `report-promoted` | 같은 테스트 사일로 evidence 승격 완료 상태 |
| `execution-window-reported` | `execution-window-reported` | 같은 execution window 전체 보고 완료 상태 |
| `deleted` | `deleted` | 같은 테스트 사일로 삭제 완료 상태 |
| `codex-review-pass` | 해당 없음 | 리뷰 gate 통과 상태이며 `cleanup-candidate`를 대체하지 않음 |
| `merged` | `cleanup-candidate` 후보 | PR 머지 후 PR/patch 대응 관계, clean 상태, 원격 상태를 별도 확인해야만 삭제 후보가 될 수 있음 |

## SSoT 갱신 시점

SSoT는 아래 시점에 갱신됩니다.

1. 0계층 정책이나 템플릿이 바뀔 때
2. 프로젝트가 등록/분리/연결될 때
3. Project SSoT 또는 Project Work SSoT 위치가 바뀔 때
4. 사일로 생성 정책이 바뀔 때
5. PR 승격/비승격 정책이 바뀔 때
6. 사용자 피드백이 퍼스널리티 규칙으로 승격될 때

## 중요한 원칙

- 사일로는 SSoT를 임의로 덮어쓰지 않습니다.
- 사일로 발견 사항은 PR description과 사일로 로그를 통해 메인으로 돌아옵니다.
- 메인 오케스트레이터가 승격 여부를 최종 판단합니다.
- 승격되지 않은 데이터도 이유와 함께 기록해야 합니다.
- 0계층은 프로젝트 issue/task를 직접 관리하지 않습니다.
- 프로젝트 내부 자료는 성격별로 분리합니다. Project SSoT에는 project contract, 기능/사용자 흐름별 요구사항, decision/ADR, 하위 2계층 위치 index처럼 위치/색인/계약을 두고, task/issue/QA/runbook/coverage 원문과 실행 중 변하는 작업 기록은 Project Work SSoT 또는 프로젝트 정책이 명시한 외부 위치에 둡니다. fork, submodule, external clone에는 제품 코드와 참조 원문을 둡니다.
