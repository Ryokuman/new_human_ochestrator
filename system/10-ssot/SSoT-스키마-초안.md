# SSoT 스키마 초안

## 목적

SSoT는 메인 오케스트레이터와 모든 사일로가 공유하는 상태와 규칙의 원본입니다.

SSoT는 다음을 저장해야 합니다.

- 전역 사용자 규칙과 판단 기준
- 프로젝트 등록과 SSoT 위치
- 프로젝트별 shared runtime registry/status 위치
- 계층별 저장 위치
- 사일로 생성 정책
- PR 리뷰와 승격 판단 정책
- 사용자 피드백과 퍼스널리티 갱신 이력

## 권장 구조

0계층 SSoT는 프로젝트별 운영 구조를 직접 담지 않고, 여러 프로젝트에 공통으로 적용할 규칙과 템플릿을 둡니다.

```text
ssot/
├── context.md
├── layer-policy.md
├── feedback-rules/
│   ├── 전역-사용자-규칙.md
│   ├── 응답-보고-규칙.md
│   └── 피드백-반영-이력.md
├── projects/
│   └── <project-id>/
│       ├── project-registry.md
│       ├── ssot-location.md
│       ├── repo-links.md
│       ├── protected-branches.md
│       ├── shared-runtime-registry.md
│       └── service-policy.md
├── templates/
│   ├── 이슈.md
│   ├── 태스크.md
│   ├── 사일로.md
│   ├── PR-description.md
│   └── 피드백.md
└── decisions/
```

프로젝트별 SSoT는 2계층 Project Internal에 속하며, 최소한 아래 구성을 가져야 합니다.

```text
project-ssot/
├── 00-dashboard/
│   ├── project-overview.md
│   ├── work-filter.md
│   ├── work-items.base
│   └── work-views.md
├── .obsidian/
│   ├── community-plugins.json
│   └── core-plugins.json
├── 20-issues/
│   └── 이슈 관리
├── 30-tasks/
│   └── 태스크 생성/관리
├── templates/
│   └── work-filter-dashboard.md
└── 90-coverage/
    └── L 기준 생성/관리
```

이 구조는 최소 필수 구성입니다. 프로젝트 특성에 따라 QA, decision/ADR, coverage, runbook, report, handoff 영역을 더 둘 수 있습니다.

0계층 `system/`은 위 구조가 필요하다는 규칙과 템플릿만 관리합니다. 특정 프로젝트의 실제 태스크, 이슈, L runner 결과, page 목록, coverage report, 대시보드/보고서 내용은 프로젝트 SSoT에 두고 0계층으로 복사하지 않습니다.

`projects/`는 제품 소스코드 저장소가 아닙니다. `projects/`에는 프로젝트 SSoT, registry, repo 연결 정보, 보호 브랜치, service policy, evidence 위치처럼 프로젝트 운영 상태를 찾기 위한 자료만 둡니다.

실제 제품 소스코드는 `.gitignore`된 `sources/` 같은 외부/로컬 소스 위치, 별도 repo/worktree, fork, submodule, external clone에 둡니다.

여러 task silo가 함께 참조하는 runtime checkout은 shared runtime으로 분리할 수 있습니다. shared runtime은 workspace root 아래 공용 실행 repo 묶음이며, task silo가 직접 소유하지 않고 참조합니다. 기본 경로 후보는 `shared-runtime/<project-id>/<runtime-name>/`입니다. 프로젝트별 실제 runtime 구성과 registry/status는 project SSoT, project registry/config, 또는 gitignore된 local config에 둡니다.

프로젝트별 evidence는 coverage 판단 근거이므로 project SSoT 내부에 보존할 수 있습니다. 단, evidence 원본이 대용량 영상, trace, runner output, 제품 소스코드인 경우에는 project SSoT에 위치와 요약을 남기고 원본은 프로젝트 정책에 맞는 외부/로컬 저장 위치에 둡니다.

## 주요 엔티티

