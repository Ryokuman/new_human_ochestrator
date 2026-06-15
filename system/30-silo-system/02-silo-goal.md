# 사일로 입력과 Goal

## 입력

사일로가 시작할 때 받는 정보:

- source issue 또는 task
- 허용 scope
- clone 대상 repo 목록
- 공용 서비스 사용 여부
- 참조할 runtime set과 branch/commit/port
- 기준 브랜치와 작업 브랜치 이름
- acceptance criteria
- verification plan
- criteria별 테스트 계약
- 리뷰 gate 적용 여부
- 사용자 취향 규칙
- 승인 경계
- 관련 QA 증거
- execution mode, 기본값은 `yolo`

## 자동 준비 범위

사용자가 task 실행, 태스크 진행, task 수행을 요청하면 메인 오케스트레이터는 별도 확인 없이 아래 준비까지 수행합니다.

```text
task-xxxx/ 생성
-> goal.md 작성
-> 필요한 repo clone
-> repo별 작업 브랜치 생성
```

## goal.md 필수 항목

- 원래 task/issue 목표와 SSoT 경로
- 사일로 유형: 테스트 사일로 또는 일반 사일로
- 필요한 repo 목록
- 참조한 runtime set, branch, commit, port, health check 결과
- 테스트 사일로인 경우 report 위치와 execution window 또는 scheduler 기준
- 보호 브랜치와 권장 작업 브랜치명
- 사일로 내부 개발자/QA/리뷰 역할의 책임
- 금지선: secret 기록, production 데이터 쓰기, 보호 브랜치 직접 push, 승인 없는 data SSoT 수정
- 검증 기준
- 원본 task의 Output, Acceptance Criteria, Test Plan
- PR 생성 직후 수동 `@codex review` 호출 여부 또는 생략 사유
- 브라우저 확인이 필요한 경우 `agent-browser` 사용 기준
- PR 본문 필수 항목

`goal.md`는 원본 task의 `Output`과 `Acceptance Criteria`를 완료 기준으로 삼아야 합니다. 각 criteria는 `unit`, `runner`, `E2E`, `agent-browser`, `manual` 중 하나 이상의 검증 방법과 연결합니다.

모든 task 명세서와 `goal.md`는 읽고 실행 범위를 파악하는 시간이 기본 5분을 넘지 않도록 작성합니다. 최대 허용치는 7분이며, 넘길 분량이면 상단에 실행 요약, 금지선, acceptance criteria, test plan을 먼저 둡니다.
