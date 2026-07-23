# system 디렉토리

이 디렉토리는 `new-human` 작업의 정리 결과물이며, 여러 프로젝트에서 재사용할 수 있는 프롬프트/에이전트 설계 모음집으로 정리합니다.

`new-human` 루트에 흩어져 있던 기존 md 원본들은 성격별로 분리합니다.

- 프로젝트 조사 결과: `../projects/`
- 원본 프롬프트와 과거 초안: `../sources/`

최종 정의와 재사용 가능한 문서는 `system/`를 기준으로 봅니다.

현재 `my_ochestrator`의 git 추적 실체는 0계층 System SSoT repo입니다. 1계층 User SSoT와 Project SSoT, 2계층 Project Work SSoT, 3계층 Silo Local / Test Evidence 실데이터는 이 repo 정본에 존재하지 않습니다. `system/`은 그 실데이터를 담는 위치가 아니라, 각 계층을 만들고 운영하는 공통 규칙과 템플릿을 담는 위치입니다.

기능 영향 계층과 실제 수정 위치는 분리합니다. 1계층 Project SSoT 관리 기능을 고치더라도 공통 규칙, 템플릿, skill 사용 기준을 바꾸는 변경이면 실제 수정 위치와 PR 기준은 0계층입니다.

## 상위 기능 트리

현재 0계층이 관리하는 상위 기능은 아래 10개입니다.

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

위험 실행 전제 확인은 독립 상위 기능이 아니라 Task/Issue/Silo 운영과 Runtime Set 관리의 하위 gate입니다. Task 내부의 `hypothesis_chain`은 Task/Issue/Silo 운영 하위 record이고, 사용자별 유저 퍼스널리티와 Feedback은 User Layer / Personality System의 범위입니다.

User Layer는 0계층이나 3계층 local이 아닌 1계층 User SSoT입니다. 실제 상태는 workspace의 `user-layer/` 디렉터리가 소유합니다.

## 계층과 브랜치 정본

```text
0계층 System SSoT -> 목표 계층 메인 브랜치 `main-v3/main`
1계층 User SSoT -> `<workspace>/user-layer/`
1계층 Project SSoT -> `<workspace>/<projectName>/01-project-ssot/`, 목표 계층 메인 브랜치 `project-{projectName}/main`
2계층 Project Work SSoT -> `<workspace>/<projectName>/02-project-work-ssot/`
3계층 Silo Local -> `<workspace>/silos/`, test evidence, 사일로 임시 feedback
3계층 Workspace Local 검수 -> `<workspace>/local/<작업명>/`, 승인 전 비정본 Markdown·계획·evidence
목표 작업 브랜치 -> `{layerNamespace}/{taskname}`
현재 마이그레이션 전 호환 작업 브랜치 -> `main-v3/{taskname}`, `project-{projectName}-{taskname}`
```

`setup.sh` 빠른 시작의 기본 물리 구조는 아래와 같습니다.

```text
<workspace>/
├── .obsidian/           # Git 제외된 workspace 단일 vault 설정
├── local/               # Git 제외된 승인 전 검수 공간
├── AGENTS.md
├── my_ochestrator/
├── user-layer/
├── <projectName>/
│   ├── 01-project-ssot/
│   └── 02-project-work-ssot/
├── sources/
├── silos/
└── shared-runtime/
```

quickstart는 workspace 루트의 `.obsidian/`과 `local/`을 실제로 준비하고, 단일 Vault에서 Project Work SSoT 대시보드를 사용할 수 있도록 Dataview 선언, core plugin 구성, appearance와 CSS snippet을 루트 `.obsidian/`에 둡니다. 다만 Obsidian 앱의 Vault 등록은 OS 사용자 상태이므로 자동 등록하지 않습니다. 최초 1회 Obsidian에서 `<workspace>` 폴더를 `Open folder as vault`로 등록한 뒤 Local 검수 링크를 사용합니다. project 내부 `02-project-work-ssot/.obsidian/`은 해당 폴더를 독립 Vault로 여는 이전 호환 설정이며 workspace 단일 Vault에서는 루트 설정이 적용됩니다.

`main-v3`나 `project-{projectName}` 자체는 브랜치로 만들지 않는 Git ref namespace입니다. 기존 slash 기반 `project/<project-id>` 모델은 목표 정본과 다른 이전 표기입니다. 기존 브랜치, PR, 문서 이력을 해석할 때만 호환/전환 필요 항목으로 언급합니다.

