# 사일로 runtime handoff 가설

## ID

OH-0002

## 상태

draft

## 기간

- 시작: 2026-07-01
- 종료 또는 폐기:

## 상태 재검증

- 최근 재검증: 2026-07-07
- 최근 근거: `codex-pr-review-loop`, `silo-runtime-handoff`, `shared-runtime-health-check`, `review-waiter`, `main-orchestrator`, 사일로 review gate 문서에 fallback과 runtime handoff 경로가 존재합니다. PR #203 메타데이터도 재조회했지만 실제 사일로 PR 적용 결과는 아직 이 원문에 없습니다.
- 다음 재검증 조건: 현재 `main-v3/main`의 반영 파일과 실제 사일로 PR 적용 결과를 확인한 뒤 실행 결과와 실제 병목을 갱신합니다.
- 외부 PR 근거: PR #203 `PR 리뷰 설정과 handoff 흐름 정리`는 2026-07-04에 `main-v2`로 머지됐습니다. URL은 `https://github.com/Ryokuman/my_ochestrator/pull/203`, merge commit은 `bc7454c63bb9e6f1b6e351cefcec5d955de11204`입니다. 현재 기준은 `main-v3/main`이므로, PR #203은 legacy 반영 근거로 두고 현재 파일 존재와 실제 사일로 PR handoff 결과를 별도로 확인합니다.

## 운영 가설

task 실행 결과인 사일로 PR이 실제 제품 코드 파일을 바꾸고 Codex no-major를 통과했거나 Codex review 설정 없음/권한 없음이 명시적으로 확인되어 review loop를 생략한 뒤 `shared-runtime-health-check`로 사일로 설정의 `runtime_set`과 서버형 runtime 상태를 확인하고, 그 결과를 바탕으로 runtime과 E2E 확인 방법을 PR 댓글로 남기면, 사용자가 재리뷰할 때 서버 주소, 실행 상태, 남은 수동 확인을 다시 묻지 않아도 된다.

## 채택 이유

사일로 PR 루프는 코드 리뷰 통과를 확인하지만, 사용자가 실제로 확인할 실행 환경과 E2E 절차를 자동으로 넘기지는 않았다. 리뷰 통과 직후 handoff를 고정하면 no-major와 사용자 재리뷰 사이의 정보 공백을 줄일 수 있다. Codex review가 명시적으로 미설정이거나 권한이 없는 repo에서는 no-major URL이 생성되지 않으므로, review loop를 억지로 반복하기보다 미설정 근거를 남기고 runtime handoff로 사용자 확인 정보를 고정해야 한다.

## 취합한 정보

- 사용자 피드백: 사일로 PR 루프 성공 후 `vite-harness`, shared BE, Docker DB를 켜고, 테스트 항목과 서버 주소를 PR 댓글로 남겨야 한다.
- 사용자 피드백: 관련 skill은 이미 있을 가능성이 높으며, 기존 skill을 새로 만들기보다 연결해야 한다.
- 사용자 피드백: runtime handoff는 모든 PR에 붙이지 않고, task성 실제 코드 파일 변경이 있었던 PR에만 붙여야 한다.
- 사용자 피드백: Codex review 세팅을 권장하되, 세팅이 안 된 repo에서는 PR loop가 돌지 않고 PR handoff만 동작해야 한다.
- 사용자 피드백: PR handoff는 config에 따라 다르게 움직이며, shared BE/API, Docker DB, FE/harness 같은 runtime이 켜져야 E2E 가능으로 볼 수 있다.
- 관찰: `silo-runtime-handoff`, `shared-runtime-health-check`, `add-shared-runtime`가 이미 존재한다.
- 관찰: 기존 `codex-pr-review-loop` 종료 기준은 no-major 이후 `silo-runtime-handoff`를 언급하지만, handoff 전에 `runtime_set` 확인과 health gate를 필수 연결로 충분히 강하게 표현하지 않았다.
- 관찰: Codex review 미설정 fallback에서는 no-major review URL이 없으므로, handoff 입력 계약에 fallback 근거 URL과 미설정/권한 없음 확인 근거가 필요하다.

## 기존 방식의 문제

