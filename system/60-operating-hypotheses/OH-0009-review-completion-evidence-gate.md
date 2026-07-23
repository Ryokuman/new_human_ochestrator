# 리뷰 완료 증거 안정화 gate 가설

## ID

OH-0009

## 상태

draft

## 기간

- 시작: 2026-07-10
- 종료 또는 폐기:

## 상태 재검증

- 최근 재검증: 2026-07-10
- 최근 근거: PR #460에서 일반 task summary를 동등 pass로 오판한 뒤 같은 head의 formal review와 P2 4건이 늦게 도착한 사건을 확인했습니다.
- 다음 재검증 조건: 이 gate를 적용한 실제 PR 3건에서 formal review/no-finding 완료 신호, 안정화 재조회, P2 분류 결과를 비교합니다.
- 외부 PR 근거: `https://github.com/Ryokuman/my_ochestrator/pull/460`

## 운영 가설

`eyes` 이후 formal review 완료 증거를 기다리고, reviews·issue comments·inline comments·`reviewThreads`를 최소 30초 간격으로 안정화 재조회하면 일반 task summary를 pass로 오판하거나 늦게 도착한 P2를 놓치는 조기 종료를 줄일 수 있습니다.

## 채택 이유

기존 규칙은 최신 head와 P2 분류를 요구했지만 어떤 GitHub 객체가 리뷰 완료 증거인지와 첫 조회 이후의 안정화 시점을 명시하지 않았습니다. 이 빈틈은 일반 issue comment를 formal review처럼 해석하고 아직 생성되지 않은 inline comments를 빈 결과로 확정할 여지를 허용했으며, PR #460에서 실제로 해당 오판이 발생했습니다.

## 취합한 정보

- RED 기준선: PR #460의 리뷰 호출 댓글 `issuecomment-4932116594`에 2026-07-10 04:54:25Z `eyes`가 확인됐습니다.
- 일반 task summary `issuecomment-4932130679`는 04:56:55Z에 `추가 수정 요청 없음`, `다음 행동 없음`을 남겼지만 formal review가 아니었습니다.
- 잘못된 상태 댓글 `issuecomment-4932132402`는 04:57:18Z에 `동등 pass`, `P2 이상 0건`을 확정했습니다.
- 같은 head `d13ff39c7c55e26b43caa97234911fc37ebafe9d`의 formal review `pullrequestreview-4668615367`은 04:58:32Z에 제출됐고 inline P2 4건을 포함했습니다.
- 잘못된 pass 상태 댓글과 formal review 사이에는 74초, `eyes`와 formal review 사이에는 247초가 있었습니다.

## 기존 방식의 문제

- 일반 issue comment와 formal `pull_request_review`의 증거 유형을 구분하지 않았습니다.
- `추가 수정 요청 없음`, `actionable 변경 지시 없음`, `다음 행동 없음`을 동등 pass로 해석할 여지가 있었습니다.
- reviews, inline comments, `reviewThreads` 가운데 일부만 첫 조회하고 빈 결과를 P2 0건으로 확정할 수 있었습니다.
- formal review 객체와 inline comments가 늦게 보이는 race에 대한 최소 안정화 재조회가 없었습니다.
- PR 상태 댓글과 최종 보고가 completion evidence보다 먼저 작성될 수 있었습니다.

## 예상 병목

- Codex review loop에서 formal review 또는 no-finding 완료 신호를 받은 PR마다 최소 30초의 추가 대기 시간이 생깁니다.
- GitHub REST reviews/comments와 GraphQL `reviewThreads`의 갱신 시점이 다를 수 있습니다.
- no-finding이 formal review body가 아니라 리뷰 트리거의 `thumbs-up` 반응으로 표현되는 저장소가 있습니다.
- API 일부를 조회할 수 없을 때 pass 대신 조회 불완전으로 중단해야 하므로 사용자 대기 시간이 늘 수 있습니다.

## 적용한 작업 방식

- exact pass, 동등 pass, 일반 task summary를 서로 다른 증거 유형으로 정의합니다.
- 일반 issue comment는 pass 증거에서 제외하되 최신 head의 actionable finding이면 수집합니다.
- `eyes` 대기 중에도 issue comments를 계속 조회해 actionable finding이면 formal 완료 신호 전이라도 즉시 분류·처리합니다.
- `eyes` 뒤 formal review 또는 저장소에서 확인 가능한 명시적 no-finding 완료 신호가 올 때까지 최대 15분 대기를 유지합니다.
- 완료 신호 뒤 reviews, inline comments, `reviewThreads`를 즉시 조회하고 최소 30초 뒤 다시 조회합니다.
- 새 evidence가 생기면 안정화 구간을 다시 시작하고, 연속 두 snapshot이 같을 때만 P2 분류를 확정합니다.
- completion-evidence gate 전에는 exact pass, 동등 pass, 최종 P2 0건, 리뷰 통과 상태를 작성하지 않습니다. 대기·timeout·미통과 findings는 별도로 보고합니다.
- findings-only formal review는 evidence 수집 시작 신호로만 보고 pass 완료 신호와 구분합니다. snapshot은 객체 ID, 대상 commit, 수정 시각, body digest, reaction, review/thread 상태까지 비교합니다.
- 안정화된 findings의 P2 건수와 분류는 `리뷰 미통과 findings`로 gate 전에도 기록해 수정 단계로 전달합니다. exact pass, 동등 pass, 최종 P2 0건, 리뷰 통과 상태만 gate 뒤 확정합니다.

## 적용 범위

