# SSoT 스키마 초안

## 목적

SSoT는 메인 오케스트레이터와 모든 사일로가 공유하는 상태와 규칙의 원본입니다.

SSoT는 다음을 저장해야 합니다.

- 사용자 취향과 판단 기준
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
├── user-model/
│   ├── 취향-불변성.md
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
│   └── 대시보드
├── 20-issues/
│   └── 이슈 관리
├── 30-tasks/
│   └── 태스크 생성/관리
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
| 대시보드 | 사람이 현재 상태, 활성 Task, 활성 Issue, 다음 행동을 한 화면에서 확인한다. | 2계층 Project Internal |

0계층 `system/`은 위 구조가 필요하다는 규칙, 템플릿, 생성 스크립트만 관리합니다. 특정 프로젝트의 실제 Task, Issue, L runner 결과, page 목록, report 내용은 0계층으로 복사하지 않습니다.

### Issue

버그, 문제, 개선 필요점입니다.

Issue는 0계층 SSoT가 아니라 project SSoT에 저장합니다.

필드:

- id
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

필드:

- id
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

`hypothesis_chain`은 task 내부 summary 역할을 하며, 사일로 실행으로 검증한 가설을 시간순으로 누적합니다. 실패한 가설은 새 task를 자동 생성하지 않고 먼저 이 체인에 남깁니다. 하나의 task에서 가설 시도는 최대 3회이며, 3회 이후에는 자동 재시도 대신 사용자 판단이 필요합니다.

### Silo

특정 이슈나 태스크를 맡은 동적 작업 단위입니다.

Silo 상태는 project SSoT 또는 silo local workspace에 저장합니다. 0계층에는 생성 정책만 둡니다.

Silo는 제품 소스코드 자체가 아니라 task 실행 단위입니다.

Silo는 `goal.md`, scope, 실행 상태, local finding, 임시 검증 결과, PR 전 작업 상태를 담습니다. 제품 repo/source workspace는 사일로가 필요할 때 clone하거나 연결하는 별도 대상이며, 사일로와 개념적으로 분리합니다.

Silo는 산출물 성격에 따라 테스트 사일로와 일반 사일로로 구분합니다.

- 테스트 사일로: lifecycle/e2e/runtime/탐색 검증처럼 보고서가 주 산출물인 임시 실행 환경입니다. 종료 시 개별 보고서와 evidence를 SSoT 또는 지정 위치에 승격한 뒤 삭제할 수 있으며, batch 종료 시 전체 사일로 보고서와 Issue/Task 승격 후보를 만듭니다.
- 일반 사일로: 구현/수정/문서/repair/conflict/PR 작업처럼 변경/PR/patch/evidence가 주 산출물인 작업 환경입니다. 자동 삭제를 기본값으로 삼지 않고 PR/patch 대응 관계, merge 상태, 미커밋 변경, 원격 상태, worktree 상태를 확인한 뒤 정리합니다.

필드:

- id
- type: `test-silo` 또는 `general-silo`
- source_issue_or_task
- scope
- branch
- status
- report_location
- evidence_location
- batch_report
- cleanup_gate
- cleanup_status
- hypothesis_try
- hypothesis_result: `success`, `partial`, `failed`
- hypothesis_evidence
- next_hypothesis_candidate
- known_context
- local_findings
- local_tasks
- pr
- patch_mapping
- merge_state
- promoted_items
- discarded_items
- feedback_updates

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
- review_rounds
- promoted_to_ssot
- not_promoted
- user_feedback
- merge_decision

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
| `batch-reported` | 테스트 사일로 | 여러 개별 보고서를 묶은 전체 사일로 보고서와 Issue/Task 승격 후보가 작성됨 |
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
