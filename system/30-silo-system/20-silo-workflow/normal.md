# 일반 사일로 Workflow

일반 사일로 workflow는 구현, 수정, 문서, repair, conflict, PR 작업을 목표로 합니다.

## 내부 역할

| 역할 | 책임 |
|---|---|
| 개발자 에이전트 | task/issue를 구현하고 필요한 repo branch와 diff를 만든다. |
| QA 에이전트 | acceptance criteria 기준으로 unit, runner, E2E, agent-browser, report, 회귀 여부를 검증한다. |
| 리뷰 에이전트 | scope, branch safety, secret/protected branch 위반, PR 본문, SSoT 승격 후보를 검토한다. |

세 역할은 별도 사일로가 아닙니다. 같은 task 사일로 안에서 순차 또는 병렬 worker로 호출됩니다.

## 실행 루프

```text
1. 입력 task/issue 읽기
2. 현재 workspace 루트에 `<unit-id>/` 사일로 root 생성
3. `goal.md` 작성
4. 필요한 repo만 사일로 root에 clone
5. 필요한 runtime set 확인
6. 각 repo에서 기준 브랜치 확인 후 작업 브랜치 생성
7. 개발 세션에 `/goal`로 `goal.md 달성 부탁해` 전달
8. 개발자 에이전트가 관련 코드와 QA 증거를 확인하고 수정 수행
9. QA 에이전트가 테스트, agent-browser 검증, report 실행
10. 리뷰 에이전트가 diff, scope, branch safety, secret policy, SSoT 후보 검토
11. PR 필요 시 base branch와 리뷰 gate 확인
12. 실패 또는 생략 사유 기록
13. 실패하면 task 내부 Hypothesis Chain에 현재 가설, 실행 로그, 실패 결과, 원인을 기록하고 다음 가설을 작성
14. 통과하면 diff가 있는 repo만 PR 생성
15. PR 본문에 결과, criteria별 검증 결과, 리뷰 gate 결과, 승격 후보, 비승격 항목 기록
16. project SSoT의 task/issue/인수인계 상태 갱신 후보 정리
17. 메인 오케스트레이터에게 최종 보고
```

YOLO 모드는 [`yolo-mode.md`](yolo-mode.md)를 기준으로 봅니다.

리뷰 gate는 [`review-gate.md`](review-gate.md)를 기준으로 봅니다.
