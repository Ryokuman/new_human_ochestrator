# system 디렉토리

이 디렉토리는 `new-human` 작업의 정리 결과물이며, 여러 프로젝트에서 재사용할 수 있는 프롬프트/에이전트 설계 모음집으로 정리합니다.

`new-human` 루트에 흩어져 있던 기존 md 원본들은 성격별로 분리합니다.

- 프로젝트 조사 결과: `../projects/`
- 원본 프롬프트와 과거 초안: `../sources/`

최종 정의와 재사용 가능한 문서는 `system/`를 기준으로 봅니다.

목표는 제품 코드를 고치는 것이 아니라, 다음 흐름을 한국어 문서로 정리하는 것입니다.

```text
레포 파악
-> 사용자가 지금까지 한 일 파악
-> 퍼스널리티 파악
-> 취향 불변성 후보 생성
-> 개인 에이전트 셋업 자료로 승격
```

## main-v2 운영 방향

`main`은 레거시 보존 브랜치입니다. 이 프로젝트에서는 작업, PR, merge, rebase, worktree 기준으로 사용하지 않습니다.

`main-v2`는 탐색형 제품 엔지니어 운영 방식 기준 브랜치입니다.

```text
Build -> Learn -> Spec
```

`main-v2`에서는 완벽한 설계보다 가장 빠르게 사용 가능한 결과물을 우선합니다. 불확실성이 있어도 합리적으로 가정하고 진행하며, 구현 후 발견한 문제를 새 spec, task, issue, SSoT 승격 후보로 정리합니다. PR 리뷰 gate는 PR 댓글의 수동 `@codex review` 호출을 기본으로 두고, 호출 댓글에는 가능하면 `한국어로 리뷰해 주세요.` 또는 이에 준하는 한국어 요청을 함께 적습니다. 외부 리뷰 봇의 고정 템플릿 언어까지 보장하지는 못합니다. 일반 PR gate는 변경 이후에도 승인 또는 actionable major/critical 및 보호 절차를 깨는 P1/P2 없음 상태가 될 때까지 최대 5회까지 수동 재호출합니다. 5회 호출 후에도 남은 major/critical 또는 보호 절차 P1/P2 항목은 더 반복하지 않고 `사용자 판단 필요` 또는 `의도된 남은 위험`으로 분리합니다. 사용자가 `~PR을 리뷰 대기 에이전트로 돌려주세요`처럼 명시하면 `review-waiter-agent`가 별도 백그라운드 루프로 관리하며, 이때 기본 상한은 전체 리뷰 호출 10회입니다.

## 읽는 순서

1. `00-system-overview/계층-구조와-관리-원칙.md`
2. `00-system-overview/전체-시스템-개요.md`
3. `10-ssot/SSoT-스키마-초안.md`
4. `10-agents/main.md`
5. `20-skills/README.md`
6. `10-agents/main-orchestrator/main-prompt.md`
7. `30-silo-system/README.md`
8. `40-pr-review-loop/README.md`
9. `50-feedback-personality-loop/README.md`

## 폴더 역할

| 폴더 | 역할 |
|---|---|
| `00-system-overview/` | SSoT, 메인 오케스트레이터, 동적 사일로 전체 구조 |
| `10-ssot/` | 상태와 규칙의 원본 스키마 |
| `10-agents/` | 에이전트 역할과 실제 전달 프롬프트 |
| `20-skills/` | 설치 가능한 repo skill과 사용법 README |
| `config/` | 사일로가 어떤 프로젝트를 clone할지, 어떤 브랜치를 보호할지, shared runtime을 어디서 참조할지 적는 설정 템플릿. 실제 프로젝트 값은 gitignore된 local 파일에 둡니다. |
| `30-silo-system/` | 동적 사일로 생성과 작업 방식 |
| `40-pr-review-loop/` | PR 리뷰, 머지, SSoT 승격 판단 |
| `50-feedback-personality-loop/` | 사용자 피드백 기반 규칙 갱신 |
| `90-archive/` | 더 이상 중심이 아닌 보관 자료 |

## 에이전트 역할 문서

