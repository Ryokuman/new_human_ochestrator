# Repo Skill 사용법

이 디렉토리는 이 저장소가 직접 제공하는 repo skill을 보관합니다.

최종 설치 위치는 실행 환경에 따라 다를 수 있지만, 이 저장소에서는 `system/20-skills/`를 repo skill의 공통 SSoT로 봅니다. 실제 설치 후에도 동작 기준이 헷갈리면 먼저 이 README와 각 `SKILL.md`를 확인합니다.

## 사용 원칙

- 사용자가 특정 skill을 말하거나, 요청이 skill 설명과 맞으면 해당 `SKILL.md`를 먼저 읽습니다.
- skill에 절차가 이미 정의되어 있으면 보고나 선택지에서 절차 전체를 반복하지 않고 skill 이름으로 압축합니다.
- 개별 `SKILL.md`의 완료 보고, 최종 보고, handoff 보고 절차는 아래 `최종 보고 계약`을 대체하지 않습니다. skill 고유 산출물은 전역 최종 응답 계약 뒤에 필요한 세부 항목으로 덧붙입니다.
- 공통 규칙, 프롬프트, `AGENTS.md`, repo skill 변경의 목표 계층 메인 브랜치는 `main-v3/main`입니다. 현재 마이그레이션 전 호환 상태에서는 `main-v3/main` 기준으로 처리합니다.
- 이 프로젝트에서는 기존 `main` 업데이트 절차를 실행하지 않습니다. 현재는 `main-v3/main`에서 branch-local 탐색형 운영 변경으로 처리하고, `main`에는 반영하지 않습니다.
- repo skill을 추가하거나 사용법을 바꾸면 이 README의 주요 skill 표와 관련 상위 README 또는 인덱스를 함께 갱신합니다.
- README 또는 인덱스 갱신이 빠졌다면 repo skill 변경은 완료로 보고하지 않습니다.
- 프로젝트별 실제 issue, task, QA, coverage 결과는 이 디렉토리에 복사하지 않습니다.
- 모든 사용자 대상 작성물, PR 제목, PR 본문, 커밋 메시지는 한국어로 작성합니다.

## 최종 보고 계약

모든 repo skill은 `AGENTS.md`의 `Skill Usage Reporting Policy`, `현재 워크트리 보고 정책`, `Final Response Option Policy`를 전역 최종 응답 계약으로 따릅니다. 따라서 repo skill을 사용한 턴의 최종 보고는 최소한 아래를 포함합니다.

- `사용한 스킬`: 사용한 repo/local skill 이름과 사용 이유를 짧게 적습니다. 도구 실행 명령은 여기에 섞지 않고 `검증` 또는 `실행한 명령`에 적습니다.
- `현재 워크트리`: 절대 경로, 현재 브랜치, dirty 여부, upstream 대비 ahead/behind 요약을 적습니다. 여러 worktree가 감지되면 현재 대화 기준 worktree와 sibling worktree를 구분합니다.
- `다음 행동`: 승인, 진행 여부, 저장 위치, 범위, 검증 범위가 남아 있으면 보기 3개를 제시합니다. 남은 다음 행동이 없으면 `다음 행동 없음`을 명시합니다.

개별 skill이 요구하는 완료 보고 항목이 있으면 이 세 항목을 생략하지 않고 함께 보고합니다. 예를 들어 `main-branch-update-flow`의 `완료된 것/아직 안 된 것/다음 행동`, `delete-shared-runtime`의 `삭제됨/보존/위험`, `silo-runtime-handoff`의 runtime handoff 결과는 skill 고유 섹션으로 유지하되, 최종 응답 직전에는 전역 계약 체크를 먼저 수행합니다.

## User Layer 준비와 라우팅

User Layer는 workspace의 고정 `user-layer/` 디렉터리가 소유합니다. `./setup.sh --init-user-layer --workspace-root <workspace>`는 `$CODEX_HOME/AGENTS.md`, workspace AGENTS 라우터와 User Layer의 `AGENTS.md`, `feedback/{active,applied,closed}`, `update-sessions/` scaffold를 준비합니다. 기존 `$CODEX_HOME/AGENTS.md`는 백업 후 교체/삭제 후 교체/셋업 중지, 기존 `AGENTS.override.md`는 백업 후 삭제/즉시 삭제/셋업 중지 선택을 사용자에게 받으며 `--yes`도 이 파일 충돌 승인을 생략하지 않습니다. User Layer가 없으면 작업은 계속하며 공개 template fallback이나 사용자 질문 gate를 추가하지 않습니다. Feedback은 임의 경로에 만들지 않고 최종 보고에 미기록 사유를 남깁니다.

