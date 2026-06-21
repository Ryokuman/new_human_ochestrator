# 브랜치 안전과 생명주기

## PR 안전 기준

사일로 PR은 아래 조건을 만족해야 리뷰 대상으로 봅니다.

- 필요한 레포지토리만 새로 clone한 격리 작업 공간에서 작업했음
- `main`, `main-v2`, `dev`, `develop`, `master` 같은 보호 브랜치에서 직접 작업하지 않았음
- 새 작업 브랜치에서 수정했음
- 보호 브랜치에 직접 commit 또는 push하지 않았음
- 0계층 `main-v2` PR과 project 계층 `project/<project-id>` PR에서는 PR 생성 직후 수동 `@codex review`를 호출했거나, 생략 또는 실패 사유를 PR 본문에 남겼음
- 리뷰 조건 종결 전에는 task, 사일로, PR 작업을 완료로 보고하지 않았음
- 브랜치별 리뷰 조건 종결 후 사용자 재리뷰 대기 상태로 넘겼음
- 결과를 PR로 제출했음

이 조건을 만족하지 않으면 메인 오케스트레이터는 머지 리뷰보다 브랜치 안전 문제를 먼저 처리합니다.

## 브랜치 생명주기

| 브랜치 종류 | 목적 | 종료 기준 | 종료 처리 |
|---|---|---|---|
| `main` | 레거시 보존 | 없음 | 삭제하지 않지만 작업, PR, merge, rebase, worktree 기준으로 사용하지 않습니다. |
| `main-v2` | 탐색형 제품 엔지니어 운영 기준 | 없음 | 삭제하지 않고 직접 commit/push하지 않습니다. |
| `project/<project-id>` | 프로젝트별 정보, SSoT 색인, repo 연결 상태를 보관하는 장기 브랜치 | 프로젝트 연결 자체를 폐기할 때 | `main-v2` 병합 대상으로 보지 않고 별도 판단합니다. |
| `silo/<task-id>-*` | task 실행 결과를 PR로 제출하는 단기 작업 브랜치 | PR 머지 확인과 로컬 안전 조건 확인이 끝났을 때 | clean 상태, ahead 없음, PR/패치 대응 관계가 확인되면 로컬 브랜치를 삭제합니다. |
| `repair/<pr-id>-*` | conflict 해결, 잘못된 PR 이력 복구 같은 임시 보정 브랜치 | 원 PR 또는 대체 PR이 머지되고 패치 동등성이 확인됐을 때 | 자동 삭제하지 않고 `삭제 후보`로 보고합니다. |
| `docs/*`, `chore/*` | 0계층 `main-v2` 업데이트용 단기 브랜치 | PR이 `main-v2`에 머지되고 머지 확인이 끝났을 때 | 로컬 브랜치와 연결 worktree를 삭제합니다. |

## 정리 전 확인

- 현재 작업트리가 clean인지 확인합니다.
- `git fetch --all --prune` 이후 상태를 기준으로 판단합니다.
- shell git 또는 GitHub CLI가 private repo를 `Repository not found`로 보고하더라도, GitHub 앱이나 다른 인증 경로에서 PR 상태가 확인될 수 있습니다. 이 경우 shell evidence와 GitHub evidence를 분리해 기록하고, 한쪽 실패만으로 삭제를 결정하지 않습니다.
- 열린 PR의 head 브랜치는 삭제하지 않습니다.
- 머지된 PR은 `state`, `mergedAt`, `mergeCommit`, PR head SHA, GitHub PR target/base branch를 재조회합니다.
- squash merge 또는 merge commit 방식 차이 때문에 `git branch --merged`나 `git merge-base --is-ancestor` 단독 결과만으로 브랜치 삭제를 결정하지 않습니다.
- 로컬 브랜치 HEAD가 PR head SHA와 일치하고, PR이 merged이며, 해당 worktree가 clean일 때만 로컬 삭제 후보로 둡니다.
- 원격 head 브랜치 삭제는 로컬 브랜치와 worktree 삭제와 별도 승인 경계로 보고합니다.
- `repair/*`는 삭제 전에 원 PR, 대체 PR, 패치 동등성을 분리해 보고합니다.
- 같은 프로젝트의 sibling worktree와 external clone을 함께 확인합니다.
- dirty diff가 있는 worktree는 branch commit이 같아도 동일 상태로 보지 않습니다.
- dirty diff가 화면, API, store, schema, business flow 같은 기능 표면을 수정했다면 삭제 대상이 아니라 기준선 후보 또는 checkpoint 필요 대상으로 분리합니다.
- 가치 있는 dirty diff는 commit, patch, handoff note 중 하나로 고정되기 전까지 정리하지 않습니다.
- 기준 SSoT가 아닌 repo, submodule, external clone이라도 ahead commit이나 untracked task/issue/evidence 문서가 있으면 바로 삭제하지 않고 `위험`으로 보고합니다.
- 제품 source worktree와 사일로 메타 디렉터리는 분리해서 판단합니다. source worktree를 삭제하더라도 `goal.md`, handoff, report 같은 사일로 메타가 남아 있으면 별도 정리 대상으로 보고합니다.

## 정리 보고

```text
삭제됨:
- 실제 삭제한 로컬 브랜치와 worktree

보존:
- main, main-v2, project/*, 열린 PR head, 판단 보류 브랜치

삭제 후보:
- gone 상태이며 ahead 커밋이 없고 PR/패치 대응 관계가 확인된 브랜치
- upstream이 살아 있어도 PR merged, PR head SHA 일치, worktree clean 상태가 확인되어 로컬 삭제만 가능한 브랜치
- PR은 머지됐지만 자동 삭제하기 전에 확인이 필요한 repair/* 브랜치

위험:
- upstream이 살아 있고 PR merged/head/clean 안전 조건이 확인되지 않았거나, ahead 커밋이 있거나, PR/패치 대응 관계가 불명확한 브랜치
- dirty source workspace, 기준 SSoT가 아닌 repo의 ahead/untracked 문서, 원격 인증 실패로 evidence가 갈린 브랜치
```

## evidence 기록

브랜치 정리 보고에는 최소한 아래 값을 남깁니다.

| 항목 | 이유 |
|---|---|
| repo 경로와 역할 | root SSoT, 제품 source, 사일로, external clone, submodule을 구분하기 위해 |
| local branch와 HEAD | 삭제 또는 보존 판단의 로컬 기준 |
| upstream branch와 fetch/prune 결과 | gone 상태와 원격 접근 실패를 구분하기 위해 |
| PR URL, state, mergedAt, mergeCommit, head SHA, GitHub PR target/base branch | PR 대응 관계와 merge 상태를 검증하기 위해 |
| worktree clean 여부 | 같은 commit이어도 dirty diff가 있으면 같은 상태가 아니기 때문 |
| 남은 dirty/ahead/untracked 항목 | `삭제됨`, `보존`, `삭제 후보`, `위험` 분류의 근거 |
