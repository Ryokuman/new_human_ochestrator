# 예시 2: 기존 프로젝트 조사와 정리

기존 GitHub repo나 로컬 프로젝트 폴더들을 조사해, task 작업 전에 구조화된 지식으로 만들 때 사용합니다.

## 질의응답

먼저 아래를 묻습니다.

1. 어떤 GitHub repo 또는 로컬 디렉토리를 스캔할 것인가?
2. 목표는 포트폴리오 evidence, 이력서 작성, 프로젝트 복구, 향후 task 생성 중 무엇인가?
3. architecture, ownership, metric, issue, screenshot, 실행 방법 중 무엇을 추출할 것인가?
4. 무엇을 복사하거나 추정하면 안 되는가?
5. project-level 요약/색인과 evidence 원문, 경로, 실행 증거는 각각 어느 계층에 둘 것인가?

## 플로우

1. repo 또는 디렉토리 입력을 수집합니다.
2. 각 프로젝트를 조사합니다.
3. 목적, 아키텍처, runtime, 저장소, API/auth 경계, 기여 evidence, 위험을 요약합니다.
4. project-level 요약과 색인은 필요한 경우 1계층 Project SSoT에 두고, evidence 원문, 경로, 실행 증거, task/QA 연결은 2계층 Project Work SSoT 또는 3계층 Silo Local/Evidence로 나눠 저장합니다.
5. 프로젝트별로 project contract, cleanup task, 또는 즉시 조치 없음 중 하나를 결정합니다.

## 설정 준비도 확인

실행 전에 아래를 확인합니다.

- Project SSoT 색인, Project Work SSoT, Silo Local/Evidence 중 필요한 저장 위치가 명확하고 존재하거나 만들 수 있는가?
- 로컬 경로 또는 GitHub repo에 접근할 수 있는가?
- evidence 저장 규칙이 명확한가?
- secret, private data, source 전체 복사를 제외하는 규칙이 있는가?
- 스캔 전에 output 형식이 정의되어 있는가?

이 조건이 참이면 오케스트레이터는 조사 플로우대로 동작할 수 있습니다. 이 플로우는 강한 프로젝트 요약을 만들 수 있지만, repo에서 보이지 않거나 사용자가 확인하지 않은 비즈니스 의도를 아는 척하면 안 됩니다.