## Project Task 상태와 칸반

`projects-setup`이 생성하는 Project Work SSoT는 Task를 `todo`, `in_progress`, `blocked`, `review`, `done` 디렉터리로 나눕니다. 실제 Task의 직계 상위 디렉터리와 frontmatter `status`는 일치해야 하며, 상태 변경은 파일 이동과 `status`, `updated` 갱신을 한 변경 단위로 처리합니다. 템플릿은 `30-work-items/tasks/_templates/TASK-template.md`에 둡니다.

`00-dashboard/kanban.md`는 다섯 상태 열을 표시하는 읽기 전용 DataviewJS 칸반입니다. 별도 Kanban 플러그인을 요구하지 않으며, 상세 필터와 Obsidian Base 뷰는 기존 `work-filter.md`, `work-items.base`, `work-views.md`를 사용합니다. 경로와 status 일치는 `ruby system/20-skills/projects-setup/scripts/validate-task-status-paths.rb <tasks-directory>`로 검증합니다.

## repo-local skill 목록

아래 목록은 source repo의 `system/20-skills/*/SKILL.md` 기준 repo-local skill 목록입니다. 공개 export 산출물의 skill 목록과 1:1로 같다고 보지 않습니다. 공개 export workflow는 `system/config/public-export-manifest.example.yaml`의 제외 기준과 public-stage 후처리를 함께 적용하며, 공개할 수 없는 runtime 의존 skill은 디렉토리와 README 인덱스 행을 함께 제거합니다. public-stage에 내부 프로젝트 식별 문자열이나 secret-like 값이 남으면 export가 실패합니다.

