---
name: codex-pr-review-loop
description: PR 유형을 계층별로 판정한 뒤 0계층 main-v2 PR 또는 project 계층 PR에 Codex 리뷰 gate가 필요하거나, 사용자가 "Didn't find any major issues" 등 no-major 응답이 나올 때까지 반복하라고 요청할 때 사용합니다.
---

# Codex PR 리뷰 루프

이 skill은 PR 유형이 판정된 뒤 Codex no-major 리뷰 목표를 실제 실행 계약으로 세팅하고, 최신 head가 no-major 상태가 될 때까지 응답 대기, 수정, 검증, 재리뷰를 반복하게 합니다.

branch base는 먼저 계층으로 판단합니다. 0계층 공통 변경은 `main-v2`, project 등록/색인 및 project SSoT, task, issue, QA, decision, coverage 같은 project 계층 변경은 해당 `project/<project-id>`가 기준입니다. GitHub PR target/base branch는 이 계층 판단 결과를 반영한 최종 머지 대상입니다. project 변경을 이 skill 때문에 `main-v2` PR로 retarget하지 않습니다. project 계층 PR은 기준 `project/<project-id>` 브랜치에 직접 커밋한 PR이 아니라, `project/<project-id>-<branch-name>` 작업 브랜치에서 커밋한 PR이어야 합니다.

사용자가 “PR을 올려 주세요”라고 말하면 아래 순서가 기본입니다.

1. 현재 브랜치의 0계층 공통 변경과 project 계층 변경을 판정합니다.
2. 올려야 할 PR 유형을 `0계층 main-v2 PR`, `project 계층 PR`, `복합 PR 분리 필요`로 나눕니다.
3. 0계층과 project 계층이 섞여 있으면 worktree와 브랜치를 나눠 서로 다른 PR로 올립니다.
4. project 계층 PR이면 PR head branch가 기준 `project/<project-id>`와 같은지, 또는 현재 로컬 작업 위치가 해당 기준 브랜치 직접 checkout인지 확인합니다. 둘 중 하나라도 해당하면 `@codex review`를 호출하지 않고 `project/<project-id>-<branch-name>` 작업 브랜치로 PR을 재생성해야 한다고 보고합니다.
5. 제품 repo PR이 독립 git submodule의 gitlink를 pin한다면 변경된 submodule repo마다 별도 PR과 Codex no-major 또는 동등 리뷰 gate가 있는지 확인합니다. submodule repo 자체 리뷰가 없으면 상위 제품 repo PR의 no-major만으로 완료 처리하지 않습니다.
6. 새 submodule repo PR이면 repo 생성 의의, submodule 유형, 제품 적용 기준, 평가 기준, 검증 한계, pin 조건이 PR 본문에 있는지 확인합니다. 기본 브랜치에는 빈 기준 또는 최소 후보만 두고 실제 코드는 PR에서 평가하는 흐름을 우선합니다.
7. PR을 만든 뒤 해당 PR의 target/base branch가 계층 판단과 맞는지 확인하고 `@codex review`를 호출합니다.
8. 사용자 응답을 기다리지 않고 이 skill의 대기/수정/재요청 루프를 수행합니다.

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