| 문서 | 역할 |
|---|---|
| [`10-agents/main.md`](10-agents/main.md) | 에이전트 역할 디렉토리 설명 |
| [`10-agents/main-orchestrator/README.md`](10-agents/main-orchestrator/README.md) | 전체 실행 흐름을 조율하는 메인 오케스트레이터 역할 설명 |
| [`10-agents/main-orchestrator/main-prompt.md`](10-agents/main-orchestrator/main-prompt.md) | 메인 오케스트레이터 전달 프롬프트 |
| [`10-agents/qa/README.md`](10-agents/qa/README.md) | QA 관점의 검증, 재현, 증거 수집 역할 설명 |
| [`10-agents/qa/main-prompt.md`](10-agents/qa/main-prompt.md) | QA agent 전달 프롬프트 |
| [`10-agents/worker/README.md`](10-agents/worker/README.md) | 구현, 문서 정리, 반복 작업 실행 역할 설명 |
| [`10-agents/worker/main-prompt.md`](10-agents/worker/main-prompt.md) | worker agent 전달 프롬프트 |
| [`10-agents/reviewer/README.md`](10-agents/reviewer/README.md) | 변경사항의 위험, 누락, 검증 공백 검토 역할 설명 |
| [`10-agents/reviewer/main-prompt.md`](10-agents/reviewer/main-prompt.md) | reviewer agent 전달 프롬프트 |
| [`10-agents/review-waiter/README.md`](10-agents/review-waiter/README.md) | PR Codex 리뷰 대기, 피드백 반영, 재리뷰 반복 역할 설명 |
| [`10-agents/review-waiter/main-prompt.md`](10-agents/review-waiter/main-prompt.md) | review waiter agent 전달 프롬프트 |
| [`10-agents/test-writer/README.md`](10-agents/test-writer/README.md) | 테스트 설계와 회귀 방지 기준 작성 역할 설명 |
| [`10-agents/test-writer/main-prompt.md`](10-agents/test-writer/main-prompt.md) | test writer agent 전달 프롬프트 |
| [`10-agents/task-writer/README.md`](10-agents/task-writer/README.md) | task를 검증 가능한 계약으로 작성하는 역할 설명 |
| [`10-agents/task-writer/main-prompt.md`](10-agents/task-writer/main-prompt.md) | task writer agent 전달 프롬프트 |
| [`10-agents/issue-writer/README.md`](10-agents/issue-writer/README.md) | 부수 발견과 반복 실패를 issue 후보로 정리하는 역할 설명 |
| [`10-agents/issue-writer/main-prompt.md`](10-agents/issue-writer/main-prompt.md) | issue writer agent 전달 프롬프트 |

## 사용 가능한 repo skill

전체 사용법은 [`20-skills/README.md`](20-skills/README.md)를 기준으로 봅니다.

fork 또는 clone 이후 실제 Codex 환경에 설치하려면 저장소 루트에서 아래 명령을 실행합니다.

```bash
./setup.sh
```

`setup.sh`는 repo 내부 skill, `using-superpowers`, Superpowers 작업 보조 묶음, `agent-browser`, `compound-engineering`을 선택적으로 설치합니다. repo 내부 skill은 이 디렉토리의 `SKILL.md` 묶음을 실제 Codex skill 디렉토리로 복사하는 경로입니다.

- [`add-dict`](20-skills/add-dict/SKILL.md)
- [`add-shared-runtime`](20-skills/add-shared-runtime/SKILL.md)
- [`command-intent-preflight`](20-skills/command-intent-preflight/SKILL.md)
- [`delete-shared-runtime`](20-skills/delete-shared-runtime/SKILL.md)
- [`main-branch-update-flow`](20-skills/main-branch-update-flow/SKILL.md)
- [`page-lifecycle-runtime-flow`](20-skills/page-lifecycle-runtime-flow/SKILL.md)
- [`projects-setup`](20-skills/projects-setup/SKILL.md)
- [`root-layer-manager`](20-skills/root-layer-manager/SKILL.md)
- [`shared-runtime-health-check`](20-skills/shared-runtime-health-check/SKILL.md)
- [`user-personality-adaptive-response`](20-skills/user-personality-adaptive-response/SKILL.md)

## Git 포함 기준

git에 남길 것은 프로젝트에 독립적인 코어 문서입니다.

