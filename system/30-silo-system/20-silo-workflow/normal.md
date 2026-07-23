# 일반 사일로 Workflow

일반 사일로 workflow는 구현, 수정, 문서, repair, conflict, PR 작업을 목표로 합니다.

## 내부 역할

| 역할 | 책임 |
|---|---|
| 테스트 작성 에이전트 | acceptance criteria를 criteria별 테스트 계약, 자동 검증 범위, Pre-QA Gate, 실행 불가 대체 증거 기준으로 바꾼다. |
| 개발자 에이전트 | task/issue를 구현하고 필요한 repo branch와 diff를 만든다. |
| QA 에이전트 | acceptance criteria 기준으로 unit, integration, runner, E2E, agent-browser, manual, report, 회귀 여부를 검증한다. |
| 리뷰 에이전트 | scope, branch safety, secret/protected branch 위반, PR 본문, feedback/follow-up 후보를 검토한다. |

네 역할은 별도 사일로가 아닙니다. 같은 task 사일로 안에서 순차 또는 병렬 worker로 호출됩니다.

## 실행 루프

```text
1. 입력 task/issue 읽기
2. project 계층 작업 브랜치에서 2계층 `Project Work SSoT` 원본 task/issue 상태를 `in_progress`로 바꾸는 상태 갱신 PR 생성 및 머지 확인. 1계층 `Project SSoT`는 해당 원문 위치를 찾기 위한 index나 project-level 계약 참조로만 사용합니다. 목표 모델에서는 `project-{projectName}/{taskname}`와 `project-{projectName}/main`, 현재 호환 상태에서는 `project-{projectName}-{taskname}`와 `project-{projectName}`을 사용
3. 현재 workspace 루트에 `<unit-id>/` 사일로 root 생성
4. `goal.md` 작성
5. 필요한 repo만 사일로 root에 clone
6. 필요한 runtime set 확인
7. 각 repo에서 기준 브랜치 확인 후 작업 브랜치 생성
8. 테스트 작성 에이전트가 criteria별 테스트 계약과 검증 범위를 작성하고 `goal.md`에 반영
9. 개발 세션에 `/goal`로 `goal.md 달성 부탁해` 전달
10. 개발자 에이전트가 관련 코드와 test evidence를 확인하고 수정 수행
11. QA 에이전트가 테스트, agent-browser 검증, report 실행
12. 리뷰 에이전트가 diff, scope, branch safety, secret policy, SSoT 후보 검토
13. PR 필요 시 base branch와 리뷰 gate 확인
14. 실패 또는 생략 사유 기록
15. 실패 원인과 다음 시도 근거가 필요하면 task 내부의 선택적 `Hypothesis Chain` 또는 task-local evidence에 현재 시도, 실행 로그, 실패 결과, 원인을 기록
16. 통과하면 diff가 있는 repo만 PR 생성
17. PR 본문에 결과, criteria별 검증 결과, 리뷰 gate 결과, 승격 후보, 비승격 항목 기록
18. 2계층 `Project Work SSoT`의 task/issue/인수인계 상태 갱신 후보 정리. 1계층 `Project SSoT` 경로는 위치 index나 요구사항/계약 참조로만 분리
19. 메인 오케스트레이터에게 최종 보고
```

2번 상태 갱신은 준비 단계의 일부가 아니라 공유 상태와 Project Work SSoT 원문을 보호하는 시작 gate입니다. 상태 갱신 PR 생성과 그 PR 안의 `in_progress` 상태 diff는 이 gate를 여는 최소 Build로 허용하지만, 상태 갱신 PR이 project 계층 메인 브랜치에 머지되기 전에는 정식 사일로 root, 정식 `goal.md`, repo clone, 작업 브랜치를 만들지 않습니다. 목표 모델에서는 `project-{projectName}/main`, 현재 호환 상태에서는 `project-{projectName}`을 확인합니다. 상태 갱신 PR을 만들거나 머지 상태를 확인할 수 없으면 정식 사일로 실행을 계속 진행하지 않고 갱신 불가 사유를 보고합니다.

단, 읽기 전용 조사, 기준 브랜치/파일/런타임 위치 확인, 대화 또는 로컬 임시 초안, 폐기 가능한 prototype 탐색, 상태 갱신 PR 작성은 2번 gate 전에도 수행할 수 있습니다. 이 선행 작업은 공유 상태 변경, Project Work SSoT 원문 변경, PR 제출, 장기 사일로 root 생성, 보호 브랜치 직접 수정으로 이어지면 안 되며, 정식 실행으로 전환할 때 gate 통과 여부를 다시 확인합니다.

외부 서비스, 인증, 실제 네트워크, 사용자 계정, 런타임 설정처럼 agent가 직접 통제하지 못하는 요소가 task completion에 끼어들면 8번에서 통제 가능성, 증명 가능성, 사용자 승인 필요 여부를 먼저 분리합니다. 구체적인 L 단계, provider별 checklist, fixture/harness 구현 방식, merge 전 세부 QA gate는 1계층 `Project SSoT`의 반복 정책, 2계층 `Project Work SSoT`의 task/runbook/QA 계약, 또는 3계층 local evidence 중 실제 소유 위치를 참조하게 하고, system SSoT에 일반 규칙처럼 고정하지 않습니다.

YOLO 모드는 [`yolo-mode.md`](yolo-mode.md)를 기준으로 봅니다.

리뷰 gate는 [`review-gate.md`](review-gate.md)를 기준으로 봅니다.
