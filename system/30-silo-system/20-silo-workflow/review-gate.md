# 사일로 리뷰 Gate

사일로 작업은 브랜치 정책에 맞는 리뷰 gate가 종결되기 전에는 완료로 보고하지 않습니다.

## PR 유형별 Codex Gate

사일로가 PR을 올릴 때는 먼저 현재 브랜치의 diff를 계층별로 판정합니다.

- 0계층 공통 변경은 `main-v2` 대상 PR로 올립니다.
- project 계층 변경은 해당 `project/<project-id>`를 기준 브랜치로 삼되, 별도 worktree의 파생 브랜치에서 커밋하고 `project/<project-id>` 대상 PR로 올립니다.
- 0계층과 project 계층 변경이 함께 있으면 0계층은 `main-v2`용 worktree/브랜치/PR로, project 계층은 해당 `project/<project-id>`에서 판 별도 worktree의 파생 브랜치와 project 대상 PR로 분리합니다.

PR 생성 직후에는 [`codex-pr-review-loop`](../../20-skills/codex-pr-review-loop/SKILL.md)를 사용해 no-major 목표를 세팅하고, 수동 `@codex review`를 호출합니다.

현재 head push 이후에 작성된 최신 `@codex review` 호출 댓글에 `eyes` 반응이 있으면 Codex 리뷰가 접수 또는 진행 중인 상태로 보고, 같은 head commit에 추가 `@codex review`를 호출하지 않습니다.

최신 리뷰 요청 뒤 15분 동안 Codex 응답이 없으면 timeout으로 중단하고 PR URL, head SHA, 호출 댓글, 대기 시간을 보고합니다.

아래 항목이 있으면 `codex-pr-review-loop` 기준으로 수정, 검증, 재호출을 반복합니다. 기본 중단 기준은 호출 횟수가 아니라 최신 head에 대한 `Didn't find any major issues` 또는 동등한 no-major 명시 응답입니다.

- actionable major/critical issue
- 보호 절차를 깨는 P1/P2 지적
- 보호 브랜치 직접 commit/push 위험

0계층 PR과 project 계층 PR 모두 반복 재리뷰 대상입니다. branch base는 계층 기준 브랜치이며, project 계층은 기준 브랜치에 직접 커밋하지 않고 별도 worktree의 파생 브랜치에서만 커밋합니다. GitHub PR target/base branch가 계층 기준과 다르거나 두 계층이 섞인 PR은 `@codex review`를 호출하지 않고 계층 분리 필요로 보고한 뒤 종료합니다.

사용자가 이번 PR에 명시한 반복 한도가 있으면 그 한도를 따릅니다. secret, credential, production 데이터, destructive action, data SSoT 임의 변경, 보호 브랜치 직접 수정에 닿으면 반복보다 승인 gate를 우선합니다.

반복 이후에도 남는 항목은 횟수 기준으로 중단하지 않고, 의도된 잔여 위험 또는 사용자 판단 필요로 분리합니다.

재호출 전에도 최신 head push 이후에 작성된 호출 댓글의 `eyes` 반응과 최신 head commit 리뷰 결과를 확인합니다. 최신 head 리뷰 결과가 아직 없고 현재 head 이후 호출 댓글에 `eyes`가 있으면 중복 호출하지 않고 15분 한도 안에서 기존 요청을 기다립니다.

## 사용자 재리뷰

Codex PR 리뷰 gate가 종결된 뒤에는 사용자 재리뷰를 다음 gate로 둡니다.

PR 생성 승인과 PR 머지 승인은 별개입니다.