- [`main-branch-update-flow`](main-branch-update-flow/SKILL.md): 공통 SSoT, 프롬프트, `AGENTS.md`, skill 초안 변경을 0계층 작업 브랜치와 PR로만 반영할 때 사용합니다. 목표 모델은 `main-v3/{taskname}` 작업 브랜치와 `main-v3/main` 대상 PR이며, 현재 호환 상태에서는 `main-v3/{taskname}` 작업 브랜치와 `main-v3/main` 대상 PR을 사용합니다. PR 생성 후 Codex review 설정이 동작하면 `codex-pr-review-loop`로 최신 head 리뷰를 관리하고, Codex review 설정 없음/권한 없음이 명시적으로 확인되면 `Codex review 미설정` 근거를 기록한 뒤 review loop를 생략합니다. 완료 보고는 skill 고유 항목과 함께 `사용한 스킬`, `현재 워크트리`, `다음 행동` 또는 `다음 행동 없음`을 포함합니다.
- [`codex-pr-review-loop`](codex-pr-review-loop/SKILL.md): Codex 최신 head 리뷰를 관리할 때 사용합니다. 일반 task summary는 pass 증거가 아니지만 exact phrase와 최신 head reviewed commit을 가진 명시적 no-finding comment는 exact pass 후보입니다. issue comment actionable finding도 수집하며 네 evidence 표면을 안정화 재조회한 뒤 통과를 확정합니다.
- [`silo-runtime-handoff`](silo-runtime-handoff/SKILL.md): 사일로 PR이 codex-review pass를 통과했거나 Codex review 설정 없음/권한 없음이 명시적으로 확인되어 review loop를 생략했고, 실제 제품 코드 파일 변경과 runtime/E2E 확인이 함께 있을 때 사용자 재리뷰를 호출하기 전에 runtime, 서버 주소, E2E 확인 절차, 실행 불가 사유를 PR 댓글로 남길 때 사용합니다. handoff는 `shared-runtime-health-check` 결과와 2계층 Project Work SSoT의 Run Set/Runtime Set/runbook/handoff, `silo-runtime.env`, `silo-projects.yaml`, `shared-runtime-registry.yaml` 기준으로 shared BE/API, Docker DB, FE/harness, worker, mock service가 준비됐는지 확인하며, 필요한 runtime이 꺼져 있으면 E2E 가능으로 쓰지 않습니다.
- [`main-v3-pr-scope-gate`](main-v3-pr-scope-gate/SKILL.md): `main-v3/main` 대상 PR 제안, push, PR 생성 전 diff path와 브랜치명을 0계층 공통 변경, 1계층 Project SSoT 원문, 2계층 Project Work SSoT 원문, 3계층 local/silo 자료로 분류해 project SSoT 원문이나 `sources/`, `silos/`, `shared-runtime/` 같은 local/silo 자료가 섞였는지 확인할 때 사용합니다.
- [`project-contract-gate`](project-contract-gate/SKILL.md): task 작성 전에 기존 요구사항 또는 자연어 앱 설명을 바탕으로 project contract와 1계층 기능/사용자 흐름별 요구사항을 구체화할 때 사용합니다. 자연어 제품 구체화와 기능별 추론/번호 질의응답의 2단계로 진행하고, 충분히 닫히기 전에는 task를 만들지 않습니다. gate 결과 중 project-level 요구사항/decision은 1계층에 두고, 단일 task 준비 상태와 구현용 issue/task/QA/runbook 원문은 2계층 Project Work SSoT로 내립니다.
- [`root-layer-manager`](root-layer-manager/SKILL.md): 정보가 0~3계층 중 어디에 속하는지 판단하거나, 1계층 User SSoT 실제 상태와 0계층 schema/template/setup/라우팅 규칙을 분리하거나, 프로젝트 contract/decision/ADR 같은 1계층 기준 정보와 task/issue/QA/runbook/coverage/dashboard/source doc 같은 2계층 Project Work SSoT 원문을 쓰기 전에 사용합니다. User Layer 사건은 `요청 목적 → 산출물 의미와 소유 계층 → Git 추적 branch와 checkout 계층 → runtime 물리 경로` 순으로 판정하며, 프로젝트 자료는 실제 Project SSoT 위치, Project Work SSoT 위치, 목표 기준 `project-{projectName}/main` 브랜치, 목표 작업 `project-{projectName}/{taskname}` 브랜치, 현재 호환 `project-{projectName}`/`project-{projectName}-{taskname}` 브랜치, task 번호 registry를 확인합니다.
- [`github-project-intake`](github-project-intake/SKILL.md): GitHub 계정, organization, repo URL, 로컬 clone 경로를 바탕으로 project-level portfolio/evidence 요약이나 project SSoT에 쓸 프로젝트 후보와 근거를 수집하고, 적용/보류/영구제외 및 FE/BE/support repo 묶음을 정리할 때 사용합니다. portfolio를 별도 계층으로 만들지 않고, 프로젝트에 연결되는 요약/색인은 1계층 Project SSoT에 두며 PR/commit/code path 원문, 캡처, 테스트 evidence는 2계층 Project Work SSoT, 3계층 사일로/로컬 evidence, PR 본문, 또는 외부 evidence 위치로 내립니다.
- [`add-shared-runtime`](add-shared-runtime/SKILL.md): 여러 task silo가 함께 참조하는 프로젝트별 shared runtime set을 등록하거나 준비할 때 사용합니다.
- [`delete-shared-runtime`](delete-shared-runtime/SKILL.md): shared runtime registry/status 정리, archived 표시, 명시 승인된 runtime checkout 제거가 필요할 때 사용합니다.
- [`add-dict`](add-dict/SKILL.md): 용어 추가, dict 정리, PR 본문 용어 점검, dictionary 변경이 필요할 때 사용합니다.
- [`user-personality-adaptive-response`](user-personality-adaptive-response/SKILL.md): 사용자가 선택지, 보고 방식, 승인 경계, skill 사용 누락, 현재 워크트리 누락, 톤이 맞지 않는다고 지적할 때 사용합니다. 응답 계약이나 판단 방향에 영향을 준 사건은 User SSoT에 Feedback으로 남기고, 최종 응답 직전에는 `사용한 스킬`, `현재 워크트리`, `다음 행동`, `보기 밖 선택/Feedback` 계약을 체크합니다. 후보 퍼스널리티 생성과 검증은 사용자 명시 갱신 세션에서만 수행하며, Project Contract와 Project Work 실행 기준은 해당 계층으로 분리합니다.

