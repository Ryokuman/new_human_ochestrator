# Repo Skill 사용법

이 디렉토리는 이 저장소가 직접 제공하는 repo skill을 보관합니다.

최종 설치 위치는 실행 환경에 따라 다를 수 있지만, 이 저장소에서는 `system/20-skills/`를 repo skill의 공통 SSoT로 봅니다. 실제 설치 후에도 동작 기준이 헷갈리면 먼저 이 README와 각 `SKILL.md`를 확인합니다.

## 사용 원칙

- 사용자가 특정 skill을 말하거나, 요청이 skill 설명과 맞으면 해당 `SKILL.md`를 먼저 읽습니다.
- skill에 절차가 이미 정의되어 있으면 보고나 선택지에서 절차 전체를 반복하지 않고 skill 이름으로 압축합니다.
- 공통 규칙, 프롬프트, `AGENTS.md`, repo skill 변경은 `main-v2` 기준으로만 처리합니다.
- 이 프로젝트에서는 기존 `main` 업데이트 절차를 실행하지 않습니다. `main-v2`에서 branch-local 탐색형 운영 변경으로 처리하고, `main`에는 반영하지 않습니다.
- repo skill을 추가하거나 사용법을 바꾸면 이 README의 주요 skill 표와 관련 상위 README 또는 인덱스를 함께 갱신합니다.
- README 또는 인덱스 갱신이 빠졌다면 repo skill 변경은 완료로 보고하지 않습니다.
- 프로젝트별 실제 issue, task, QA, coverage 결과는 이 디렉토리에 복사하지 않습니다.
- 모든 사용자 대상 작성물, PR 제목, PR 본문, 커밋 메시지는 한국어로 작성합니다.

## 사용 가능한 모든 skill

아래 목록은 이 디렉토리의 `*/SKILL.md` 기준 사용 가능한 repo skill 전체입니다.

- [`main-branch-update-flow`](main-branch-update-flow/SKILL.md): 공통 SSoT, 프롬프트, `AGENTS.md`, skill 초안 변경을 `main-v2` 파생 브랜치와 PR로만 반영할 때 사용합니다.
- [`main-v2-pr-scope-gate`](main-v2-pr-scope-gate/SKILL.md): `main-v2` 대상 PR 제안, push, PR 생성 전 diff path와 브랜치명을 계층별로 분류해 project SSoT 원문이나 local/silo 자료가 섞였는지 확인할 때 사용합니다.
- [`root-layer-manager`](root-layer-manager/SKILL.md): 정보가 0~3계층 중 어디에 속하는지 판단하거나, 프로젝트 task/issue/QA/decision/dashboard/source doc을 쓰기 전에 실제 project SSoT 위치, 기준 `project/<project-id>` 브랜치/worktree, task 번호 registry를 확인해야 할 때 사용합니다.
- [`projects-setup`](projects-setup/SKILL.md): 새 프로젝트를 `projects/` 구조에 등록하거나 project SSoT와 사일로 config를 함께 셋업해야 할 때 사용합니다.
- [`add-shared-runtime`](add-shared-runtime/SKILL.md): 여러 task silo가 함께 참조하는 프로젝트별 shared runtime set을 등록하거나 준비할 때 사용합니다.
- [`shared-runtime-health-check`](shared-runtime-health-check/SKILL.md): page-lifecycle, run, E2E 실행 전 `runtime_set` 유무나 서버형 shared runtime 상태를 확인해야 할 때 사용합니다.
- [`delete-shared-runtime`](delete-shared-runtime/SKILL.md): shared runtime registry/status 정리, archived 표시, 명시 승인된 runtime checkout 제거가 필요할 때 사용합니다.
- [`command-intent-preflight`](command-intent-preflight/SKILL.md): lifecycle, run, E2E, 다건 테스트 사일로 실행 전에 실행 전제가 완성됐는지 확인해야 할 때 사용합니다.
- [`page-lifecycle-runtime-flow`](page-lifecycle-runtime-flow/SKILL.md): page-lifecycle L 채점을 위해 단일 page를 생성하고 dynavite와 agent-browser로 확인해야 할 때 사용합니다.
- [`add-dict`](add-dict/SKILL.md): 용어 추가, dict 정리, PR 본문 용어 점검, dictionary 변경이 필요할 때 사용합니다.
- [`user-personality-adaptive-response`](user-personality-adaptive-response/SKILL.md): 사용자가 선택지, 보고 방식, 승인 경계, skill 사용 누락, 현재 워크트리 누락, 톤이 맞지 않는다고 지적할 때 사용합니다. 외부 skill 목록에 보이지 않아도 repo-local `system/20-skills/`에 같은 skill이 있는지 확인합니다. 응답 계약에 영향을 주는 사건은 로컬 evidence로 반드시 남기고, 최종 응답 직전에는 `사용한 스킬`, `현재 워크트리`, `다음 행동`, `보기 밖 선택/evidence` 계약을 체크합니다. 사용자가 좁은 스코프의 처방과 판단 근거의 위치를 지적하면 system SSoT에는 판단 근거만 남기고 구체 대처는 project SSoT 또는 task 계약으로 내려보내는 evidence로 분리합니다. 장기 규칙 반영은 사용자가 원하는 주기로 여는 검토 세션에서 판단합니다.

