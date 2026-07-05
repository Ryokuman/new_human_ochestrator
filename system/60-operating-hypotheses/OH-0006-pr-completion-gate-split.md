# PR completion gate 분리 가설

## ID

OH-0006

## 상태

draft

## 기간

- 시작: 2026-07-03
- 종료 또는 폐기:

## 운영 가설

PR 완료 루프를 하나의 `codex-pr-review-loop`로 계속 확장하지 않고 `pr-completion-loop` 아래의 `pr-authoring-process`, `pr-codex-review-gate`, `pr-agent-browser-e2e-gate`, `pr-runtime-handoff-gate`로 나누면, 각 단계가 자기 책임 밖의 성공을 주장하는 일을 줄이고 PR 종료 전 검증 누락과 handoff 과장을 줄일 수 있다.

## 채택 이유

기존 PR 루프는 Codex no-major 확인, 현재 head 대상 P1/P2 분류, runtime handoff까지 한 흐름 안에서 다뤘다. 여기에 agent-browser E2E까지 같은 skill에 직접 붙이면 리뷰, E2E, handoff의 증거 종류와 실패 복귀 지점이 섞일 수 있다. skill 이름과 gate 이름을 먼저 분리하면 agent가 현재 단계에서 무엇을 증명할 수 있고 무엇을 증명할 수 없는지 더 명확하게 제한할 수 있다.

## 취합한 정보

- 사용자 피드백: PR handoff 전에 agent-browser로 예상 플로우를 실행하고, 검증이 완료될 때까지 PR loop를 반복하고 싶다.
- 사용자 피드백: PR에는 작성, 리뷰, E2E, handoff 성격의 프로세스가 있으며 작성 외 단계는 다시 작성 프로세스를 재호출할 수 있다.
- 사용자 피드백: 리뷰 프로세스의 주체는 Codex review이며 no-major가 아니면 작성 프로세스를 재호출해야 한다.
- 사용자 피드백: E2E 프로세스의 주체는 별도 background agent와 agent-browser이며, 사일로 내부 서버를 대상으로 사용자가 확인할 플로우를 먼저 검증해야 한다.
- 사용자 피드백: 스킬 이름부터 gate를 적절히 나누면 할루시네이션을 줄일 수 있는지 검토가 필요하다.
- 사용자 선택: 이후 PR loop 개편안의 기준 명칭을 `pr-completion-loop`, `pr-authoring-process`, `pr-codex-review-gate`, `pr-agent-browser-e2e-gate`, `pr-runtime-handoff-gate`로 확정했다.
- 기존 0계층 문서: `codex-pr-review-loop`는 최신 head no-major와 현재 head 대상 P1/P2/major/critical 분류를 관리한다.
- 기존 0계층 문서: `silo-runtime-handoff`는 no-major 이후 사용자 재리뷰 전 서버 주소와 E2E 방법을 PR 댓글로 남기지만, agent-browser E2E 통과 자체를 독립 gate로 요구하지는 않는다.

## 기존 방식의 문제

- `codex-pr-review-loop`가 계속 커지면 Codex 리뷰 통과, browser E2E 통과, runtime handoff 작성이 한 skill 안에서 섞일 수 있다.
- handoff가 E2E 전에 작성되면 실행 방법 안내와 검증 통과 증거가 뒤섞일 수 있다.
- agent-browser 검증 실패 후 QA agent가 직접 코드를 고치면 작성 주체와 검증 주체가 섞이고, 같은 PR head에서 충돌이 생길 수 있다.
- E2E 실패 후 작성 프로세스가 새 commit을 push했는데도 이전 리뷰 또는 E2E 결과를 재사용하면 stale 증거로 PR 종료를 주장할 수 있다.
- `예상 플로우`라는 표현만으로는 scope 밖 화면이나 임의 경로까지 QA 범위에 들어갈 수 있다.

## 예상 병목

- PR마다 E2E 대상 플로우가 `goal.md`, task contract, PR 본문 criteria 중 어디에 가장 명확하게 있는지 다를 수 있다.
- 로그인, secret, 외부 네트워크, production data, destructive action 때문에 agent-browser가 끝까지 실행할 수 없는 플로우가 있다.
- 별도 background agent가 agent-browser 로그, screenshot, 실패 단계, 기대 결과를 같은 형식으로 남기지 않으면 작성 프로세스가 실패를 재현하기 어렵다.
- 새 commit이 생긴 뒤 어떤 gate 결과를 stale 처리해야 하는지 중앙 상태가 없으면 이전 증거를 잘못 재사용할 수 있다.
- gate를 너무 잘게 나누면 각 skill의 결과를 모으는 오케스트레이션 비용이 늘어날 수 있다.

## 적용한 작업 방식