## main-v3/main 운영
`main-v3/main`는 기존 `main`과 다른 탐색형 운영 브랜치입니다.

```text
Build -> Learn -> Spec
```

원칙:

- 완벽한 설계보다 사용 가능한 첫 결과물을 우선합니다.
- 불확실성이 남아도 합리적으로 가정하고 진행합니다.
- 질문이 필요해도 저위험 구현은 멈추지 않습니다.
- 구현 후 문제를 찾고, 그 문제를 새 spec/task/issue 후보로 승격합니다.
- secret, production, destructive action, data SSoT, 보호 브랜치 직접 수정, 법적/IP 위험은 여전히 승인 gate입니다.

리뷰 gate:

- 0계층 공통 변경 PR: 수동 `@codex review` gate를 권장합니다. 목표 대상은 `main-v3/main`, 현재 호환 대상은 `main-v3/main`입니다.
- project 계층 PR: 수동 `@codex review` gate를 권장합니다. 목표 대상은 `project-{projectName}/main`, 현재 호환 대상은 `project-{projectName}`입니다.
- Codex review 설정이 명시적으로 없는 repo 또는 organization에서는 PR review loop를 돌리지 않고, PR 본문 또는 보고에 `Codex review 미설정`을 남깁니다. 아직 확인 전인 repo는 먼저 `@codex review`를 호출해 접수 여부를 확인합니다. task 실행 결과인 사일로 PR이 실제 제품 코드 파일과 runtime/E2E 확인을 함께 포함할 때만 `shared-runtime-health-check`와 runtime handoff를 수행합니다. 문서, skill, config, project SSoT, PR 본문 템플릿만 바꾼 PR은 fallback 보고로 닫습니다.

PR을 만들 때는 먼저 변경 내용이 0계층 공통 변경인지, 1계층 Project SSoT 변경인지, 2계층 Project Work SSoT 변경인지 확인합니다. branch base는 계층 기준 브랜치이며, 목표 모델의 0계층은 `main-v3/main`, 1계층과 2계층 project 변경은 해당 `project-{projectName}/main`이 기준입니다. 현재 마이그레이션 전 호환 기준은 `main-v3/main`와 `project-{projectName}`입니다. GitHub PR target/base branch는 이 계층 판단이 반영된 최종 머지 대상입니다. project 계층 변경도 계층 메인 브랜치에 직접 커밋하지 않고, 목표 모델에서는 `project-{projectName}/{taskname}` 작업 브랜치에서 커밋한 뒤 `project-{projectName}/main` 대상 PR로 올립니다. 현재 호환 상태에서는 `project-{projectName}-{taskname}` 작업 브랜치와 `project-{projectName}` 대상 PR을 사용합니다. 두 계층이 섞이면 worktree와 브랜치를 분리해 서로 다른 PR로 올립니다. 제품 repo가 독립 git submodule commit을 pin하는 구조라면 상위 제품 repo PR의 submodule gitlink 리뷰만으로 완료 처리하지 않습니다. 변경된 각 submodule repo도 보호 브랜치 직접 커밋 없이 repo별 파생 브랜치와 별도 PR, codex-review pass 또는 동등 리뷰 gate를 먼저 거쳐야 하며, 상위 제품 repo PR은 리뷰 통과 commit의 gitlink pin과 host 연결만 검증합니다.

PR 생성 직후에는 [`codex-pr-review-loop`](codex-pr-review-loop/SKILL.md)를 사용할 수 있도록 Codex review 설정을 먼저 확인합니다. `eyes` 이후 일반 task summary로 대기를 끝내지 않되, issue comments를 계속 조회해 최신 head actionable finding이면 formal 완료 신호 전에도 즉시 분류·처리합니다. 완료 신호 뒤에는 네 evidence 표면을 최소 30초 간격으로 재조회합니다.

