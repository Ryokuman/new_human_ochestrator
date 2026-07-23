# 현재 head 대상 리뷰 분류 가설

## ID

OH-0004

## 상태

draft

## 기간

- 시작: 2026-07-03
- 종료 또는 폐기:

## 상태 재검증

- 최근 재검증: 2026-07-07
- 최근 근거: `codex-pr-review-loop`, `review-waiter/main-prompt.md`, `main-orchestrator/main-prompt.md`, PR review policy에 현재 head 대상 지적 분류와 stale review 배제 기준이 반영돼 있음을 확인했습니다.
- 다음 재검증 조건: PR #196 또는 대체 실제 PR 사례의 state, base/head, merge commit, review/comment 수집 근거를 재조회하거나 review API 수집 방식이 바뀌면 갱신합니다.
- 외부 PR 근거: PR #196 `Codex PR 리뷰 P1 P2 분류 규칙 보강`은 2026-07-03에 `main-v2`로 머지됐습니다. URL은 `https://github.com/Ryokuman/my_ochestrator/pull/196`, merge commit은 `df620319622027e65a65f3879bbd5e3a105fb9ba`입니다. 현재 `main-v3/main`에서는 관련 규칙 파일이 존재하지만, 반복 PR 적용 결과가 더 필요하므로 `draft`를 유지합니다.

## 운영 가설

Codex PR 리뷰 루프의 종료 기준은 no-major 문구 단독이 아니라 현재 head 대상 P1/P2/major/critical 지적 분류까지 포함한다. 이 방식은 no-major 응답과 inline P1/P2 지적이 함께 있는 PR에서 loop가 잘못 종료되는 문제를 줄이기 위한 현재 기본 운영 규칙이다.

## 채택 이유

PR 리뷰 봇은 review body에 no-major 또는 그와 유사한 요약을 남기면서도 같은 commit에 inline P1/P2 지적을 남길 수 있다. 반대로 P1/P2처럼 보이는 지적 중 일부는 사용자 결정, project contract, PR scope, 의도된 예외로 수비 가능할 수 있다. 따라서 종료 기준은 단순 문구가 아니라 현재 head 대상 지적의 분류 상태여야 한다.

## 취합한 정보

- 사용자 피드백: `Didn't find any major issues` 또는 유사 응답이 있어도 P1/P2가 남아 PR loop가 끊길 수 있다.
- 사용자 피드백: P1/P2 중에도 수비 가능한 항목이 있다. 예를 들어 특정 프로젝트에서 project contract 작성을 생략해도 되는 결정이 있으면 contract 누락 지적은 수비 가능하다.
- PR #196 실행 관찰: Codex review body는 요약형 응답을 남기면서 inline P2를 별도로 제시했다.
- PR #196 실행 관찰: 이전 head 리뷰가 새 push 이후 늦게 게시되면 작성 시각만으로 현재 head 이후 지적처럼 보일 수 있다.
- PR #196 실행 관찰: GitHub inline comment의 현재 `commit_id`가 최신 diff 위치로 재매핑될 수 있어, comment의 `commit_id`만 보면 이전 review의 P2가 현재 head 지적으로 섞일 수 있다.

## 기존 방식의 문제

- no-major 문구를 발견하면 같은 commit의 inline P1/P2를 놓칠 수 있었다.
- 모든 P1/P2를 blocker로 고정하면 사용자 결정이나 project contract로 수비 가능한 지적까지 불필요하게 수정할 수 있었다.
- 작성 시각만 기준으로 리뷰를 수집하면 stale review/comment가 현재 head 지적으로 섞일 수 있었다.
- 수정 없는 통과 경로에서도 review-waiter가 검증/커밋/push 단계로 떨어질 수 있었다.

## 예상 병목

- GitHub review, issue comment, inline comment의 대상 commit 확인 방식이 도구별로 다를 수 있다.
- 외부 리뷰 봇의 no-major 문구가 exact phrase가 아니라 동등 표현으로 올 수 있다.
- 수비 가능 근거가 PR 본문, `goal.md`, project contract, 사용자 결정 중 어디에 있는지 빠르게 찾지 못할 수 있다.
- 수비 가능한 항목을 agent 추론만으로 닫으려는 유혹이 생길 수 있다.

## 적용한 작업 방식