- 최상위 오케스트레이터 skill 이름은 `pr-completion-loop`로 둔다.
- `pr-completion-loop`는 직접 성공을 주장하지 않고 현재 `head SHA`, 각 gate 결과, 재시도 이력, stale 처리만 관리한다.
- 작성 주체는 `pr-authoring-process`로 제한한다. 코드 수정, PR 본문 갱신, criteria 검증표 갱신, 실패 반영 커밋은 이 프로세스만 수행한다.
- Codex 리뷰는 `pr-codex-review-gate`로 분리한다. 이 gate는 최신 head no-major, 현재 head 대상 P1/P2/major/critical 분류, `수정 필요`/`수비 가능`/`사용자 판단 필요`를 판단한다.
- browser E2E는 `pr-agent-browser-e2e-gate`로 분리한다. 이 gate는 별도 QA/background agent와 agent-browser를 사용해 명시된 사용자 플로우만 검증하고, 직접 코드를 수정하지 않는다.
- runtime handoff는 `pr-runtime-handoff-gate`로 분리한다. 이 gate는 이미 통과한 review/E2E evidence를 바탕으로 서버 주소, 실행 방법, 테스트 입력, 남은 수동 확인을 PR 댓글로 남긴다.
- 모든 gate는 종료 결과를 `status`, `headSha`, `evidence`, `failureReason`, `nextProcess` 형식으로 남긴다.
- `pr-authoring-process`가 새 commit을 push하면 이전 `pr-codex-review-gate`, `pr-agent-browser-e2e-gate`, `pr-runtime-handoff-gate` 결과는 stale 처리한다.
- `pr-agent-browser-e2e-gate`가 실패하면 `pr-authoring-process`로 돌아가고, 새 head가 만들어진 뒤에는 `pr-codex-review-gate`부터 다시 시작한다.

## 적용 범위

- task silo PR
- 실제 제품 코드 변경이 있고 사용자 화면, runtime, browser, manual QA, E2E 확인이 남은 PR
- project 계층 PR 중 제품 repo 또는 runtime submodule의 실행 플로우 검증이 필요한 PR
- 0계층 문서/skill만 바꾸는 PR은 agent-browser E2E 대상에서 제외한다.

## 실행 결과

- 아직 실제 PR에 적용하지 않았다.
- 이번 문서는 다음 PR loop 개편을 위한 운영 가설 초안이다.

## 실제 병목

- 아직 실행 결과가 없다.

## 사람 확인 지점

- `pr-agent-browser-e2e-gate`가 검증할 사용자 플로우를 어디에서 가져올지 확인해야 한다.
- E2E 실행 불가를 `pass`로 볼지, `blocked` 또는 `skipped-with-risk`로 볼지 확인해야 한다.
- handoff 댓글이 E2E 성공을 과장하지 않고 실제 evidence와 남은 수동 확인을 분리했는지 확인해야 한다.
- gate 분리가 PR loop 속도를 지나치게 늦추는지 확인해야 한다.

## 유지할 것

- 작성 주체와 검증 주체를 분리하는 방식
- 새 commit 이후 이전 review/E2E/handoff 결과를 stale 처리하는 방식
- Codex 리뷰 실패와 browser E2E 실패 모두 작성 프로세스로 되돌리는 방식
- handoff는 검증 성공을 새로 판단하지 않고 이미 통과한 test evidence를 사용자에게 넘기는 방식

## 버릴 것

- `codex-pr-review-loop` 하나에 review, E2E, handoff 책임을 계속 붙이는 방식
- handoff를 E2E 검증 전 안내문으로 먼저 작성하는 방식
- QA/background agent가 E2E 실패를 직접 수정하는 방식
- 이전 head의 review 또는 E2E 결과를 새 head의 통과 근거로 재사용하는 방식

## 0계층 반영 위치

- 문서: `system/40-pr-review-loop/README.md`, `system/40-pr-review-loop/02-review-policy.md`, `system/40-pr-review-loop/06-pr-template.md`, `system/60-operating-hypotheses/OH-0006-pr-completion-gate-split.md`
- skill: `system/20-skills/codex-pr-review-loop/SKILL.md`, `system/20-skills/silo-runtime-handoff/SKILL.md`, 신규 또는 개편 후보 `pr-completion-loop`, `pr-agent-browser-e2e-gate`
- agent prompt: `system/10-agents/main-orchestrator/main-prompt.md`, `system/10-agents/review-waiter/main-prompt.md`, QA/background agent prompt 후보

## 후속 운영 가설 후보

- `pr-agent-browser-e2e-gate`의 evidence schema를 고정하면 E2E 실패 재현과 작성 프로세스 재호출 시간이 줄어드는가
- `pr-completion-loop`가 gate 결과를 PR 본문 또는 사일로 `goal.md`에 구조화해 동기화하면 stale evidence 재사용이 줄어드는가
- E2E 실행 불가를 `blocked`, `skipped-with-risk`, `manual-required`로 나누면 사용자 handoff 품질이 높아지는가