Codex review 설정이 명시적으로 없거나 호출 권한이 없으면 review loop를 돌리지 않습니다. 아직 확인 전인 repo는 미설정으로 단정하지 않고 먼저 `@codex review`를 호출해 `eyes` 반응 또는 Codex 응답을 확인합니다. 미설정이 확인된 경우 PR 본문 또는 보고에 `Codex review 미설정`을 남깁니다. task 실행 결과인 사일로 PR이 실제 제품 코드 파일을 바꾸고 runtime, browser, manual QA, E2E 확인이 남아 있을 때만 codex-review pass 이후 또는 Codex review 미설정 fallback에서 [`shared-runtime-health-check`](shared-runtime-health-check/SKILL.md)로 사일로 설정에 맞는 `runtime_set`과 서버형 runtime 상태를 확인한 뒤 [`silo-runtime-handoff`](silo-runtime-handoff/SKILL.md)를 사용해 서버 주소, E2E 방법, 실행 불가 사유를 PR 댓글로 남기고 사용자 재리뷰를 호출합니다. 문서, skill, config, project SSoT, PR 본문 템플릿만 바꾼 PR에는 runtime handoff를 붙이지 않고, PR URL, head SHA, 검증 결과, 남은 수동 리뷰 필요는 `codex-pr-review-loop` fallback 보고로 기록합니다. `runtime_set`이 없으면 임의로 서버를 조합하지 않고 정의 누락 또는 `add-shared-runtime` 필요를 handoff 댓글에 남깁니다. 이 handoff는 `system/config/`의 local config, 특히 `silo-runtime.env`, `silo-projects.yaml`, `shared-runtime-registry.yaml`에 따라 달라집니다. shared BE/API, Docker DB, FE/harness, worker, mock service가 E2E 전제이면 해당 runtime이 켜져 있고 health check가 통과해야 E2E 가능으로 기록합니다.

## Project SSoT / Project Work SSoT 기본값

`setup.sh` 빠른 시작은 repo의 부모 workspace에 아래 구조를 기본 생성합니다.

```text
<workspace>/
├── <projectName>/01-project-ssot/
├── <projectName>/02-project-work-ssot/
├── sources/
├── silos/
└── shared-runtime/
```

`setup.sh --create-project-ssot`은 1계층 Project SSoT 기준 정보와 2계층 Project Work SSoT 작업 표면을 함께 만듭니다. `project-overview.md`만 두지 않고 기본으로 아래 항목을 생성하거나 연결합니다.

- `../README.md`: 얇은 root index. 1계층 `01-project-ssot/`와 2계층 `02-project-work-ssot/` 위치를 안내하며, project task/issue/QA 원문은 담지 않습니다.
- `../00-secrets/README.md`: 실제 secret 값을 쓰지 않는 secret/credential 경계 안내
- `../01-project-ssot/AGENTS.md`: 기능 task 생성 전 확인하는 1계층 제품 정의, 현재 버전 목표/비목표, 핵심 사용자 플로우, 데이터 저장과 동기화 경계, repo 역할, 추정 금지 정보
- `../01-project-ssot/10-requirements/`: 기능/사용자 흐름별 1계층 요구사항 정본
- `00-layer-index/README.md`: 1~3계층 자료 위치와 소유 경계 색인
- `00-dashboard/work-filter.md`: 2계층 issue/task 상태를 종류, 상태, 레벨, 태그, 담당 사일로, 브랜치, PR, 가설/실패 이력, 날짜, 검색어로 조합하는 즉석 멀티필터
- `00-dashboard/work-items.base`: 2계층 Project Work SSoT의 Obsidian Base table view와 저장된 view. 기본 view에는 실패 이력 Task가 포함됩니다.
- `00-dashboard/work-views.md`: 2계층 작업 대시보드의 Base 사용법과 embed 안내
- `01-branch-policy/README.md`: project/source/harness 기준 브랜치와 PR target
- `10-dictionary/project-dictionary.md`: 프로젝트 용어, 고유명사, 내부 약어, 공통 승격 후보
- `30-work-items/coverage/RUN-REPORT-template.md`: 실패 이력과 재시도 흐름을 남기는 run report 템플릿
- `30-work-items/silo-template/goal.md`: 사일로 목표와 evidence 위치 기본 템플릿
- `40-runtime-sets/README.md`: runtime set 정의와 선택 우선순위
- `40-runtime-sets/runtime-resolution.md`: runtime set 우선순위 해석 기준
- `50-pr-review/README.md`: PR review gate와 test evidence 기준
- `60-feedback-update/README.md`: feedback 상태 관리
- `templates/run-report.md`: run report 복제 템플릿
- `templates/silo-goal.md`: 사일로 goal 복제 템플릿
- `templates/pr-description.md`: `system/40-pr-review-loop/06-pr-template.md`의 중앙 PR 본문 템플릿을 기준으로 생성되는 Project Work SSoT PR 본문 템플릿
- `templates/work-filter-dashboard.md`: BE/FE/ops처럼 경로별 2계층 작업 대시보드를 추가할 때 복제하는 DataviewJS 템플릿. 별도 tracked source가 아니라 `setup.sh`가 tracked `system/templates/project-ssot/00-dashboard/work-filter.md`를 target `templates/` 아래로 복사해 생성합니다.
- `.obsidian/community-plugins.json`: Dataview community plugin 기본 선언
- `.obsidian/core-plugins.json`: Obsidian 기본 plugin 구성
- `.obsidian/appearance.json`: CSS snippet 활성화 설정
- `.obsidian/snippets/readable-markdown-width.css`: Markdown 편집/미리보기 영역에 `90%` 폭을 적용하는 기본 CSS snippet

