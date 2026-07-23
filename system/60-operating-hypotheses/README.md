# Operating Hypotheses

0계층 운영 가설 원문과 상태 카탈로그의 정본 위치입니다.

운영 가설은 제품 기능 가설이 아니라 task 처리 방식, 정보 취합 방식, 전체 구현 플랜 수립 방식, 사일로/PR/review loop 운영 방식에 대한 가설입니다.

feedback loop 문서가 "운영 hypothesis 상세 관리 방식은 별도 정리 범위"라고 할 때는 `system/60-operating-hypotheses/`의 정본성을 부정하는 뜻이 아닙니다. 단일 feedback을 곧바로 상위 필수 gate나 hypothesis chain으로 승격하지 않고, 이 카탈로그에 새 가설을 추가하거나 상태를 바꾸는 작업을 별도 승인 단위로 다룬다는 뜻입니다.

각 가설은 실행 전 채택 이유와 예상 병목을 먼저 적고, 실제 task/PR/silo 실행 후 결과와 병목을 이어 붙입니다.

## 템플릿

새 운영 가설은 [`template.md`](template.md)를 복사해 작성합니다.

## 현재 가설

원문 `## 상태` 값 기준:

아래 count는 각 OH 원문의 상태값 기준이며, 현재 기본 규칙 또는 system/skill 반영 완료 목록이 아닙니다. 현재 기본 운영 반영 상태는 표의 `단계`와 `관리 메모`에서 별도로 확인합니다.

- `active`: 1개
- `draft`: 11개
- `closed`: 0개
- `discarded`: 0개

| ID | 상태 | 검증 단계 | 가설 | 최근 근거 / 재검증 기준 |
| --- | --- | --- | --- | --- |
| [`OH-0001`](OH-0001-task-plan-pseudocode-gate.md) | `active` | 기본 적용 중 | 기능 task 사전 계획 리뷰 가설 | 2026-07-10 기준 일반 기능 task의 pseudo code gate는 유지하고, 별도 실행 로직이 없는 단순 config 변경은 명시적 변경 계약으로 대체하도록 재검증했습니다. |
| [`OH-0002`](OH-0002-silo-runtime-handoff.md) | `draft` | PR 반영 근거 확인, 실사용 검증 전 | 사일로 runtime handoff 가설 | PR #203은 2026-07-04 `main-v2`에 머지됐고 관련 파일은 현재 `main-v3/main`에도 존재합니다. 실제 사일로 PR handoff 적용 결과를 기록한 뒤 active 승격 여부를 판단합니다. |
| [`OH-0003`](OH-0003-sprint-parallel-mock-contract.md) | `draft` | 실행 전 | 스프린트 병렬 mock 계약 가설 | project contract가 성숙한 병렬 스프린트에서 실제 적용 전까지 draft로 둡니다. |
| [`OH-0004`](OH-0004-current-head-review-classification.md) | `draft` | PR loop 실험 중 | 현재 head 대상 리뷰 분류 가설 | current-head review/comment 분리 방식은 적용 중이지만, 반복 PR에서 더 검증한 뒤 active 승격 여부를 판단합니다. |
| [`OH-0005`](OH-0005-github-project-intake.md) | `draft` | 구현 반영, 실사용 검증 전 | GitHub 프로젝트 수집 evidence pack 가설 | `github-project-intake` skill은 있으나 실제 프로젝트 조사 세션 결과가 아직 없습니다. 첫 실제 조사 세션 뒤 실행 결과와 병목을 기록해야 합니다. |
| [`OH-0006`](OH-0006-pr-completion-gate-split.md) | `draft` | 설계 후보, 미구현 skill 있음 | PR completion gate 분리 가설 | `pr-completion-loop`, `pr-agent-browser-e2e-gate`는 아직 실제 skill이 아닙니다. 기존 `codex-pr-review-loop`를 쪼개 구현하지 않고 후보 추적 상태로 둡니다. |
| [`OH-0007`](OH-0007-review-waiter-default.md) | `draft` | 정책 일부 반영, 실행 보장 검증 전 | PR 리뷰 대기 실행자 기본 연결 가설 | review-waiter 문서와 prompt는 있으나 백그라운드 실행 보장과 queue 기록 위치는 검증 전입니다. 실제 PR 대기 세션 뒤 재검증합니다. |
| [`OH-0008`](OH-0008-silo-prep-gate-exploratory-build.md) | `draft` | PR 반영 중 | 사일로 준비 gate와 탐색형 Build 분리 가설 | 상태 갱신 PR 머지를 사일로 실행 상태 보호 gate로 유지하되, 저위험 조사와 초안화는 `Build -> Learn -> Spec` 범위로 둡니다. |
| [`OH-0009`](OH-0009-review-completion-evidence-gate.md) | `draft` | RED 확인, GREEN 압력 재검증 통과 | 리뷰 완료 증거 안정화 gate 가설 | PR #460 실패를 기준선으로 삼고 findings-only review와 늦은 P2를 포함한 압력 시나리오 재검증을 통과했습니다. 실제 PR 반복 검증 전까지 draft로 유지합니다. |
| [`OH-0010`](OH-0010-task-status-directory-kanban.md) | `draft` | 0계층 구현·검증, 첫 project 적용 전 | Task 상태 디렉터리와 칸반 동기화 가설 | 공통 검증기와 scaffold smoke를 통과했으며, 첫 project 마이그레이션 뒤 링크·상태 전환 병목을 재검증합니다. |
| [`OH-0011`](OH-0011-human-readable-test-contract.md) | `draft` | 첫 PR 적용, 반복 검증 전 | 사람이 읽는 PR 테스트 계약 가설 | 첫 project PR의 테스트 9개를 목적·입력·방법·기대/실제 결과·한계·명령으로 다시 작성했으며, 다른 유형 PR 세 건 이상에서 작성 부담과 이해도를 재검증합니다. |
| [`OH-0012`](OH-0012-task-control-vault.md) | `draft` | 설계 승인, 구현 전 | 고정 Task Control Vault와 승인 후 번호 발급 가설 | 보호 브랜치 직접 수정 없이 병렬 세션의 Task 요청을 한 Vault에서 검수하는 구조를 승인했으며, 5개 병렬 생성·갱신 압력 시나리오와 실제 project prototype을 재검증해야 합니다. |