## Project SSoT 최소 필수 구성

프로젝트 SSoT를 만들거나 점검할 때는 프로젝트별 실제 내용과 무관하게 아래 네 가지 구조가 있어야 합니다.

| 필수 구성 | 역할 | 저장 계층 |
|---|---|---|
| 태스크 생성/관리 | 실제 수행 가능한 작업 단위를 만들고 상태, 완료 조건, 검증 결과를 추적한다. | 2계층 Project Internal |
| L 기준 생성/관리 | 프로젝트의 단계별 채점 기준, runner 계약, report 위치를 명시한다. | 2계층 Project Internal |
| 이슈 관리 | 문제, 원인 가설, 영향, 연결 Task를 추적한다. | 2계층 Project Internal |
| 대시보드 | 사람이 현재 상태, 활성 Task, 활성 Issue, 다음 행동을 한 화면에서 필터링해 확인한다. | 2계층 Project Internal |

0계층 `system/`은 위 구조가 필요하다는 규칙, 템플릿, `setup.sh` 셋업 흐름만 관리합니다. 특정 프로젝트의 실제 Task, Issue, L runner 결과, page 목록, report 내용은 0계층으로 복사하지 않습니다.

Project SSoT의 `00-dashboard/`는 단순 설명 문서만 두지 않습니다. 기본 scaffold는 아래 네 파일을 생성해야 합니다.

- `project-overview.md`: 프로젝트 목적, 위치, 운영 경계, 다음 행동을 설명합니다.
- `work-filter.md`: issue/task를 종류, 상태, 레벨, 태그, 날짜, 검색어로 즉석 필터링하는 DataviewJS 대시보드입니다.
- `work-items.base`: Obsidian Base에서 사용할 기본 table view와 저장된 view입니다. setup은 target이 현재 repo/vault 아래에 있으면 해당 Project SSoT 경로로 Base 필터를 제한하고, 외부 target이면 해당 SSoT를 vault root로 여는 전제의 로컬 `20-issues/`, `30-tasks/` 필터를 생성합니다.
- `work-views.md`: Obsidian Base 사용법과 `work-items.base` embed를 둔 안내 문서입니다.
- `.obsidian/community-plugins.json`: DataviewJS 대시보드를 위한 `dataview` community plugin 선언입니다. 실제 플러그인 설치와 DataviewJS 허용은 Obsidian 앱에서 확인합니다.
- `templates/work-filter-dashboard.md`: 같은 프로젝트 안에서 BE, FE, ops처럼 경로별 작업 대시보드를 추가할 때 복제하는 템플릿입니다.

대시보드의 기본 첫 화면은 `project-overview.md`의 정적 표가 아니라 `work-filter.md` 또는 `work-views.md`처럼 실제 issue/task를 필터링할 수 있는 작업 목록이어야 합니다. 프로젝트 설명은 overview에 두되, 운영자가 지금 볼 화면은 필터 가능한 작업 대시보드로 연결합니다.

`work-filter.md`는 frontmatter의 `dashboardScope.paths`를 기준으로 수집 경로를 정합니다. 기본값은 `20-issues/`, `30-tasks/`입니다. 한 프로젝트 안에서 여러 작업 흐름을 분리해야 하면 대시보드 파일을 복제하고 `dashboardTitle`, `dashboardScope.paths`만 바꿉니다. 예를 들어 onjump BE와 onjump FE가 별도 source/workflow를 갖는다면 각각 `be/30-tasks/`, `fe/30-tasks/` 또는 프로젝트가 정한 경로를 scope로 둔 대시보드를 만들 수 있습니다. 같은 task/issue 풀을 공유하고 싶으면 별도 대시보드를 만들지 않고 기본 대시보드를 사용합니다.

대시보드는 실제 작업 항목만 집계해야 합니다. `20-issues/ISSUE-template.md`, `30-tasks/TASK-template.md`처럼 live 폴더 안에 있는 템플릿 파일은 frontmatter가 있더라도 작업 목록에서 제외합니다.

