---
name: main-branch-update-flow
description: main-v2 업데이트 절차 문서입니다. 이 프로젝트에서는 main을 절대로 작업 대상으로 쓰지 않으며, 공통 규칙, AGENTS.md, system 문서, 프롬프트, skill 초안 변경은 main-v2 기준으로만 처리합니다.
---

# Main-v2 Update Flow

이 문서는 공통 SSoT를 `main-v2` 기준으로 업데이트하는 절차를 설명합니다.

현재 프로젝트에서는 레거시 `main` 업데이트 절차를 실행하지 않습니다. `main-v2`는 new main 보호 브랜치이며, `main` checkout, `origin/main` 기준 worktree 생성, `main` 대상 PR, `main` merge, `main` rebase는 금지합니다. `main-v2` 직접 commit/push도 금지하고, 항상 파생 작업 브랜치와 PR로 반영합니다.

## 적용 시점

아래 요청이 나오면 이 스킬을 사용합니다.

- main-v2 업데이트
- 공통 규칙 반영
- AGENTS.md 수정
- system 문서 수정
- 프롬프트 수정
- skill 초안 추가/수정
- 사용자 피드백을 장기 규칙으로 승격
- main-v2 대상 PR 제안, PR 본문 초안, PR 생성

현재 프로젝트에서는 사용자가 `main-v2`를 명시하지 않아도 `main-v2`를 기본값으로 봅니다. `main` 직접 업데이트 절차는 적용하지 않습니다.

## 원칙

- 공통 SSoT 수정은 `main-v2`에서 파생한 작업 브랜치에서만 처리합니다.
- `main` 기준 별도 worktree 또는 clean checkout을 만들지 않습니다.
- 모든 작성 산출물은 한국어로 작성합니다.
- PR 제목, PR 본문, 커밋 메시지도 한국어로 작성합니다.
- PR 생성 승인과 PR 머지 승인은 별개로 봅니다.
- PR은 사용자가 `approve`, `LGTM`, `머지하세요`, `머지해도 됩니다`, `1. 머지`처럼 머지를 명시한 경우에만 머지합니다.
- `진행해`, `작업 이어가`, `PR 만들어`, `main-v2 업데이트`, `1. 승인`처럼 작업 또는 PR 생성 승인은 머지 승인으로 해석하지 않습니다.
- PR이 머지된 뒤에도 원래 작업 브랜치를 `main` 위로 rebase하지 않습니다.
- 프로젝트 내부 실제 issue/task/coverage 결과는 root `main-v2`에 복사하지 않고, 반복 가능한 운영 규칙만 `system/`에 둡니다.
- `main-v2` 변경은 `main`으로 승격하지 않습니다.
- `project/*` 브랜치는 프로젝트별 정보 보관용 장기 브랜치이며 `main-v2` 병합 대상이 아닙니다. `project/*` 브랜치 작업에는 이 `main-v2` 업데이트/PR 생성 흐름을 기본 적용하지 않습니다.
- `main-v2` 대상 PR을 제안하거나 생성하기 전에는 [`main-v2-pr-scope-gate`](../main-v2-pr-scope-gate/SKILL.md)를 먼저 적용합니다. project SSoT 원문이나 local/silo 자료가 diff에 포함되면 PR 제안을 중단하고, 공통 승격 후보 분리 또는 project 브랜치 유지로 보고합니다.
- PR 생성 후에는 [`codex-pr-review-loop`](../codex-pr-review-loop/SKILL.md)를 사용해 no-major 목표를 세팅하고, Codex 수동 리뷰 gate를 통과할 때까지 수정, 검증, 재리뷰를 반복합니다. task silo의 `goal.md`가 확인되면 no-major 목표를 `goal.md`에 세팅하고, 그렇지 않은 공통 문서/skill PR은 PR 본문, 리뷰 thread, 현재 사용자 요청을 재리뷰 컨텍스트로 사용합니다. 기본 반복 상한은 두지 않습니다.

## 절차

