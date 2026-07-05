# New Human Orchestrator Public Agent Notes

## Scope

이 공개 저장소는 여러 프로젝트에서 재사용할 수 있는 에이전트 운영 규칙, 프롬프트, repo skill, 배포 가능한 템플릿을 보관한다.

최종 정의는 `system/`을 기준으로 본다.

## Branch Policy

- 공개 배포 기준 브랜치는 `main-v3/main`이다.
- `main-v3/main`는 보호 브랜치로 보고 직접 commit/push하지 않는다.
- 공통 운영 변경은 `main-v3/<branch-name>` 형식의 작업 브랜치와 `main-v3/main` 대상 PR로 반영한다.
- 프로젝트별 내부 SSoT, secret, 로컬 evidence, task runtime 산출물은 이 공개 저장소에 포함하지 않는다.

## Layer Policy

```text
0계층: 공통 규칙, skill, config template, 역할별 agent prompt, 계층 운영 방식
1계층: project 등록, fork/submodule/external clone 연결, project SSoT 위치
2계층: project 내부 issue/task/QA/decision/coverage/runbook
3계층: silo 로컬 발견, local task, 실험 로그, PR 전 임시 상태
```

공개 저장소에는 기본적으로 0계층 공통 산출물과 공개 가능한 템플릿만 둔다.

## Edit Policy

- 문서와 보고 산출물은 한국어로 작성한다.
- 코드 식별자, 명령어, 파일명, API 이름, 외부 원문 인용은 원문을 유지할 수 있다.
- secret, token, password, credential 값은 읽거나 기록하지 않는다.
- `system/`에는 프로젝트 비의존 정의와 템플릿만 둔다.

## Skill Usage Reporting Policy

- repo skill 또는 local skill을 사용한 경우 최종 보고에 `사용한 스킬` 섹션을 포함한다.
- 도구 실행 명령과 스킬 사용은 구분한다.

## Current Worktree Reporting Policy

- git 작업을 했거나 worktree를 전환한 경우 최종 보고에 현재 worktree 경로, 브랜치, dirty 여부, upstream 대비 ahead/behind 요약을 적는다.

## Final Response Policy

- 다음 행동, 승인 단위, 진행 여부, 저장 위치, 검증 범위가 남아 있으면 보기 3개를 제시한다.
- 다음 행동이 없으면 `다음 행동 없음`을 명시한다.
