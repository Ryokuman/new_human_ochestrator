---
name: codex-pr-review-loop
description: 0계층 공통 변경만 담은 main-v2 대상 PR에 Codex 리뷰 gate가 필요하거나, 사용자가 "Didn't find any major issues" 응답이 나올 때까지 반복하라고 요청하거나, task/PR에 횟수 제한 없는 no-major Codex 리뷰 루프를 적용해야 할 때 사용합니다.
---

# Codex PR 리뷰 루프

이 skill은 0계층 공통 변경이 `main-v2` 대상 PR로 분리된 뒤 Codex no-major 리뷰 목표를 실제 실행 계약으로 세팅하고, 최신 head가 no-major 상태가 될 때까지 수정, 검증, 재리뷰를 반복하게 합니다.

branch base는 먼저 계층으로 판단합니다. GitHub PR target/base branch가 `main-v2`인지 확인하는 단계는, 해당 변경이 0계층 system update로 분리된 뒤의 최종 확인입니다. project SSoT, task, issue, QA, decision, coverage 같은 1계층 이상 변경을 이 skill 때문에 `main-v2` PR로 retarget하지 않습니다.

## 실패 압력

정책 문서만 고치고 신규 skill을 만들지 않으면 실패입니다. 이 skill을 사용했다면 아래 중 하나 이상의 실행 흔적이 남아야 합니다.

- task silo의 `goal.md`에 Codex no-major 목표가 추가됨
- PR 댓글에 외부 리뷰 요청문으로 `@codex review`가 호출됨
- PR 본문 `Codex PR 리뷰` 항목에 최신 head 기준 리뷰 상태가 기록됨

## 내부 목표 문구

기본 `/goal`은 아래 문구입니다. 이 문구는 메인 에이전트가 루프를 운영하기 위한 내부 실행 계약이며, `@codex review` 댓글에 그대로 붙이지 않습니다.

```text
codex review 가 Didn't find any major issues라고 응답 할 때까지 수정을 반복해 주세요, 횟수제한은 두지 않겠습니다.
```

Codex 실제 응답은 `Didn't find any major issues` 명시 문구여야 합니다. 요약형 응답, `추가 수정 없음`, `다음 행동 없음`, `no-major와 동등해 보이는 상태`는 통과로 보지 않습니다.

## 외부 리뷰 댓글 문구

`@codex review` 호출 댓글은 리뷰어에게 전달할 요청만 담습니다.

```text
@codex review

한국어로 리뷰해 주세요.

최신 head `<head-sha>` 기준으로 변경사항을 리뷰해 주세요.
```

반복 횟수, exact pass phrase, 통과 판정 방식은 외부 리뷰어에게 강제하지 않고, PR 본문 `Codex PR 리뷰` 항목이나 task silo의 `goal.md`에서 메인 에이전트가 관리합니다.

## 실행 절차

1. repo, PR 번호, 현재 branch, dirty state, head SHA를 확인합니다.
2. 변경 내용이 0계층 공통 변경으로 분리된 PR인지 확인합니다. project SSoT 원문이나 1계층 이상 project 변경이 포함되어 있으면 이 skill을 적용하지 않고 계층 분리 필요로 보고합니다.
3. GitHub PR target/base branch를 확인합니다. target/base가 `main-v2`가 아니면 이 skill로 `@codex review`를 호출하지 않고, 해당 project gate 또는 계층 기준 브랜치 불일치로 보고합니다.
4. task silo의 `goal.md`가 있으면 내부 목표 문구와 PR URL, head SHA, 검증 기준을 추가합니다. `goal.md`가 없으면 PR 본문 `Codex PR 리뷰` 항목에 내부 목표와 현재 상태를 남깁니다.
5. 최신 head push 이후의 `@codex review` 호출 댓글, `eyes` 반응, Codex 리뷰 결과를 확인합니다.
6. 최신 head 이후 호출 댓글에 `eyes` 반응이 있고 아직 리뷰 결과가 없으면 중복 호출하지 않고 대기 상태로 보고합니다.
7. 최신 head에 대한 리뷰 요청이 없으면 PR 댓글로 `@codex review`를 호출하고, 외부 리뷰 댓글 문구만 적습니다.
8. Codex 결과가 도착하면 최신 head에 대해 `Didn't find any major issues`라고 명시 응답했는지 확인합니다.
9. actionable major/critical/P1/P2 또는 보호 절차 위반 지적이 있으면 validity를 판단하고 타당한 항목만 수정합니다.
10. 수정 후 변경 범위에 맞는 검증을 실행하고, 한국어 커밋 메시지로 커밋한 뒤 push합니다.
11. PR 댓글 또는 본문에 수정 내용, 검증 결과, 남은 위험, 새 head SHA를 기록하고 5번으로 돌아갑니다.

## 종료 기준

- 최신 head에 대한 Codex 결과가 `Didn't find any major issues`라고 명시 응답했습니다.
- 같은 head에 대해 진행 중인 `eyes` 반응이 있으면 종료가 아니라 대기입니다.
- 사용자가 명시한 반복 한도가 없으면 횟수 제한으로 중단하지 않습니다.

## 금지

- formal GitHub approve 리뷰 객체가 없다는 이유만으로 `Didn't find any major issues` 명시 응답을 무시하지 않습니다.
- 이전 head의 no-major 결과를 현재 head의 승인으로 재사용하지 않습니다.
- 최신 head 이후 `eyes` 반응이 붙은 호출이 있는데 같은 head에 중복 호출하지 않습니다.
- PR을 머지하지 않습니다. 머지는 별도 명시 승인 뒤 메인 오케스트레이터가 처리합니다.
- `project/dynamos` 또는 `project/onjump`처럼 project 계층 기준 브랜치가 따로 있는 변경을 이 skill 때문에 `main-v2`로 retarget하지 않습니다.
