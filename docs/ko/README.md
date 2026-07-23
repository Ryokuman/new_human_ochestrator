# New-Human Orchestrator 사용 방법

이 문서는 일부러 짧게 유지합니다.

`setup.sh`로 반복 가능한 운영 표면을 만들고, 질의응답으로 실제 플로우를 선택하고 정의합니다.

공통 운영 용어는 [시스템 용어 사전](dictionary.md)에서 확인합니다.

현재 이 저장소의 추적 정본은 0계층 System SSoT입니다. 1계층 User SSoT와 Project SSoT, 2계층 Project Work SSoT, 3계층 Silo Local / Test Evidence 실데이터는 이 repo 정본에 있다고 보지 않습니다.

상위 기능은 10개입니다.

1. 계층 운영
2. 메인 브랜치/작업 브랜치 운영
3. 1계층 Project SSoT 관리
4. Project Contract Gate
5. Task/Issue/Silo 운영
6. Runtime Set 관리
7. PR Review Loop
8. Feedback/퍼스널리티 Loop
9. 셋업/지원 표면 관리
10. User Layer / Personality System

위험 실행 전제 확인은 독립 기능으로 두지 않고 Task/Issue/Silo 운영과 Runtime Set 관리의 하위 gate로 흡수합니다. Task 내부 `hypothesis_chain`은 Task/Issue/Silo 운영의 하위 실행 기록이고, User Layer / Personality System은 사용자별 유저 퍼스널리티와 Feedback 실제 상태를 1계층 User SSoT에 두기 위한 상위 기능입니다.

운영 가설 관리는 0계층 System SSoT의 별도 메타 기록입니다. 운영 가설은 제품 기능 가설이 아니라 task 처리 방식, 정보 취합 방식, 구현 플랜, 사일로/PR/review loop 운영 방식이 왜 선택됐고 어떤 병목을 만들었는지 추적합니다.

정본은 `system/60-operating-hypotheses/`에 두며, 현재 가설 목록, `draft`/`active`/`closed`/`discarded` 상태, 템플릿과 승격 기준은 해당 README를 기준으로 봅니다. task 내부 실행 실패와 재시도를 다루는 `hypothesis chain`과 0계층 운영 방식 자체를 다루는 운영 가설은 서로 다른 기록 단위입니다.

## 셋업

대화형 셋업:

```bash
./setup.sh
```

기본 셋업은 프로젝트 이름 하나로 workspace를 만듭니다.

```text
<workspace>/
├── AGENTS.md
├── user-layer/
├── <projectName>/01-project-ssot/
├── <projectName>/02-project-work-ssot/
├── sources/
├── silos/
└── shared-runtime/
```

자주 쓰는 비대화형 셋업:

```bash
./setup.sh --quickstart --project-name sample --yes
./setup.sh --repo-skills --using-superpowers --yes
./setup.sh --init-config --yes
./setup.sh --init-user-layer --yes
./setup.sh --agent-browser --compound-engineering --yes
AGENT_BROWSER_SKIP_RUNTIME=1 ./setup.sh --agent-browser --yes
./setup.sh --none
```

배포된 저장소의 루트 `user-layer/`는 setup 실행 전 `.gitignore`로 보호됩니다. `setup.sh`의 모든 선택 작업이 성공하면 정확한 `/user-layer/` 제외 규칙을 제거하며, setup이 실패하면 보호 규칙을 유지합니다.

`--all`은 기본 환경 전체를 설치/생성하지만, project SSoT scaffold는 제외합니다. project SSoT scaffold는 프로젝트별 대상 경로와 id를 명시해야 하므로 `--create-project-ssot`으로 별도 실행합니다.

Project SSoT scaffold 생성:

```bash
./setup.sh --create-project-ssot \
  --project-id <project-id> \
  --project-name "<project-name>" \
  --yes
```

주요 옵션:

