---
name: main-branch-update-flow
description: 0계층 업데이트 절차 문서입니다. 이 프로젝트에서는 main을 절대로 작업 대상으로 쓰지 않으며, 공통 규칙, AGENTS.md, system 문서, 프롬프트, skill 초안 변경은 계층 메인 브랜치 기준으로만 처리합니다. 목표 모델은 main-v3/main이고, 현재 호환 기준은 main-v3/main입니다.
---

# 0계층 Update Flow

이 문서는 공통 SSoT를 0계층 계층 메인 브랜치 기준으로 업데이트하는 절차를 설명합니다.

현재 프로젝트에서는 레거시 `main` 업데이트 절차를 실행하지 않습니다. 목표 0계층 계층 메인 브랜치는 `main-v3/main`이고, 현재 마이그레이션 전 호환 기준은 `main-v3/main`입니다. `main` checkout, `origin/main` 기준 worktree 생성, `main` 대상 PR, `main` merge, `main` rebase는 금지합니다. 계층 메인 브랜치 직접 commit/push도 금지하고, 항상 파생 작업 브랜치와 PR로 반영합니다.

## 적용 시점

아래 요청이 나오면 이 스킬을 사용합니다.

- 0계층 계층 메인 브랜치 업데이트
- main-v3/main 호환 업데이트
- 공통 규칙 반영
- AGENTS.md 수정
- system 문서 수정
- 프롬프트 수정
- skill 초안 추가/수정
- 사용자 Feedback에서 여러 사용자·프로젝트에 반복되는 공통 시스템 규칙을 0계층으로 승격
- 0계층 대상 PR 제안, PR 본문 초안, PR 생성

현재 프로젝트에서는 사용자가 별도 마이그레이션 브랜치를 명시하지 않으면 `main-v3/main` 호환 기준을 기본값으로 봅니다. `main` 직접 업데이트 절차는 적용하지 않습니다.

## 원칙

- 공통 SSoT 수정은 계층 메인 브랜치에서 파생한 작업 브랜치에서만 처리합니다.
- 목표 모델에서는 `main-v3/main`에서 파생한 `main-v3/{taskname}` 작업 브랜치를 사용합니다. `main-v3` 자체는 브랜치가 아니라 Git ref namespace입니다.
- 현재 호환 상태에서도 `main-v3/main`에서 파생한 `main-v3/{taskname}` 작업 브랜치를 사용합니다. Git ref namespace에서는 `main-v3/main` 브랜치가 존재하면 `main-v3/main/<branch-name>` 브랜치를 만들 수 없으므로, 이 slash namespace 기반 작업 브랜치 형식은 마이그레이션 전 호환 형식입니다.
- `main` 기준 별도 worktree 또는 clean checkout을 만들지 않습니다.
- 모든 작성 산출물은 한국어로 작성합니다.
- PR 제목, PR 본문, 커밋 메시지도 한국어로 작성합니다.
- PR 생성 승인과 PR 머지 승인은 별개로 봅니다.
- 사용자 검수가 필요한 Markdown 초안에서 시작한 0계층 변경은 [`workspace-local-review`](../workspace-local-review/SKILL.md)로 승인된 revision과 hash를 확인한 후에만 worktree를 생성합니다. 승인 전 local 파일은 0계층 diff나 PR에 포함하지 않습니다.
- PR은 사용자가 `approve`, `LGTM`, `머지하세요`, `머지해도 됩니다`, `1. 머지`처럼 머지를 명시한 경우에만 머지합니다.
- `진행해`, `작업 이어가`, `PR 만들어`, `main-v3/main 업데이트`, `1. 승인`처럼 작업 또는 PR 생성 승인은 머지 승인으로 해석하지 않습니다.
- PR이 머지된 뒤에도 원래 작업 브랜치를 `main` 위로 rebase하지 않습니다.
- 프로젝트 내부 실제 issue/task/coverage 결과는 root `main-v3/main`에 복사하지 않고, 반복 가능한 운영 규칙만 `system/`에 둡니다.
- 0계층 변경은 `main`으로 승격하지 않습니다.
- 목표 모델의 project 계층 메인 브랜치는 `project-{projectName}/main`이며, `main-v3/main` 병합 대상이 아닙니다. 마이그레이션 전 호환 `project-{projectName}` 브랜치와 기존 slash 기반 `project/*` 브랜치는 호환/전환 필요 브랜치로 해석합니다. project 브랜치 작업에는 이 0계층 업데이트/PR 생성 흐름을 기본 적용하지 않습니다.
- 0계층 대상 PR을 제안하거나 생성하기 전에는 [`main-v3-pr-scope-gate`](../main-v3-pr-scope-gate/SKILL.md)를 먼저 적용합니다. 현재 skill 이름은 `main-v3/main` 호환 상태를 반영하지만, 목적은 0계층 PR scope gate입니다. project SSoT 원문이나 local/silo 자료가 diff에 포함되면 PR 제안을 중단하고, 공통 승격 후보 분리 또는 project 브랜치 유지로 보고합니다.
- PR 생성 후에는 먼저 Codex review 설정 여부를 확인합니다. Codex review 설정 없음, 호출 권한 없음, GitHub App 미설치, repo 정책상 비활성화가 명시적으로 확인되면 codex-review pass 목표를 세팅하지 않고 `Codex review 미설정`과 확인 근거를 PR 본문 또는 보고에 남깁니다. 아직 확인 전이거나 동작 가능하면 [`codex-pr-review-loop`](../codex-pr-review-loop/SKILL.md)를 사용해 codex-review pass 목표를 세팅하고, Codex 수동 리뷰 gate를 통과할 때까지 수정, 검증, 재리뷰를 반복합니다. task silo의 `goal.md`가 확인되면 codex-review pass 목표를 `goal.md`에 세팅하고, 그렇지 않은 공통 문서/skill PR은 PR 본문, 리뷰 thread, 현재 사용자 요청을 재리뷰 컨텍스트로 사용합니다. 기본 반복 상한은 두지 않습니다.

