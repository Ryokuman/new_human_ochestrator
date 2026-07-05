# 예시 1: 기존 프로젝트에 이식

이미 코드베이스가 있고, 그 주변에 오케스트레이터 운영 흐름을 붙일 때 사용합니다.

## 질의응답

먼저 아래를 묻습니다.

1. 기존 프로젝트 source는 어디에 있는가?
2. 이 프로젝트는 현재 무엇을 하는가?
3. 처음 개선하거나 검증할 사용자 결과는 무엇인가?
4. DB schema, API/auth 계약, runtime 안내, test command는 어디에 있는가?
5. `project-contract-gate`가 설치되어 있고 사용할 수 있는가?
6. 무엇을 추정하면 안 되는가?

## 플로우

1. 기존 프로젝트를 조사합니다.
2. project SSoT scaffold를 만들거나 기존 위치를 확인합니다.
3. 실제 코드베이스와 사용자 답변을 바탕으로 `project-contract.md`를 작성합니다.
4. 질의응답, 가능하면 `project-contract-gate`로 목표와 경계의 미확정 항목을 닫습니다.
5. contract를 기준으로 첫 task를 만듭니다.
6. task를 silo에서 실행합니다.
7. 검증하고 PR을 만들며, 반복 가능한 발견은 SSoT로 승격합니다.

## 설정 준비도 확인

실행 전에 아래를 확인합니다.

- `setup.sh --create-project-ssot`으로 SSoT scaffold를 만들거나 갱신할 수 있는가?
- repo skill이 설치되어 있는가?
- `project-contract-gate` 또는 동등한 질의응답 skill이 있는가?
- source repo 경로나 GitHub repo에 접근할 수 있는가?
- project branch 정책이 명확한가?
- task와 silo 템플릿이 있는가?

이 조건이 참이면 오케스트레이터는 이 플로우대로 동작할 수 있습니다. project contract가 비어 있으면 구조는 준비할 수 있지만 구현 task를 먼저 만들면 안 됩니다.
