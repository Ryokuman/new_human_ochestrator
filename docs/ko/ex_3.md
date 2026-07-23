# 예시 3: 새 프로젝트 시작

아직 제품 코드가 없을 때 사용합니다.

## 질의응답

먼저 아래를 묻습니다.

1. 제품 아이디어를 한 문장으로 말하면 무엇인가?
2. 첫 사용자는 누구인가?
3. 첫 사용자 결과는 무엇인가?
4. 첫 버전에 포함할 것은 무엇인가?
5. 명시적으로 제외할 것은 무엇인가?
6. 가치를 증명하는 가장 작은 end-to-end slice는 무엇인가?
7. FE, BE, DB, API/auth, harness/runtime, submodule 역할과 데이터 저장/동기화 경계는 무엇인가?

## 플로우

1. 질의응답으로 전체 설계가 아니라 첫 사용자 결과와 가장 작은 slice를 정의합니다.
2. 첫 사용 가능한 build를 막지 않는 범위에서만 `setup.sh`로 project SSoT scaffold를 만듭니다.
3. 첫 lightweight `AGENTS.md`에는 project id/name, repo 또는 workspace 위치, 첫 사용자 결과, 가장 작은 slice, 명시적 제외 범위, 검증 방법, 데이터 저장/동기화 경계, FE/BE/DB/API/auth/harness/runtime/submodule 실행 역할을 최소 계약으로 작성합니다. 아직 확정되지 않은 역할이나 경계는 추정하지 않고 명시적 미정 표시를 둡니다.
4. 첫 작은 task를 만듭니다.
5. task를 silo에서 실행합니다.
6. `Build -> Learn -> Spec` 순서로 build하고, 배운 내용만 contract 또는 후속 task로 승격합니다.

## 설정 준비도 확인

실행 전에 아래를 확인합니다.

- repo skill이 설치되어 있는가?
- project SSoT scaffold가 첫 build를 막지 않는 최소 계약만 담는가?
- 질의응답으로 초기 project contract의 최소 계약, 실행 역할, 데이터 저장/동기화 경계를 확인값으로 닫았는가? 미정 항목이 있으면 첫 기능 task가 아니라 contract 보강 또는 비기능 setup task로 라우팅할 수 있는가?
- task 템플릿이 있는가?
- silo 실행 규칙이 있는가?
- 첫 slice 검증 방법이 알려져 있는가?

이 조건이 참이면 오케스트레이터는 새 프로젝트 플로우대로 동작할 수 있습니다. 새 프로젝트의 project SSoT scaffold는 첫 사용 가능한 build 전 전체 시스템 설계가 아니라, step 4의 첫 기능 task 생성을 막지 않는 실행 역할/경계 확인값까지 닫는 최소 contract/scaffold gate입니다. 역할/경계가 명시적 미정이면 step 4는 기능 task 생성이 아니라 contract 보강 또는 비기능 setup task로 전환합니다.