목표는 제품 코드를 고치는 것이 아니라, 다음 흐름을 한국어 문서로 정리하는 것입니다.

```text
레포 파악
-> 사용자가 지금까지 한 일 파악
-> 퍼스널리티 파악
-> 취향 불변성 후보 생성
-> 개인 에이전트 셋업 자료로 승격
```

## main-v3/main 운영 방향

`main`은 레거시 보존 브랜치입니다. 이 프로젝트에서는 작업, PR, merge, rebase, worktree 기준으로 사용하지 않습니다.

`main-v3/main`는 탐색형 제품 엔지니어 운영 방식 기준 브랜치입니다.

```text
Build -> Learn -> Spec
```

`main-v3/main`에서는 완벽한 설계보다 가장 빠르게 사용 가능한 결과물을 우선합니다. 불확실성이 있어도 합리적으로 가정하고 진행하며, 구현 후 발견한 문제를 새 spec, task, issue, feedback/follow-up 후보로 정리합니다. 다만 요구사항, 애플리케이션 세부사항, project contract, 유저 플로우를 정리하는 단계에서는 task를 먼저 만들지 않습니다. 먼저 현재 운영 가설과 gate를 보고하고, 제품 정의와 사용자 흐름을 기반으로 agent 추론 질문을 던져 사용자 확인을 받은 뒤, 확정 내용을 기능 또는 사용자 흐름별 project SSoT 요구사항 문서로 나눕니다. task는 project contract가 충분히 성숙하고 사용자가 첫 구현 slice를 고른 뒤 작성합니다. task를 검토하거나 실행할 때는 프론트와 백엔드를 분리된 소유권으로 보지 않고, 사용자 목적과 완료 경로 기준의 풀스택 단위로 봅니다. API 부재는 단독 위험으로 단정하지 않고, 같은 task 안에서 백엔드 계약을 먼저 만들고 프론트가 소비하는 순서를 기본 제안으로 둡니다. system SSoT는 상황별 처방 모음이 아니라 agent가 판단할 근거, 계층 분류, 승격 기준을 모아둔 프롬프트/스킬 하네스입니다. 외부 서비스, 인증, 실제 네트워크, 사용자 계정, 런타임 설정처럼 agent가 직접 통제하지 못하는 요소가 completion에 끼어들면, system에는 통제 가능성, 증명 가능성, 사용자 승인 필요 여부를 분리하는 판단 근거만 둡니다. provider별 체크리스트, L 단계 이름, fixture/harness 구현 방식, merge 전 세부 QA gate 같은 반복 실행/QA/runbook/fixture/harness 계약은 project-level contract/registry와 분리해 2계층 Project Work SSoT 또는 task 계약으로 내려보냅니다. branch base는 계층 기준 브랜치로 판단합니다. 목표 모델의 0계층 계층 메인 브랜치는 `main-v3/main`, project 계층 메인 브랜치는 `project-{projectName}/main`입니다. 현재 마이그레이션 전 호환 기준은 `main-v3/main`와 `project-{projectName}`입니다. 하나의 작업 브랜치에 system update와 project SSoT update가 섞이면 worktree와 PR을 계층별로 분리합니다. 1계층 project registry/config 변경이나 2계층 project SSoT 변경이라도 계층 메인 브랜치에 직접 커밋하지 않습니다. 목표 모델에서는 `project-{projectName}/{taskname}` 작업 브랜치와 `project-{projectName}/main` 대상 PR을, 현재 호환 상태에서는 `project-{projectName}-{taskname}` 작업 브랜치와 `project-{projectName}` 대상 PR을 거칩니다. PR 생성 요청을 받으면 먼저 현재 브랜치의 0계층/project 계층을 판정하고, 목표 모델에서는 0계층 PR을 `main-v3/main`, project 계층 PR을 `project-{projectName}/main` 대상으로 올립니다. 현재 호환 상태에서는 0계층 PR을 `main-v3/main`, project 계층 PR을 `project-{projectName}` 대상으로 올립니다. 제품 repo가 독립 git submodule commit을 pin한다면 상위 제품 repo PR의 gitlink 리뷰만으로 완료하지 않고, 변경된 submodule repo마다 별도 PR과 codex-review pass 또는 동등 리뷰 gate를 먼저 확인합니다. PR 생성 직후에는 `codex-pr-review-loop` skill로 codex-review pass 목표를 세팅한 뒤 PR 댓글의 수동 `@codex review` 호출을 기본으로 둡니다. 호출 댓글에는 가능하면 `한국어로 리뷰해 주세요.` 또는 이에 준하는 한국어 요청과 최신 head 기준 리뷰 요청만 적습니다. codex-review pass 목표와 통과 판정은 외부 댓글이 아니라 PR 본문, task silo의 `goal.md`, 메인 에이전트 내부 상태에서 관리합니다. codex-review pass 기준은 최신 head commit에 대한 Codex review 이후 P2 이상 지적이 남아 있지 않은 상태입니다. 외부 리뷰 봇의 고정 템플릿 언어까지 보장하지는 못합니다. 현재 head push 이후에 작성된 최신 `@codex review` 호출 댓글에 `eyes` 반응이 있으면 리뷰가 접수 또는 진행 중인 상태로 보고 같은 head commit에 추가 호출하지 않고 `eyes` 확인 시점부터 최대 15분까지 기다립니다. 최신 호출 댓글에 3분 동안 `eyes` 반응이 없고 최신 head 리뷰 결과도 없으면 접수 실패로 보고 같은 head 기준으로 최대 3회까지 재호출한 뒤 새 호출 댓글 기준으로 다시 확인합니다. 3회 모두 접수되지 않으면 `Codex 리뷰 접수 실패 timeout`으로 중단합니다. `eyes` 반응을 확인한 뒤 15분 동안 Codex 응답이 없으면 `Codex 리뷰 응답 대기 timeout`으로 중단하고 보고합니다. PR 생성 후에는 최신 head에 대한 `Didn't find any major issues` 또는 동등한 codex-review pass 명시 응답과 현재 head 대상 지적의 `수정 필요`/`수비 가능`/`사용자 판단 필요` 분류가 끝날 때까지 수정, 검증, 재리뷰를 반복합니다. task silo의 `goal.md`가 확인되면 codex-review pass 목표를 `goal.md`에 세팅하고, 그렇지 않은 PR은 PR 본문, 리뷰 thread, 현재 사용자 요청을 재리뷰 컨텍스트로 사용합니다. 기본 중단 기준은 호출 횟수가 아니라 리뷰 결과입니다. task 실행 결과인 사일로 PR이 실제 제품 코드 파일을 바꾸고 runtime, browser, manual QA, E2E 확인이 남아 있을 때만 codex-review pass 이후 사용자 재리뷰 전에 `shared-runtime-health-check`로 사일로 설정의 `runtime_set`과 서버형 runtime 상태를 확인하고, `silo-runtime-handoff`로 실행 서버 주소, E2E 방법, 실행 불가 사유를 PR 댓글에 남깁니다. 문서, skill, project SSoT, config example만 바꾼 PR에는 runtime handoff를 붙이지 않습니다. `runtime_set`이 없거나 어떤 서버를 켤지 불명확하면 임의로 서버 조합을 만들지 않고 정의 누락 또는 `add-shared-runtime` 필요를 댓글에 남깁니다. 사용자가 `~PR을 리뷰 대기 에이전트로 돌려주세요`처럼 명시하지 않아도 PR 생성 후 루프는 사용자 응답을 기다리지 않고 진행합니다. 최신 head 리뷰 결과가 없는 `eyes` 진행 중 상태, 리뷰 호출 직후 접수 확인 전 상태, 수정 후 push했지만 재리뷰 결과가 없는 상태에서 메인 에이전트가 같은 턴에 polling/timeout 확인을 끝낼 수 없으면 기본적으로 `review-waiter-agent`가 관리합니다. 사용자가 이번 PR에 명시한 반복 한도가 있을 때만 그 한도를 따릅니다. 다만 secret, credential, production 데이터, destructive action, data SSoT 임의 변경, 보호 브랜치 직접 수정은 여전히 승인 gate입니다.

