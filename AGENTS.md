# New-Human Root Agent Notes

## Scope

이 저장소는 여러 프로젝트에서 재사용할 수 있는 에이전트 운영 규칙, 프롬프트, 계층 관리 skill 초안을 보관합니다.

최종 정의는 `result/`를 기준으로 봅니다.

프로젝트 내부 자료는 기본적으로 이 저장소 main에 커밋하지 않습니다. 프로젝트별 SSoT, fork, submodule, external clone, 또는 gitignore된 로컬 자료로 둡니다.

## Read Order

1. `result/README.md`
2. `result/00-system-overview/계층-구조와-관리-원칙.md`
3. `result/00-system-overview/전체-시스템-개요.md`
4. `result/10-ssot/SSoT-스키마-초안.md`
5. `result/20-agent-rules/skill-drafts/root-layer-manager/SKILL.md`
6. `result/60-final-prompts/메인-오케스트레이터-프롬프트-초안.md`

## Layer Policy

요청을 받으면 먼저 계층을 판정합니다.

```text
0계층: 공통 규칙, skill, config template, profile template, 계층 운영 방식
1계층: project 등록, fork/submodule/external clone 연결, project SSoT 위치
2계층: project 내부 issue/task/QA/decision/coverage/runbook
3계층: silo local finding, local task, 실험 로그, PR 전 임시 상태
```

저장 위치:

```text
0계층 -> result/
1계층 -> project registry/config, fork/submodule reference
2계층 -> 해당 project SSoT
3계층 -> silo local workspace, PR description
```

## Edit Policy

- `result/`에는 프로젝트 비의존 정의와 템플릿만 둡니다.
- 프로젝트 issue/task는 `result/`에 만들지 않습니다.
- 프로젝트 내부 자료는 main에 기본 커밋하지 않습니다.
- 프로젝트 자료를 이 저장소에 추가해야 하면 별도 브랜치에서만 다룹니다.
- 실제 secret, token, password, credential 값은 읽거나 기록하지 않습니다.
- `profile/*.local.md`, `config/silo-projects.yaml`, `config/*.env`는 로컬 설정으로 취급합니다.

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
