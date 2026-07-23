# SSoT 승격 판단

## 승격 후보 기준

사일로 내부 이슈/태스크의 승격 판단은 발견 항목을 0/1/2계층 정본으로 올릴지, 3계층 사일로/PR 기록으로 남길지 먼저 나눕니다.

| 승격 대상 | 판단 기준 | 저장/브랜치 기준 |
|---|---|---|
| 0계층 System SSoT | 여러 프로젝트에 반복 적용되는 공통 규칙, repo skill, agent prompt, setup scaffold/template 기준 | `system/` 변경, `main-v3/{taskname}` 작업 브랜치, `main-v3/main` 대상 PR |
| 1계층 Project SSoT | 프로젝트 등록, project contract, 기능/사용자 흐름 요구사항, decision/ADR, 하위 SSoT 위치 색인 | 해당 project 계층 작업 브랜치, 목표 모델은 `project-{projectName}/{taskname}` -> `project-{projectName}/main` |
| 2계층 Project Work SSoT | 특정 요구사항을 구현하기 위한 issue, task, QA, runbook, coverage, handoff | 해당 project의 Project Work SSoT 위치, project 계층 작업 브랜치 |
| 3계층 Silo Local / PR 기록 | 단일 PR 판단, 임시 evidence, 아직 반복성이나 정본 위치가 확인되지 않은 발견 | silo local, evidence, PR 본문에 남기며 SSoT 승격으로 부르지 않음 |

승격 대상 계층을 정한 뒤, 아래 기준으로 실제 승격 후보인지 판단합니다.

승격 판단은 먼저 대상 계층과 대상 종류를 분리합니다.

| 대상 계층 | 대상 종류 | 저장 위치 | 브랜치 기준 |
|---|---|---|---|
| 0계층 System SSoT | 공통 규칙, repo skill, agent prompt, PR/review/runtime 공통 정책 | `system/` | `main-v3/main` 기준 `main-v3/{taskname}` |
| 1계층 Project SSoT | project 등록/색인, project contract, 기능/사용자 흐름별 요구사항, decision/ADR, project-level 운영 기준 | 해당 project SSoT | 목표 `project-{projectName}/main`, 호환 `project-{projectName}` |
| 2계층 Project Work SSoT | task, issue, QA, coverage, runbook, work dashboard, Run Set/Runtime Set | 해당 project의 Project Work SSoT | 목표 `project-{projectName}/main`, 호환 `project-{projectName}` |
| 3계층 local/evidence/feedback | silo local 발견, test evidence, 실험 로그, feedback 원자료, PR 전 임시 상태 | silo local, evidence, feedback log, PR 본문 | 보존/승격 판단 전에는 상위 SSoT에 직접 커밋하지 않음 |

| 기준 | 설명 |
|---|---|
| 반복 가능성 | 다른 기능/레포에서도 반복될 가능성이 있음 |
| 독립 실행성 | 별도 task로 쪼개 수행 가능 |
| 영향 범위 | 현재 PR scope 밖에 영향이 있음 |
| 사용자 취향 관련성 | 에이전트 행동 규칙이나 취향 불변성 갱신과 관련 있음 |
| 검증 필요성 | 별도 QA/테스트가 필요함 |
| 승인 필요성 | 사용자 또는 메인 승인이 필요한 변경임 |

## 승격하지 않을 기준

아래 항목은 기본적으로 SSoT로 승격하지 않습니다.

- 현재 PR에서 이미 해결됨
- 일회성 local cleanup
- 재현 불가
- 기존 issue/task와 중복
- scope 밖이지만 근거가 약함
- 사용자 취향 규칙과 무관한 사소한 구현 메모

## 판단 보고

PR 본문과 완료 보고에는 아래를 분리합니다.

```text
feedback/follow-up 후보
- 후보:
- 근거:
- 대상 계층: 0계층/1계층/2계층/3계층
- 대상 종류: rule/skill/prompt/project-contract/decision/ADR/task/issue/QA/runbook/coverage/feedback
- 저장 위치:
- evidence grade:
- 적용 범위:
- promotion status: proposed/needs-user-approval/accepted/rejected/deferred

처리하지 않고 남긴 항목
- 항목:
- 이유:
```