- `--all`: 모든 setup 그룹을 실행합니다.
- `--none`: setup 없이 종료합니다.
- `--repo-skills`: 이 저장소의 repo skill을 설치합니다.
- `--using-superpowers`: `obra/superpowers`의 `using-superpowers`를 설치합니다.
- `--superpowers-workflow`: 필요한 Superpowers workflow skill을 설치합니다.
- `--agent-browser`: `agent-browser` CLI/browser runtime과 skill을 설치합니다.
- `AGENT_BROWSER_SKIP_RUNTIME=1`: `--agent-browser` 실행 시 CLI/browser runtime 설치 없이 skill 파일만 설치합니다.
- `--compound-engineering`: Compound Engineering skill을 설치합니다.
- `--init-config`: 예시 파일에서 local config 파일을 생성합니다.
- `--init-user-layer`: `$CODEX_HOME/AGENTS.md`, workspace 라우터와 고정 `user-layer/` User SSoT 디렉터리를 준비합니다. 기존 전역 `AGENTS.md`는 백업 후 교체/삭제 후 교체/셋업 중지, 기존 `AGENTS.override.md`는 백업 후 삭제/즉시 삭제/셋업 중지 승인을 `--yes`와 무관하게 받습니다.
- `--create-project-ssot`: project SSoT scaffold를 생성합니다.
- `--project-id <id>`, `--project-name <name>`, `--target <dir>`: project SSoT scaffold 생성 값을 지정합니다.
- `--force`: 허용된 setup 생성 local 파일을 덮어씁니다.
- `--yes`, `-y`: 마지막 확인 질문을 생략합니다.
- `--help`, `-h`: 도움말을 표시합니다.

## setup이 만들 수 있는 것

`setup.sh`는 대부분의 반복 구조를 만들 수 있습니다. 단, `--all`은 아래 항목 중 project SSoT 폴더와 그 하위 scaffold를 만들지 않습니다.

- repo skill
- local config 초안
- `user-layer/` User SSoT 디렉터리
- 0계층 루트 AGENTS 라우터와 User Layer 정본을 연결하는 `$CODEX_HOME/AGENTS.md`
- project SSoT 폴더
- Project Work SSoT 폴더
- `sources/`, `silos/`, `shared-runtime/` workspace 폴더
- dashboard 파일
- issue/task 템플릿
- project contract 템플릿
- handoff 템플릿과 PR 본문 초기 템플릿
- coverage 폴더

현재 `setup.sh --create-project-ssot`이 만드는 `templates/pr-description.md`는 scaffold 시작점입니다. PR 제출 전 정식 필수 섹션, criteria별 검증 결과, Codex 리뷰, runtime handoff, feedback/follow-up 메타데이터는 `system/40-pr-review-loop/06-pr-template.md`를 기준으로 보강합니다.

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

## 예시별 repo skill 연결

- 기존 프로젝트에 이식할 때는 `projects-setup`으로 Project SSoT scaffold와 project 등록 상태를 만들거나 확인하고, `project-contract-gate`로 사용자 목표와 구현 경계의 미확정 항목을 닫습니다.
- 기존 GitHub repo나 로컬 프로젝트를 조사해 지식 베이스로 정리할 때는 `github-project-intake`로 repo 후보, 근거, 적용/보류/제외 판단을 수집하고, 저장 위치가 필요하면 `projects-setup`으로 Project SSoT scaffold를 준비합니다.
- 새 프로젝트를 시작할 때는 `project-contract-gate`로 첫 제품 정의와 smallest slice를 닫은 뒤, `projects-setup`으로 Project SSoT, contract, task/silo 템플릿을 만듭니다.

## 준비도 확인

플로우를 고른 뒤 아래를 확인합니다.

- 선택한 예시에 맞는 repo skill이 설치되어 있는가? 기존 프로젝트 이식은 `projects-setup`과 `project-contract-gate`, GitHub/project 조사 정리는 `github-project-intake`와 필요 시 `projects-setup`, 새 프로젝트 시작은 `project-contract-gate`와 `projects-setup`을 우선 확인합니다.
- project SSoT 위치가 있거나 `projects-setup` scaffold로 만들 수 있는가?
- source repo 또는 GitHub 입력이 접근 가능한가?
- `project-contract-gate` 또는 동등한 질의응답 절차로 미확정 항목을 닫을 수 있는가?
- task 생성 규칙이 있는가?
- silo 실행 규칙이 있는가?
- 브랜치 target이 계층과 맞는가? 목표 계층 메인 브랜치는 `main-v3/main`, `project-{projectName}/main`이고, 목표 작업 브랜치는 `main-v3/{taskname}`, `project-{projectName}/{taskname}`입니다. 마이그레이션 전 현재 0계층 호환 기준은 `main-v3/main`와 `main-v3/{taskname}`입니다.
- `main-v3`나 `project-{projectName}` 자체를 브랜치로 만들지 않는다고 명시했는가?
- 기존 slash 기반 `project/<project-id>` 모델을 목표 정본이 아니라 호환/전환 필요 항목으로 분리했는가?
