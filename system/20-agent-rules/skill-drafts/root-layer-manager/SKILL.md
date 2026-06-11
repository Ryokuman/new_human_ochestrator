---
name: root-layer-manager
description: 0계층 Root/Global 에이전트 운영 규칙을 적용해 요청을 0계층, 프로젝트, 프로젝트 내부, 사일로 local로 분류하고, issue/task/피드백/프로젝트 자료를 어디에 저장하거나 승격할지 판단할 때 사용합니다. 프로젝트 내부 자료를 root에 커밋할지, fork/submodule/reference로 둘지 판단할 때도 사용합니다.
---

# Root Layer Manager

## 핵심 원칙

0계층은 작업 내용을 직접 관리하지 않습니다.

0계층은 아래만 관리합니다.

- 계층 구조
- 사일로 생성 방법
- project SSoT 기본 구조 생성 방법
- 공통 YOLO 정책
- 보호 브랜치 정책
- secret/config 주입 방식
- 사용자 퍼스널리티와 전역 취향 규칙
- 공통 skill
- 프로젝트 등록/연결/분리/승격 규칙

## 계층 분류

요청을 받으면 먼저 계층을 판정합니다.

```text
0계층: 공통 규칙, skill, config template, profile template, 계층 운영 방식
1계층: project 등록, fork/submodule/external clone 연결, project SSoT 위치
2계층: project 내부 issue/task/QA/decision/coverage/runbook
3계층: silo local finding, local task, 실험 로그, PR 전 임시 상태
```

## 저장 위치

```text
0계층 -> system/
1계층 -> project registry/config, fork/submodule reference
2계층 -> 해당 project SSoT
3계층 -> silo local workspace, PR description
```

## 금지

- 0계층 `system/`에 프로젝트 issue/task를 직접 저장하지 않습니다.
- 프로젝트 내부 자료를 main에 기본 커밋하지 않습니다.
- 사일로 local finding을 PR 전 project SSoT에 바로 승격하지 않습니다.
- project SSoT를 root 문서로 덮어쓰지 않습니다.

## 프로젝트 자료 정책

프로젝트 내부 자료는 기본적으로 아래 중 하나로 연결합니다.

- fork
- `project/<project-id>` 장기 브랜치
- git submodule
- external clone
- project registry
- secret/config reference

root 저장소 main에는 공통 운영 규칙만 둡니다.

`project/*` 브랜치는 별도 fork를 만들지 않을 때 쓰는 프로젝트별 정보 보관 브랜치입니다. 이 브랜치는 root main으로 머지할 기능 브랜치가 아니며, 프로젝트별 코드 분석, repo 연결 상태, SSoT 색인, 운영 메모를 보관합니다.

`project/*` 브랜치가 최신 `main` 위로 rebase되어 있지 않아 rebase할 때는, rebase 전후로 최신 `main`에서 변경된 공통 규칙, AGENTS.md, system 문서, 프롬프트, skill 초안을 확인합니다. rebase 후에는 현재 project SSoT, task, issue, 실행 방식이 새 main 규칙과 맞지 않는 부분을 `규칙 불일치`와 `조치 후보`로 분리해 보고합니다.

프로젝트 자료를 root 저장소 main에 추가해야 한다면 `project/*` 브랜치 내용을 그대로 합치지 않습니다. 공통 운영 규칙으로 승격할 항목만 별도 main 업데이트 후보로 분리하고, PR description에 이유를 적습니다.

project SSoT의 dashboard, task format, issue format, L 기준, Obsidian Dataview 설정이 필요하면 실제 project 산출물을 root main에 커밋하지 않습니다. 대신 `system/scripts/`의 생성 스크립트나 `system/20-agent-rules/skill-drafts/`의 skill draft를 추가하고, 생성 결과는 project SSoT에 둡니다.

## 승격 판단

사일로 local finding은 PR 시점에 판단합니다.

승격 후보:

- 반복 가능한 버그
- 프로젝트 전체에 영향을 주는 문제
- 별도 task로 수행 가능한 일
- project-specific skill이 필요한 패턴
- 전역 사용자 취향이나 사일로 운영 규칙에 영향을 주는 피드백

비승격:

- 현재 PR에서 해결된 일회성 문제
- 근거 약한 추측
- 재현되지 않은 문제
- 임시 실험 로그
- 프로젝트 내부에만 의미 있는 정보를 0계층으로 올리는 경우

## 보고 형식

계층 판단을 보고할 때는 아래처럼 씁니다.

```text
판정 계층:
저장 위치:
실행 주체:
승격 필요 여부:
커밋 대상 여부:
다음 행동:
```
