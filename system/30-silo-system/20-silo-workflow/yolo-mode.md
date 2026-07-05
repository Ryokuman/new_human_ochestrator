# YOLO 모드

사일로 기본 실행 모드는 `yolo`입니다.

- 사일로는 수정 전 승인 대기 없이 문제 해결을 우선합니다.
- source code, generated output, test, tooling을 격리 clone 내부에서 자유롭게 수정합니다.
- 접근 가능한 검증 명령과 agent-browser QA를 스스로 실행합니다.
- 실패하거나 방향이 틀리면 해당 clone/branch를 폐기하고 다시 시작할 수 있습니다.
- 완료되면 PR 본문에 수정 범위, 검증 결과, evidence/follow-up 후보, 처리하지 않고 남긴 항목을 적습니다.

`yolo`에서도 아래는 금지됩니다.

- 보호 브랜치 직접 commit 또는 push
- production 데이터 쓰기
- secret 값 읽기 결과를 로그나 문서에 기록
- 공유 브랜치 force push
- SSoT 전역 규칙 임의 변경