## main-v2 운영

## Project SSoT 대시보드 기본값

`setup.sh --create-project-ssot`으로 만드는 Project SSoT는 `00-dashboard/project-overview.md`만 두지 않습니다. 기본으로 아래 작업 대시보드를 함께 생성합니다.

- `00-dashboard/work-filter.md`: 종류, 상태, 레벨, 태그, 날짜, 검색어를 조합하는 즉석 멀티필터
- `00-dashboard/work-items.base`: Obsidian Base table view와 저장된 view
- `00-dashboard/work-views.md`: Base 사용법과 embed 안내
- `templates/work-filter-dashboard.md`: BE/FE/ops처럼 경로별 작업 대시보드를 추가할 때 복제하는 DataviewJS 템플릿
- `.obsidian/snippets/readable-markdown-width.css`: Markdown 편집/미리보기 영역을 넓게 쓰는 기본 CSS snippet

`project-overview.md`는 프로젝트 설명과 운영 경계를 담고, 실제 issue/task 확인은 `work-filter.md` 또는 `work-views.md`에서 시작합니다. 생성되는 issue/task 템플릿은 대시보드 필터가 읽을 수 있도록 `type`, `id`, `taskID`/`taskTitle` 또는 `issueID`/`issueTitle`, `status`, `priority` 또는 `severity`, `updated` frontmatter를 포함합니다.

생성되는 task 템플릿은 병렬 task 독립성 계약을 포함합니다. 병렬 task는 sibling task 완료를 Output, Acceptance Criteria, Test Plan의 전제로 삼지 않고, 개별 output은 해당 task가 독립적으로 증명할 수 있는 산출물로 제한합니다. 인증/데이터/화면/backend 의존성은 agent가 통제할 수 있는 대체 검증 경로와 실제 사용자 경로의 차이를 적고, 여러 sibling task 완료를 전제로 하는 최종 통합 E2E는 별도 QA gate, integration task, 또는 후속 project 검증으로 분리합니다. 단일 task의 화면 동작 자체가 산출물이면 E2E 또는 agent-browser acceptance를 유지합니다.

`work-filter.md`는 frontmatter의 `dashboardScope.paths`를 기준으로 수집 경로를 정합니다. 기본값은 `20-issues/`, `30-tasks/`이고, 같은 프로젝트 안에서 BE, FE, ops 대시보드를 나누려면 템플릿을 복제해 `dashboardTitle`과 `dashboardScope.paths`만 바꿉니다. 대시보드는 ID와 제목을 별도 컬럼으로 보여주며, 기존 `id`/`title` 문서도 호환합니다.

DataviewJS 대시보드는 Obsidian community plugin `dataview`와 DataviewJS 허용을 전제로 합니다. scaffold는 `.obsidian/community-plugins.json`에 `dataview`를 선언하고, Obsidian Base 대체 화면인 `work-items.base`도 함께 생성합니다. Markdown 본문 폭을 넓히기 위해 `.obsidian/appearance.json`에서 `readable-markdown-width` CSS snippet도 기본 활성화합니다.

