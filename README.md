# New-Human Orchestrator

여러 프로젝트에서 재사용할 수 있는 에이전트 운영 규칙, project SSoT 템플릿, silo 실행 흐름, PR review loop, feedback 정책을 보관합니다.

## Documentation

- [한국어 사용 방법](docs/ko/README.md)
- [English usage guide](docs/en/README.md)

The canonical reusable system definitions live under `system/`.

현재 이 저장소의 추적 정본은 0계층 System SSoT입니다. 1계층 User SSoT와 Project SSoT, 2계층 Project Work SSoT, 3계층 Silo Local / Test Evidence 실데이터는 이 repo 정본에 있다고 보지 않습니다.

## 저장소 지도

| 경로 | 역할 | 공개 배포 기준 |
|---|---|---|
| `system/` | 여러 프로젝트에서 재사용하는 0계층 System SSoT, agent prompt, repo skill, scaffold template 정본 | 공개 export 포함 |
| `docs/ko/`, `docs/en/` | 공개 사용자를 위한 언어별 사용 안내 | 공개 export 포함 |
| `.github/workflows/` | 내부 원본 repo의 공개 export workflow와 CI 지원 표면 | source repo 운영 표면 |
| `setup.sh` | repo skill 설치, local config, User SSoT 디렉터리, Project SSoT scaffold를 만드는 셋업 진입점 | 공개 export 포함 |

`setup.sh --init-user-layer`는 `$CODEX_HOME/AGENTS.md`, `<workspace>/AGENTS.md` 라우터와 `<workspace>/user-layer/` User SSoT를 함께 준비합니다. Codex 전역 AGENTS는 0계층 루트 AGENTS 라우터와 User Layer 정본의 절대 경로를 연결하고, workspace 라우터는 System → User → Project 읽기 순서를 정의합니다. 기존 전역 `AGENTS.md`는 백업 후 교체/삭제 후 교체/셋업 중지, 기존 `AGENTS.override.md`는 백업 후 삭제/즉시 삭제/셋업 중지 선택을 받습니다.

브랜치 모델:

- 목표 계층 namespace: 0계층은 `main-v3`, Project SSoT는 `project-{projectName}`.
- 목표 계층 메인 브랜치: `main-v3/main`, `project-{projectName}/main`.
- 목표 작업 브랜치: `main-v3/{taskname}`, `project-{projectName}/{taskname}`.
- 현재 마이그레이션 전 호환 기준: 0계층은 `main-v3/main`, 작업 브랜치는 `main-v3/{taskname}`.

`main-v3`나 `project-{projectName}` 자체는 브랜치로 만들지 않습니다. 이 이름들은 Git ref namespace입니다. 기존 slash 기반 `project/<project-id>` 브랜치 모델은 목표 정본이 아니라 호환 또는 전환 필요 항목으로 봅니다.

상위 운영 기능:

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

위험 실행 전제 확인은 독립 기능으로 두지 않고 Task/Issue/Silo 운영과 Runtime Set 관리의 하위 gate로 흡수합니다. Task 내부 `hypothesis_chain`은 Task/Issue/Silo 운영의 하위 실행 기록이고, User Layer / Personality System은 사용자별 유저 퍼스널리티와 Feedback 실제 상태를 workspace의 `user-layer/` User SSoT 디렉터리에 두기 위한 상위 기능입니다.

운영 가설 관리는 0계층 System SSoT의 별도 메타 기록입니다. 운영 가설은 제품 기능 가설이 아니라 task 처리 방식, 정보 취합 방식, 구현 플랜, 사일로/PR/review loop 운영 방식이 왜 선택됐고 어떤 병목을 만들었는지 추적합니다.

정본은 `system/60-operating-hypotheses/`에 두며, 현재 가설 목록, `draft`/`active`/`closed`/`discarded` 상태, 템플릿과 승격 기준은 해당 README를 기준으로 봅니다. task 내부 실행 실패와 재시도를 다루는 `hypothesis chain`과 0계층 운영 방식 자체를 다루는 운영 가설은 서로 다른 기록 단위입니다.

## 공개 배포

이 저장소의 내부 원본 기준 브랜치는 `main-v3/main`입니다.

오픈소스 배포본은 `Ryokuman/new_human_ochestrator`의 `main-v3/main`로 동기화합니다. 배포는 전체 mirror가 아니라 allowlist export 방식이며, project SSoT, task silo, local feedback, secret 가능 설정은 공개 배포 대상이 아닙니다.

공개 export 정책 예시는 `system/config/public-export-manifest.example.yaml`에서 확인합니다. 이 manifest는 공개/비공개 파일군을 설명하는 정책 템플릿입니다. 실제 복사 allowlist, 제외, README 항목 제거, 민감 경로/secret-like content guard는 `.github/workflows/sync-public-orchestrator.yml`의 run block이 수행합니다. 내부 프로젝트 참조 차단 regex는 공개 배포 대상이 아닌 `system/config/public-export-guard-manifest.yaml`에서 관리하고, 동기화 workflow가 이 guard manifest를 읽어 검사합니다.

동기화 workflow는 `PUBLIC_ORCHESTRATOR_SYNC_ENABLED` repo variable이 `true`일 때만 실행합니다. target repo push용 `PUBLIC_ORCHESTRATOR_SYNC_TOKEN` secret을 먼저 준비한 뒤 활성화합니다.

공개 repo가 독립적으로 읽히고 설치 표면을 제공하려면 아래 경로는 required입니다.

- 루트 공개 설명과 라이선스: `README.md`, `LICENSE`, `NOTICE`
- 공개 runtime 지시문: `AGENTS.public.md`를 target의 `AGENTS.md`로 export
- 사용자 문서: `docs/ko/`, `docs/en/`
- 0계층 핵심 정의: `system/README.md`, `system/00-system-overview/`, `system/10-agents/`, `system/10-ssot/`, `system/20-skills/`, `system/30-silo-system/`, `system/40-pr-review-loop/`, `system/50-feedback-personality-loop/`, `system/60-operating-hypotheses/`
- setup/runtime 표면: `setup.sh`, `system/config/README.md`, `system/config/public-export-manifest.example.yaml`, `system/config/shared-runtime-registry.example.yaml`, `system/config/silo-projects.example.yaml`, `system/config/silo-runtime.env.example`, `system/templates/codex-home/`, `system/templates/workspace/`, `system/templates/user-layer/`, `system/templates/project-ssot/`

`.gitignore`와 `system/.gitignore`는 있으면 export하지만 공개 repo 동작의 필수 조건으로 보지 않습니다.

이 프로젝트는 Apache License 2.0으로 배포되며, 재배포 또는 파생 배포 시 `NOTICE`의 attribution 문구를 Apache License 2.0 Section 4(d)에 따라 유지해야 합니다.
