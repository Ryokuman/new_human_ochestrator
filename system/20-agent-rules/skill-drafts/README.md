# Skill 초안 사용법

이 디렉토리는 공통 운영에 쓰는 skill 초안을 보관합니다.

최종 설치 위치는 실행 환경에 따라 다를 수 있지만, 이 저장소에서는 `system/20-agent-rules/skill-drafts/`를 공통 SSoT로 봅니다. 실제 설치 후에도 동작 기준이 헷갈리면 먼저 이 README와 각 `SKILL.md`를 확인합니다.

## 사용 원칙

- 사용자가 특정 skill을 말하거나, 요청이 skill 설명과 맞으면 해당 `SKILL.md`를 먼저 읽습니다.
- skill에 절차가 이미 정의되어 있으면 보고나 선택지에서 절차 전체를 반복하지 않고 skill 이름으로 압축합니다.
- 공통 규칙, 프롬프트, `AGENTS.md`, skill 초안 변경은 `main-branch-update-flow`를 사용합니다.
- skill 초안을 추가하거나 사용법을 바꾸면 이 README의 주요 skill 표와 관련 상위 README 또는 인덱스를 함께 갱신합니다.
- README 또는 인덱스 갱신이 빠졌다면 skill 초안 변경은 완료로 보고하지 않습니다.
- 프로젝트별 실제 issue, task, QA, coverage 결과는 이 디렉토리에 복사하지 않습니다.
- 모든 사용자 대상 작성물, PR 제목, PR 본문, 커밋 메시지는 한국어로 작성합니다.

## 사용 가능한 모든 skill

아래 목록은 이 디렉토리의 `*/SKILL.md` 기준 사용 가능한 skill 초안 전체입니다.

- [`main-branch-update-flow`](main-branch-update-flow/SKILL.md): main SSoT, 공통 규칙, 프롬프트, `AGENTS.md`, skill 초안을 바꿀 때 사용합니다.
- [`root-layer-manager`](root-layer-manager/SKILL.md): 정보가 0~3계층 중 어디에 속하는지 판단해야 할 때 사용합니다.
- [`projects-setup`](projects-setup/SKILL.md): 새 프로젝트를 `projects/` 구조에 등록하거나 project SSoT와 사일로 config를 함께 셋업해야 할 때 사용합니다.
- [`add-shared-runtime`](add-shared-runtime/SKILL.md): 여러 task silo가 함께 참조하는 프로젝트별 shared runtime set을 등록하거나 준비할 때 사용합니다.
- [`shared-runtime-health-check`](shared-runtime-health-check/SKILL.md): page-lifecycle, run, E2E 실행 전 `runtime_set` 유무나 서버형 shared runtime 상태를 확인해야 할 때 사용합니다.
- [`delete-shared-runtime`](delete-shared-runtime/SKILL.md): shared runtime registry/status 정리, archived 표시, 명시 승인된 runtime checkout 제거가 필요할 때 사용합니다.
- [`command-intent-preflight`](command-intent-preflight/SKILL.md): lifecycle, run, E2E, 다건 테스트 사일로 실행 전에 실행 전제가 완성됐는지 확인해야 할 때 사용합니다.
- [`page-lifecycle-runtime-flow`](page-lifecycle-runtime-flow/SKILL.md): page-lifecycle L 채점을 위해 단일 page를 생성하고 dynavite와 agent-browser로 확인해야 할 때 사용합니다.
- [`add-dict`](add-dict/SKILL.md): 용어 추가, dict 정리, PR 본문 용어 점검, dictionary 변경이 필요할 때 사용합니다.
- [`user-personality-adaptive-response`](user-personality-adaptive-response/SKILL.md): 사용자가 선택지, 보고 방식, 승인 경계, 톤이 맞지 않는다고 지적할 때 사용합니다.

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
1. main 업데이트 스킬 활용: 선택지 작성 방식을 공통 SSoT에 반영합니다.
2. 현재 답변에만 임시 적용: 이번 대화에서는 적용하지만 main에는 반영하지 않습니다.
3. 기타: 선택지 이름, 범위, 적용 위치를 사용자가 직접 지정합니다.
```

나쁜 예:

```text
1. 보기 문구 규칙 반영
2. 지금 당장 업데이트
3. 기타
```

나쁜 예는 사용자가 무엇이 바뀌는지, 어떤 절차가 실행되는지 바로 알기 어렵습니다.

이미 스킬로 고정된 절차는 `main 기준 별도 worktree/브랜치 생성 -> PR -> 머지 확인 -> rebase`처럼 매번 길게 쓰지 않습니다. 대신 `main 업데이트 스킬 활용`처럼 압축하고, 바뀌는 대상과 결과를 분명히 적습니다.