Codex 실제 응답은 `Didn't find any major issues` 또는 그와 동등하게 최신 head에 major/actionable 지적이 없다는 명시 응답이어야 합니다. 단순 `추가 수정 없음`, `다음 행동 없음`, 사람이 추정한 no-major 상태는 통과로 보지 않습니다.

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
2. 변경 내용을 0계층 공통 변경, project 계층 변경, 복합 변경으로 분류합니다.
3. GitHub PR target/base branch를 확인합니다. 0계층 PR은 `main-v2`, project 계층 PR은 해당 `project/<project-id>`가 target/base여야 합니다. target/base가 계층 판단과 맞지 않으면 `@codex review`를 호출하지 않고 계층 기준 브랜치 불일치로 보고합니다.
4. project 계층 PR이면 GitHub PR head branch와 로컬 현재 branch를 확인합니다. head branch나 로컬 현재 branch가 기준 `project/<project-id>`와 같으면 기준 브랜치 직접 커밋 위험이므로 `@codex review`를 호출하지 않고 `project/<project-id>-<branch-name>` 작업 브랜치 PR로 재생성해야 한다고 보고합니다.
5. PR diff에 submodule gitlink 변경이 있으면 해당 submodule repo의 head commit이 별도 PR과 Codex no-major 또는 동등 리뷰를 통과했는지 확인합니다. 확인되지 않으면 상위 제품 repo PR은 pin/host 변경 검토만 남기고, submodule repo PR gate 미완료를 blocker로 보고합니다.
6. 새 submodule repo PR이면 기본 브랜치가 우회 머지 경로가 아닌지, PR 본문에 `patch/evidence`, `runtime`, `service/MSA` 중 유형이 있는지 확인합니다. service/MSA 유형이면 별도 배포, DB, auth, observability 필요 증거가 있어야 합니다.
7. 로컬에서 PR head를 수정하며 루프를 수행할 때는 `git rev-parse --git-dir`와 `git rev-parse --git-common-dir`가 다른 linked worktree인지 확인합니다. submodule이면 `git rev-parse --show-superproject-working-tree`로 구분합니다. project 계층 PR인데 linked worktree가 아니면 commit/push를 진행하지 않고 별도 worktree 전환 필요로 보고합니다.
8. task silo의 `goal.md`가 있으면 내부 목표 문구와 PR URL, head SHA, 검증 기준을 추가합니다. `goal.md`가 없으면 PR 본문 `Codex PR 리뷰` 항목에 내부 목표와 현재 상태를 남깁니다.
9. 최신 head push 이후의 `@codex review` 호출 댓글, `eyes` 반응, Codex 리뷰 결과를 확인합니다.
10. 최신 head 이후 호출 댓글에 `eyes` 반응이 있고 아직 리뷰 결과가 없으면 중복 호출하지 않고 `eyes` 확인 시점부터 최대 15분까지 대기합니다.
11. 최신 head 이후 호출 댓글이 있지만 3분 동안 `eyes` 반응이 없고 아직 리뷰 결과도 없으면 리뷰 요청이 접수되지 않은 것으로 보고, 같은 head 기준으로 `@codex review`를 재호출한 뒤 9번으로 돌아갑니다. 같은 head의 no-`eyes` 재호출은 기본 최대 3회로 제한하고, 3회 모두 `eyes` 반응과 리뷰 결과가 없으면 `Codex 리뷰 접수 실패 timeout`으로 중단해 사용자 판단 필요로 보고합니다.
12. 최신 head에 대한 리뷰 요청이 없으면 PR 댓글로 `@codex review`를 호출하고, 외부 리뷰 댓글 문구만 적은 뒤 9번으로 돌아갑니다.
13. `eyes` 반응을 확인한 뒤 15분 동안 Codex 응답이 없으면 루프를 중단하고 PR URL, head SHA, 호출 댓글, 대기 시간을 보고합니다.
14. Codex 결과가 도착하면 최신 head에 대해 no-major 응답인지 확인합니다.
15. no-major 응답이고 사일로 PR이며 task silo 또는 PR 본문에 runtime, browser, manual QA, E2E, vite-harness, shared BE/API, Docker DB 확인이 남아 있으면 [`silo-runtime-handoff`](../silo-runtime-handoff/SKILL.md)를 실행해 서버 주소, E2E 방법, 실행 불가 사유를 PR 댓글로 남긴 뒤 사용자 재리뷰로 넘깁니다.
16. no-major 응답이 아니면 actionable major/critical/P1/P2 또는 보호 절차 위반 지적의 validity를 판단하고 타당한 항목만 수정합니다.
17. 수정 후 변경 범위에 맞는 검증을 실행하고, 한국어 커밋 메시지로 커밋한 뒤 push합니다. project 계층 PR에서는 이 커밋이 `project/<project-id>-<branch-name>` 작업 브랜치에서 발생해야 하며, 기준 `project/<project-id>` 브랜치에는 직접 커밋하지 않습니다.
18. PR 댓글 또는 본문에 수정 내용, 검증 결과, 남은 위험, 새 head SHA를 기록하고 9번으로 돌아갑니다.

## 종료 기준

- 최신 head에 대한 Codex 결과가 `Didn't find any major issues` 또는 동등한 no-major 응답을 명시했습니다.
- 사일로 PR이고 runtime, browser, manual QA, E2E 확인이 남아 있으면 `silo-runtime-handoff` 댓글까지 남긴 뒤 종료합니다.
- 같은 head에 대해 진행 중인 `eyes` 반응이 있으면 종료가 아니라 `eyes` 확인 시점부터 15분 한도의 대기입니다.
- 같은 head에 대해 호출했지만 3분 동안 `eyes` 반응이 없고 리뷰 결과도 없으면 접수 실패로 보고 재호출합니다. 같은 head의 no-`eyes` 재호출은 기본 최대 3회이며, 모두 실패하면 `Codex 리뷰 접수 실패 timeout`으로 중단해 사용자 판단 필요로 보고합니다.
- `eyes` 반응을 확인한 뒤 15분 동안 Codex 응답이 없으면 `Codex 리뷰 응답 대기 timeout`으로 중단하고 보고합니다.
- 사용자가 명시한 반복 한도가 없으면 횟수 제한으로 중단하지 않습니다.

## 금지

- formal GitHub approve 리뷰 객체가 없다는 이유만으로 `Didn't find any major issues` 명시 응답을 무시하지 않습니다.
- 이전 head의 no-major 결과를 현재 head의 승인으로 재사용하지 않습니다.
- 최신 head 이후 `eyes` 반응이 붙은 호출이 있는데 같은 head에 중복 호출하지 않습니다. 단, 최신 head 이후 호출 댓글에 3분 동안 `eyes` 반응이 없고 리뷰 결과도 없으면 접수 실패 재호출로 분류하고, 재호출 뒤 최신 호출 댓글 기준으로 다시 확인합니다.
- PR을 머지하지 않습니다. 머지는 별도 명시 승인 뒤 메인 오케스트레이터가 처리합니다.
- `project/dynamos` 또는 `project/onjump`처럼 project 계층 기준 브랜치가 따로 있는 변경을 이 skill 때문에 `main-v2`로 retarget하지 않습니다.
- project 계층 PR에서 기준 `project/<project-id>` 브랜치 자체를 head로 쓰거나, 기준 브랜치 checkout에서 직접 commit/push하지 않습니다.
