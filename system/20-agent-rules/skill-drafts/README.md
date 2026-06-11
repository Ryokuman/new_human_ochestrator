# Skill 초안 사용법

이 디렉토리는 공통 운영에 쓰는 skill 초안을 보관합니다.

최종 설치 위치는 실행 환경에 따라 다를 수 있지만, 이 저장소에서는 `system/20-agent-rules/skill-drafts/`를 공통 SSoT로 봅니다. 실제 설치 후에도 동작 기준이 헷갈리면 먼저 이 README와 각 `SKILL.md`를 확인합니다.

## 사용 원칙

- 사용자가 특정 skill을 말하거나, 요청이 skill 설명과 맞으면 해당 `SKILL.md`를 먼저 읽습니다.
- skill에 절차가 이미 정의되어 있으면 보고나 선택지에서 절차 전체를 반복하지 않고 skill 이름으로 압축합니다.
- 공통 규칙, 프롬프트, `AGENTS.md`, skill 초안 변경은 `main-branch-update-flow`를 사용합니다.
- 프로젝트별 실제 issue, task, QA, coverage 결과는 이 디렉토리에 복사하지 않습니다.
- 모든 사용자 대상 작성물, PR 제목, PR 본문, 커밋 메시지는 한국어로 작성합니다.

## 주요 skill

| skill | 사용할 때 | 사용법 |
|---|---|---|
| `main-branch-update-flow` | main SSoT, 공통 규칙, 프롬프트, `AGENTS.md`, skill 초안을 바꿀 때 | main 업데이트 스킬을 활용한다고 보고한 뒤, 별도 main 작업 브랜치에서 수정하고 PR로 반영합니다. |
| `root-layer-manager` | 정보가 0~3계층 중 어디에 속하는지 판단해야 할 때 | 프로젝트 내부 자료를 root main에 올릴지 말지 판단하기 전에 계층을 판정합니다. |
| `projects-setup` | 새 프로젝트를 `projects/` 구조에 등록하거나 project SSoT와 사일로 config를 함께 셋업해야 할 때 | `projects/<project-id>/` 기본 구조, Dataview 포함 project SSoT, `system/config/silo-projects.yaml` 등록을 함께 처리합니다. |
| `user-personality-adaptive-response` | 사용자가 선택지, 보고 방식, 승인 경계, 톤이 맞지 않는다고 지적할 때 | 피드백을 관찰/해석/후보 규칙으로 분리하고, 승인 전에는 장기 규칙으로 확정하지 않습니다. |

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