## 읽는 순서

저장소에 처음 진입하는 agent는 루트 `AGENTS.md`의 Read Order를 먼저 따릅니다.
`system/` 내부 문서만 다시 훑을 때는 아래 순서를 기준으로 봅니다.

1. `README.md`
2. `00-system-overview/계층-구조와-관리-원칙.md`
3. `00-system-overview/workspace-local-review-and-promotion.md`
4. `00-system-overview/전체-시스템-개요.md`
5. `00-system-overview/운영-가설-로그.md`
6. `60-operating-hypotheses/README.md`
7. `10-ssot/SSoT-스키마-초안.md`
8. `10-agents/main.md`
9. `20-skills/README.md`
10. `20-skills/root-layer-manager/SKILL.md`
11. `10-agents/main-orchestrator/main-prompt.md`
12. `30-silo-system/README.md`
13. `40-pr-review-loop/README.md`
14. `50-feedback-personality-loop/README.md`
15. `50-feedback-personality-loop/06-system-scope-routing-audit.md`

## 저장소 지도

루트 `AGENTS.md`의 Read Order는 공통 규칙을 빠르게 읽기 위한 핵심 `system/` 문서 순서입니다. 전체 저장소 표면을 파악할 때는 아래 지도를 함께 봅니다.

| 경로 | 역할 | 운영 기준 |
|---|---|---|
| `README.md`, `docs/ko/`, `docs/en/` | 공개 사용자와 contributor가 처음 읽는 진입점 | `docs/`는 사용자용 공개 문서만 소유하며 공개 export에 포함됩니다. |
| `AGENTS.md`, `AGENTS.public.md` | 내부 agent 지시문과 공개 export용 agent 지시문 | 내부 지시와 공개 지시는 분리해 관리합니다. |
| `system/` | 0계층 System SSoT, agent prompt, repo skill, scaffold template 정본 | 공통 규칙 변경은 `main-v3/{taskname}` 작업 브랜치와 `main-v3/main` 대상 PR로 처리합니다. |
| `.github/workflows/` | source repo의 공개 export workflow와 운영 자동화 | workflow 자체는 내부 source repo 지원 표면입니다. |
| `setup.sh` | repo skill 설치, local config, User SSoT 디렉터리, Project SSoT scaffold 생성 진입점 | 생성 결과가 1~3계층 실데이터이면 `system/` 정본에 복사하지 않습니다. |

