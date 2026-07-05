# New-Human Orchestrator 사용 방법

이 문서는 일부러 짧게 유지합니다.

`setup.sh`로 반복 가능한 운영 표면을 만들고, 질의응답으로 실제 플로우를 선택하고 정의합니다.

현재 이 저장소의 추적 정본은 0계층 System SSoT입니다. 1계층 Project SSoT, 2계층 Project Work SSoT, 3계층 Silo Local / Test Evidence / Feedback 실데이터는 아직 이 repo 정본에 있다고 보지 않습니다.

상위 기능은 9개입니다.

1. 계층 운영
2. 메인 브랜치/작업 브랜치 운영
3. 1계층 Project SSoT 관리
4. Project Contract Gate
5. Task/Issue/Silo 운영
6. Runtime Set 관리
7. PR Review Loop
8. Feedback/퍼스널리티 Loop
9. 셋업/지원 표면 관리

위험 실행 전제 확인은 독립 기능으로 두지 않고 Task/Issue/Silo 운영과 Runtime Set 관리의 하위 gate로 흡수합니다. `hypothesis chain`은 이번 안정화 범위 밖입니다.

## 셋업

대화형 셋업:

```bash
./setup.sh
```

자주 쓰는 비대화형 셋업:

```bash
./setup.sh --all --yes
./setup.sh --repo-skills --using-superpowers --yes
./setup.sh --init-config --yes
```

Project SSoT scaffold 생성:

```bash
./setup.sh --create-project-ssot \
  --project-id <project-id> \
  --project-name "<project-name>" \
  --target <project-ssot-path> \
  --yes
```

## setup이 만들 수 있는 것

`setup.sh`는 대부분의 반복 구조를 만들 수 있습니다.

- repo skill
- local config 초안
- project SSoT 폴더
- dashboard 파일
- issue/task 템플릿
- project contract 템플릿
- handoff와 PR 템플릿
- coverage 폴더

다만 프로젝트별 실제 지식까지 자동으로 채우지는 않습니다. 제품 의도, 실제 사용자 흐름, DB/API/auth 경계, 아키텍처 의미는 repo 조사, LLM 활용 조사, 사용자 확인이 필요합니다.

## 플로우 선택 질문

먼저 아래를 묻습니다.

1. 이미 코드베이스가 있는가?
2. 한 프로젝트를 운영할 것인가, 여러 프로젝트를 정리할 것인가?
3. 지금 목표는 task 생성인가, 프로젝트 지식 베이스 생성인가, 새 제품 시작인가?
4. `project-contract-gate`를 사용할 수 있는가?
5. 플로우가 정의된 뒤, 현재 setup으로 그 플로우를 실제로 실행할 수 있는가?

## 예시

1. [`ex_1.md`](ex_1.md): 기존 프로젝트에 이식
2. [`ex_2.md`](ex_2.md): 기존 프로젝트를 조사해 프로젝트 지식 베이스로 정리
3. [`ex_3.md`](ex_3.md): 새 프로젝트 시작

## 준비도 확인

플로우를 고른 뒤 아래를 확인합니다.

- 필요한 repo skill이 설치되어 있는가?
- project SSoT 위치가 있거나 scaffold로 만들 수 있는가?
- source repo 또는 GitHub 입력이 접근 가능한가?
- `project-contract-gate` 또는 동등한 질의응답 절차로 미확정 항목을 닫을 수 있는가?
- task 생성 규칙이 있는가?
- silo 실행 규칙이 있는가?
- 브랜치 target이 계층과 맞는가? 목표 계층 메인 브랜치는 `main-v3/main`, `project-{projectName}/main`이고, 목표 작업 브랜치는 `main-v3/{taskname}`, `project-{projectName}/{taskname}`입니다. 마이그레이션 전 현재 0계층 호환 기준은 `main-v3/main`와 `main-v3/{taskname}`입니다.
- `main-v3`나 `project-{projectName}` 자체를 브랜치로 만들지 않는다고 명시했는가?
- 기존 slash 기반 `project/<project-id>` 모델을 목표 정본이 아니라 호환/전환 필요 항목으로 분리했는가?