- 리뷰 루프 성공과 사용자 재리뷰 호출 사이의 runtime handoff가 명시된 gate가 아니었다.
- Codex review 미설정/권한 없음 상태에서도 no-major URL을 요구하면 handoff가 시작되지 않거나 no-major 통과처럼 잘못 기록될 수 있다.
- 중앙 PR 리뷰 정책이 fallback을 모르면 agent가 미설정 repo에서 `@codex review`를 반복 호출하다가 handoff 경로를 건너뛸 수 있다.
- runtime handoff가 사일로 `runtime_set`을 먼저 확인해야 한다는 연결이 약하면 agent가 임의로 서버 조합을 만들 수 있다.
- 문서, skill, project SSoT만 바꾼 PR에도 runtime handoff를 요구하면 불필요한 서버 실행과 PR 댓글 소음이 생긴다.
- 서버를 켤 수 없는 경우에도 실행 불가 사유, 대체 증거, 남은 확인을 한곳에 남기는 형식이 없었다.

## 예상 병목

- Docker 또는 shared runtime이 로컬에서 켜지지 않을 수 있다.
- Codex review 미설정 fallback에서는 리뷰 통과가 아니라 리뷰 미실행 상태이므로 PR 본문과 handoff 댓글에서 표현이 섞일 수 있다.
- fallback 근거 URL이 PR 본문, 보고, 댓글 중 어디에 있는지 일정하지 않으면 review-waiter와 handoff skill이 서로 다른 입력을 기대할 수 있다.
- task contract에 E2E 시작 URL, seed, 테스트 입력이 부족하면 댓글이 추정으로 채워질 수 있다.
- project registry/config 또는 2계층 Project Work SSoT에 `runtime_set`이 없으면 no-major 이후 handoff가 막힐 수 있다.

## 적용한 작업 방식

- `silo-runtime-handoff` skill을 별도로 둔다.
- `codex-pr-review-loop`는 no-major 이후 task 실행 결과인 사일로 PR이 실제 제품 코드 파일을 바꾸고 runtime/E2E 조건이 있으면 `shared-runtime-health-check`로 `runtime_set`과 서버형 runtime 상태를 먼저 확인한 뒤 `silo-runtime-handoff`를 호출한다.
- Codex review 설정 없음/권한 없음이 명시적으로 확인되면 no-major 통과로 표현하지 않고 `Codex review 미설정`과 확인 근거를 남긴 뒤, task 실행 결과인 사일로 PR이면 같은 runtime handoff 조건을 평가한다.
- `silo-runtime-handoff`는 Codex review 미설정 fallback에서 no-major 댓글 URL을 요구하지 않고, fallback 근거 URL과 미설정/권한 없음 확인 근거를 입력으로 받는다.
- 사일로 review gate는 사용자 재리뷰 직전에 handoff 댓글을 요구한다.
- 문서, skill, project SSoT, config example만 바꾼 PR은 runtime handoff 대상에서 제외한다.
- `runtime_set`은 `run_set.required_runtime_set`, `task.runtime_set`, `qa_or_runbook.runtime_set`, `project.common_runtime_set` 순서로 project registry/config 또는 2계층 Project Work SSoT에서 찾는다.
- `runtime_set`이 없으면 임의 서버 조합을 만들지 않고 `add-shared-runtime` 또는 project registry/config, 2계층 Project Work SSoT 보강 필요를 handoff 댓글에 남긴다.

## 적용 범위

- task 실행 결과인 사일로 PR
- 실제 제품 코드 파일 변경이 있는 PR
- runtime, browser, manual QA, E2E, vite-harness, shared BE/API, Docker DB 확인이 남은 PR

## 실행 결과

- PR review fallback 반영 후보가 문서와 skill에 일부 들어가 있습니다. Codex review loop에서 `review-waiter` fallback 누락, `silo-runtime-handoff` no-major URL 요구, 중앙 PR 리뷰 정책 누락, 사일로 review gate fallback 누락, main-orchestrator fallback 누락, 루트 `AGENTS.md` fallback 누락이 P2로 발견되어 보강 대상이 됐습니다.
- PR #203은 이 가설의 legacy 반영 근거입니다. 다만 `main-v2` 기반 PR이므로 현재 `main-v3/main`의 반영 파일 존재와 실제 사일로 PR handoff 적용 결과를 함께 확인하기 전에는 `active` 승격 근거로 쓰지 않습니다.

