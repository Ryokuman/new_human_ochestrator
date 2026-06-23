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

`main-v2`에서는 완벽한 설계보다 가장 빠르게 사용 가능한 결과물을 우선합니다. 불확실성이 있어도 합리적으로 가정하고 진행하며, 구현 후 발견한 문제를 새 spec, task, issue, SSoT 승격 후보로 정리합니다. task를 검토하거나 실행할 때는 프론트와 백엔드를 분리된 소유권으로 보지 않고, 사용자 목적과 완료 경로 기준의 풀스택 단위로 봅니다. API 부재는 단독 위험으로 단정하지 않고, 같은 task 안에서 백엔드 계약을 먼저 만들고 프론트가 소비하는 순서를 기본 제안으로 둡니다. system SSoT는 상황별 처방 모음이 아니라 agent가 판단할 근거, 계층 분류, 승격 기준을 모아둔 프롬프트/스킬 하네스입니다. 외부 서비스, 인증, 실제 네트워크, 사용자 계정, 런타임 설정처럼 agent가 직접 통제하지 못하는 요소가 completion에 끼어들면, system에는 통제 가능성, 증명 가능성, 사용자 승인 필요 여부를 분리하는 판단 근거만 둡니다. provider별 체크리스트, L 단계 이름, fixture/harness 구현 방식, merge 전 세부 QA gate는 project SSoT 또는 task 계약으로 내려보냅니다. branch base는 계층 기준 브랜치로 판단하며, 0계층 공통 변경은 `main-v2`, project 계층 변경은 해당 `project/<project-id>`가 기준입니다. 하나의 작업 브랜치에 system update와 project SSoT update가 섞이면 worktree와 PR을 계층별로 분리합니다. 1계층 project registry/config 변경이나 2계층 project SSoT 변경이라도 기준 `project/<project-id>` 브랜치에 직접 커밋하지 않고, 별도 worktree와 파생 브랜치, project 대상 PR을 반드시 거칩니다. PR 생성 요청을 받으면 먼저 현재 브랜치의 0계층/project 계층을 판정하고, 0계층 PR은 `main-v2` 대상으로 올리며, project 계층 PR은 해당 `project/<project-id>` 기준 브랜치에서 판 별도 worktree의 파생 브랜치에서 커밋한 뒤 `project/<project-id>` 대상으로 올립니다. PR 생성 직후에는 `codex-pr-review-loop` skill로 no-major 목표를 세팅한 뒤 PR 댓글의 수동 `@codex review` 호출을 기본으로 둡니다. 호출 댓글에는 가능하면 `한국어로 리뷰해 주세요.` 또는 이에 준하는 한국어 요청과 최신 head 기준 리뷰 요청만 적습니다. no-major 목표와 통과 판정은 외부 댓글이 아니라 PR 본문, task silo의 `goal.md`, 메인 에이전트 내부 상태에서 관리합니다. 외부 리뷰 봇의 고정 템플릿 언어까지 보장하지는 못합니다. 현재 head push 이후에 작성된 최신 `@codex review` 호출 댓글에 `eyes` 반응이 있으면 리뷰가 접수 또는 진행 중인 상태로 보고 같은 head commit에 추가 호출하지 않고 최대 15분까지 기다립니다. 15분 동안 Codex 응답이 없으면 timeout으로 중단하고 보고합니다. PR 생성 후에는 최신 head에 대한 `Didn't find any major issues` 또는 동등한 no-major 명시 응답이 나올 때까지 수정, 검증, 재리뷰를 반복합니다. task silo의 `goal.md`가 확인되면 no-major 목표를 `goal.md`에 세팅하고, 그렇지 않은 PR은 PR 본문, 리뷰 thread, 현재 사용자 요청을 재리뷰 컨텍스트로 사용합니다. 기본 중단 기준은 호출 횟수가 아니라 리뷰 결과입니다. 사용자가 `~PR을 리뷰 대기 에이전트로 돌려주세요`처럼 명시하지 않아도 PR 생성 후 루프는 사용자 응답을 기다리지 않고 진행하며, 별도 백그라운드 실행자가 필요하면 `review-waiter-agent`가 관리합니다. 사용자가 이번 PR에 명시한 반복 한도가 있을 때만 그 한도를 따릅니다. 다만 secret, credential, production 데이터, destructive action, data SSoT 임의 변경, 보호 브랜치 직접 수정은 여전히 승인 gate입니다.

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
10. `50-feedback-personality-loop/06-system-scope-routing-audit.md`

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
- [`codex-pr-review-loop`](20-skills/codex-pr-review-loop/SKILL.md)
- [`command-intent-preflight`](20-skills/command-intent-preflight/SKILL.md)
- [`delete-shared-runtime`](20-skills/delete-shared-runtime/SKILL.md)
- [`main-branch-update-flow`](20-skills/main-branch-update-flow/SKILL.md)
- [`main-v2-pr-scope-gate`](20-skills/main-v2-pr-scope-gate/SKILL.md)
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
- `setup.sh --create-project-ssot`은 `projects/<project-id>/` 아래 target을 만들 때 해당 project SSoT만 git 추적 가능하도록 `.gitignore` 예외를 보정합니다.
- project SSoT scaffold는 DataviewJS 작업 대시보드, Obsidian Base 대체 뷰, Markdown 본문 폭을 넓히는 기본 CSS snippet을 함께 생성합니다. Dataview 대시보드는 `taskID`/`taskTitle`, `issueID`/`issueTitle`을 분리해서 보여주고, `dashboardScope.paths`를 바꿔 프로젝트 안에 여러 작업 대시보드를 둘 수 있습니다. 생성되는 task 템플릿은 병렬 task 독립성 계약을 포함하며, sibling task 완료를 개별 task의 Output, Acceptance Criteria, Test Plan 전제로 두지 않습니다. 여러 sibling task 완료를 전제로 하는 최종 통합 E2E만 별도 QA gate 또는 integration task로 분리합니다.
- 프로젝트 내부 task, issue, QA, decision, dashboard, source doc을 쓰기 전에는 `projects/<project-id>/README.md`에서 선언된 project SSoT 경로를 먼저 확인합니다. 선언이 없으면 기본 scaffold인 `projects/<project-id>/02-project-internal/` 아래 dashboard와 task 위치를 확인합니다. `project/<project-id>` 브랜치가 있으면 기준 브랜치에 직접 쓰지 않고, 그 브랜치에서 판 별도 worktree와 파생 브랜치에서만 project SSoT 원문을 작성한 뒤 `project/<project-id>` 대상 PR로 반영합니다. 제품 repo 내부 `obs/`, `.obsidian`, `docs/`, submodule, external clone은 기준 SSoT라고 추정하지 않습니다.
- 오래된 브랜치가 project SSoT 파일을 추가, 삭제, 이동한 것처럼 보이면 `main-v2` 기준 공통 규칙 drift와 `project/<project-id>` 기준 project SSoT diff를 나눠 봅니다. 보고할 때는 최종 트리 차이인 `base..branch`와 브랜치 고유 변경인 `base...branch`를 구분합니다.
- `main-v2` 대상 PR을 제안하거나 push하거나 생성하기 전에는 `main-v2-pr-scope-gate`로 diff path와 브랜치명을 먼저 분류합니다. project SSoT 원문이나 local/silo 자료가 포함되면 push/PR을 진행하지 않고 project 브랜치 유지 또는 공통 승격 후보 분리로 보고합니다.
- project SSoT 삭제 PR은 삭제 대상 파일을 `이관 확인됨`, `미이관`, `중복`, `폐기 후보`, `사용자 판단 필요`로 먼저 분류한 뒤 만듭니다. `todo`, `in_progress`, active issue, QA evidence, handoff, source doc은 이관 또는 폐기 근거 없이 삭제하지 않습니다.
- task/issue 사일로를 시작할 때는 사일로 root, `goal.md`, repo clone, 작업 브랜치 중 하나라도 만들기 전에 project SSoT의 원본 task/issue 상태를 `in_progress`로 갱신합니다. 이 상태 갱신도 기준 `project/<project-id>` 브랜치에 직접 커밋하지 않고, 별도 worktree의 파생 브랜치에서 상태 갱신 PR을 먼저 만든 뒤 `project/<project-id>`에 머지된 것을 확인합니다. 상태 갱신 PR이 머지되기 전에는 사일로 준비를 시작하지 않으며, 갱신 PR 생성 또는 머지 확인을 할 수 없으면 사일로 진행을 멈추고 이유를 보고합니다.
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