target이 이전 호환 구조인 `projects/<project-id>/...` 아래면 setup은 `.gitignore`의 `projects/` 전체 ignore를 `projects/*`로 바꾸고, 해당 Project SSoT 또는 Project Work SSoT target만 추적 가능하게 예외를 추가합니다. 새 기본 빠른 시작 구조는 repo sibling workspace에 `<projectName>/`, `sources/`, `silos/`, `shared-runtime/`을 만들므로 root repo의 `projects/` 예외 보정에 의존하지 않습니다. target 밖 sibling 경로와 target 안의 `.env`, secret 디렉터리, key/db/dump/log/media 파일은 계속 ignore합니다.

`projects-setup` 검증은 단일 `README.md` 존재 여부가 아니라 1계층 Project SSoT, 2계층 Project Work SSoT 대시보드/사일로 템플릿, local config 초안, 그리고 현재 브랜치가 요구하는 project root/secret/silo local 안내 경계를 분리해 확인합니다.

`03-silo-local/` 같은 3계층 실제 local/evidence 디렉터리는 root project scaffold 기본 생성물이 아닙니다. task 실행 중 생긴 임시 발견, 실험 로그, PR 전 판단은 별도 silo workspace, PR 본문, 또는 project별 외부 evidence 위치에 두고 반복 가능한 항목만 issue/task나 공통 규칙 후보로 승격합니다.

현재 `setup.sh --create-project-ssot` smoke 검증은 지정한 Project Work SSoT target과 sibling `01-project-ssot/` 생성물을 기준으로 합니다. project root README와 `00-secrets/README.md`는 지원 안내 파일로 생성될 수 있지만 smoke 필수 확인 대상은 아닙니다. `03-silo-local/pr-description-template.md`는 기본 생성물로 요구하지 않습니다.

`project-overview.md`는 프로젝트 설명, 운영 경계, 1계층/2계층 정본 참조 위치를 담고, 실제 Task 흐름은 2계층 `kanban.md`, 상세 issue/task 확인은 `work-filter.md` 또는 `work-views.md`에서 시작합니다. 생성되는 issue/task 템플릿은 대시보드 필터가 읽을 수 있도록 `type`, `id`, `taskID`/`taskTitle` 또는 `issueID`/`issueTitle`, `status`, `priority` 또는 `severity`, `level_target`, `updated` frontmatter를 포함합니다. Task 템플릿은 여기에 더해 `created`, `closed`, SSoT 스키마의 필수/권장 구조화 필드와 실패 이력/가설 해결 추적 필드를 기본 frontmatter로 포함합니다.

