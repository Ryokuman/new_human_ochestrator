# YOLO 모드

사일로 기본 실행 모드는 `yolo`입니다.

- 사일로는 수정 전 승인 대기 없이 문제 해결을 우선합니다.
- source code, generated output, test, tooling을 격리 clone 내부에서 자유롭게 수정합니다.
- 접근 가능한 검증 명령과 agent-browser QA를 스스로 실행합니다.
- 실패하거나 방향이 틀리면 해당 clone/branch를 폐기하고 다시 시작할 수 있습니다.
- 완료되면 PR 본문에 수정 범위, 검증 결과, feedback/follow-up 후보, 처리하지 않고 남긴 항목을 적습니다.

`yolo`는 시작 gate를 생략하는 권한이 아닙니다. 여기서 생략하는 승인은 이미 시작 gate를 통과한 사일로 내부 수정 승인입니다. 공유 상태나 2계층 `Project Work SSoT` 원문을 바꾸는 정식 사일로 실행은 상태 갱신 PR gate를 먼저 통과해야 합니다. gate 전에는 읽기 전용 조사, 초안, 폐기 가능한 prototype 탐색처럼 공유 상태를 바꾸지 않는 선행 작업만 허용합니다.

- 2계층 `Project Work SSoT` 원본 task/issue 상태를 `in_progress`로 갱신하는 PR은 사일로 root, `goal.md`, repo clone, 작업 브랜치 생성보다 먼저 머지되어야 합니다. 1계층 `Project SSoT`는 해당 원문 위치를 찾기 위한 index나 project-level 계약 참조로만 사용합니다.
- 상태 갱신 PR을 만들거나 머지 확인을 할 수 없으면 `yolo`라도 사일로를 시작하지 않고 갱신 불가 사유를 보고합니다.

`yolo`에서도 아래는 금지됩니다.

- 보호 브랜치 직접 commit 또는 push
- production 데이터 쓰기
- secret 값 읽기 결과를 로그나 문서에 기록
- 공유 브랜치 force push
- SSoT 전역 규칙 임의 변경
- 상태 갱신 PR 없이 Project Work SSoT 원문, 공유 report/test evidence 위치, 회수 대상 작업 브랜치를 만드는 것
