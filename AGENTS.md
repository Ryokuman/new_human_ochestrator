# New-Human Root Agent Notes

## Scope

이 저장소는 여러 프로젝트에서 재사용할 수 있는 에이전트 운영 규칙, 프롬프트, 계층 관리 skill 초안을 보관합니다.

최종 정의는 `system/`을 기준으로 봅니다.

프로젝트 내부 자료는 기본적으로 이 저장소 main에 커밋하지 않습니다. 프로젝트별 SSoT, fork, submodule, external clone, 또는 gitignore된 로컬 자료로 둡니다.

## Read Order

1. `system/README.md`
2. `system/00-system-overview/계층-구조와-관리-원칙.md`
3. `system/00-system-overview/전체-시스템-개요.md`
4. `system/10-ssot/SSoT-스키마-초안.md`
5. `system/20-agent-rules/skill-drafts/root-layer-manager/SKILL.md`
6. `system/20-agent-rules/references/agent-md-reinforcement-guide.md`
7. `system/60-final-prompts/메인-오케스트레이터-프롬프트-초안.md`

## Layer Policy

요청을 받으면 먼저 계층을 판정합니다.

```text
0계층: 공통 규칙, skill, config template, profile template, 계층 운영 방식
1계층: project 등록, fork/submodule/external clone 연결, project SSoT 위치
2계층: project 내부 issue/task/QA/decision/coverage/runbook
3계층: silo 로컬 발견, local task, 실험 로그, PR 전 임시 상태
```

저장 위치:

```text
0계층 -> system/
1계층 -> project registry/config, fork/submodule reference
2계층 -> 해당 project SSoT
3계층 -> silo local workspace, PR 본문
```

## Reference Policy

에이전트 md, AGENTS.md, CLAUDE.md, 프롬프트, skill 초안이 빈약하다는 피드백을 받으면 바로 새 규칙을 상상해서 추가하지 않습니다.

먼저 `system/20-agent-rules/references/`를 사용합니다.

- 프로젝트 맥락이 부족하면 `project-context-reference-template.md` 기준으로 기존 프로젝트 운영 패턴을 정리합니다.
- PR 리뷰 기준이 부족하면 `pr-review-reference-template.md` 기준으로 반복 피드백을 정리합니다.
- 보고 방식이나 퍼스널리티 판단이 부족하면 `reporting-and-personality-reference-template.md` 기준으로 관찰, 해석, 승인 상태를 분리합니다.
- 보강 절차 전체가 필요하면 `agent-md-reinforcement-guide.md`를 따릅니다.

에이전트 md에는 reference 원문을 모두 넣지 않습니다. 언제 어떤 reference를 읽을지, 어떤 기준으로 장기 규칙에 반영할지만 넣습니다.

프로젝트 내부 실제 issue/task/QA 결과는 0계층에 복사하지 않고, project SSoT 위치와 반복 가능한 운영 패턴만 기록합니다.

## Edit Policy

- 모든 문서와 작성 산출물은 무조건 한국어로 작성합니다.
- 작성 산출물에는 PR 제목, PR 본문, 커밋 메시지, 보고 문구, 인수인계, task/issue 본문, 에이전트 프롬프트, 리뷰 코멘트, 사용자 대상 요약이 포함됩니다.
- 코드 식별자, 명령어, 파일명, API 이름, 외부 원문 인용처럼 원문 유지가 필요한 경우만 영어를 허용합니다.
- `system/`에는 프로젝트 비의존 정의와 템플릿만 둡니다.
- 프로젝트 issue/task는 `system/`에 만들지 않습니다.
- 프로젝트 내부 자료는 main에 기본 커밋하지 않습니다.
- 프로젝트 자료를 이 저장소에 추가해야 하면 별도 브랜치에서만 다룹니다.
- 실제 secret, token, password, credential 값은 읽거나 기록하지 않습니다.
- `profile/*.local.md`, `config/silo-projects.yaml`, `config/*.env`는 로컬 설정으로 취급합니다.

## Personality Option Policy

- 옵션 정책은 퍼스널리티 전용 정책이 아니라 모든 대화의 기본 선택지 제시 정책입니다.
- 사용자의 다음 행동, 승인 단위, 진행 여부, 저장 위치, 범위, 검증 범위가 걸린 응답에서는 항상 보기 3개를 제시합니다.
- 에이전트가 "진행하겠습니다", "수정하겠습니다", "반영하겠습니다"처럼 다음 행동을 확정하려는 경우에도 보기 없이 단정하지 않습니다.
- 기본 보기는 `1. 승인`, `2. 거절`, `3. 기타`를 기준으로 하되, 현재 목표와 승인 경계에 맞게 더 구체화할 수 있습니다.
- 보기 3개는 현재 목표, 기존 퍼스널리티/취향 규칙, 승인 경계를 기준으로 만듭니다.
- 사용자가 보기 1~3 중 하나를 고르지 않고 직접 답변하면, 해당 답변은 "보기 밖 선택"으로 보고 퍼스널리티 업데이트 후보 신호로 남깁니다.
- 답변이 끝난 뒤 필요한 경우 `user-personality-adaptive-response` 스킬을 사용하여 백그라운드 에이전트로 퍼스널리티 업데이트 보고서를 작성한다고 보고합니다.
- 퍼스널리티 업데이트 보고서는 후보 자료이며, 실제 프로필, 공통 규칙, 또는 관련 skill 초안 반영은 사용자 승인 후에만 실행합니다.
- 승인되지 않은 단일 응답은 장기 퍼스널리티 규칙으로 확정하지 않습니다.

## Reporting

보고할 때는 아래를 분리합니다.

```text
완료된 것
아직 안 된 것
목표 밖 산출물
SSoT 승격 후보
승격하지 않을 항목
다음 행동
```
