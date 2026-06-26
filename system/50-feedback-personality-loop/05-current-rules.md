# 현재 규칙 후보

## 현재 확정된 전역 규칙

사용자 답변으로 확정된 규칙:

1. 사람이 읽는 프롬프트와 보고서는 한국어를 우선합니다.
2. 사일로는 필요한 레포지토리만 새로 clone해서 격리 작업 공간을 만듭니다.
3. 사일로는 새 작업 브랜치에서 문제 해결에 필요한 코드를 자유롭게 수정할 수 있습니다.
4. 사일로는 `main`, `main-v2`, `dev`, `develop`, `master` 같은 보호 브랜치에 절대 직접 손대지 않습니다.
5. 사일로 발견 사항은 PR 본문에서 `SSoT 승격 후보`와 `승격하지 않을 항목`으로 나눕니다.
6. 퍼스널리티/취향/응답 규칙 갱신은 항상 `main-v2`에서 파생한 새 브랜치에서 수행하고 PR로 제출합니다.
7. 프로젝트 artifact를 설명할 때는 느슨한 별칭보다 SSoT 경로와 역할이 드러나는 이름을 우선합니다.
8. 다음 행동, 승인 단위, 진행 여부가 걸린 응답에서는 보기 3개를 제시합니다.
9. 퍼스널리티 업데이트는 evidence 작성, 보고서 후보 작성, 실제 반영을 분리하고, 실제 반영 전 사용자 승인을 받습니다.
10. `user-personality-adaptive-response`는 모든 사용자 답변을 장기 로그로 저장하는 장치가 아니라, 응답 계약에 영향을 준 명시 피드백, 보기 밖 선택, 반복 오류, 특이 실행 전제를 evidence로 남기는 장치입니다.
11. 응답 계약에 영향을 주는 사건은 승격 여부와 무관하게 evidence로 남깁니다. 승격될지는 사용자가 원하는 주기로 여는 퍼스널리티 검토 세션에서 판단합니다.
12. 프로젝트/기기별 QA 런타임 제약은 전역 사용자 취향으로 일반화하지 않고 project SSoT, project registry, 또는 로컬 evidence의 project override로 분리합니다.
13. 모바일 QA 준비에서 사용자가 특정 기기, 설치 방식, 네트워크 전제를 명시하면, 일반적인 도구 추천보다 그 명시 전제를 우선합니다.
14. 프로젝트별 personality/override의 실제 값은 전역 규칙 문서에 고정하지 않고, `project/*` 브랜치, project SSoT, project registry, 또는 로컬 evidence에 둡니다. 전역 `system/`에는 분류 기준, 승인 경계, 저장 위치, 보고 방식만 둡니다.
15. 사용자가 퍼스널리티, 선택지, 보고 방식, 승인 경계 누락을 지적했을 때 해당 skill이 세션의 외부 skill 목록에 없더라도, repo-local `system/20-skills/`에 같은 skill이 있는지 확인합니다.
16. 사용자가 목적, 완료 범위, 달성률, 테스트 여부가 헷갈린다고 말하면 새 작업을 진행하기 전에 목표, 완료된 것, 남은 것, 검증 증거를 먼저 재정렬합니다.
17. 사용자가 서버 실행, 앱 설치 가능 상태, QA 리스트를 요구하면 코드 변경 보고만으로 완료하지 않습니다. 실행 가능한 runtime, 접근 방법, 검증 목록을 함께 준비합니다.
18. 최종 보고에는 `사용한 스킬` 바로 다음에 `현재 워크트리`를 적고, 새 worktree를 생성하거나 기준 worktree를 전환한 직후에는 중간 보고에서도 새 경로와 브랜치를 즉시 알립니다.
19. 기능 task는 프론트/백엔드 분리 소유권이 아니라 사용자 목적과 완료 경로 기준의 풀스택 단위로 검토하고 실행합니다.
20. 소비 API, schema, store method, route 부재는 단독 task 위험으로 단정하지 않고, 같은 task 안에서 백엔드 계약을 먼저 만들고 프론트가 소비하는 순서를 기본 실행안으로 둡니다.
21. PR 생성 시에는 먼저 현재 브랜치의 0계층/project 계층과 target/base를 판정합니다. 0계층은 `main-v2`, project 계층은 별도 worktree의 파생 브랜치에서 커밋한 뒤 해당 `project/<project-id>` 대상 PR로 올리고, 둘이 섞이면 worktree와 브랜치를 분리합니다. PR 생성 후에는 `codex-pr-review-loop` skill로 no-major 목표를 세팅하고, 최신 head에 대한 `Didn't find any major issues` 또는 동등한 no-major 명시 응답이 나올 때까지 수정, 검증, 재리뷰를 반복합니다. 최신 호출 댓글에 3분 동안 `eyes` 반응이 없고 최신 head 리뷰 결과도 없으면 접수 실패로 보고 같은 head 기준으로 최대 3회까지 재호출한 뒤 새 호출 댓글 기준으로 다시 확인하며, 3회 모두 접수되지 않으면 `Codex 리뷰 접수 실패 timeout`으로 중단합니다. `eyes` 반응을 확인한 뒤 15분 동안 Codex 응답이 없으면 `Codex 리뷰 응답 대기 timeout`으로 중단하고 보고합니다. task silo의 `goal.md`가 확인되면 no-major 목표를 `goal.md`에 세팅하고, 그렇지 않은 PR은 PR 본문, 리뷰 thread, 현재 사용자 요청을 재리뷰 컨텍스트로 사용합니다. no-major 반복은 기본 상한을 두지 않지만, no-`eyes` 접수 실패 재호출은 같은 head 기준 기본 3회로 제한합니다.
22. 병렬로 생성하거나 실행할 task는 sibling task 완료를 `Output`, `Acceptance Criteria`, `Test Plan`의 전제로 삼지 않습니다. 개별 task output은 그 task가 독립적으로 증명할 수 있는 산출물로 제한하고, 인증/데이터/화면/backend 의존성이 있으면 agent가 통제할 수 있는 대체 검증 경로와 실제 사용자 경로의 차이를 task 계약에 명시합니다. 여러 sibling task 완료를 전제로 하는 최종 통합 E2E는 개별 task acceptance가 아니라 별도 QA gate, integration task, 또는 후속 project 검증으로 분리합니다. 단일 task의 화면 동작 자체가 산출물이면 E2E 또는 agent-browser acceptance를 유지합니다.
23. system SSoT는 상황별 행동 처방을 누적하는 곳이 아니라, agent가 판단할 근거와 계층 분류 기준을 모아두는 프롬프트/스킬 하네스입니다. 외부 서비스, 인증, 실제 네트워크, 사용자 계정, 런타임 설정처럼 agent가 직접 통제하지 못하는 요소가 completion에 끼어들면 system에는 통제 가능성, 증명 가능성, 사용자 승인 필요 여부를 분리하는 판단 근거만 둡니다. provider별 체크리스트, L 단계 이름, fixture/harness 구현 방식, merge 전 세부 QA gate는 project SSoT 또는 task 계약으로 내려보냅니다.
24. agent 감사나 PR 리뷰에서 특정 provider, 화면, DB fixture, L runner, runtime harness처럼 좁은 스코프 항목이 발견되면 system에는 그 항목의 실제 절차를 추가하지 않습니다. 대신 `system에 남길 판단 근거`, `project SSoT로 내려보낼 실행 처방`, `승격하지 않을 항목`, `누락된 project SSoT 정의`를 분리해 보고합니다. project SSoT 위치가 불명확하면 system에 임시 처방을 쓰지 않고 `project SSoT 위치 누락` 또는 `task 계약 누락`으로 남깁니다.
25. 기능 task는 사일로 실행 전에 단계별 구현 계획과 pseudo code를 먼저 작성하고 리뷰합니다. pseudo code는 실제 코드가 아니라 파일/함수/API/DB mutation/화면 상태 변화가 드러나는 수준으로 작성하며, task 목표 밖 화면, 버튼, endpoint, table mutation, submodule, E2E 범위가 보이면 `범위 drift 후보`로 표시합니다. pseudo code 없이 바로 구현에 들어간 기능 task는 계획 리뷰 gate 누락으로 보고합니다.
26. 제품 또는 운영 버전이 바뀌는 작업은 project SSoT에 version hypothesis를 남깁니다. 각 버전에는 설계 가설, 채택 이유, 예상 병목, 실행한 task/issue/silo/PR, 결과물, 실제 병목, 사람 확인 지점, 다음 버전에서 유지하거나 버릴 것을 기록합니다. 0계층에는 형식, 승격 기준, 금지선만 두고 프로젝트별 실제 version hypothesis 원문은 project SSoT에 둡니다.

## 현재 강한 후보 규칙

아직 전역 확정은 아니지만, 현재 대화 기준으로 강한 후보인 규칙:

1. 레포 파악 요청은 제품 수정, 사용자 분석, 에이전트 셋업 목적을 먼저 분리합니다.
2. 완료, 미완료, 목표 밖 산출물, 다음 행동을 분리해서 보고합니다.
3. 실제 기능 검증이 필요한 작업은 agent-browser 시연과 QA 증거를 우선합니다.
4. 반복 입력 UI 또는 로그성 기능에서는 날짜/시간 picker, 명시적 선택 UI, 검색 가능한 모달 리스트, `마스터 데이터 + 변수` 구조, 다중 항목 리스트, 계산 가능한 값 자동 계산을 우선 검토합니다. 단, 프로젝트 고유 요구, 기존 디자인 시스템, 도메인 제약, 더 강한 local evidence가 있으면 그 기준을 우선합니다.
