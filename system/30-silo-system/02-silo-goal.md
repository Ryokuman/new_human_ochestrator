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
- 초기 DB 목데이터
- 테스트 입력
- 리뷰 gate 적용 여부
- 사용자 취향 규칙
- 승인 경계
- 관련 test evidence
- execution mode, 기본값은 `yolo`

## 자동 준비 범위

사용자가 task 실행, 태스크 진행, task 수행을 요청하면 메인 오케스트레이터는 별도 확인 없이 아래 준비까지 수행합니다.

```text
task-xxxx/ 생성
-> goal.md 작성
-> 필요한 repo clone
-> repo별 작업 브랜치 생성
```

위 준비 중 하나라도 실제로 시작하기 전에 project SSoT의 원본 task/issue 상태를 `in_progress`로 갱신해야 합니다. 이 상태 갱신도 project 계층 변경이므로 project 계층 메인 브랜치에 직접 커밋하지 않습니다. 목표 모델에서는 `project-{projectName}/{taskname}` 작업 브랜치에서 상태 갱신 PR을 먼저 만든 뒤 `project-{projectName}/main`에 머지된 것을 확인합니다. 현재 호환 상태에서는 `project-{projectName}-{taskname}` 작업 브랜치와 `project-{projectName}` 대상 PR을 사용합니다. 상태 갱신 PR이 머지되기 전에는 사일로 root 생성, `goal.md` 작성, repo clone, 작업 브랜치 생성을 시작하지 않습니다. SSoT 상태 갱신 PR을 만들거나 머지 상태를 확인할 수 없으면 사일로 진행을 멈추고, 갱신 불가 사유를 보고합니다.

## goal.md 필수 항목

- 원래 task/issue 목표와 SSoT 경로
- 원래 task/issue가 속한 2계층 `Project Work SSoT` 경로. root `main-v3/main`에 실데이터가 없으면 해당 project SSoT 위치를 참조하고, task, issue, QA, runbook, coverage, work dashboard, Run Set 중 어떤 work data를 소비하는지 적습니다.
- 사일로 유형: 테스트 사일로 또는 일반 사일로
- 필요한 repo 목록
- 참조한 Runtime Set 결정 근거, runtime set id, branch, commit, port, health check 결과
- 테스트 사일로인 경우 report 위치와 execution window 또는 scheduler 기준
- 보호 브랜치와 권장 작업 브랜치명
- 사일로 내부 개발자/QA/리뷰 역할의 책임
- 금지선: secret 기록, production 데이터 쓰기, 보호 브랜치 직접 push, 승인 없는 data SSoT 수정
- 검증 기준
- 기능 task인 경우 task 작성 전 확인한 project contract 위치와 누락 항목
- 기능 task인 경우 project contract gate 통과 근거: 제품 정의, 핵심 사용자 흐름, MVP/비목표, 데이터 저장/동기화 경계, repo/runtime 정본 위치
- 기능 task인 경우 단계별 구현 계획
- 기능 task인 경우 pseudo code: 파일별 대표 함수 골격, 필요한 입력/의존성, 조회/검증/가공/분기/저장/반환, API/DB mutation/화면 상태 변화
- 기능 task pseudo code에서 발견한 범위 drift 후보
- criteria별 테스트 계약
- 초기 DB 목데이터와 각 데이터가 필요한 이유
- 테스트 입력과 실행 중 입력되는 액션/payload
- 원본 task의 Output, Acceptance Criteria, Test Plan
- PR 생성 직후 수동 `@codex review` 호출 여부 또는 생략 사유
- 브라우저 확인이 필요한 경우 `agent-browser` 사용 기준
- PR 본문 필수 항목

Runtime Set은 아래 우선순위로 결정합니다.

1. `run_set.required_runtime_set`
2. `task.runtime_set`
3. `qa_or_runbook.runtime_set`
4. `project.common_runtime_set`
5. 없으면 `runtime 정의 누락`

`goal.md`에는 어느 위치에서 runtime set을 찾았는지와 더 높은 우선순위가 없다는 확인 결과를 적습니다. runtime 정의가 없으면 임의 서버 조합을 만들지 않고 `runtime 정의 누락`으로 보고합니다.

`goal.md`는 원본 task의 `Output`과 `Acceptance Criteria`를 완료 기준으로 삼아야 합니다. 각 criteria는 `unit`, `integration`, `runner`, `E2E`, `agent-browser`, `manual` 중 하나 이상의 검증 방법과 연결합니다.

기능 task의 `goal.md`에는 사일로 실행 전에 project contract 확인 결과, 단계별 구현 계획, pseudo code를 적습니다. pseudo code는 사용자 흐름 설명이나 구현 계획 문장이 아니라 파일별 대표 함수에 실제 로직 구조가 어떻게 들어갈지 확인하는 코드 골격입니다. TypeScript/JavaScript 같은 실제 컴파일 가능한 코드나 완성된 함수 구현은 아니지만, 각 파일마다 대표 함수와 보조 함수를 나누고 `필요한 입력/의존성`, `조회`, `검증`, `가공`, `조건 분기`, `반복`, `저장`, `반환`이 코드에 가깝게 보여야 합니다. 파일명, 함수명, API query, DB mutation, op 이름(`D/L/C/R`) 같은 코드 식별자는 원문 그대로 쓸 수 있지만, 설명 문장은 한국어로 씁니다. task 목표 밖 화면, 버튼, endpoint, table mutation, submodule, E2E 범위가 보이면 `범위 drift 후보`로 표시하고, 리뷰 전에는 구현을 시작하지 않습니다. 비기능 task, coverage task, 문서 task에는 pseudo code를 기계적으로 요구하지 않습니다.

예시:

```text
파일: src/features/meal/api.ts

saveMeal은 mealInput, session, mealRepository가 필요합니다.

saveMeal(mealInput, session, mealRepository) {
    if (session 없음) {
        return 실패("인증 필요")
    }

    validation = validateMealInput(mealInput)

    if (validation 실패) {
        return 실패(validation.message)
    }

    savedMeal = mealRepository.create({
        userId: session.user.id
        name: mealInput.name
        calories: mealInput.calories
        mealTime: mealInput.mealTime
    })

    return 성공(savedMeal)
}

파일: src/features/meal/store.ts

applySavedMeal은 currentMeals, savedMeal이 필요합니다.

applySavedMeal(currentMeals, savedMeal) {
    nextMeals = currentMeals에 savedMeal 추가
    todayFoodCard.status = "logged"

    return {
        meals: nextMeals
        todayFoodCard
    }
}
```

기능 task의 project contract 확인은 task 작성 전에 수행합니다. project contract에는 제품 정의, 현재 버전 목표/비목표, 핵심 사용자 플로우, 데이터 저장과 동기화 경계, FE/BE/DB/harness/submodule 역할, 디자인 톤 정본, 추정 금지 정보가 있어야 합니다. project contract 또는 하위 SSoT 참조가 없으면 해당 정보를 추정하지 않고 `project contract 누락` 또는 더 좁은 `project SSoT 계약 누락`으로 분류합니다.

project contract gate가 아직 진행 중이면 사일로 `goal.md`를 만들지 않습니다. 이 상태에서는 `현재 gate`, `누락된 계약 항목`, `agent 추론`, `사용자 확인 질문`, `요구사항 문서화 위치 후보`, `task 작성 가능 조건`을 보고하고, project contract가 충분히 성숙한 뒤 사용자가 첫 구현 slice를 고르면 task와 사일로 준비로 넘어갑니다.

project contract gate를 통과한 task라도 `goal.md`는 제품 요구사항 전체를 복사하는 곳이 아닙니다. 기능 또는 사용자 흐름별 project SSoT 요구사항 문서의 경로를 참조하고, 사일로에는 이번 task가 소비할 계약, acceptance, test plan, 파일별 대표 함수 골격형 pseudo code만 둡니다.

`초기 DB 목데이터`는 테스트 시작 전에 DB에 미리 seed로 존재해야 하는 상태입니다. 실제 DB schema에서 FK나 조회 조건으로 확인된 테스트 사용자 row, 날짜 컬럼을 가진 기존 기록 row, 참조 테이블 값처럼 테스트 전제 상태를 만드는 데이터만 포함합니다. 각 항목에는 해당 데이터가 왜 시작 전에 필요한지, 어떤 criteria를 가능하게 하는지, 재실행 시 중복 또는 오염을 어떻게 피하는지 적습니다.

초기 DB 목데이터가 필요한 `goal.md`를 작성할 때는 먼저 project registry/config 또는 project SSoT의 DB schema 정본 위치나 schema 요약을 확인합니다. schema 참조가 없으면 테이블, 컬럼, FK, profile, goal, 날짜 테이블 같은 제품 정보를 추정하지 않고 `project SSoT schema 계약 누락`으로 분류합니다. API contract, auth/session contract, runtime DB/harness DB 계약처럼 mock data 정의와 task 실행에 필요한 중요 제품 정보도 같은 방식으로 정본 위치나 요약을 참조합니다.

`테스트 입력`은 테스트 실행 중 사용자, runner, harness, API client가 넣는 값과 액션입니다. 폼 입력값, 버튼 선택, 빠른 체크 액션, API request body, validation 실패를 확인하기 위한 잘못된 값은 테스트 입력입니다. 어떤 값이 사용자 액션 또는 API 호출 이후에만 생길 수 있다면 초기 DB 목데이터가 아니라 테스트 입력으로 분류합니다.

유닛 테스트 계획을 설명할 때도 초기 상태와 실행 입력을 나눕니다. task나 `goal.md`에는 실제 유닛 테스트 코드를 작성하지 않고, 준비할 seed state, 호출할 함수/API 또는 UI action payload, 기대 결과와 실패 조건만 적습니다.

구현 task의 `goal.md`에는 자동 검증이 보장하는 것과 보장하지 못하는 것을 분리합니다. agent가 통제한 대체 검증 경로의 통과는 실제 사용자 설치/로그인/네트워크 경로 통과와 구분합니다. 사용자 화면, 설치, 서버 실행, 앱 다운로드 가능 상태가 acceptance에 포함되면 인간 QA 전 `Pre-QA Gate`와 사용자가 따라 할 QA 리스트를 포함합니다.

외부 서비스, 인증, 실제 네트워크, 사용자 계정, 런타임 설정처럼 agent가 직접 통제하지 못하는 요소가 task completion에 끼어들면 `goal.md`에는 통제 가능성, 증명 가능성, 사용자 승인 필요 여부를 분리합니다. 구체적인 L 단계, provider별 checklist, fixture/harness 구현 방식, merge 전 세부 QA gate는 project SSoT 또는 task 계약을 참조하게 하고, system SSoT에 일반 규칙처럼 고정하지 않습니다.

runner, E2E, agent-browser, 외부 도구를 실행할 수 없으면 실행 불가 사유, 대체 증거, 남은 수동 확인 범위를 완료 보고와 PR 본문에 남깁니다. 사일로 시작 전부터 실행 불가가 예상되는 경우에는 `goal.md`에도 함께 남깁니다.

모든 task 명세서와 `goal.md`는 읽고 실행 범위를 파악하는 시간이 기본 5분을 넘지 않도록 작성합니다. 최대 허용치는 7분이며, 넘길 분량이면 상단에 실행 요약, 금지선, acceptance criteria, test plan을 먼저 둡니다.