한글, 공백, 특수문자가 포함된 tracked 경로를 순회하는 운영 명령을 문서화할 때는 `git ls-files -z`와 `xargs -0`, 또는 사용하는 도구의 NUL 구분 옵션을 기본으로 둡니다.

## 폴더 역할

| 폴더 | 역할 |
|---|---|
| `00-system-overview/` | SSoT, 메인 오케스트레이터, 동적 사일로 전체 구조 |
| `10-ssot/` | 상태와 규칙의 원본 스키마 |
| `10-agents/` | 에이전트 역할과 실제 전달 프롬프트 |
| `20-skills/` | 설치 가능한 repo skill과 사용법 README |
| `config/` | 사일로가 어떤 프로젝트를 clone할지, 어떤 브랜치를 보호할지, shared runtime을 어디서 참조할지 적는 설정 템플릿. `setup.sh --init-config`와 repo skill의 기본 실행 경로는 `system/config/` 아래 gitignore된 local 파일입니다. |
| `30-silo-system/` | 동적 사일로 생성과 작업 방식 |
| `40-pr-review-loop/` | PR 리뷰, 머지, SSoT 승격 판단 |
| `50-feedback-personality-loop/` | 사용자 피드백 기반 규칙 갱신 |
| `60-operating-hypotheses/` | task 처리 방식, 정보 취합, 구현 플랜, 사일로/PR/review loop 운영 가설 |
| `templates/` | `setup.sh`가 Codex-home/workspace AGENTS 라우터, User Layer 디렉터리, Project SSoT scaffold를 준비할 때 복사하는 공통 템플릿 조각 |

`system/templates/codex-home/`는 setup에 사용한 동일 `$CODEX_HOME`과 유효한 정본 경로를 사용하는 동안 Codex가 어느 저장소에서 시작해도 0계층 루트 AGENTS 라우터와 User Layer 정본을 찾게 하는 전역 라우터를 둡니다. `system/templates/workspace/`는 System → User → Project AGENTS 읽기 순서만 가진 workspace 라우터를 둡니다. `system/templates/user-layer/`는 User SSoT의 빈 정본·Feedback·갱신 세션 양식을 둡니다. `system/templates/project-ssot/`는 완성된 Project SSoT 전체가 아니라 `setup.sh --create-project-ssot`이 복사하는 파일 템플릿만 둡니다. `project-overview.md`, Project AGENTS, `work-items.base`, issue/task 템플릿처럼 프로젝트별 값이 들어가는 파일은 `setup.sh`가 생성합니다.

