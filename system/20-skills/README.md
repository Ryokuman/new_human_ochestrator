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
- [`root-layer-manager`](root-layer-manager/SKILL.md): 정보가 0~3계층 중 어디에 속하는지 판단해야 할 때 사용합니다.
- [`projects-setup`](projects-setup/SKILL.md): 새 프로젝트를 `projects/` 구조에 등록하거나 project SSoT와 사일로 config를 함께 셋업해야 할 때 사용합니다.
- [`add-shared-runtime`](add-shared-runtime/SKILL.md): 여러 task silo가 함께 참조하는 프로젝트별 shared runtime set을 등록하거나 준비할 때 사용합니다.
- [`shared-runtime-health-check`](shared-runtime-health-check/SKILL.md): page-lifecycle, run, E2E 실행 전 `runtime_set` 유무나 서버형 shared runtime 상태를 확인해야 할 때 사용합니다.
- [`delete-shared-runtime`](delete-shared-runtime/SKILL.md): shared runtime registry/status 정리, archived 표시, 명시 승인된 runtime checkout 제거가 필요할 때 사용합니다.
- [`command-intent-preflight`](command-intent-preflight/SKILL.md): lifecycle, run, E2E, 다건 테스트 사일로 실행 전에 실행 전제가 완성됐는지 확인해야 할 때 사용합니다.
- [`page-lifecycle-runtime-flow`](page-lifecycle-runtime-flow/SKILL.md): page-lifecycle L 채점을 위해 단일 page를 생성하고 dynavite와 agent-browser로 확인해야 할 때 사용합니다.
- [`add-dict`](add-dict/SKILL.md): 용어 추가, dict 정리, PR 본문 용어 점검, dictionary 변경이 필요할 때 사용합니다.
- [`user-personality-adaptive-response`](user-personality-adaptive-response/SKILL.md): 사용자가 선택지, 보고 방식, 승인 경계, 톤이 맞지 않는다고 지적할 때 사용합니다. 응답 계약에 영향을 주는 사건은 로컬 evidence로 반드시 남기고, 장기 규칙 반영은 사용자가 원하는 주기로 여는 검토 세션에서 판단합니다.

## main-v2 운영

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

`main-v2`의 PR은 생성 직후 base branch가 `main-v2`인지 확인하고, PR 댓글로 수동 `@codex review`를 호출합니다. PR 본문에는 `Codex PR 리뷰` 항목을 두고, 호출 횟수와 결과를 기록합니다.

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
