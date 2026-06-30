# 에이전트 디렉토리

`system/10-agents/`는 이 저장소에서 재사용할 에이전트 역할 설명과 실제 전달 프롬프트를 관리합니다.

이 디렉토리는 제품 코드나 프로젝트별 task 원문을 저장하지 않습니다. 여러 프로젝트에서 반복되는 에이전트 역할, 보고 방식, 검토 기준, 실제 전달 프롬프트를 보관합니다.

## 문서 구성

| 경로                                 | 역할                                |
| ---------------------------------- | --------------------------------- |
| `main.md`                          | 이 디렉토리의 목적과 문서 목록                 |
| `main-orchestrator/README.md`      | 전체 실행 흐름을 조율하는 메인 오케스트레이터 역할 설명   |
| `main-orchestrator/main-prompt.md` | 메인 오케스트레이터에게 직접 전달하는 프롬프트         |
| `qa/README.md`                     | QA 관점의 검증, 재현, 증거 수집 역할 설명        |
| `qa/main-prompt.md`                | QA agent에게 직접 전달하는 프롬프트           |
| `worker/README.md`                 | 구현, 문서 정리, 반복 작업 실행 역할 설명         |
| `worker/main-prompt.md`            | worker agent에게 직접 전달하는 프롬프트       |
| `reviewer/README.md`               | 코드/문서/운영 규칙 검토 역할 설명              |
| `reviewer/main-prompt.md`          | reviewer agent에게 직접 전달하는 프롬프트     |
| `review-waiter/README.md`          | PR Codex 리뷰 대기, 수정, 재리뷰 반복 역할 설명 |
| `review-waiter/main-prompt.md`     | review waiter agent에게 직접 전달하는 프롬프트 |
| `test-writer/README.md`            | 테스트 설계와 회귀 방지 기준 작성 역할 설명         |
| `test-writer/main-prompt.md`       | test writer agent에게 직접 전달하는 프롬프트  |
| `task-writer/README.md`            | task를 검증 가능한 계약으로 작성하는 역할 설명      |
| `task-writer/main-prompt.md`       | task writer agent에게 직접 전달하는 프롬프트  |
| `issue-writer/README.md`           | 발견 사항을 issue 후보로 정리하는 역할 설명       |
| `issue-writer/main-prompt.md`      | issue writer agent에게 직접 전달하는 프롬프트 |


## 사용 원칙

- 각 agent 디렉토리의 `README.md`는 역할 설명입니다.
- 각 agent 디렉토리의 `main-prompt.md`는 실제 전달용 프롬프트입니다.
- 프로젝트별 실제 task, issue, QA 원문은 project SSoT에 둡니다.
- 사용자 선호는 단일 프로필 파일에 바로 확정하지 않고, `system/50-feedback-personality-loop/` 기준으로 관찰/해석/승인 상태를 분리합니다.
- 역할별 규칙이 skill 절차와 겹치면 절차는 `system/20-skills/`를 우선합니다.
- 에이전트 문서가 빈약하다는 피드백을 받으면 `system/50-feedback-personality-loop/` 기준으로 증거 등급과 승격 여부를 분리한 뒤 반영합니다.
- PR 리뷰 기준 보강은 `system/40-pr-review-loop/`, 역할별 실행 규칙 보강은 각 agent의 `README.md`와 `main-prompt.md`를 기준으로 합니다.
- PR 생성 시 Codex gate는 먼저 PR 유형을 판정합니다. 0계층 공통 변경은 `main-v2` 대상 PR로 올리고, project 계층 변경은 해당 `project/<project-id>`를 기준 브랜치로 삼되 `project/<project-id>-<branch-name>` 작업 브랜치에서 커밋한 뒤 `project/<project-id>` 대상 PR로 올립니다. 이후 `codex-pr-review-loop` skill로 no-major 목표를 세팅합니다. Codex 응답 대기, 수정, 검증, 재리뷰 반복을 맡길 실행자가 필요하면 `review-waiter-agent`를 사용합니다.