생성되는 `project-overview.md`에는 repo/source 위치, 상위 제품 repo host 역할, 기능 submodule 소유권, BE/FE submodule 경로, harness library 정책, 제품별 scenario/adapter 위치, DB 사용 여부, DB schema 정본 위치, schema 요약 위치, schema 적용 경로, API/auth/session contract 위치, harness/runtime DB 계약 위치를 적는 정본 참조 섹션을 둡니다. project-level DB schema 정본/요약/적용 경로와 반복 가능한 scenario/adapter 참조는 1계층 Project SSoT, project registry/config, 제품 repo schema 정본, 기능 submodule repo 중 실제 정본 위치를 가리키고, 단일 task seed/input/fixture/scenario 원문은 2계층 task/runbook/QA checklist 또는 3계층 evidence에 둡니다. overview에는 원문을 복사하지 않고 참조 위치만 둡니다.

생성되는 task 템플릿은 task-writer 정식 task 필수 구조, `Project Contract 확인 결과`, 파일별 대표 함수 골격형 `Pseudo Code`, `parallel_independence_contract` frontmatter, `병렬 task 독립성 계약` 본문 섹션을 포함합니다. 기능 task는 project contract 위치와 확인한 제품 정의/목표/비목표/핵심 플로우/데이터 저장과 동기화 경계/repo 역할, 누락 항목을 먼저 남깁니다. `Pseudo Code`는 실제 구현 코드가 아니라 각 파일의 대표 함수와 보조 함수가 어떤 입력/의존성을 받고 조회, 검증, 가공, 조건 분기, 반복, 저장, 반환을 어떻게 수행하는지 코드에 가깝게 작성하게 하며, 코드 식별자와 API 이름은 원문을 유지할 수 있습니다. 선언적 config, prop, default, value 한두 곳만 수정하고 별도 분기·가공·조회·저장 흐름이 없는 경우에는 `Pseudo Code`를 생략하고 대상 파일, 설정 key, 기존값 또는 누락 상태, 목표값, 회귀 검증을 변경 계약에 적게 합니다. 로직 변경이나 여러 파일 실행 흐름은 단순 config 변경으로 분류하지 않습니다. task에는 criteria별 테스트 계약, 초기 DB 목데이터와 테스트 입력 분리, 자동 검증 범위, Pre-QA Gate, 실행 불가 또는 대체 증거, 관련 repo/branch/silo, feedback/follow-up 후보, 필요한 runtime/run set, PR 본문 필수 항목을 둡니다. 병렬 task는 sibling task 완료를 Output, Acceptance Criteria, Test Plan의 전제로 삼지 않고, 개별 output은 해당 task가 독립적으로 증명할 수 있는 산출물로 제한합니다. 인증/데이터/화면/backend 의존성은 agent가 통제할 수 있는 대체 검증 경로와 실제 사용자 경로의 차이를 적고, 여러 sibling task 완료를 전제로 하는 최종 통합 E2E는 별도 QA gate, integration task, 또는 후속 project 검증으로 분리합니다. 단일 task의 화면 동작 자체가 산출물이면 E2E 또는 agent-browser acceptance를 유지합니다. 생성되는 `30-work-items/silo-template/goal.md`와 `templates/silo-goal.md`는 원본 task/issue SSoT와 2계층 Project Work SSoT 경로, Runtime Set 결정 근거, 테스트 report/window, criteria별 테스트 계약, 초기 DB 목데이터, 테스트 입력, 원본 task Output/Acceptance/Test Plan, Codex review, agent-browser 기준, PR 본문 필수 항목, Evidence 위치를 받을 수 있어야 합니다.

`work-filter.md`는 frontmatter의 `dashboardScope.paths`를 기준으로 수집 경로를 정합니다. 기본값은 `30-work-items/issues/`, `30-work-items/tasks/`이고, 같은 프로젝트 안에서 BE, FE, ops 대시보드를 나누려면 템플릿을 복제해 `dashboardTitle`과 `dashboardScope.paths`만 바꿉니다. 대시보드는 ID와 제목을 별도 컬럼으로 보여주며, 기존 `id`/`title` 문서도 호환합니다. Task 추적은 `owner_silo`, `branch`, `pr`, `promotion_status`를 보고, 가설/실패 이력은 `hypothesis_attempt_count`, `hypothesis_limit_status`, `dashboard_flags`, `had_failed_run`, `resolved_by_hypothesis`, `failed_run_count`, `resolved_attempt_no`, `latest_failed_report`, `latest_retry_report`, `blocked_reason`, `latest_resolution_summary`를 필터 또는 표시 컬럼으로 제공합니다.

