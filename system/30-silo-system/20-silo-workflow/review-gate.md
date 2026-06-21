# 사일로 리뷰 Gate

사일로 작업은 브랜치 정책에 맞는 리뷰 gate가 종결되기 전에는 완료로 보고하지 않습니다.

## main-v2

0계층 공통 변경만 담은 `main-v2` 대상 PR은 생성 직후 [`codex-pr-review-loop`](../../20-skills/codex-pr-review-loop/SKILL.md)를 사용해 no-major 목표를 세팅하고, 수동 `@codex review`를 호출합니다.

현재 head push 이후에 작성된 최신 `@codex review` 호출 댓글에 `eyes` 반응이 있으면 Codex 리뷰가 접수 또는 진행 중인 상태로 보고, 같은 head commit에 추가 `@codex review`를 호출하지 않습니다.

아래 항목이 있으면 `codex-pr-review-loop` 기준으로 수정, 검증, 재호출을 반복합니다. 기본 중단 기준은 호출 횟수가 아니라 최신 head에 대한 `Didn't find any major issues` 명시 응답입니다.

- actionable major/critical issue
- 보호 절차를 깨는 P1/P2 지적
- 보호 브랜치 직접 commit/push 위험

0계층 공통 변경만 담은 `main-v2` 대상 PR만 반복 재리뷰 대상입니다. branch base는 계층 기준 브랜치이며, 1계층 이상 project 변경은 해당 `project/<project-id>` 기준 브랜치와 project gate를 따릅니다. GitHub PR target/base branch가 `main-v2`가 아니거나 project 변경이 섞인 PR은 `@codex review`를 호출하지 않고 계층 분리 필요 또는 project gate 대상으로 보고한 뒤 종료합니다.

사용자가 이번 PR에 명시한 반복 한도가 있으면 그 한도를 따릅니다. secret, credential, production 데이터, destructive action, data SSoT 임의 변경, 보호 브랜치 직접 수정에 닿으면 반복보다 승인 gate를 우선합니다.

반복 이후에도 남는 항목은 횟수 기준으로 중단하지 않고, 의도된 잔여 위험 또는 사용자 판단 필요로 분리합니다.

재호출 전에도 최신 head push 이후에 작성된 호출 댓글의 `eyes` 반응과 최신 head commit 리뷰 결과를 확인합니다. 최신 head 리뷰 결과가 아직 없고 현재 head 이후 호출 댓글에 `eyes`가 있으면 중복 호출하지 않고 기존 요청을 기다립니다.

## 사용자 재리뷰

Codex PR 리뷰 gate가 종결된 뒤에는 사용자 재리뷰를 다음 gate로 둡니다.

PR 생성 승인과 PR 머지 승인은 별개입니다.
