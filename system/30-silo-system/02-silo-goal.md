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

위 준비 중 하나라도 실제로 시작하면 project SSoT의 원본 task/issue 상태를 먼저 `in_progress`로 갱신합니다. 시작 시점은 사일로 root 생성, `goal.md` 작성, repo clone, 작업 브랜치 생성 중 가장 이른 실행으로 봅니다. SSoT 상태를 갱신할 수 없으면 사일로 진행을 멈추고, 갱신 불가 사유와 이미 생성한 로컬 evidence 위치를 보고합니다.

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
- criteria별 테스트 계약
- 원본 task의 Output, Acceptance Criteria, Test Plan
- PR 생성 직후 수동 `@codex review` 호출 여부 또는 생략 사유
- 브라우저 확인이 필요한 경우 `agent-browser` 사용 기준
- PR 본문 필수 항목

`goal.md`는 원본 task의 `Output`과 `Acceptance Criteria`를 완료 기준으로 삼아야 합니다. 각 criteria는 `unit`, `integration`, `runner`, `E2E`, `agent-browser`, `manual` 중 하나 이상의 검증 방법과 연결합니다.

구현 task의 `goal.md`에는 자동 검증이 보장하는 것과 보장하지 못하는 것을 분리합니다. agent가 통제한 대체 검증 경로의 통과는 실제 사용자 설치/로그인/네트워크 경로 통과와 구분합니다. 사용자 화면, 설치, 서버 실행, 앱 다운로드 가능 상태가 acceptance에 포함되면 인간 QA 전 `Pre-QA Gate`와 사용자가 따라 할 QA 리스트를 포함합니다.

외부 서비스, 인증, 실제 네트워크, 사용자 계정, 런타임 설정처럼 agent가 직접 통제하지 못하는 요소가 task completion에 끼어들면 `goal.md`에는 통제 가능성, 증명 가능성, 사용자 승인 필요 여부를 분리합니다. 구체적인 L 단계, provider별 checklist, fixture/harness 구현 방식, merge 전 세부 QA gate는 project SSoT 또는 task 계약을 참조하게 하고, system SSoT에 일반 규칙처럼 고정하지 않습니다.

runner, E2E, agent-browser, 외부 도구를 실행할 수 없으면 실행 불가 사유, 대체 증거, 남은 수동 확인 범위를 완료 보고와 PR 본문에 남깁니다. 사일로 시작 전부터 실행 불가가 예상되는 경우에는 `goal.md`에도 함께 남깁니다.

모든 task 명세서와 `goal.md`는 읽고 실행 범위를 파악하는 시간이 기본 5분을 넘지 않도록 작성합니다. 최대 허용치는 7분이며, 넘길 분량이면 상단에 실행 요약, 금지선, acceptance criteria, test plan을 먼저 둡니다.
