# PR 리뷰 루프

`40-pr-review-loop/`는 사일로 결과가 PR로 올라온 뒤, 리뷰, 재작업, SSoT 승격 판단, 머지 보고까지 이어지는 기준을 관리합니다.

PR은 단순히 코드를 머지하는 절차가 아닙니다. 사일로가 발견한 로컬 issue/task 중 무엇을 project SSoT 또는 0계층 규칙 후보로 승격할지 판단하는 시점입니다.

## 읽는 순서

1. [`01-pr-description.md`](01-pr-description.md)
2. [`02-review-policy.md`](02-review-policy.md)
3. [`03-promotion-decision.md`](03-promotion-decision.md)
4. [`04-branch-safety-and-lifecycle.md`](04-branch-safety-and-lifecycle.md)
5. [`05-merge-report.md`](05-merge-report.md)
6. [`06-pr-template.md`](06-pr-template.md)

## 핵심 원칙

- PR 생성 승인과 PR 머지 승인은 별개입니다.
- `main`은 레거시 보존 브랜치이며 작업 기준으로 쓰지 않습니다.
- `main-v2`는 보호 브랜치이며 직접 commit/push하지 않습니다.
- `main-v2` 대상 PR은 수동 `@codex review`를 기본 리뷰 조건으로 둡니다.
- 사용자가 PR을 리뷰 대기 에이전트로 돌리라고 하면 `review-waiter-agent`가 승인 리뷰까지 백그라운드 루프로 관리합니다. task silo의 `goal.md`가 확인되면 `/goal`을 재사용하고, 그렇지 않으면 PR 본문, 리뷰 thread, 현재 사용자 요청을 컨텍스트로 사용합니다. 반복 한도는 사용자가 이번 PR에 명시한 경우에만 적용합니다.
- 사일로 발견 사항은 `SSoT 승격 후보`와 `승격하지 않을 항목`으로 분리합니다.