1. 현재 브랜치와 dirty state를 확인합니다.
2. remote 접근 가능 여부를 확인합니다.
3. remote 계정이 맞지 않으면 `gh auth status`와 `gh auth switch -u <account>`로 복구합니다.
4. 현재 브랜치가 `main-v2`에서 파생한 작업 브랜치인지 확인합니다.
5. 필요한 경우 `main-v2`에서 단기 브랜치를 만들고 이동합니다.
6. `main-v2-pr-scope-gate`로 브랜치명, diff path, 계층 분류, PR 가능 여부를 확인합니다.
7. 공통 SSoT 파일만 수정합니다.
8. 문서 변경이면 논리 비약 자가검수를 수행합니다.
9. 필요한 검증을 실행합니다.
10. 한국어 커밋을 만듭니다.
11. push 직전 `main-v2-pr-scope-gate`를 다시 실행합니다.
12. 작업 브랜치를 push합니다.
13. PR 생성 직전 `main-v2-pr-scope-gate`를 다시 실행합니다.
14. 한국어 제목/본문으로 PR을 만듭니다.
15. GitHub PR target/base branch가 `main-v2`인지 확인합니다.
16. [`codex-pr-review-loop`](../codex-pr-review-loop/SKILL.md)를 사용해 no-major 목표를 세팅하고, PR 댓글로 수동 `@codex review`를 호출합니다. 가능하면 `한국어로 리뷰해 주세요.` 또는 이에 준하는 한국어 요청과 최신 head 기준 리뷰 요청만 적습니다. 외부 리뷰 봇의 고정 템플릿 언어까지 보장하지는 못합니다.
17. 현재 head push 이후에 작성된 최신 `@codex review` 호출 댓글에 `eyes` 반응이 있으면 Codex 리뷰가 접수 또는 진행 중인 상태로 보고, 같은 head commit에 추가 리뷰 요청을 호출하지 않고 `eyes` 확인 시점부터 최대 15분까지 기다립니다. 최신 호출 댓글에 3분 동안 `eyes` 반응이 없고 최신 head 리뷰 결과도 없으면 접수 실패로 보고 같은 head 기준으로 최대 3회까지 재호출한 뒤 새 호출 댓글 기준으로 다시 확인합니다. 3회 모두 접수되지 않으면 `Codex 리뷰 접수 실패 timeout`으로 중단해 사용자 판단 필요로 보고합니다. `eyes` 반응을 확인한 뒤 15분 동안 응답이 없으면 `Codex 리뷰 응답 대기 timeout`으로 중단하고 보고합니다.
18. Codex 리뷰 결과와 호출 횟수를 PR 본문에 기록합니다.
19. 최신 head에 대한 `Didn't find any major issues` 또는 동등한 no-major 명시 응답이 아니라 major/critical 지적 또는 P1/P2처럼 보호 절차를 깨는 지적이 있으면, `codex-pr-review-loop` 기준으로 수정, 검증, 수동 재호출을 반복합니다. 기본 중단 기준은 호출 횟수가 아니라 리뷰 결과입니다. 재호출 전 현재 head push 이후에 작성된 최신 호출 댓글에 `eyes` 반응이 있으면 중복 호출하지 않고 `eyes` 확인 시점부터 15분 한도 안에서 기존 요청의 결과를 기다립니다. 최신 호출 댓글에 3분 동안 `eyes` 반응이 없고 최신 head 리뷰 결과도 없으면 접수 실패 재호출로 분류하되, 같은 head의 no-`eyes` 재호출 기본 상한 3회를 넘기지 않습니다. 반복 이후에도 남은 major/critical 또는 보호 절차 P1/P2 항목은 횟수 기준으로 중단하지 않고, 실제 blocker 여부와 사용자 승인 gate 필요 여부를 분리합니다.
20. PR URL, 상태, mergeable 여부, Codex 리뷰 gate 상태를 확인해 보고합니다.
21. 사용자의 명시 머지 승인이 있으면 PR을 머지합니다.
22. 머지했다면 `state`, `mergedAt`, `mergeCommit`을 재조회해 보고합니다.
23. PR이 머지된 뒤에도 `main`을 fetch/rebase 기준으로 쓰지 않습니다.
24. `main-v2` 기준으로 원격 추적 상태와 dirty state를 확인합니다.
25. worktree 정리 여부를 보고합니다.

## 보기 3개 규칙

main 또는 main-v2 업데이트가 다음 행동 후보로 떠오른 경우, 이 프로젝트에서는 `main-v2` 업데이트로 바꿔 제시합니다.

```text
1. main-v2 업데이트: 공통 SSoT를 main-v2에 반영합니다.
2. 현재 답변 기준만 임시 적용: 이번 대화부터 적용하되 main-v2 SSoT에는 아직 반영하지 않습니다.
3. 기타: 범위, 문구, 적용 위치를 사용자가 직접 지정합니다.
```

사용자가 이미 특정 보기를 고르거나 명시 실행을 요청한 경우에는 그 선택을 따른 뒤, 다음 승인 경계에서 다시 보기 3개를 제시합니다.

선택지 작성 시 고정된 절차를 과도하게 풀어쓰지 않습니다. 이 프로젝트에서는 `main-v2 업데이트`처럼 압축하고, `main` 대상 절차를 제시하지 않습니다.

다만 선택지가 실행 승인 역할을 할 때는 목적과 결과가 보여야 합니다. 예를 들어 `선택지 작성 방식 개선`, `SSoT manager 사용법 README 추가`처럼 사용자가 이해할 수 있는 변경 이름을 함께 적습니다.

## 실패 처리

- remote fetch/push 실패: 계정, remote URL, repository 권한을 먼저 확인합니다.
- PR 생성 실패: 커밋은 유지하고 실패 원인과 재시도 명령을 보고합니다.
- 명시 머지 승인 없음: PR URL과 상태를 보고하고, 머지하지 않습니다.
- rebase conflict: conflict 파일과 원인을 보고하고, 사용자가 수정 방향을 고를 수 있도록 보기 3개를 제시합니다.
- worktree 생성 실패: 기존 worktree 목록을 확인하고 충돌 경로를 정리 후보로 보고합니다.

## 완료 보고

보고는 아래를 분리합니다.

```text
완료된 것
아직 안 된 것
목표 밖 산출물
SSoT 승격 후보
승격하지 않을 항목
다음 행동
```
