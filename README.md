# New-Human Orchestrator

이 저장소는 여러 프로젝트에서 재사용할 수 있는 에이전트 운영 규칙, SSoT 구조, 사일로 실행 방식, PR 리뷰 루프, 퍼스널리티 갱신 규칙을 관리합니다.

최종 정의와 재사용 가능한 문서는 `system/`을 기준으로 봅니다.

## 처음 읽는 순서

1. `AGENTS.md`
2. `system/README.md`
3. `system/00-system-overview/계층-구조와-관리-원칙.md`
4. `system/00-system-overview/전체-시스템-개요.md`
5. `system/10-ssot/SSoT-스키마-초안.md`
6. `system/20-main-orchestrator/메인-오케스트레이터-역할.md`
7. `system/60-final-prompts/메인-오케스트레이터-프롬프트-초안.md`

## 오케스트레이터 사용 흐름

1. 요청을 0/1/2/3계층으로 판정한다.
2. 공통 규칙, 프롬프트, skill 초안은 `system/`에서 관리한다.
3. 프로젝트별 상태, issue, task, QA 결과는 project SSoT에서 관리한다.
4. 실제 구현 작업은 task silo에서 분리 실행한다.
5. 사일로 결과는 PR 본문에 검증 결과, SSoT 승격 후보, 승격하지 않을 항목을 분리해 제출한다.
6. 사용자 피드백은 현재 작업 수정, 사일로 전용 규칙, 전역 규칙 후보를 구분해 처리한다.

## 계층별 저장 위치

| 계층 | 저장 위치 | 내용 |
|---|---|---|
| 0계층 | `system/` | 공통 규칙, 프롬프트, skill 초안, 생성 스크립트 |
| 1계층 | project registry/config, `project/*` 브랜치 | 프로젝트 등록, 연결 방식, SSoT 위치 |
| 2계층 | project SSoT | 프로젝트 내부 issue, task, QA, decision, coverage, dashboard |
| 3계층 | task silo workspace | 임시 발견, 실험 로그, PR 전 작업 상태 |

## Project SSoT 생성

새 project SSoT는 공통 생성 스크립트를 사용합니다.

```bash
node system/scripts/create-project-ssot.mjs \
  --project-id <project-id> \
  --project-name "<project-name>" \
  --target <project-ssot-path> \
  --dry-run
```

실제 생성:

```bash
node system/scripts/create-project-ssot.mjs \
  --project-id <project-id> \
  --project-name "<project-name>" \
  --target <project-ssot-path>
```

Dataview 대시보드 렌더링까지 준비해야 하면 `--install-dataview`를 추가합니다.

## Main 업데이트

공통 규칙, `AGENTS.md`, `system/` 문서, 프롬프트, skill 초안을 바꿀 때는 현재 작업 브랜치에서 직접 수정하지 않습니다.

`main-branch-update-flow`에 따라 main 기준 별도 worktree 또는 clean checkout에서 새 브랜치를 만들고, 수정 후 PR로 반영합니다. PR 생성 승인과 PR 머지 승인은 별개입니다.

## 주의

- 프로젝트 내부 issue/task/QA 원문은 root main에 복사하지 않는다.
- 실제 secret, token, password, credential 값은 읽거나 기록하지 않는다.
- `profile/*.local.md`, `config/silo-projects.yaml`, `config/*.env`는 로컬 설정으로 취급한다.
- 프로젝트 자료를 이 저장소에 추가해야 하면 main이 아니라 project 전용 브랜치나 project SSoT에서 다룬다.