## repo-local 지원 표면

| 경로 | 역할 | 설치/실행 기준 |
|---|---|---|

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
- [`delete-shared-runtime`](20-skills/delete-shared-runtime/SKILL.md)
- [`github-project-intake`](20-skills/github-project-intake/SKILL.md)
- [`main-branch-update-flow`](20-skills/main-branch-update-flow/SKILL.md)
- [`main-v3-pr-scope-gate`](20-skills/main-v3-pr-scope-gate/SKILL.md)
- [`project-contract-gate`](20-skills/project-contract-gate/SKILL.md)
- [`projects-setup`](20-skills/projects-setup/SKILL.md)
- [`root-layer-manager`](20-skills/root-layer-manager/SKILL.md)
- [`shared-runtime-health-check`](20-skills/shared-runtime-health-check/SKILL.md)
- [`silo-runtime-handoff`](20-skills/silo-runtime-handoff/SKILL.md)
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

루트 workspace 제외 대상은 루트 `.gitignore`에, `system/` 하위 제외 대상은 `system/.gitignore`에 나눠 정리했습니다.

- `.env`, token, password, credential, secret, private key 계열
- 로컬 실행 로그, trace, 영상, screenshot, cache
- 루트 `.gitignore`가 제외하는 특정 workspace 분석 자료인 `../projects/`
- 루트 `.gitignore`가 제외하는 원본 프롬프트와 과거 초안인 `../sources/`
- 루트 `.gitignore`가 제외하는 작업/로컬 산출물인 `../task-*/`, `../local/`
- `system/.gitignore`가 제외하는 프로젝트별 override인 `local/`, `project-local/`, `project-overrides/`, `workspace-local/`
- 실제 프로젝트 목록, 보호 브랜치, clone URL, secret provider 값을 담은 `system/config/*.env`, `system/config/silo-projects.yaml`, `system/config/silo-secrets.yaml`

## 설정 주입

여러 프로젝트에서 재사용하려면 공통 프롬프트에 프로젝트 의존 값을 직접 박지 않습니다.

대신 아래 템플릿을 사용합니다.

- `config/silo-runtime.env.example`
- `config/silo-projects.example.yaml`
- `config/silo-secrets.example.yaml`
- `config/shared-runtime-registry.example.yaml`
- `config/public-export-manifest.example.yaml`: `main-v3/main`의 공개 가능한 산출물을 `Ryokuman/new_human_ochestrator:main-v3/main`로 배포할 때 참고하는 allowlist export 정책 예시입니다. 현재 실행 workflow는 이 파일을 파싱하지 않고 `.github/workflows/sync-public-orchestrator.yml`의 run block을 실행 기준으로 사용합니다.

`setup.sh --init-config`가 만드는 실제 값 초안은 `system/config/` 아래 gitignore된 파일에 두고, secret 실제 값은 secret manager에 둡니다. 아래 `config/...`는 이 문서 기준 상대경로이며 repo 기준으로는 `system/config/...`입니다.

- `config/silo-runtime.env`
- `config/silo-projects.yaml`
- `config/shared-runtime-registry.yaml`
- `config/silo-secrets.yaml`

루트 `config/`는 수동 local override나 향후 전환 중 실제 값이 잘못 커밋되지 않도록 루트 `.gitignore`가 추가로 보호합니다.

사용자 선호에서 확정되지 않은 항목은 추론으로 채우지 않습니다. 사용자가 직접 말했거나, 반복된 PR 피드백으로 충분히 확인된 경우에만 `50-feedback-personality-loop/` 기준으로 증거 등급과 승격 여부를 분리하고, 필요한 경우 관련 agent 프롬프트나 공통 규칙에 반영합니다.

## 현재 주의점