## 절차

사용자 검수가 필요한 Markdown 초안에서 시작한 작업이면 먼저 `workspace-local-review`로 계층 메인 최신화, local 검수, 승인 revision과 hash를 확인합니다. 승인 전에는 아래 worktree 생성 단계로 진행하지 않습니다.

1. 현재 브랜치와 dirty state를 확인합니다.
2. remote 접근 가능 여부를 확인합니다.
3. remote 계정이 맞지 않으면 `gh auth status`와 `gh auth switch -u <account>`로 복구합니다.
4. 현재 브랜치가 0계층 계층 메인 브랜치에서 파생한 작업 브랜치인지 확인합니다.
5. 필요한 경우 현재 호환 기준에서는 `main-v3/main`에서 `main-v3/{taskname}` 단기 브랜치를 만들고 이동합니다. 목표 모델 마이그레이션 후에는 `main-v3/main`에서 `main-v3/{taskname}` 단기 브랜치를 만듭니다.
6. `main-v3-pr-scope-gate`로 브랜치명, diff path, 계층 분류, PR 가능 여부를 확인합니다.
7. 공통 SSoT 파일만 수정합니다.
8. 문서 변경이면 `decision-doc-logic-audit` skill로 논리 비약 자가검수를 수행합니다. 해당 skill을 사용할 수 없으면 fallback self-audit로 Symptom-as-Cause, Scope Overreach, Premature Conclusion, Missing Causal Step, Effect Drift를 점검하고 fallback 사용 사실을 보고합니다.
9. 필요한 검증을 실행합니다.
10. 한국어 커밋을 만듭니다.
11. push 직전 `main-v3-pr-scope-gate`를 다시 실행합니다.
12. 작업 브랜치를 push합니다.
13. PR 생성 직전 `main-v3-pr-scope-gate`를 다시 실행합니다.
14. 한국어 제목/본문으로 PR을 만듭니다.
15. GitHub PR target/base branch가 0계층 계층 메인 브랜치인지 확인합니다. 현재 호환 기준은 `main-v3/main`, 목표 모델 기준은 `main-v3/main`입니다.
16. Codex review 설정 여부를 codex-review pass 목표 세팅보다 먼저 확인합니다. Codex review 설정 없음, 호출 권한 없음, GitHub App 미설치, repo 정책상 비활성화가 명시적으로 확인되면 codex-review pass 목표를 세팅하지 않고 PR 댓글로 수동 `@codex review`를 호출하지 않으며, `Codex review 미설정`과 확인 근거를 PR 본문 또는 보고에 남긴 뒤 20번의 PR 상태 보고로 이동합니다. 아직 확인 전이거나 동작 가능하면 [`codex-pr-review-loop`](../codex-pr-review-loop/SKILL.md)를 사용해 codex-review pass 목표를 세팅하고, PR 댓글로 수동 `@codex review`를 호출해 접수 여부를 확인합니다. 호출 댓글에는 가능하면 `한국어로 리뷰해 주세요.` 또는 이에 준하는 한국어 요청과 최신 head 기준 리뷰 요청만 적습니다. 외부 리뷰 봇의 고정 템플릿 언어까지 보장하지는 못합니다.
17. 현재 head push 이후 작성된 최신 호출 댓글에 `eyes` 반응이 있으면 같은 head에 추가 요청하지 않고 최대 15분 기다립니다. 이전 head 호출의 `eyes`는 현재 head 대기·중복 호출 억제 근거로 재사용하지 않습니다. 일반 summary로 대기를 끝내지 않지만 매 poll에서 issue comments를 조회해 최신 head actionable finding이면 즉시 분류·처리합니다.
18. completion-evidence gate 전에는 PR 본문에 호출 횟수와 `리뷰 대기 중`만 기록합니다. exact pass, 동등 pass, P2 건수 같은 리뷰 결과는 기록하지 않습니다.
19. formal review 또는 no-finding 완료 신호가 도착하면 네 evidence 표면을 안정화 재조회합니다. SHA/formal 연결 없는 post-request issue comment finding은 현재 head 코드·diff에 실제 적용되는지 대조하고, 귀속 불명확이면 `사용자 판단 필요`로 pass를 막습니다.
20. PR URL, mergeable 여부, 리뷰 대기·timeout·미통과 상태는 completion-evidence gate 전에도 보고할 수 있습니다. exact pass, 동등 pass, 최종 P2 0건과 리뷰 통과 상태만 gate 통과 뒤 PR 댓글과 최종 보고에 확정합니다.
21. 사용자의 명시 머지 승인이 있으면 PR을 머지합니다.
22. 머지했다면 `state`, `mergedAt`, `mergeCommit`을 재조회해 보고합니다.
23. PR이 머지된 뒤에도 `main`을 fetch/rebase 기준으로 쓰지 않습니다.
24. 0계층 계층 메인 브랜치 기준으로 원격 추적 상태와 dirty state를 확인합니다.
25. worktree 정리 여부를 보고합니다.