DataviewJS 대시보드는 Obsidian community plugin `dataview`와 DataviewJS 허용을 전제로 합니다. scaffold는 `.obsidian/community-plugins.json`에 `dataview`를 선언하고, Obsidian Base 대체 화면인 `work-items.base`도 함께 생성합니다. Markdown 편집/미리보기 영역에 `90%` 폭을 적용하기 위해 `.obsidian/appearance.json`에서 `readable-markdown-width` CSS snippet도 기본 활성화합니다.

`projects-setup` 검증은 `setup.sh --create-project-ssot` 자동 smoke 범위와 config 등록/수동 project root 산출물 확인 범위를 분리합니다. 검증 목록을 늘릴 때는 자동 `test` 명령도 함께 늘리거나 smoke 밖 수동 확인으로 표시합니다.

## Run Set과 runtime_set

`Run Set`은 이번 실행에서 무엇을 돌릴지 정합니다.

- 대상 목록
- 제외 기준
- 순서
- execution window 크기
- 사일로 단위
- target level 또는 target goal

`runtime_set`은 그 실행을 위해 무엇이 떠 있거나 준비되어야 하는지 정합니다.

- 공용 runtime
- 사일로별 runtime
- owner
- health check
- auth/session 참조
- source workspace 정책

`run_set.required_runtime_set`은 사용할 `runtime_set.id`를 참조합니다.

## SSoT manager 역할

현재 별도 `ssot-manager` skill 이름은 없지만, 역할은 아래처럼 나뉩니다.

- root 계층 판단: `root-layer-manager`
- project 등록과 SSoT 생성: `projects-setup`
- 세션 종료, handoff, task/issue/QA/runbook/source doc 갱신: 프로젝트별 설치 skill을 우선 사용합니다. 없으면 `<workspace>/<projectName>/01-project-ssot/`와 `<workspace>/<projectName>/02-project-work-ssot/`를 먼저 확인하고, 이전 호환 구조만 있으면 `projects/<project-id>/README.md`가 가리키는 1계층 Project SSoT 운영 기준과 2계층 Project Work SSoT의 `runbook`/`handoff`/task/issue/QA 문서를 분리해 확인합니다.

프로젝트 내부 문서를 쓸 때는 제품 repo 안의 `obs/`, `.obsidian`, `docs/`, submodule, external clone을 기준 SSoT로 추정하지 않습니다. 먼저 실제 Project SSoT와 Project Work SSoT 경로를 확인합니다. 목표 모델에서 `project-{projectName}/main` 브랜치가 있으면 해당 브랜치에서 판 `project-{projectName}/{taskname}` 작업 브랜치에서만 1계층 Project SSoT 원문 또는 2계층 Project Work SSoT 원문을 작성합니다. 현재 호환 상태에서는 `project-{projectName}`와 `project-{projectName}-{taskname}`을 사용합니다. 기준 SSoT나 기준 worktree가 아닌 위치에는 새 task/issue/QA/runbook/source doc을 만들지 않습니다.

새로운 `ssot-manager` skill이 필요해지면 기존 세 역할과 겹치지 않게, “세션 종료와 SSoT 갱신을 언제 어떻게 수행하는가”를 전담하도록 추가합니다.

## 선택지 작성 방식

선택지는 사용자가 이해할 수 있는 이름으로 작성합니다.

좋은 예:

```text
1. main-v3/main 업데이트: 선택지 작성 방식을 main-v3/main SSoT에 반영합니다.
2. 현재 답변에만 임시 적용: 이번 대화에서는 적용하지만 main-v3/main SSoT에는 반영하지 않습니다.
3. 기타: 선택지 이름, 범위, 적용 위치를 사용자가 직접 지정합니다.
```

나쁜 예:

```text
1. 보기 문구 규칙 반영
2. 지금 당장 업데이트
3. 기타
```

나쁜 예는 사용자가 무엇이 바뀌는지, 어떤 절차가 실행되는지 바로 알기 어렵습니다.

이미 스킬로 고정된 절차는 매번 길게 쓰지 않습니다. 이 프로젝트에서는 `main-v3/main 업데이트`처럼 압축하고, `main` 기준 worktree, PR, 머지, rebase 절차를 제시하지 않습니다.