필터 대시보드가 동작하려면 issue/task 문서에 최소 frontmatter가 있어야 합니다.

- issue: `type: issue`, `id`, `issueID`, `issueTitle`, `title`, `status`, `severity`, `updated`
- task: `type: task`, `id`, `taskID`, `taskTitle`, `title`, `status`, `priority`, `updated`

파일명과 문서 제목은 사람이 읽는 이름을 우선하고, 식별자와 제목은 frontmatter에서 분리합니다. 새 issue는 `issueID`와 `issueTitle`, 새 task는 `taskID`와 `taskTitle`을 우선 사용합니다. `id`와 `title`은 기존 문서 호환 필드로 유지합니다. 대시보드는 ID와 제목을 별도 컬럼으로 보여야 합니다.

### Issue

버그, 문제, 개선 필요점입니다.

Issue는 0계층 SSoT가 아니라 project SSoT에 저장합니다.

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

### Task

실제로 수행 가능한 작업 단위입니다.

Task는 0계층 SSoT가 아니라 project SSoT에 저장합니다.

`main-v2`에서는 Task가 처음부터 완전한 계약일 필요가 없습니다. 작은 build 실험으로 시작하고, 실행 후 관찰한 learn 결과를 acceptance criteria, test plan, follow-up spec으로 승격할 수 있습니다.

Task 문서의 제목은 사람이 읽는 작업 목표나 문제 이름으로 작성합니다. `TASK-NNNN` 또는 `TASK-NNNNN` 같은 식별자는 제목에 합치지 않고 별도 `ID` 섹션이나 `id` 필드에 둡니다. 이렇게 해야 대시보드와 문서 목록에서 작업 의미와 식별자를 각각 안정적으로 읽을 수 있습니다.

모든 task 명세서는 읽고 실행 범위를 파악하는 시간이 기본 5분을 넘지 않도록 작성합니다. 최대 허용치는 7분입니다. 7분을 넘길 분량이면 task를 분할하거나, 상단에 5분 이내로 읽을 수 있는 실행 요약, 금지선, acceptance criteria, test plan을 먼저 둡니다.

필드:

- id
- taskID
- taskTitle
- title
- parent_issue
- status
- owner_silo
- branch
- output
- acceptance_criteria
- test_plan
- coverage_target
- verification_plan
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
- latest_resolution_summary
- dashboard_flags: 예: `had_failed_run`, `resolved_by_hypothesis`, `needs-user-judgment`
- mode: `contract` 또는 `exploratory`
- build_assumption
- learn_summary
- promoted_spec_candidate
- follow_up_task_candidates

Task 기본 필드에는 `owner`와 `files_touched`를 두지 않습니다. 담당 실행 단위는 `owner_silo`, `branch`, `pr`, 또는 관련 repo/branch/silo 섹션으로 추적합니다. 실제 변경 파일 목록은 task 작성 시점에 예측해야 하는 계약이 아니라 구현 결과이므로 PR 본문, 변경 요약, 리뷰 evidence에서 기록합니다.

병렬로 생성하거나 실행할 task는 sibling task 완료를 `output`, `acceptance_criteria`, `test_plan`의 전제로 삼지 않습니다. 개별 task output은 해당 task가 독립적으로 증명할 수 있는 산출물로 제한합니다. 인증, 데이터, 화면, backend 의존성이 있으면 agent가 통제할 수 있는 대체 검증 경로와 실제 사용자 경로의 차이를 `verification_plan` 또는 `test_plan`에 명시합니다. 여러 sibling task 완료를 전제로 하는 최종 통합 E2E는 개별 task acceptance가 아니라 별도 QA gate, integration task, 또는 후속 project 검증으로 분리합니다. 단일 task의 화면 동작 자체가 산출물이면 E2E 또는 agent-browser acceptance를 유지합니다.

