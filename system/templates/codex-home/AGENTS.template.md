<!-- new-human-codex-home:start -->
# New-Human Global Agent Router

이 파일은 New-Human setup이 설치한 Codex 전역 지침입니다. 모든 저장소와 작업 위치에서 System → User → Project 계약을 먼저 찾도록 연결합니다.

## System Layer

- 작업을 시작하기 전에 `<system-agents-path>`를 읽고 공통 운영·안전·브랜치·보고 계약을 적용합니다.

## User Layer

- 모든 실질적 판단과 사용자 응답 전에 `<user-layer-agents-path>`를 읽고 사용자별 판단 기준을 적용합니다.
- User Layer가 없으면 일반 작업은 계속하되, 공개 template을 실제 사용자 퍼스널리티로 대신하지 않습니다.

## Project Contract

- 프로젝트 관련 Task, Issue, QA, 계획, 구현 또는 제품 판단 전에는 현재 저장소와 상위 경로의 Project AGENTS 및 Project SSoT를 찾아 Project Contract를 확인합니다.
- Project Contract가 없거나 서로 충돌하면 탐색과 증거 수집은 계속할 수 있지만, 제품 계약 확정과 제품 코드 변경 전에 `project-contract-gate`로 누락이나 충돌을 해소합니다.

## 적용 순서

- 현재 사용자의 직접 지시가 가장 우선합니다.
- 공통 System 규칙 다음에 User Layer 판단 기준을 적용하고, 프로젝트 제품 계약은 Project AGENTS를 적용합니다.
- Task 실행 조건과 상태는 해당 Task 문서와 silo `goal.md`를 적용합니다.
<!-- new-human-codex-home:end -->
