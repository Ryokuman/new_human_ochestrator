<!-- new-human-workspace-router:start -->
# Workspace Agent Router

이 파일은 workspace 루트에서 Codex가 각 계층의 `AGENTS.md` 정본을 찾도록 연결하는 라우터입니다. 실제 유저 퍼스널리티나 Project Contract를 이 파일에 복사하지 않습니다.

## System Layer

- 가장 먼저 `<system-agents-path>`를 읽고 0계층 공통 운영·안전·브랜치·보고 계약을 적용합니다. 이 경로는 setup이 현재 System SSoT repo의 실제 절대 경로로 렌더링합니다.

## User Layer

- 모든 실질적 판단과 사용자 응답 전에 `<workspace>/user-layer/AGENTS.md`를 읽습니다.
- User Layer가 없으면 일반 작업을 계속합니다. 공개 template을 실제 퍼스널리티로 대신하지 않고, 누락 자체를 사용자 질문 gate로 만들지 않습니다.
- User Layer가 없어 Feedback을 영속 기록할 수 없으면 임의 경로를 만들지 않고 최종 보고에 `Feedback 미기록: User Layer 없음`을 남깁니다.

## Project Contract

- 프로젝트 관련 Task, Issue, QA, 계획, 구현 또는 제품 판단 전에는 Task/`goal.md`의 `project_id`, 현재 `<workspace>/<projectName>` 경로, `project-<projectName>` 브랜치 namespace, project registry의 source repo 매핑 순서로 프로젝트를 판별합니다.
- 판별한 프로젝트의 `<workspace>/<projectName>/01-project-ssot/AGENTS.md`를 Project Contract 정본으로 읽습니다.
- 프로젝트 신호가 충돌하면 탐색과 증거 수집은 계속할 수 있지만, 제품 계약 확정과 제품 코드 변경은 충돌을 해소한 뒤 수행합니다.

## 소유권

- 실제 유저 퍼스널리티와 Feedback은 1계층 User SSoT가 소유합니다.
- 실제 Project Contract와 요구사항은 1계층 Project SSoT가 소유합니다.
- 이 라우터는 `System → User → Project` 읽기 순서와 경로만 소유합니다.
<!-- new-human-workspace-router:end -->
