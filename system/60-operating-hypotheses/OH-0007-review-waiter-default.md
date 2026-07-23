# PR 리뷰 대기 실행자 기본 연결 가설

## ID

OH-0007

## 상태

draft

## 기간

- 시작: 2026-07-06
- 종료 또는 폐기:

## 상태 재검증

- 최근 재검증: 2026-07-07
- 최근 근거: `codex-pr-review-loop`, `review-waiter/README.md`, `review-waiter/main-prompt.md`, `main-orchestrator` 문서에는 pending 상태를 종료 불가로 보고 `review-waiter-agent`를 기본 연결하는 규칙이 있습니다.
- 다음 재검증 조건: 실제 PR에서 `eyes` 진행 중, 호출 직후 접수 확인 전, 수정 후 최신 head 재리뷰 결과 없음 상태를 `review-waiter-agent`가 끝까지 관리한 기록이 생기면 실행 결과와 실제 병목을 갱신합니다.
- 외부 PR 근거: PR #211 `PR 리뷰 대기 실행자 기본 연결 반영`은 2026-07-05에 `main-v3/main`으로 머지됐습니다. URL은 `https://github.com/Ryokuman/my_ochestrator/pull/211`, merge commit은 `149cac43b27d8b312a3ffd72d96371045a56c2c7`입니다. PR #211의 반영 파일에는 `review-waiter/README.md`는 있었지만 `review-waiter/main-prompt.md`는 없었으므로, 현재 실행 prompt 추적성은 별도 현재 파일 확인 근거로 둡니다.

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
- 현재 문서가 보장하는 것은 종료 불가 상태 분류와 기본 연결 판단입니다. 실제 백그라운드 프로세스가 항상 유지되는지, queue 상태를 어디에 영속 기록하는지는 아직 검증 전입니다.

## 적용 범위

- 0계층 `main-v3/main` 대상 PR
- project 계층 PR
- `codex-pr-review-loop`를 사용하는 PR 리뷰 gate
- `review-waiter-agent`가 관리하는 Codex 리뷰 대기, 수정, 재리뷰 루프

## 실행 결과

- PR #211에서 초기 반영 후보로 다뤘고, 해당 PR은 `main-v3/main`에 머지됐습니다.
- `codex-pr-review-loop`, `review-waiter-agent`, 메인 오케스트레이터 문서, PR review loop 문서, skill README, 루트 AGENTS/README에 기본 연결 조건을 반영했습니다.
- PR #211 Codex 리뷰에서 운영 가설 로그 누락이 P2로 지적되어 이 문서를 추가했습니다.
- 현재 실행 prompt 추적성을 맞추기 위해 `system/10-agents/review-waiter/main-prompt.md`도 0계층 반영 위치에 포함합니다. PR #211 반영 파일 목록에는 이 prompt가 없었으므로, 이 항목은 현재 파일 존재 기준의 추적 보강입니다.
- 다만 실제 PR 대기 세션에서 백그라운드 감시가 끝까지 유지됐는지, queue 또는 PR comment state가 어디에 남았는지는 아직 이 원문에 기록돼 있지 않습니다.

## 실제 병목

- 초기 변경은 정책과 agent prompt를 갱신했지만, 운영 가설 로그를 함께 남기지 않아 review loop 운영 방식 변경 근거가 빠졌습니다.
- 상위 README, skill README, 역할별 agent 문서, 루트 AGENTS.md에 같은 의미의 문구를 반복 반영해야 하므로 drift 가능성이 있습니다.
- 기본 연결 문구가 실제 실행 보장을 뜻하는 것처럼 읽히면, 백그라운드 실행자가 없는 환경에서 pending 상태가 다시 유실될 수 있습니다.
- 같은 턴 polling과 별도 waiter 연결의 상태 기록 위치가 PR 본문, task silo `goal.md`, 리뷰 댓글, 로컬 queue 후보 중 어디인지 고정되지 않았습니다.
- 문서 반영 완료와 반복 PR 검증 완료가 섞이면 README에서 `draft`가 미반영 상태처럼 읽힐 수 있습니다.

## 사람 확인 지점

- `review-waiter-agent` 기본 연결이 실제 실행 환경에서 백그라운드 감시를 보장하는지 확인해야 합니다.
- “같은 턴에서 polling/timeout 확인을 끝낼 수 없으면”이라는 조건이 너무 넓거나 좁지 않은지 확인해야 합니다.
- Codex review 미설정 fallback PR에 waiter가 붙지 않는 예외가 실제 실행에서 유지되는지 확인해야 합니다.
- pending 상태의 최소 기록 위치를 PR 본문, PR 댓글, task silo `goal.md`, 또는 로컬 queue 중 어디로 둘지 확인해야 합니다.

## 유지할 것

- 호출, `eyes`, 수정 후 push를 종료가 아니라 pending 상태로 분류하는 방식
- pending 상태에서 중복 호출하지 않고 `review-waiter-agent` 또는 같은 턴 polling으로 책임 주체를 유지하는 방식
- 사용자 지정 반복 한도가 없으면 호출 횟수가 아니라 리뷰 결과와 지적 분류 상태로 종료하는 방식

## 버릴 것

- `@codex review` 호출만으로 PR loop를 완료 보고하는 방식
- `eyes` 반응 확인만으로 사용자에게 리뷰 대기를 넘기는 방식
- `review-waiter-agent`를 사용자가 명시해야만 쓰는 선택 실행자로만 보는 방식

## 0계층 반영 위치

- 반영 완료:
  - 문서: `AGENTS.md`, `system/README.md`, `system/40-pr-review-loop/README.md`, `system/40-pr-review-loop/02-review-policy.md`, `system/60-operating-hypotheses/OH-0007-review-waiter-default.md`
  - skill: `system/20-skills/codex-pr-review-loop/SKILL.md`, `system/20-skills/README.md`
  - agent prompt: `system/10-agents/main.md`, `system/10-agents/main-orchestrator/README.md`, `system/10-agents/main-orchestrator/main-prompt.md`, `system/10-agents/review-waiter/README.md`, `system/10-agents/review-waiter/main-prompt.md`
- 반영 후보:
  - pending 상태를 PR 본문, PR 댓글, task silo `goal.md`, 또는 local queue 중 어디에 기록할지 결정하는 규칙
  - 실제 백그라운드 실행 보장 또는 대체 queue 운영 방식
- 미구현 후보:
  - review-waiter queue 상태 저장소
  - Codex review 호출, `eyes`, review body, inline comment 수집 표준 스크립트

## 후속 운영 가설 후보

- Codex review 호출, `eyes`, review body, inline comment 수집을 단일 스크립트로 표준화하면 waiter 실행 실패가 줄어드는가
- 실제 백그라운드 실행자가 없는 환경에서 PR loop 상태를 local queue 또는 PR comment state로 고정하면 대기 유실이 줄어드는가
