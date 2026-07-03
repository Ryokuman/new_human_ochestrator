# 사일로 runtime handoff 가설

## ID

OH-0002

## 상태

draft

## 기간

- 시작: 2026-07-01
- 종료 또는 폐기:

## 운영 가설

사일로 PR이 Codex no-major를 통과한 뒤 `shared-runtime-health-check`로 사일로 설정의 `runtime_set`과 서버형 runtime 상태를 확인하고, 그 결과를 바탕으로 runtime과 E2E 확인 방법을 PR 댓글로 남기면, 사용자가 재리뷰할 때 서버 주소, 실행 상태, 남은 수동 확인을 다시 묻지 않아도 된다.

## 채택 이유

사일로 PR 루프는 코드 리뷰 통과를 확인하지만, 사용자가 실제로 확인할 실행 환경과 E2E 절차를 자동으로 넘기지는 않았다. 리뷰 통과 직후 handoff를 고정하면 no-major와 사용자 재리뷰 사이의 정보 공백을 줄일 수 있다.

## 취합한 정보

- 사용자 피드백: 사일로 PR 루프 성공 후 `vite-harness`, shared BE, Docker DB를 켜고, 테스트 항목과 서버 주소를 PR 댓글로 남겨야 한다.
- 사용자 피드백: 관련 skill은 이미 있을 가능성이 높으며, 기존 skill을 새로 만들기보다 연결해야 한다.
- 관찰: `silo-runtime-handoff`, `shared-runtime-health-check`, `add-shared-runtime`가 이미 존재한다.
- 관찰: 기존 `codex-pr-review-loop` 종료 기준은 no-major 이후 `silo-runtime-handoff`를 언급하지만, handoff 전에 `runtime_set` 확인과 health gate를 필수 연결로 충분히 강하게 표현하지 않았다.

## 기존 방식의 문제

- 리뷰 루프 성공과 사용자 재리뷰 호출 사이의 runtime handoff가 명시된 gate가 아니었다.
- runtime handoff가 사일로 `runtime_set`을 먼저 확인해야 한다는 연결이 약하면 agent가 임의로 서버 조합을 만들 수 있다.
- 서버를 켤 수 없는 경우에도 실행 불가 사유, 대체 증거, 남은 확인을 한곳에 남기는 형식이 없었다.

## 예상 병목

- Docker 또는 shared runtime이 로컬에서 켜지지 않을 수 있다.
- task contract에 E2E 시작 URL, seed, 테스트 입력이 부족하면 댓글이 추정으로 채워질 수 있다.
- project SSoT 또는 local config에 `runtime_set`이 없으면 no-major 이후 handoff가 막힐 수 있다.

## 적용한 작업 방식

- `silo-runtime-handoff` skill을 별도로 둔다.
- `codex-pr-review-loop`는 no-major 이후 사일로 runtime/E2E 조건이 있으면 `shared-runtime-health-check`로 `runtime_set`과 서버형 runtime 상태를 먼저 확인한 뒤 `silo-runtime-handoff`를 호출한다.
- 사일로 review gate는 사용자 재리뷰 직전에 handoff 댓글을 요구한다.
- `runtime_set`이 없으면 임의 서버 조합을 만들지 않고 `add-shared-runtime` 또는 project SSoT 보강 필요를 handoff 댓글에 남긴다.

## 적용 범위

- task silo PR
- runtime, browser, manual QA, E2E, vite-harness, shared BE/API, Docker DB 확인이 남은 PR

## 실행 결과

- 초기 반영 중이다.

## 실제 병목

- 아직 실행 결과가 없다.

## 사람 확인 지점

- PR 댓글의 서버 주소와 E2E 절차가 사용자가 그대로 따라 할 수준인지 확인해야 한다.
- 실행 불가 항목을 성공처럼 포장하지 않았는지 확인해야 한다.

## 유지할 것

- no-major 이후 사용자 재리뷰 전에 runtime handoff 댓글을 남기는 순서
- handoff 전에 `shared-runtime-health-check`로 `runtime_set`과 서버형 runtime 상태를 확인하는 순서
- 실행 불가 항목을 별도 표로 남기는 방식

## 버릴 것

- no-major만 보고 사일로 PR을 사용자 재리뷰로 넘기는 방식
- `runtime_set` 없이 agent 추론으로 서버 구성을 만드는 방식

## 0계층 반영 위치

- 문서: `system/30-silo-system/20-silo-workflow/review-gate.md`, `system/40-pr-review-loop/02-review-policy.md`, `system/60-operating-hypotheses/OH-0002-silo-runtime-handoff.md`
- skill: `system/20-skills/silo-runtime-handoff/SKILL.md`, `system/20-skills/shared-runtime-health-check/SKILL.md`, `system/20-skills/codex-pr-review-loop/SKILL.md`
- agent prompt:

## 후속 운영 가설 후보

- runtime handoff 댓글을 PR 본문 상태와 자동 동기화하면 재리뷰 추적 비용이 줄어드는가