`main-v2`는 기존 `main`과 다른 탐색형 운영 브랜치입니다.

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

- `main-v2`: 수동 `@codex review` gate

`main-v2`의 PR은 생성 직후 base branch가 `main-v2`인지 확인하고, PR 댓글로 수동 `@codex review`를 호출합니다. 호출 댓글에는 가능하면 `한국어로 리뷰해 주세요.` 또는 이에 준하는 한국어 요청을 함께 적습니다. 외부 리뷰 봇의 고정 템플릿 언어까지 보장하지는 못합니다. PR 본문에는 `Codex PR 리뷰` 항목을 두고, 호출 횟수와 결과를 기록합니다. 현재 head push 이후에 작성된 최신 `@codex review` 호출 댓글에 `eyes` 반응이 있으면 리뷰가 접수 또는 진행 중인 상태로 보고 같은 head commit에 추가 호출하지 않습니다. PR 생성 이후에는 승인 리뷰 또는 actionable major/critical 및 보호 절차를 깨는 P1/P2 없음 상태가 될 때까지 수정, 검증, 재리뷰를 반복합니다. task silo의 `goal.md`가 확인되면 `/goal`을 재사용하고, 그렇지 않은 공통 문서/skill PR은 PR 본문, 리뷰 thread, 현재 사용자 요청을 재리뷰 컨텍스트로 사용합니다. 기본 중단 기준은 호출 횟수가 아니라 리뷰 결과입니다. 사용자가 이번 PR에 명시한 반복 한도가 있을 때만 그 한도를 따릅니다.

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

`Run Set.required_runtime_set`은 사용할 `runtime_set.id`를 참조합니다.

## SSoT manager 역할

현재 별도 `ssot-manager` skill 이름은 없지만, 역할은 아래처럼 나뉩니다.

- root 계층 판단: `root-layer-manager`
- project 등록과 SSoT 생성: `projects-setup`
- 세션 종료, handoff, task/issue/QA 갱신: 프로젝트별 설치 skill 또는 project SSoT의 운영 문서를 따릅니다.

프로젝트 내부 문서를 쓸 때는 제품 repo 안의 `obs/`, `.obsidian`, `docs/`, submodule, external clone을 기준 SSoT로 추정하지 않습니다. 먼저 `projects/<project-id>/README.md`에서 선언된 project SSoT 경로를 확인하고, 선언이 없으면 기본 scaffold인 `projects/<project-id>/02-project-internal/` 아래 dashboard와 task 위치를 확인합니다. `project/<project-id>` 브랜치가 있으면 해당 브랜치 또는 그 브랜치에서 판 별도 worktree에서만 project SSoT 원문을 작성합니다. 기준 SSoT나 기준 worktree가 아닌 위치에는 새 task/issue/QA/source doc을 만들지 않습니다.

새로운 `ssot-manager` skill이 필요해지면 기존 세 역할과 겹치지 않게, “세션 종료와 SSoT 갱신을 언제 어떻게 수행하는가”를 전담하도록 추가합니다.

## 선택지 작성 방식

선택지는 사용자가 이해할 수 있는 이름으로 작성합니다.

좋은 예:

```text
1. main-v2 업데이트: 선택지 작성 방식을 main-v2 SSoT에 반영합니다.
2. 현재 답변에만 임시 적용: 이번 대화에서는 적용하지만 main-v2 SSoT에는 반영하지 않습니다.
3. 기타: 선택지 이름, 범위, 적용 위치를 사용자가 직접 지정합니다.
```

나쁜 예:

```text
1. 보기 문구 규칙 반영
2. 지금 당장 업데이트
3. 기타
```

나쁜 예는 사용자가 무엇이 바뀌는지, 어떤 절차가 실행되는지 바로 알기 어렵습니다.

이미 스킬로 고정된 절차는 매번 길게 쓰지 않습니다. 이 프로젝트에서는 `main-v2 업데이트`처럼 압축하고, `main` 기준 worktree, PR, 머지, rebase 절차를 제시하지 않습니다.
