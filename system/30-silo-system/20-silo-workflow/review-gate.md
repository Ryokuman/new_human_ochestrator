# 사일로 리뷰 Gate

사일로 작업은 브랜치 정책에 맞는 리뷰 gate가 종결되기 전에는 완료로 보고하지 않습니다.

## main-v2

`main-v2` 대상 PR은 생성 직후 수동 `@codex review`를 호출합니다.

현재 head push 이후에 작성된 최신 `@codex review` 호출 댓글에 `eyes` 반응이 있으면 Codex 리뷰가 접수 또는 진행 중인 상태로 보고, 같은 head commit에 추가 `@codex review`를 호출하지 않습니다.

아래 항목이 있으면 수정 후 최대 5회까지 재호출합니다.

- actionable major/critical issue
- 보호 절차를 깨는 P1/P2 지적
- base branch가 `main-v2`가 아닌 PR
- 보호 브랜치 직접 commit/push 위험

최대 5회 후에도 남는 항목은 의도된 잔여 위험 또는 사용자 판단 필요로 분리합니다.

재호출 전에도 최신 head push 이후에 작성된 호출 댓글의 `eyes` 반응과 최신 head commit 리뷰 결과를 확인합니다. 최신 head 리뷰 결과가 아직 없고 현재 head 이후 호출 댓글에 `eyes`가 있으면 중복 호출하지 않고 기존 요청을 기다립니다.

## 사용자 재리뷰

Codex PR 리뷰 gate가 종결된 뒤에는 사용자 재리뷰를 다음 gate로 둡니다.

PR 생성 승인과 PR 머지 승인은 별개입니다.