`hypothesis_chain`은 task 내부 summary 역할을 하며, 사일로 실행으로 검증한 가설을 시간순으로 누적합니다. 실패한 가설은 새 task를 자동 생성하지 않고 먼저 이 체인에 남깁니다. 하나의 task에서 가설 시도는 최대 3회이며, 3회 이후에는 자동 재시도 대신 사용자 판단이 필요합니다.

`mode: exploratory`인 task는 `hypothesis_chain`을 `Build -> Learn -> Spec` 기록으로 사용합니다. 이 경우 실패는 즉시 중단 사유가 아니라 학습 결과이며, 반복 가능하거나 소유권이 분리되는 문제만 새 task/spec 후보로 승격합니다.

실행 중 실패 report가 생성된 뒤 가설을 세워 해결한 경우, 최종 상태가 `pass`가 되더라도 실패 이력을 숨기지 않습니다. task에는 `had_failed_run: true`, `resolved_by_hypothesis: true`, `failed_run_count`, `resolved_attempt_no`를 남기고, `hypothesis_chain`에 아래 항목을 시도별로 기록합니다.

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

사용자가 실행 결과를 볼 때는 “최종 pass”와 “중간 실패를 가설로 해결한 pass”를 구분할 수 있어야 합니다. 따라서 project dashboard나 run report dashboard는 최소한 `had_failed_run`, `resolved_by_hypothesis`, `failed_run_count`, `resolved_attempt_no`, `latest_resolution_summary`를 필터 또는 표시 컬럼으로 제공해야 합니다.

`is_failed`는 최신 상태만 의미하는 필드로 쓰지 않습니다. 최신 상태는 기존 `status`를 사용하고, 실패 이력은 `had_failed_run`으로 표현합니다. 이렇게 해야 `status: pass`이면서도 과거 실패가 있었던 대상을 필터링할 수 있습니다.

### Silo

특정 이슈나 태스크를 맡은 동적 작업 단위입니다.

Silo 상태는 project SSoT 또는 silo local workspace에 저장합니다. 0계층에는 생성 정책만 둡니다.

Silo는 제품 소스코드 자체가 아니라 task 실행 단위입니다.

Silo는 `goal.md`, scope, 실행 상태, local finding, 임시 검증 결과, PR 전 작업 상태를 담습니다. 제품 repo/source workspace는 사일로가 필요할 때 clone하거나 연결하는 별도 대상이며, 사일로와 개념적으로 분리합니다.

Silo는 산출물 성격에 따라 테스트 사일로와 일반 사일로로 구분합니다.

- 테스트 사일로: lifecycle/e2e/runtime/탐색 검증처럼 보고서가 주 산출물인 임시 실행 환경입니다. 종료 시 개별 보고서와 evidence를 SSoT 또는 지정 위치에 승격한 뒤 삭제할 수 있습니다. 여러 테스트 사일로를 묶어 실행하는 execution window가 끝나면 개별 보고서를 묶어 전체 사일로 보고서와 Issue/Task 승격 후보를 만듭니다.
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

execution window가 끝났을 때 `100개 중 3개 실패 후 가설 해결, 최종 100 pass` 같은 결과가 나오면, 대시보드는 최종 pass 100개와 별도로 `had_failed_run=true`, `resolved_by_hypothesis=true`인 3개를 바로 볼 수 있어야 합니다. 이 3개는 각 task의 `hypothesis_chain` 또는 run report의 failure chain section으로 연결되어야 합니다.

### Command Intent Preflight

Command Intent Preflight는 사용자 명령이 시스템 안에서 실행 가능한 형태로 변환되었는지 확인하는 gate입니다.

`main-v2`에서는 Command Intent Preflight를 모든 작업에 강제하지 않습니다. lifecycle, run, E2E, 다건 테스트, production/data/destructive 위험이 있는 실행에만 정식 gate로 적용합니다. 저위험 prototype이나 로컬 fixture 작성은 누락 정의가 있어도 합리적 가정으로 먼저 실행하고, 누락 정의는 learn 결과로 기록합니다.

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
- 실행 후 report/evidence 승격 위치