## 관리 기준

- `active`는 현재 기본 운영 규칙으로 적용하며, 원문에 실행 결과, 실제 병목, 유지할 것, 버릴 것, 최근 재검증 근거가 기록된 가설입니다.
- `draft`는 PR 또는 실제 작업에서 실험 중이거나 아직 실행 전인 가설입니다. 구현이 일부 반영됐더라도 실사용 검증 전, 외부 PR 근거 재검증 전, 또는 미구현 skill 후보가 포함된 경우에는 `draft`로 둡니다.
- `closed`는 충분히 검증되어 별도 규칙이나 skill로 흡수된 가설입니다.
- `discarded`는 적용 결과 폐기하기로 한 가설입니다.
- 새 가설을 추가하거나 기존 가설의 상태가 바뀌면 이 README의 count와 표를 함께 갱신합니다.
- `draft`를 `active`로 올릴 때는 실행 결과, 실제 병목, 유지할 것, 버릴 것, 상태 재검증 근거가 원문에 기록돼 있어야 합니다.
- `active`가 더 이상 기본 운영 규칙이 아니면 `closed` 또는 `discarded`로 바꾸고 종료 또는 폐기 날짜를 기록합니다.
- 외부 PR 번호를 근거로 쓰는 가설은 상태 재검증 때 PR URL, state, base/head, merge commit, 반영 파일 또는 미반영 사유를 함께 기록합니다.
- `검증 단계`는 상태가 아니라 보조 설명입니다. 예를 들어 `실사용 검증 전`, `정책 일부 반영`, `미구현 skill 있음`, `PR 반영 근거 재검증 필요`는 기본 운영 규칙 채택 여부와 별도로 현재 증거 수준을 설명합니다.