## 실제 병목

- Codex review 설정이 동작하는 repo에서는 fallback 경로를 실제로 타지 않기 때문에 문서 일관성 검증은 Codex P2와 diff 검증에 의존했다.
- fallback 도입 범위가 `AGENTS.md`, `codex-pr-review-loop`, `main-orchestrator`, `review-waiter`, `silo-runtime-handoff`, 중앙 PR 리뷰 정책, 사일로 review gate, 운영 가설에 걸쳐 있어 한 파일만 바꾸면 drift가 생긴다.
- runtime_set 실데이터 위치를 0계층 system 문서처럼 쓰면 project별 실행 계약이 공통 규칙에 섞인다. 실제 runtime_set은 project registry/config 또는 2계층 Project Work SSoT에 두고, 0계층은 우선순위와 금지선만 정의해야 한다.
- 문서 반영 완료와 실제 사일로 handoff 검증 완료가 섞이면 README 단계가 stale 상태로 남는다.

## 사람 확인 지점

- PR 댓글의 서버 주소와 E2E 절차가 사용자가 그대로 따라 할 수준인지 확인해야 한다.
- 실행 불가 항목을 성공처럼 포장하지 않았는지 확인해야 한다.
- Codex review 미설정 fallback을 no-major 통과로 표현하지 않았는지 확인해야 한다.
- fallback 근거 URL이 PR 본문, 보고, 댓글 중 하나에 남아 있어 handoff가 없는 no-major URL을 요구하지 않는지 확인해야 한다.

## 유지할 것

- no-major 이후 사용자 재리뷰 전에 runtime handoff 댓글을 남기는 순서
- Codex review 미설정 fallback에서는 no-major 통과가 아니라 미설정 근거 기록 이후 runtime handoff 조건을 평가하는 순서
- 실제 제품 코드 변경이 있는 task PR에만 runtime handoff를 붙이는 범위 제한
- handoff 전에 `shared-runtime-health-check`로 project registry/config 또는 2계층 Project Work SSoT의 `runtime_set`과 서버형 runtime 상태를 확인하는 순서
- 실행 불가 항목을 별도 표로 남기는 방식

## 버릴 것

- no-major만 보고 사일로 PR을 사용자 재리뷰로 넘기는 방식
- Codex review 미설정 fallback을 no-major 통과처럼 기록하는 방식
- fallback에서 no-major 댓글 URL을 필수 입력으로 요구하는 방식
- 문서/skill/project SSoT 변경 PR에 runtime handoff를 기계적으로 붙이는 방식
- `runtime_set` 없이 agent 추론으로 서버 구성을 만드는 방식
- 실제 project runtime_set 값을 root `main-v3/main` 0계층 문서에 저장하는 방식

## 0계층 반영 위치

- 반영 완료:
  - 문서: `system/30-silo-system/20-silo-workflow/review-gate.md`, `system/40-pr-review-loop/README.md`, `system/40-pr-review-loop/02-review-policy.md`, `system/60-operating-hypotheses/OH-0002-silo-runtime-handoff.md`
  - skill: `system/20-skills/silo-runtime-handoff/SKILL.md`, `system/20-skills/shared-runtime-health-check/SKILL.md`, `system/20-skills/codex-pr-review-loop/SKILL.md`
  - agent prompt: `system/10-agents/main-orchestrator/README.md`, `system/10-agents/main-orchestrator/main-prompt.md`, `system/10-agents/review-waiter/README.md`, `system/10-agents/review-waiter/main-prompt.md`
- 반영 후보:
  - 실제 사일로 PR에서 Codex review 미설정 fallback과 runtime handoff가 함께 동작한 결과
- 미구현 후보:
  - 없음

## 후속 운영 가설 후보

- runtime handoff 댓글을 PR 본문 상태와 자동 동기화하면 재리뷰 추적 비용이 줄어드는가
