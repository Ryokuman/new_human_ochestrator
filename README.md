# New-Human Orchestrator

이 저장소는 여러 프로젝트에서 재사용할 수 있는 에이전트 운영 규칙, SSoT 구조, 사일로 실행 방식, PR 리뷰 루프, 퍼스널리티 갱신 규칙을 관리합니다.

최종 정의와 재사용 가능한 문서는 `system/`을 기준으로 봅니다.

## Using This Repository as a Project SSoT

This repository can be used as a personal Single Source of Truth for project knowledge, portfolio preparation, and agent-assisted work. It is designed to keep reusable operating rules separate from project-specific evidence, so the same orchestration system can manage many projects without mixing temporary notes, implementation details, and long-term career material.

Use `main-v2` for shared rules and reusable infrastructure:

- agent roles and prompts
- reusable repo skills
- project SSoT templates
- silo execution rules
- PR review loop policies
- feedback and personality adaptation rules

Use long-lived `project/<project-id>` branches for project-specific knowledge. For example, a portfolio branch can keep structured evidence about personal projects, including:

- what each project is
- why it matters
- architecture decisions
- issues encountered during development
- ownership and contribution evidence
- metrics, screenshots, drafts, and interview material

Project materials should be organized as a layered SSoT rather than as one large document. A portfolio project can use a structure like:

```text
projects/portfolio/
  00-project/
  10-research/
  10.projects/
    <project-name>/
      README.md
      10.summary/
      20.images/
      30.architecture/
      40.issues/
      50.ownership/
      60.metrics/
      70.drafts/
  20-issues/
  30-tasks/
  40-applications/
```

The key rule is that `main-v2` describes how the system works, while `project/*` branches store what is known about a specific project. This keeps the root system reusable and lets each project evolve as its own knowledge base.

When using this repository for portfolio work, treat each portfolio project as an evidence package. Start with a short summary, then collect architecture notes, issue history, contribution proof, measurable outcomes, and draft copy in separate folders. This makes it easier for an agent to answer questions such as "what did I build?", "what was technically difficult?", "what did I own?", and "what should be shown in the portfolio?" without rereading every source repository from scratch.

## 처음 읽는 순서

1. `AGENTS.md`
2. `system/README.md`
3. `system/00-system-overview/계층-구조와-관리-원칙.md`
4. `system/00-system-overview/전체-시스템-개요.md`
5. `system/10-ssot/SSoT-스키마-초안.md`
6. `system/10-agents/main.md`
7. `system/20-skills/README.md`
8. `system/10-agents/main-orchestrator/main-prompt.md`

## 오케스트레이터 사용 흐름

1. 요청을 0/1/2/3계층으로 판정한다.
2. 공통 규칙, 역할별 agent 프롬프트, repo skill은 `system/`에서 관리한다.
3. 프로젝트별 상태, issue, task, QA 결과는 project SSoT에서 관리한다.
4. 실제 구현 작업은 task silo에서 분리 실행한다.
5. 사일로 결과는 PR 본문에 검증 결과, SSoT 승격 후보, 승격하지 않을 항목을 분리해 제출한다.
6. 사용자 피드백은 현재 작업 수정, 사일로 전용 규칙, 전역 규칙 후보를 구분해 처리한다.

## 계층별 저장 위치

| 계층 | 저장 위치 | 내용 |
|---|---|---|
| 0계층 | `system/` | 공통 규칙, 프롬프트, repo skill, 셋업 템플릿 |
| 1계층 | project registry/config, `project/*` 브랜치 | 프로젝트 등록, 연결 방식, SSoT 위치 |
| 2계층 | project SSoT | 프로젝트 내부 issue, task, QA, decision, coverage, dashboard |
| 3계층 | task silo workspace | 임시 발견, 실험 로그, PR 전 작업 상태 |

## Project SSoT 초안 생성

새 project SSoT scaffold는 루트 `setup.sh`로 생성합니다.

```bash
./setup.sh --create-project-ssot \
  --project-id <project-id> \
  --project-name "<project-name>" \
  --target <project-ssot-path> \
  --yes
```

이 명령은 dashboard, dictionary, issue, task, decision, handoff, coverage, templates 기본 폴더와 문서 초안을 생성합니다. 실제 프로젝트 issue/task/QA 원문은 root `main-v2`에 만들지 않습니다.

config local 초안은 아래 명령으로 생성합니다.

```bash
./setup.sh --init-config --yes
```

## 초기 셋업

이 저장소를 fork 또는 clone한 뒤 공통 작업 스킬을 설치하려면 루트의 `setup.sh`를 실행합니다.

```bash
./setup.sh
```

`setup.sh`는 아래 항목을 다중 선택으로 실행할 수 있습니다. 전체 실행은 `all`, 실행하지 않음은 `none`을 입력합니다.

1. repo 내부 skill
2. `using-superpowers`
3. Superpowers 작업 보조 묶음
4. `agent-browser`
5. `compound-engineering`
6. config 초안 생성
7. project SSoT 반복 구조 생성

비대화형 전체 설치:

```bash
./setup.sh --all --yes
```

설치 위치는 기본적으로 `$CODEX_HOME/skills`이며, `CODEX_HOME`이 없으면 `~/.codex/skills`를 사용합니다.

`agent-browser`는 CLI와 browser runtime 설치도 함께 시도합니다. skill 파일만 설치하고 runtime 설치를 건너뛰려면 아래처럼 실행합니다.

```bash
AGENT_BROWSER_SKIP_RUNTIME=1 ./setup.sh --agent-browser --yes
```

## Main-v2 업데이트

공통 규칙, `AGENTS.md`, `system/` 문서, 프롬프트, repo skill을 바꿀 때는 현재 작업 브랜치에서 직접 수정하지 않습니다.

`main-branch-update-flow`에 따라 `main-v2` 기준 파생 브랜치를 만들고, 수정 후 `main-v2` 대상 PR로 반영합니다. PR 생성 승인과 PR 머지 승인은 별개입니다. 레거시 `main`은 이 프로젝트에서 작업 대상으로 사용하지 않습니다.

## 주의

- 프로젝트 내부 issue/task/QA 원문은 root `main-v2`에 복사하지 않는다.
- 실제 secret, token, password, credential 값은 읽거나 기록하지 않는다.
- `config/silo-projects.yaml`, `config/*.env`는 로컬 설정으로 취급한다.
- 프로젝트 자료를 이 저장소에 추가해야 하면 root `main-v2`가 아니라 project 전용 브랜치나 project SSoT에서 다룬다.
