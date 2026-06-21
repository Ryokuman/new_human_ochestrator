# 일반 사일로 Workflow

일반 사일로 workflow는 구현, 수정, 문서, repair, conflict, PR 작업을 목표로 합니다.

## 내부 역할

| 역할 | 책임 |
|---|---|
| 테스트 작성 에이전트 | acceptance criteria를 criteria별 테스트 계약, 자동 검증 범위, Pre-QA Gate, 실행 불가 대체 증거 기준으로 바꾼다. |
| 개발자 에이전트 | task/issue를 구현하고 필요한 repo branch와 diff를 만든다. |
| QA 에이전트 | acceptance criteria 기준으로 unit, integration, runner, E2E, agent-browser, manual, report, 회귀 여부를 검증한다. |
| 리뷰 에이전트 | scope, branch safety, secret/protected branch 위반, PR 본문, SSoT 승격 후보를 검토한다. |

네 역할은 별도 사일로가 아닙니다. 같은 task 사일로 안에서 순차 또는 병렬 worker로 호출됩니다.

## 실행 루프

```text
1. 입력 task/issue 읽기
2. project SSoT의 원본 task/issue 상태를 `in_progress`로 갱신
3. 현재 workspace 루트에 `<unit-id>/` 사일로 root 생성
4. `goal.md` 작성
5. 필요한 repo만 사일로 root에 clone
6. 필요한 runtime set 확인
7. 각 repo에서 기준 브랜치 확인 후 작업 브랜치 생성
8. 테스트 작성 에이전트가 criteria별 테스트 계약과 검증 범위를 작성하고 `goal.md`에 반영
9. 개발 세션에 `/goal`로 `goal.md 달성 부탁해` 전달
10. 개발자 에이전트가 관련 코드와 QA 증거를 확인하고 수정 수행
11. QA 에이전트가 테스트, agent-browser 검증, report 실행
12. 리뷰 에이전트가 diff, scope, branch safety, secret policy, SSoT 후보 검토
13. PR 필요 시 base branch와 리뷰 gate 확인
14. 실패 또는 생략 사유 기록
15. 실패하면 task 내부 Hypothesis Chain에 현재 가설, 실행 로그, 실패 결과, 원인을 기록하고 다음 가설을 작성
16. 통과하면 diff가 있는 repo만 PR 생성
17. PR 본문에 결과, criteria별 검증 결과, 리뷰 gate 결과, 승격 후보, 비승격 항목 기록
18. project SSoT의 task/issue/인수인계 상태 갱신 후보 정리
19. 메인 오케스트레이터에게 최종 보고
```

2번 상태 갱신은 준비 단계의 일부가 아니라 시작 gate입니다. 상태 갱신이 불가능하면 사일로를 계속 진행하지 않고, 이미 생성된 로컬 파일이 있으면 임시 evidence로 분리해 보고합니다.

외부 서비스, 인증, 실제 네트워크, 사용자 계정, 런타임 설정처럼 agent가 직접 통제하지 못하는 요소가 task completion에 끼어들면 8번에서 통제 가능성, 증명 가능성, 사용자 승인 필요 여부를 먼저 분리합니다. 구체적인 L 단계, provider별 checklist, fixture/harness 구현 방식, merge 전 세부 QA gate는 project SSoT 또는 task 계약을 참조하게 하고, system SSoT에 일반 규칙처럼 고정하지 않습니다.

YOLO 모드는 [`yolo-mode.md`](yolo-mode.md)를 기준으로 봅니다.

리뷰 gate는 [`review-gate.md`](review-gate.md)를 기준으로 봅니다.