- `system/`에는 정의와 템플릿만 둡니다.
- 프로젝트 조사 결과는 기본적으로 fork/submodule/external clone/project SSoT에 둡니다. 로컬 참고 자료는 `../projects/`에 둘 수 있지만 `main-v3/main` 커밋 대상은 아닙니다.
- project SSoT의 dashboard, task format, issue format, L 기준이 필요하면 실제 산출물을 0계층 계층 메인 브랜치에 커밋하지 않고 `setup.sh --create-project-ssot`으로 project SSoT 위치에 scaffold를 만듭니다.
- `setup.sh` 빠른 시작은 repo의 부모 workspace에 `<projectName>/01-project-ssot`, `<projectName>/02-project-work-ssot`, `sources/`, `silos/`, `shared-runtime/`을 만듭니다.
- portfolio/evidence 요약은 별도 계층이 아니라 현재 계층 모델 안에서 라우팅합니다. 특정 프로젝트에 연결되는 공개 가능성, repo 묶음, 사용자 역할, 근거 위치 색인은 1계층 Project SSoT의 project-level 요약/색인에 두고, PR/commit/code path 원문, 캡처, 테스트 evidence, 실행 로그 같은 근거 원문은 2계층 Project Work SSoT, 3계층 사일로/로컬 evidence, PR 본문, 또는 project가 정한 외부 evidence 위치로 내립니다.
- `setup.sh --create-project-ssot`은 호환을 위해 직접 target을 받을 수 있습니다. target이 이전 구조인 `projects/<project-id>/` 아래이면 해당 project SSoT만 git 추적 가능하도록 `.gitignore` 예외를 보정합니다.
- project SSoT scaffold는 DataviewJS Task 칸반과 작업 멀티필터, Obsidian Base 대체 뷰, Markdown 편집/미리보기 영역에 `90%` 폭을 적용하는 기본 CSS snippet을 함께 생성합니다. Task는 `todo`, `in_progress`, `blocked`, `review`, `done` 상태 디렉터리로 나누고 직계 상위 디렉터리와 frontmatter `status`를 일치시킵니다. 상태 변경은 파일 이동과 `status`, `updated` 갱신을 한 변경 단위로 처리합니다. 칸반은 읽기 전용이며 별도 Kanban 플러그인을 요구하지 않습니다. Dataview 대시보드는 `taskID`/`taskTitle`, `issueID`/`issueTitle`을 분리해서 보여주고, `owner_silo`, `branch`, `pr`, 가설 요약, 실패 이력 상세를 필터 또는 표시 컬럼으로 제공합니다. `dashboardScope.paths`를 바꾸면 프로젝트 안에 여러 작업 대시보드를 둘 수 있습니다. 생성되는 task 템플릿은 `parallel_independence_contract` frontmatter와 `병렬 task 독립성 계약` 본문 섹션을 포함하며, sibling task 완료를 개별 task의 Output, Acceptance Criteria, Test Plan 전제로 두지 않습니다. 여러 sibling task 완료를 전제로 하는 최종 통합 E2E만 별도 QA gate 또는 integration task로 분리합니다. 생성되는 `30-work-items/silo-template/goal.md`와 `templates/silo-goal.md`는 원본 task/issue SSoT, 2계층 Project Work SSoT, Runtime Set 결정 근거, 테스트 report/window, criteria별 테스트 계약, 초기 DB 목데이터, 테스트 입력, 원본 task Output/Acceptance/Test Plan, Codex review, agent-browser 기준을 받을 수 있어야 합니다.
- 프로젝트 내부 task, issue, QA, decision, dashboard, source doc을 쓰기 전에는 `<workspace>/<projectName>/01-project-ssot/`와 `<workspace>/<projectName>/02-project-work-ssot/`를 먼저 확인합니다. 이전 호환 구조에서는 `projects/<project-id>/README.md`와 `projects/<project-id>/02-project-internal/`을 확인합니다. 목표 모델에서는 `project-{projectName}/main` 기준 브랜치에 직접 쓰지 않고, 그 브랜치에서 판 `project-{projectName}/{taskname}` 작업 브랜치에서만 project SSoT 원문을 작성한 뒤 `project-{projectName}/main` 대상 PR로 반영합니다. 현재 호환 상태에서는 `project-{projectName}`와 `project-{projectName}-{taskname}`을 사용합니다. 제품 repo 내부 `obs/`, `.obsidian`, `docs/`, submodule, external clone은 기준 SSoT라고 추정하지 않습니다.
- 오래된 브랜치가 project SSoT 파일을 추가, 삭제, 이동한 것처럼 보이면 0계층 기준 공통 규칙 drift와 project 계층 기준 project SSoT diff를 나눠 봅니다. 현재 호환 기준은 `main-v3/main`와 `project-{projectName}`이고, 목표 기준은 `main-v3/main`과 `project-{projectName}/main`입니다. 보고할 때는 최종 트리 차이인 `base..branch`와 브랜치 고유 변경인 `base...branch`를 구분합니다.
- 0계층 대상 PR을 제안하거나 push하거나 생성하기 전에는 `main-v3-pr-scope-gate`로 diff path와 브랜치명을 먼저 분류합니다. 현재 skill 이름은 `main-v3/main` 호환 상태를 반영하지만 목적은 0계층 PR scope gate입니다. project SSoT 원문이나 local/silo 자료가 포함되면 push/PR을 진행하지 않고 project 브랜치 유지 또는 공통 승격 후보 분리로 보고합니다.
- PR 생성 후 Codex review 설정이 있는 repo 또는 organization에서는 `codex-pr-review-loop`로 최신 head codex-review pass 리뷰를 권장합니다. Codex review 설정 없음, 호출 권한 없음, GitHub App 미설치, repo 정책상 비활성화가 명시적으로 확인되면 review loop를 돌리지 않고 `Codex review 미설정`을 PR 본문 또는 보고에 남깁니다. 아직 확인 전인 repo는 먼저 `@codex review`를 호출해 접수 여부를 확인합니다. task 실행 결과인 사일로 PR이 실제 제품 코드 파일과 runtime/E2E 확인을 함께 포함할 때만 `silo-runtime-handoff`로 사용자 확인에 필요한 runtime, URL, E2E 방법, 실행 불가 사유를 정리합니다. 문서, skill, project SSoT, config example/config template, PR 본문 템플릿만 바꾼 PR은 `codex-pr-review-loop` fallback 보고로 닫고 `silo-runtime-handoff` 댓글 필수 조건을 적용하지 않습니다.
- 일반 task summary는 Codex review pass 증거가 아닙니다. 단, `Codex Review` 완료 표지, exact phrase, 최신 head reviewed commit을 함께 가진 no-finding comment는 exact pass 후보입니다. actionable issue comment를 별도 수집하고 네 evidence 표면 안정화 뒤 pass를 확정합니다.
- `silo-runtime-handoff`는 config에 따라 다르게 동작합니다. `silo-runtime.env`는 사일로 work root와 project config 위치, branch prefix, 실행 모드를 정하고, `silo-projects.yaml`은 repo/protected branch/service policy/DB 정본 위치를 정하며, `shared-runtime-registry.yaml`은 shared BE/API, Docker DB, FE/harness, worker, mock service, health check를 정합니다. shared BE/API나 DB가 E2E 전제이면 해당 runtime이 켜져 있고 health check가 통과해야 E2E 가능으로 기록합니다.
- project SSoT 삭제 PR은 삭제 대상 파일을 `이관 확인됨`, `미이관`, `중복`, `폐기 후보`, `사용자 판단 필요`로 먼저 분류한 뒤 만듭니다. `todo`, `in_progress`, active issue, QA test evidence, handoff, source doc은 이관 또는 폐기 근거 없이 삭제하지 않습니다.
- task/issue 사일로를 시작할 때는 사일로 root, `goal.md`, repo clone, 작업 브랜치 중 하나라도 만들기 전에 2계층 Project Work SSoT의 원본 task/issue 상태를 `in_progress`로 갱신합니다. 이 상태 갱신도 project 계층 메인 브랜치에 직접 커밋하지 않고, 목표 모델에서는 `project-{projectName}/{taskname}` 작업 브랜치에서 상태 갱신 PR을 먼저 만든 뒤 `project-{projectName}/main`에 머지된 것을 확인합니다. 현재 호환 상태에서는 `project-{projectName}-{taskname}` 작업 브랜치와 `project-{projectName}` 대상 PR을 사용합니다. 이 gate는 `Build -> Learn -> Spec` 기본값을 막는 선행 설계 요구가 아니라, 사일로 실행 상태와 Project Work SSoT 소유권을 보호하는 시작 gate입니다. 상태 갱신 PR 생성 자체와 그 PR 안의 `in_progress` 상태 diff는 가장 작은 Build로 진행할 수 있고, 그 전에도 읽기 전용 조사, 대화 안의 실행 계획 초안, 변경안 후보 정리는 합리적 추정으로 진행할 수 있습니다. 반면 보호 브랜치 직접 수정, secret/credential 또는 production 데이터 접근, destructive action, 상태 갱신 PR 범위를 넘는 Project Work SSoT 원문 변경, 사일로 root/`goal.md`/repo clone/작업 브랜치 생성은 상태 갱신 PR 머지 확인 전에는 진행하지 않습니다. 갱신 PR 생성 또는 머지 확인을 할 수 없으면 사일로 준비를 시작하지 않고 이유를 보고합니다.
- 기능 task는 작성 전에 project contract를 먼저 확인하고, 사일로 실행 전에 단계별 구현 계획과 pseudo code를 작성해 리뷰합니다. project contract에는 제품 정의, 현재 버전 목표/비목표, 핵심 사용자 플로우, 데이터 저장과 동기화 경계, FE/BE/DB/harness/submodule 역할, 디자인 톤 정본, 추정 금지 정보가 있어야 합니다. project contract가 미성숙하면 task를 먼저 만들지 않고 현재 gate, 누락 항목, agent 추론, 사용자 확인 질문, 요구사항 문서화 위치 후보, task 작성 가능 조건을 보고합니다. pseudo code는 사용자 흐름 설명이나 구현 계획 문장이 아니라, 파일별 대표 함수에 실제 로직 구조가 어떻게 들어갈지 보는 코드 골격입니다. 실제 컴파일 가능한 구현 코드는 아니지만 `파일 -> 대표 함수 -> 필요한 입력/의존성 -> 조회/검증/가공/분기/저장/반환` 순서가 드러나야 합니다. 파일명, 함수명, API query, DB mutation, op 이름(`D/L/C/R`) 같은 식별자는 원문을 유지할 수 있지만 설명 문장은 한국어로 씁니다. 선언적 config, prop, default, value 한두 곳만 수정하고 별도 분기·가공·조회·저장 흐름이 없으면 pseudo code를 생략하고 대상 파일, 설정 key, 기존값 또는 누락 상태, 목표값, 회귀 검증을 변경 계약에 적을 수 있습니다. 로직 변경이나 여러 파일 실행 흐름은 이 예외로 우회하지 않습니다.
- task 처리 방식, 전체 구현 플랜 수립 방식, 정보 취합 방식, 사일로/PR/review loop 운영 방식이 바뀌면 `system/60-operating-hypotheses/`에 운영 가설을 남깁니다. 운영 가설은 제품 기능 가설이 아니라 0계층 운영 방식에 대한 가설이며, 채택 이유, 취합한 정보, 기존 방식의 문제, 예상 병목, 실행 결과, 실제 병목, 사람 확인 지점, 유지하거나 버릴 것을 기록합니다.
- 원본 프롬프트와 과거 초안은 `../sources/`에 둡니다.
- 이 프롬프트 모음집은 여러 프로젝트에서 쓰는 것이 목표이므로, 프로젝트 의존 자료는 gitignore 대상으로 둡니다.
- 현재 목표 기준 다음 행동은 코드 수정이 아니라, 분석 초안 검토와 규칙 승격입니다.
- 프롬프트와 repo skill은 한국어로 읽히도록 정리합니다.
- `docs/en/README.md` 같은 영문 공개 안내서는 다국어 안내 목적상 영어 본문을 허용합니다. 이 예외는 일반 계획서, 보고서, skill 설명, agent metadata에는 적용하지 않습니다.
- repo skill을 추가하거나 기존 skill 사용법을 바꾸면 `20-skills/README.md`와 필요한 상위 README/인덱스를 함께 갱신합니다.
- README 또는 인덱스에 사용 시점과 사용법이 연결되지 않은 skill 변경은 완료로 보지 않습니다.

## 에이전트 md 보강 방식

`AGENTS.md`, `CLAUDE.md`, 역할별 agent 프롬프트, 설치용 skill이 빈약하다고 판단되면 바로 규칙을 추가하지 않습니다.

먼저 `50-feedback-personality-loop/` 기준으로 피드백 유형, 적용 범위, 증거 등급, 승격 여부를 분리합니다. PR 리뷰 기준은 `40-pr-review-loop/`, 역할별 실행 규칙은 `10-agents/<agent>/README.md`와 `main-prompt.md`에 반영합니다.

프로젝트 내부 실제 자료는 0계층에 그대로 복사하지 않습니다. project-level contract/decision/registry 같은 1계층 정본과 색인은 Project SSoT 위치로 연결하고, task/issue/QA/runbook 같은 실행 결과와 evidence는 Project Work SSoT 위치로 연결하며, 0계층에는 반복 가능한 운영 패턴만 기록합니다.
