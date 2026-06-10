# SSoT 스키마 초안

## 목적

SSoT는 메인 오케스트레이터와 모든 사일로가 공유하는 상태와 규칙의 원본입니다.

SSoT는 다음을 저장해야 합니다.

- 사용자 취향과 판단 기준
- 프로젝트 등록과 SSoT 위치
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
├── tasks/
│   └── 태스크 생성/관리
├── l-criteria/
│   └── L 기준 생성/관리
├── issues/
│   └── 이슈 관리
└── dashboard/
    └── 대시보드
```

이 구조는 최소 필수 구성입니다. 프로젝트 특성에 따라 QA, decision/ADR, coverage, runbook, report, handoff 영역을 더 둘 수 있습니다.

0계층 `system/`은 위 구조가 필요하다는 규칙과 템플릿만 관리합니다. 특정 프로젝트의 실제 태스크, 이슈, L runner 결과, page 목록, coverage report, 대시보드/보고서 내용은 프로젝트 SSoT에 두고 0계층으로 복사하지 않습니다.

## 주요 엔티티

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
- acceptance_criteria
- verification_plan
- approval_required
- pr
- promotion_status

### Silo

특정 이슈나 태스크를 맡은 동적 작업 단위입니다.

Silo 상태는 project SSoT 또는 silo local workspace에 저장합니다. 0계층에는 생성 정책만 둡니다.

필드:

- id
- source_issue_or_task
- scope
- branch
- status
- known_context
- local_findings
- local_tasks
- pr
- promoted_items
- discarded_items
- feedback_updates

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
