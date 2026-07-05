# PR 리뷰 대기 실행자 기본 연결 가설

## ID

OH-0007

## 상태

draft

## 기간

- 시작: 2026-07-06
- 종료 또는 폐기:

## 운영 가설

Codex PR 리뷰 루프에서 최신 head 리뷰 결과가 없는 pending 상태를 종료 불가 상태로 두고, 메인 에이전트가 같은 턴에서 polling과 timeout 확인을 끝낼 수 없으면 기본적으로 `review-waiter-agent`에 연결하면, `@codex review` 호출이나 `eyes` 반응 확인만으로 loop가 끊기는 문제를 줄일 수 있다.

## 채택 이유

PR loop는 외부 Codex 리뷰 응답을 기다리는 비동기 절차입니다. 기존 규칙에는 `eyes` 반응과 timeout 기준이 있었지만, 실행자가 `eyes` 확인을 작업 완료처럼 보고하면서 최신 head 리뷰 결과, P1/P2 분류, timeout 확인 전에 최종 보고로 빠질 수 있었습니다. 호출과 접수는 종료가 아니라 대기 상태이므로, 대기 상태를 맡는 실행자 연결이 기본값이어야 합니다.

## 취합한 정보

- 사용자 피드백: 실제 skill을 사용했는데도 PR loop가 호출로 끝나는 사례가 반복됐습니다.
- 실행 관찰: 최신 head 기준 `@codex review` 호출 뒤 `eyes` 반응이 붙었지만 리뷰 결과 본문이 없는 상태를 최종 보고로 넘기는 실패가 발생했습니다.
- 기존 0계층 규칙: PR/review loop 운영 방식이 바뀌면 `system/60-operating-hypotheses/`에 운영 가설을 남기도록 요구합니다.
- Codex 리뷰 지적: 이번 변경은 PR review loop 운영 방식을 바꾸므로 운영 가설 로그가 함께 필요하다는 P2 지적이 있었습니다.

## 기존 방식의 문제

- `@codex review` 호출 성공과 `eyes` 반응 확인이 종료 상태처럼 오해될 수 있었습니다.
- 메인 에이전트가 대기 poll을 계속 유지하지 못하면 “리뷰 대기 계속”이라는 보고만 남고 실제 감시 주체가 사라질 수 있었습니다.
- `review-waiter-agent`가 “사용자가 명시하면 쓰는 선택 실행자”처럼 읽혀 기본 루프 책임과 분리될 수 있었습니다.
- 운영 방식 변경 근거가 operating hypothesis에 남지 않으면, 이후 실패 원인과 병목을 추적하기 어렵습니다.

## 예상 병목

- 별도 실행자가 실제로 백그라운드에서 계속 실행되지 않는 환경에서는 문서상 기본 연결만으로 충분하지 않을 수 있습니다.
- Codex 리뷰 응답이 issue comment, review body, inline review comment로 나뉘어 도착하므로 waiter가 최신 head 대상 여부를 잘못 분류할 수 있습니다.
- `Codex review 미설정` 또는 권한 없음 fallback PR에서는 waiter를 억지로 붙이면 불필요한 대기와 재호출이 생길 수 있습니다.
- 사용자가 명시한 반복 한도와 기본 no-limit loop가 충돌할 수 있습니다.

## 적용한 작업 방식

- `eyes`만 있고 최신 head 리뷰 결과가 없는 상태, 리뷰 호출 직후 접수 확인 전 상태, 수정 후 push했지만 재리뷰 결과가 없는 상태를 종료 불가 상태로 명시합니다.
- 메인 에이전트가 같은 턴에서 polling과 timeout 확인을 끝낼 수 없으면 `review-waiter-agent`에 기본 연결합니다.
- Codex review 미설정, 호출 권한 없음, GitHub App 미설치, repo 정책상 비활성화가 명시적으로 확인된 PR은 review loop가 아니라 fallback 기록과 조건부 runtime handoff로 분리합니다.
- 사용자가 이번 PR에 명시한 반복 한도가 있을 때만 그 한도를 적용합니다.

## 적용 범위

- 0계층 `main-v3/main` 대상 PR
- project 계층 PR
- `codex-pr-review-loop`를 사용하는 PR 리뷰 gate
- `review-waiter-agent`가 관리하는 Codex 리뷰 대기, 수정, 재리뷰 루프

## 실행 결과

- PR #211에서 초기 반영 중입니다.
- `codex-pr-review-loop`, `review-waiter-agent`, 메인 오케스트레이터 문서, PR review loop 문서, skill README, 루트 AGENTS/README에 기본 연결 조건을 반영했습니다.
- PR #211 Codex 리뷰에서 운영 가설 로그 누락이 P2로 지적되어 이 문서를 추가했습니다.

## 실제 병목

- 초기 변경은 정책과 agent prompt를 갱신했지만, 운영 가설 로그를 함께 남기지 않아 review loop 운영 방식 변경 근거가 빠졌습니다.
- 상위 README, skill README, 역할별 agent 문서, 루트 AGENTS.md에 같은 의미의 문구를 반복 반영해야 하므로 drift 가능성이 있습니다.

## 사람 확인 지점

- `review-waiter-agent` 기본 연결이 실제 실행 환경에서 백그라운드 감시를 보장하는지 확인해야 합니다.
- “같은 턴에서 polling/timeout 확인을 끝낼 수 없으면”이라는 조건이 너무 넓거나 좁지 않은지 확인해야 합니다.
- Codex review 미설정 fallback PR에 waiter가 붙지 않는 예외가 실제 실행에서 유지되는지 확인해야 합니다.

## 유지할 것

- 호출, `eyes`, 수정 후 push를 종료가 아니라 pending 상태로 분류하는 방식
- pending 상태에서 중복 호출하지 않고 `review-waiter-agent` 또는 같은 턴 polling으로 책임 주체를 유지하는 방식
- 사용자 지정 반복 한도가 없으면 호출 횟수가 아니라 리뷰 결과와 지적 분류 상태로 종료하는 방식

## 버릴 것

- `@codex review` 호출만으로 PR loop를 완료 보고하는 방식
- `eyes` 반응 확인만으로 사용자에게 리뷰 대기를 넘기는 방식
- `review-waiter-agent`를 사용자가 명시해야만 쓰는 선택 실행자로만 보는 방식

## 0계층 반영 위치

- 문서: `AGENTS.md`, `system/README.md`, `system/40-pr-review-loop/README.md`, `system/40-pr-review-loop/02-review-policy.md`, `system/60-operating-hypotheses/OH-0007-review-waiter-default.md`
- skill: `system/20-skills/codex-pr-review-loop/SKILL.md`, `system/20-skills/README.md`
- agent prompt: `system/10-agents/main.md`, `system/10-agents/main-orchestrator/README.md`, `system/10-agents/main-orchestrator/main-prompt.md`, `system/10-agents/review-waiter/README.md`

## 후속 운영 가설 후보

- Codex review 호출, `eyes`, review body, inline comment 수집을 단일 스크립트로 표준화하면 waiter 실행 실패가 줄어드는가
- 실제 백그라운드 실행자가 없는 환경에서 PR loop 상태를 local queue 또는 PR comment state로 고정하면 대기 유실이 줄어드는가