누락 시 중단 규칙은 lifecycle, run, E2E, 다건 테스트, production/data/destructive 위험 실행에만 강제합니다. 이 경우 정식 실행을 시작하지 않고 `누락된 정의`, `실행하면 위험한 이유`, `사용자에게 물어볼 항목`을 보고합니다.

### Shared Runtime

여러 task silo가 함께 참조하는 장기 runtime checkout입니다.

Shared Runtime은 0계층 SSoT가 아니라 프로젝트별 registry/status에서 관리합니다. 0계층 `system/`은 생성/삭제 규칙과 템플릿만 둡니다.

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
- health_check_command 또는 health_check.url
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

`codex_review`에는 `main-v2`의 Codex 리뷰 실행 여부, 리뷰 대상 diff, 발견한 major/critical 위험, 수정 여부, 재리뷰 결과, 실패 또는 생략 사유를 기록합니다.

## 승격 상태

사일로에서 발견한 이슈나 태스크는 아래 상태 중 하나를 가집니다.

| 상태 | 의미 |
|---|---|
| `local-only` | 사일로 내부에서만 처리하거나 폐기 |
| `candidate` | SSoT 승격 후보 |
| `promoted` | 메인 이슈/태스크로 승격됨 |
| `rejected` | 승격하지 않기로 결정 |
| `merged-as-fix` | 별도 메인 태스크 없이 PR 수정으로 해결 |

## 사일로 정리 상태

테스트 사일로와 일반 사일로는 정리 기준이 다릅니다.

| 상태 | 적용 유형 | 의미 |
|---|---|---|
| `report-promoted` | 테스트 사일로 | 개별 보고서와 evidence가 SSoT 또는 지정 위치에 승격됨 |
| `execution-window-reported` | 테스트 사일로 | 여러 개별 보고서를 묶은 전체 사일로 보고서와 Issue/Task 승격 후보가 작성됨 |
| `deleted` | 테스트 사일로 | 보고서/evidence 승격 gate와 dirty status 확인 뒤 사일로 디렉터리 삭제 완료 |
| `preserved` | 일반 사일로 | PR/patch, 검증, merge/cleanup 상태 확인 결과 보존 필요 |
| `cleanup-candidate` | 일반 사일로 | PR/patch 대응 관계와 clean 상태가 확인되어 삭제 후보로 보고됨 |
| `cleanup-blocked` | 일반 사일로 | 미커밋 변경, ahead commit, 원격 상태 불명확, repair/conflict 동등성 미확인 등으로 삭제 금지 |

테스트 사일로 삭제 전에는 보고서/evidence 승격 gate와 dirty status 확인이 필수입니다. 일반 사일로에는 테스트 사일로 삭제 규칙을 적용하지 않습니다. destructive action, upload/import, production mutation은 사일로 유형과 관계없이 별도 승인이 필요합니다.

## SSoT 갱신 시점

SSoT는 아래 시점에 갱신됩니다.

1. 0계층 정책이나 템플릿이 바뀔 때
2. 프로젝트가 등록/분리/연결될 때
3. 프로젝트 SSoT 위치가 바뀔 때
4. 사일로 생성 정책이 바뀔 때
5. PR 승격/비승격 정책이 바뀔 때
6. 사용자 피드백이 퍼스널리티 규칙으로 승격될 때

## 중요한 원칙

- 사일로는 SSoT를 임의로 덮어쓰지 않습니다.
- 사일로 발견 사항은 PR description과 사일로 로그를 통해 메인으로 돌아옵니다.
- 메인 오케스트레이터가 승격 여부를 최종 판단합니다.
- 승격되지 않은 데이터도 이유와 함께 기록해야 합니다.
- 0계층은 프로젝트 issue/task를 직접 관리하지 않습니다.
- 프로젝트 내부 자료는 기본적으로 project SSoT, fork, submodule, external clone에 둡니다.