포함 대상:

- SSoT, 메인 오케스트레이터, 동적 사일로, PR 리뷰 루프 설계
- 사용자 퍼스널리티와 취향 불변성을 다루는 일반 규칙
- 여러 프로젝트에 적용 가능한 역할별 agent 프롬프트
- 한국어 repo skill과 rule 초안
- env/config 템플릿
- project SSoT scaffold와 config 초안을 생성하는 `setup.sh` 흐름
- 에이전트 역할 설명과 전달 프롬프트

git에서 제외할 것은 프로젝트 의존 자료와 시크릿성 자료입니다.

제외 대상은 `system/.gitignore`에 정리했습니다.

- `.env`, token, password, credential, secret, private key 계열
- 로컬 실행 로그, trace, 영상, screenshot, cache
- 특정 workspace 분석 자료인 `../projects/`
- 원본 프롬프트와 과거 초안인 `../sources/`
- 프로젝트별 override를 담는 `local/`, `project-local/`, `project-overrides/`, `workspace-local/`
- 실제 프로젝트 목록, 보호 브랜치, clone URL, secret provider 값을 담은 `config/*.env`, `config/silo-projects.yaml`, `config/silo-secrets.yaml`

## 설정 주입

여러 프로젝트에서 재사용하려면 공통 프롬프트에 프로젝트 의존 값을 직접 박지 않습니다.

대신 아래 템플릿을 사용합니다.

- `config/silo-runtime.env.example`
- `config/silo-projects.example.yaml`
- `config/shared-runtime-registry.example.yaml`

실제 값은 gitignore된 파일이나 secret manager에 둡니다.

- `config/silo-runtime.env`
- `config/silo-projects.yaml`
- `config/silo-secrets.yaml`

사용자 선호에서 확정되지 않은 항목은 추론으로 채우지 않습니다. 사용자가 직접 말했거나, 반복된 PR 피드백으로 충분히 확인된 경우에만 `50-feedback-personality-loop/` 기준으로 증거 등급과 승격 여부를 분리하고, 필요한 경우 관련 agent 프롬프트나 공통 규칙에 반영합니다.

## 현재 주의점

- `system/`에는 정의와 템플릿만 둡니다.
- 프로젝트 조사 결과는 기본적으로 fork/submodule/external clone/project SSoT에 둡니다. 로컬 참고 자료는 `../projects/`에 둘 수 있지만 `main-v2` 커밋 대상은 아닙니다.
- project SSoT의 dashboard, task format, issue format, L 기준이 필요하면 실제 산출물을 `main-v2`에 커밋하지 않고 `setup.sh --create-project-ssot`으로 project SSoT 위치에 scaffold를 만듭니다.
- 원본 프롬프트와 과거 초안은 `../sources/`에 둡니다.
- 이 프롬프트 모음집은 여러 프로젝트에서 쓰는 것이 목표이므로, 프로젝트 의존 자료는 gitignore 대상으로 둡니다.
- 현재 목표 기준 다음 행동은 코드 수정이 아니라, 분석 초안 검토와 규칙 승격입니다.
- 프롬프트와 repo skill은 한국어로 읽히도록 정리합니다.
- repo skill을 추가하거나 기존 skill 사용법을 바꾸면 `20-skills/README.md`와 필요한 상위 README/인덱스를 함께 갱신합니다.
- README 또는 인덱스에 사용 시점과 사용법이 연결되지 않은 skill 변경은 완료로 보지 않습니다.

## 에이전트 md 보강 방식

`AGENTS.md`, `CLAUDE.md`, 역할별 agent 프롬프트, 설치용 skill이 빈약하다고 판단되면 바로 규칙을 추가하지 않습니다.

먼저 `50-feedback-personality-loop/` 기준으로 피드백 유형, 적용 범위, 증거 등급, 승격 여부를 분리합니다. PR 리뷰 기준은 `40-pr-review-loop/`, 역할별 실행 규칙은 `10-agents/<agent>/README.md`와 `main-prompt.md`에 반영합니다.

프로젝트 내부 실제 issue/task/QA 결과는 0계층에 그대로 복사하지 않고, 해당 project SSoT 위치와 반복 가능한 운영 패턴만 기록합니다.
