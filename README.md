# New-Human Orchestrator

Reusable agent operating rules, project SSoT templates, silo execution flows, PR review loops, and feedback policies.

## Documentation

- [한국어 사용 방법](ko/README.md)
- [English usage guide](en/README.md)

The canonical reusable system definitions live under `system/`.

현재 이 저장소의 추적 정본은 0계층 System SSoT입니다. 1~3계층의 실제 Project SSoT, Project Work SSoT, Silo Local / Test Evidence / Feedback 실데이터는 아직 이 repo 정본에 있다고 보지 않습니다.

브랜치 모델:

- 목표 계층 namespace: 0계층은 `main-v3`, 1계층은 `project-{projectName}`.
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

위험 실행 전제 확인은 독립 기능으로 두지 않고 Task/Issue/Silo 운영과 Runtime Set 관리의 하위 gate로 흡수합니다. `hypothesis chain`은 이번 안정화 범위 밖입니다.

## 공개 배포

이 저장소의 내부 원본 기준 브랜치는 `main-v3/main`입니다.

오픈소스 배포본은 `Ryokuman/new_human_ochestrator`의 `main-v3/main`로 동기화합니다. 배포는 전체 mirror가 아니라 allowlist export 방식이며, project SSoT, task silo, local feedback, secret 가능 설정은 공개 배포 대상이 아닙니다.

공개 export 정책 예시는 `system/config/public-export-manifest.example.yaml`에서 확인합니다.

동기화 workflow는 `PUBLIC_ORCHESTRATOR_SYNC_ENABLED` repo variable이 `true`일 때만 실행합니다. target repo push용 `PUBLIC_ORCHESTRATOR_SYNC_TOKEN` secret과 root `LICENSE`, `NOTICE`를 먼저 준비한 뒤 활성화합니다.

이 프로젝트는 Apache License 2.0으로 배포되며, 재배포 또는 파생 배포 시 `NOTICE`의 attribution 문구를 Apache License 2.0 Section 4(d)에 따라 유지해야 합니다.