## 보기 3개 규칙

main 또는 0계층 업데이트가 다음 행동 후보로 떠오른 경우, 이 프로젝트에서는 0계층 계층 메인 브랜치 업데이트로 바꿔 제시합니다. 현재 호환 상태에서는 `main-v3/main`, 목표 모델에서는 `main-v3/main`입니다.

```text
1. 0계층 업데이트: 공통 SSoT를 계층 메인 브랜치에 반영합니다.
2. 현재 답변 기준만 임시 적용: 이번 대화부터 적용하되 0계층 SSoT에는 아직 반영하지 않습니다.
3. 기타: 범위, 문구, 적용 위치를 사용자가 직접 지정합니다.
```

사용자가 이미 특정 보기를 고르거나 명시 실행을 요청한 경우에는 그 선택을 따른 뒤, 다음 승인 경계에서 다시 보기 3개를 제시합니다.

선택지 작성 시 고정된 절차를 과도하게 풀어쓰지 않습니다. 이 프로젝트에서는 `0계층 업데이트`처럼 압축하고, `main` 대상 절차를 제시하지 않습니다.

다만 선택지가 실행 승인 역할을 할 때는 목적과 결과가 보여야 합니다. 예를 들어 `선택지 작성 방식 개선`, `SSoT manager 사용법 README 추가`처럼 사용자가 이해할 수 있는 변경 이름을 함께 적습니다.

## 실패 처리

- remote fetch/push 실패: 계정, remote URL, repository 권한을 먼저 확인합니다.
- PR 생성 실패: 커밋은 유지하고 실패 원인과 재시도 명령을 보고합니다.
- 명시 머지 승인 없음: PR URL과 상태를 보고하고, 머지하지 않습니다.
- rebase conflict: conflict 파일과 원인을 보고하고, 사용자가 수정 방향을 고를 수 있도록 보기 3개를 제시합니다.
- worktree 생성 실패: 기존 worktree 목록을 확인하고 충돌 경로를 정리 후보로 보고합니다.

## 완료 보고

최종 보고는 먼저 전역 최종 응답 계약을 확인하고, 아래 skill 고유 항목을 함께 분리합니다. repo/local skill을 사용한 턴이므로 `사용한 스킬`, `현재 워크트리`, `다음 행동` 또는 남은 승인 경계가 없을 때의 `다음 행동 없음`을 생략하지 않습니다.

```text
사용한 스킬
현재 워크트리
완료된 것
아직 안 된 것
목표 밖 산출물
feedback/follow-up 후보
처리하지 않고 남긴 항목
다음 행동 또는 다음 행동 없음
```
