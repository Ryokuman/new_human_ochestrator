# 시스템 용어 사전

이 문서는 New-Human Orchestrator의 공통 운영 용어를 설명합니다. 프로젝트 고유 업무 용어는 각 Project Work SSoT의 dictionary가 소유합니다.

| 용어 | 정의 |
|---|---|
| 0계층 System SSoT | 모든 프로젝트에 공통으로 적용되는 계층 구조, 에이전트 지시, skill, template, 운영 규칙의 정본입니다. |
| Codex-home AGENTS | `$CODEX_HOME/AGENTS.md`에 설치되어 동일한 Codex home을 사용하는 Codex가 0계층 루트 AGENTS 라우터와 User Layer 정본을 먼저 찾게 하는 전역 라우터입니다. |
| User Layer | 사용자별 판단 기준과 Feedback 이력을 소유하는 workspace의 1계층 User SSoT 디렉터리입니다. |
| 유저 퍼스널리티 | 사용자와의 반복 마찰을 검토하고 시나리오로 검증한 뒤 User Layer `AGENTS.md`에 반영한 현재 판단 기준입니다. |
| Feedback | 일반 작업 세션에서 사용자와 에이전트 사이에 발생한 응답 계약 또는 판단 방향의 교정 사건입니다. 현재 작업을 막는 gate가 아닙니다. |
| 후보 퍼스널리티 | 사용자가 명시적으로 연 퍼스널리티 갱신 세션에서 여러 Feedback을 범위별로 분류한 뒤 추출한 사용자 판단 원리 후보입니다. |
| 검증 시나리오 | 후보 퍼스널리티가 가까운 사례, 경계 사례, 전이 사례에서도 사용자의 판단을 예측하는지 확인하는 질문입니다. |
| 검증 결과 | 검증 시나리오에 대한 사용자의 선택과 이유, 후보의 예측 일치 여부, 수정 또는 기각 근거를 기록한 결과입니다. |
| Project SSoT | 제품 정의, Project Contract, repo/source 위치, 요구사항, decision/ADR처럼 프로젝트의 장기 기준 정보를 소유하는 1계층 정본입니다. |
| Project Contract | 프로젝트의 제품 정의, 목표와 비목표, 사용자 흐름, 데이터 경계, 제품 불변 조건을 규정하는 계약입니다. 목표 구조에서는 `<workspace>/<projectName>/01-project-ssot/AGENTS.md`가 정본입니다. |
| Project Work SSoT | Project Contract를 구현하고 검증하기 위한 Task, Issue, QA, Runbook, Coverage, Handoff를 소유하는 2계층 정본입니다. |
| Task | 확인된 요구사항을 구현 가능한 목표, 범위, 계약, acceptance criteria와 검증 계획으로 구체화한 작업 정본입니다. |
| Issue | 구현 또는 검증 과정에서 확인한 문제, 영향, 원인 후보와 연결 Task를 추적하는 기록입니다. |
| Silo | 하나의 Task 또는 Issue를 격리해 실행하는 동적 작업 단위입니다. 제품 source repo 자체와는 구분합니다. |
| Operating Hypothesis | Task 처리, 정보 취합, 사일로, PR·review loop 같은 0계층 운영 방식을 실험하고 병목을 기록하는 시스템 운영 가설입니다. |
| Task `hypothesis_chain` | Task 실행 중 실패 원인 후보와 재시도 결과를 시간순으로 기록하는 실행 기록입니다. Operating Hypothesis와 다릅니다. |

## 용어 경계

- `Feedback`은 교정 사건이고, `evidence`는 그 사건이나 검증 결과를 뒷받침하는 근거입니다.
- 후보 퍼스널리티와 유저 퍼스널리티에는 `hypothesis`라는 이름을 사용하지 않습니다.
- 프로젝트 제품 규칙은 유저 퍼스널리티가 아니라 Project Contract가 소유합니다.
- 현재 Task에만 필요한 실행 조건은 User Layer나 Project Contract가 아니라 Task와 `goal.md`가 소유합니다.