- `codex-pr-review-loop`는 no-major를 통과 후보로만 보고, 현재 head 대상 P1/P2/major/critical 지적을 모두 수집한다.
- 수집 대상은 현재 head commit SHA와 일치하는 Codex review body, 부모 review의 대상 commit 또는 `original_commit_id`가 현재 head와 일치하는 inline review comment, 또는 호출 댓글에 적힌 head SHA가 현재 head와 일치하는 Codex 댓글로 제한한다.
- 지적은 `수정 필요`, `수비 가능`, `사용자 판단 필요`로 분류한다.
- `수비 가능`은 사용자 결정, project contract, `goal.md`, PR scope, 코드/문서 근거 중 하나를 기록한 경우에만 인정한다.
- review-waiter는 수정 diff가 있을 때만 검증, 커밋, push 단계로 내려간다.

## 적용 범위

- 0계층 `main-v3/main` 대상 PR
- project 계층 PR
- task silo PR
- `review-waiter-agent`가 관리하는 PR 리뷰 대기 루프

## 실행 결과

- PR #196에서 초기 반영됐고, 해당 PR은 2026-07-03에 `main-v2`로 머지됐습니다.
- 같은 PR에서 no-major처럼 보이는 review body와 inline P2가 함께 오는 사례를 확인했고, P2를 수정한 뒤 재리뷰를 반복했습니다.
- 현재 `main-v3/main`에도 관련 review loop 규칙 파일이 존재하지만, 반복 PR 적용 결과가 더 필요하므로 `draft`를 유지합니다.

## 실제 병목

- PR 본문 갱신 중 shell heredoc quoting 실수로 본문이 비는 문제가 발생했고, 즉시 복구했다.
- Codex review body만으로는 통과 여부를 알 수 없어 inline comment API 조회가 필요했다.
- inline comment API의 현재 `commit_id`만으로 stale 여부를 판단하면 안 되고, `pull_request_review_id`로 부모 review 대상 commit을 함께 조회해야 했다.
- no-major가 없는 실패 라운드에서도 P1/P2/major/critical 지적을 수집해야 하므로, no-major 응답이 있는 경우에만 수집하는 문구는 review-waiter 경로에서 병목이 된다.
- `수정 필요`와 `사용자 판단 필요`가 함께 있을 때 사용자 판단 보고를 먼저 하면 수정 diff가 commit/push되지 않은 채 멈출 수 있다.
- 운영 가설 기록 누락이 P2로 지적되어 이 문서를 추가했다.

## 사람 확인 지점

- `수비 가능` 근거가 실제 사용자 결정 또는 project contract에 기반했는지 확인해야 한다.
- exact `Didn't find any major issues`와 동등 no-major 판정을 보고에서 분리했는지 확인해야 한다.
- stale review/comment를 현재 head 지적으로 섞지 않았는지 확인해야 한다.

## 유지할 것

- no-major 문구를 통과 후보로만 보고 현재 head 대상 inline 지적을 함께 확인하는 방식
- P1/P2를 `수정 필요`, `수비 가능`, `사용자 판단 필요`로 분리하는 방식
- 수비 가능 근거를 PR 본문 또는 review thread에 남기는 방식

## 버릴 것

- no-major 문구만으로 PR loop를 종료하는 방식
- 작성 시각만으로 stale review/comment를 현재 head 지적으로 수집하는 방식
- 수정 diff가 없는데도 빈 커밋이나 push를 시도하는 방식

## 0계층 반영 위치

- 문서: `system/40-pr-review-loop/02-review-policy.md`, `system/30-silo-system/20-silo-workflow/review-gate.md`, `system/60-operating-hypotheses/OH-0004-current-head-review-classification.md`
- skill: `system/20-skills/codex-pr-review-loop/SKILL.md`, `system/20-skills/main-branch-update-flow/SKILL.md`
- agent prompt: `system/10-agents/review-waiter/main-prompt.md`, `system/10-agents/main-orchestrator/main-prompt.md`

## 후속 운영 가설 후보

- PR review API 조회와 inline comment 수집을 스크립트화하면 no-major와 P1/P2 분류 누락이 더 줄어드는가
- 수비 가능 근거를 PR 본문 템플릿 필드로 구조화하면 사용자 판단 필요 항목이 줄어드는가
