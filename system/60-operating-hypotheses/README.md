# Operating Hypotheses

0계층 운영 가설의 정본 위치입니다.

운영 가설은 제품 기능 가설이 아니라 task 처리 방식, 정보 취합 방식, 전체 구현 플랜 수립 방식, 사일로/PR/review loop 운영 방식에 대한 가설입니다.

각 가설은 실행 전 채택 이유와 예상 병목을 먼저 적고, 실제 task/PR/silo 실행 후 결과와 병목을 이어 붙입니다.

## 템플릿

새 운영 가설은 [`template.md`](template.md)를 복사해 작성합니다.

## 현재 가설

원문 상태 기준:

- `active`: 2개
- `draft`: 4개
- `closed`: 0개
- `discarded`: 0개

| ID | 상태 | 단계 | 가설 | 관리 메모 |
| --- | --- | --- | --- | --- |
| [`OH-0001`](OH-0001-task-plan-pseudocode-gate.md) | `active` | 적용 중 | 기능 task 사전 계획 리뷰 가설 | task 생성 전 project contract 확인, 단계별 구현 계획, 파일별 pseudo code gate를 유지합니다. |
| [`OH-0005`](OH-0005-github-project-intake.md) | `active` | 적용 중, 실사용 검증 전 | GitHub 프로젝트 수집 evidence pack 가설 | repo inventory와 evidence pack 분리를 유지하되, 실제 프로젝트 조사 세션 결과를 추가 기록해야 합니다. |
| [`OH-0002`](OH-0002-silo-runtime-handoff.md) | `draft` | PR 반영 중 | 사일로 runtime handoff 가설 | PR #203 머지 전까지는 draft로 두고, 머지 후 실제 사일로 PR 적용 결과를 기록한 뒤 active 승격 여부를 판단합니다. |
| [`OH-0003`](OH-0003-sprint-parallel-mock-contract.md) | `draft` | 실행 전 | 스프린트 병렬 mock 계약 가설 | project contract가 성숙한 병렬 스프린트에서 실제 적용 전까지 draft로 둡니다. |
| [`OH-0004`](OH-0004-current-head-review-classification.md) | `draft` | PR loop 실험 중 | 현재 head 대상 리뷰 분류 가설 | current-head review/comment 분리 방식은 적용 중이지만, 반복 PR에서 더 검증한 뒤 active 승격 여부를 판단합니다. |
| [`OH-0006`](OH-0006-pr-completion-gate-split.md) | `draft` | 실행 전 | PR completion gate 분리 가설 | 다음 PR loop 개편에서 작성, Codex review, agent-browser E2E, runtime handoff gate를 분리해 검증한 뒤 active 승격 여부를 판단합니다. |

## 관리 기준

- `active`는 현재 기본 운영 규칙으로 적용하는 가설입니다.
- `draft`는 PR 또는 실제 작업에서 실험 중이거나 아직 실행 전인 가설입니다.
- `closed`는 충분히 검증되어 별도 규칙이나 skill로 흡수된 가설입니다.
- `discarded`는 적용 결과 폐기하기로 한 가설입니다.
- 새 가설을 추가하거나 기존 가설의 상태가 바뀌면 이 README의 count와 표를 함께 갱신합니다.
- `draft`를 `active`로 올릴 때는 실행 결과, 실제 병목, 유지할 것, 버릴 것이 원문에 기록돼 있어야 합니다.
- `active`가 더 이상 기본 운영 규칙이 아니면 `closed` 또는 `discarded`로 바꾸고 종료 또는 폐기 날짜를 기록합니다.