- 0계층과 project 계층의 Codex PR review loop
- `review-waiter-agent`가 관리하는 review 대기
- PR 상태 댓글과 사용자 대상 최종 리뷰 보고

## 실행 결과

- RED: PR #460에서 일반 task summary를 동등 pass로 오판하고 74초 뒤 도착한 formal review의 P2 4건을 놓친 실패를 재현 evidence로 고정했습니다.
- GREEN: 변경된 skill을 읽은 별도 압력 시나리오 에이전트가 일반 summary와 첫 빈 조회에서 종료하지 않고, findings-only formal review를 비-pass 수집 시작 신호로 구분한 뒤 30초 안정화 재조회 후 같은 head의 P2 4건을 처리해야 한다고 판정했습니다. 허점 보강 뒤 같은 시나리오 재검증도 통과했습니다.

## 실제 병목

- 기존 문서 여러 곳에 15분 대기와 P2 분류가 중복돼 있어 skill, review-waiter, README의 정합화가 필요했습니다.
- GitHub issue comment와 formal review가 같은 Codex 주체에서 생성될 수 있어 작성자만으로 증거 유형을 구분할 수 없었습니다.
- 첫 GREEN 검증에서 findings-only formal review가 수집 시작 신호인지 pass 완료 신호인지와 snapshot 동일성 필드가 모호하다는 허점을 발견해 규칙을 보강했습니다.
- PR #464 첫 formal review에서 일반 issue comment의 pass 역할과 actionable finding 역할을 함께 제외하면 지적을 놓칠 수 있다는 P2가 발견돼, pass 증거와 finding 수집 역할을 분리했습니다.
- PR #464 두 번째 formal review에서 issue comment 수집을 완료 신호 뒤로 미루면 단독·선행 actionable finding 처리가 늦어진다는 P2가 발견돼, `eyes` 대기 poll에도 issue comment 분류를 추가했습니다.
- PR #464 세 번째 formal review에서 축약된 main orchestrator 문구가 이전 head 호출의 `eyes`까지 대기 근거로 오인할 수 있다는 P2가 발견돼, 모든 대기 기준을 현재 head push 이후 호출로 한정했습니다.
- PR #464 네 번째 formal review에서 review-waiter의 `즉시 분류` 뒤 수정 이동이 명시되지 않아 대기를 계속할 여지가 있다는 P2가 발견돼, 분류별 다음 동작을 prompt에 명시했습니다.
- PR #464 다섯 번째 formal review에서 SHA가 없는 단독 issue comment finding이 누락될 수 있다는 P2가 발견돼, Codex가 현재 head push 이후 생성·수정한 시각도 최신 head 귀속 근거로 추가했습니다.
- 해당 귀속 규칙의 GREEN 검증에서 이전 head 작업이 현재 head 요청 뒤 늦게 게시될 race를 발견해, 작성 시각 단독 귀속을 폐기하고 현재 head 코드·diff 적용 여부 대조와 `head 귀속 불명확` 차단 분기를 추가했습니다.
- PR #464 최신 head에서 `Codex Review`, exact phrase, reviewed commit을 함께 가진 no-finding issue comment가 실제 완료 신호로 도착해, 일반 task summary와 명시적 no-finding 완료 comment를 분리했습니다.

## 사람 확인 지점

- 저장소가 no-finding 완료 신호로 사용하는 반응이 `thumbs-up`인지 확인해야 합니다.
- 30초 안정화 구간이 실제 GitHub 전달 지연에 충분한지는 반복 PR evidence로 재검증해야 합니다.
- API 일부 조회 불가를 pass가 아닌 불완전 상태로 보고했는지 확인해야 합니다.

## 유지할 것

- 최신 head와 부모 review commit을 대조하는 기존 기준
- P2 이상 지적의 `수정 필요`, `수비 가능`, `사용자 판단 필요` 분류
- `eyes` 이후 최대 15분 대기와 같은 head 중복 호출 금지

## 버릴 것

- 일반 task summary를 동등 pass로 해석하는 방식
- 첫 빈 조회로 P2 0건을 확정하는 방식
- completion evidence 안정화 전에 exact pass, 동등 pass, 최종 P2 0건, 리뷰 통과 상태를 작성하는 방식

## 0계층 반영 위치

- 반영 완료: 변경 브랜치에서 규칙과 agent prompt 초안 작성
- 반영 후보: `main-v3/main` 대상 PR 머지 후 기본 운영 적용
- 미구현 후보: reviews/comments/reviewThreads 안정화 snapshot 자동 수집 도구
- 문서: `AGENTS.md`, `system/README.md`, `system/40-pr-review-loop/README.md`
- skill: `system/20-skills/codex-pr-review-loop/SKILL.md`, `system/20-skills/main-branch-update-flow/SKILL.md`
- agent prompt: `system/10-agents/review-waiter/README.md`, `system/10-agents/review-waiter/main-prompt.md`
- 적용 단계: PR 반영 전 검증 중
- 검증 상태: RED 확인, GREEN 1차 통과 후 허점 보강, GREEN 재검증 통과
- PR 번호:
- 적용 단계 메모: 실제 PR 3건의 완료 evidence와 P2 분류 누락 여부를 확인한 뒤 active 승격을 검토합니다.

## 후속 운영 가설 후보

- 세 API surface의 snapshot을 한 번에 수집하고 head별 digest를 만드는 도구가 수동 분류 누락을 더 줄이는가
- 30초 고정 안정화보다 새 evidence 시각 기반 적응형 안정화가 대기 시간과 누락률을 함께 줄이는가
