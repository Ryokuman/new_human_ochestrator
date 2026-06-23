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
0계층: 공통 규칙, skill, config template, 역할별 agent prompt, 계층 운영 방식
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

## 계층 기준 브랜치

branch base는 먼저 계층으로 판단합니다. GitHub PR target/base branch는 이 판단 결과가 반영된 최종 머지 대상일 뿐입니다.

```text
0계층 공통 변경 -> main-v2 기준 브랜치와 main-v2 대상 PR
1계층 이상 project 변경 -> project/<project-id> 기준 브랜치, 별도 worktree의 파생 브랜치, project/<project-id> 대상 PR
```

- `project/onjump`의 SSoT, task, issue, QA, decision, coverage 같은 project 내부 변경은 `project/onjump`을 기준 브랜치로 삼되, 별도 worktree의 파생 브랜치에서 커밋하고 `project/onjump` 대상 PR로 처리합니다.
- 작업 중 공통 system update가 발견되면 그 변경만 `main-v2` 기준 worktree와 브랜치로 분리합니다.
- 하나의 브랜치에 0계층 변경과 project 변경이 섞이면 계층별 커밋을 분리하고, 서로 다른 PR로 제출합니다.
- 0계층 PR이 `main-v2`에 머지되면 관련 `project/<project-id>` 브랜치와 진행 중인 project 작업 브랜치를 최신 `main-v2` 위로 rebase한 뒤 project 작업을 이어갑니다.

## Project SSoT 쓰기 전 확인

프로젝트 내부 task, issue, QA, decision, dashboard, source doc을 새로 만들거나 크게 수정하기 전에는 실제 저장 위치를 추정하지 않습니다.

아래 순서로 기준 SSoT와 기준 worktree를 먼저 확인합니다.

1. `projects/<project-id>/README.md`
2. README에 선언된 project SSoT 경로
3. 선언이 없으면 기본 scaffold인 `projects/<project-id>/02-project-internal/README.md`
4. project dashboard는 기본값 `projects/<project-id>/02-project-internal/00-dashboard/project-overview.md`
5. task 작성이면 실제 project SSoT 아래 `30-tasks/`와 task registry 또는 기존 task 목록
6. issue/QA/decision 작성이면 실제 project SSoT 아래 해당 index 또는 README
7. `project/<project-id>` 브랜치가 존재하는지 확인합니다.
8. `project/<project-id>` 브랜치가 있으면 해당 브랜치에서 판 별도 worktree의 파생 브랜치가 현재 작업 기준인지 확인합니다.

확인 결과와 다른 위치가 보이면 아래처럼 처리합니다.

- 제품 repo 내부 `obs/`, `.obsidian`, `docs/`, submodule, external clone, 오래된 vault가 있어도 기준 SSoT라고 추정하지 않습니다.
- 기준 SSoT가 아닌 제품 repo 내부 `obs/`, `.obsidian`, `docs/`, submodule, external clone, 오래된 vault에는 새 project task, issue, QA, dashboard, source doc, project handoff를 만들지 않습니다.
- `project/<project-id>` 브랜치가 있는데 현재 브랜치가 `docs/*`, `chore/*`, `silo/*`, 또는 `main-v2` 파생 공통 규칙 브랜치라면 project SSoT 원문을 직접 쓰지 않습니다.
- 현재 브랜치에 project SSoT diff가 이미 있으면 기준 worktree로 이어 쓰지 않고 `기준 아님`, `이관 후보`, `위험`, `사용자 판단 필요`로 분리해 보고합니다.
- `main-v2` 대상 PR을 제안하거나 생성하려는 순간에는 [`main-v2-pr-scope-gate`](../main-v2-pr-scope-gate/SKILL.md)를 먼저 적용합니다. project SSoT 원문이 diff에 있으면 PR 제안을 중단합니다.
- project 작업 브랜치에서 `main-v2` 대상 공통 승격 후보가 생기면 project SSoT 원문과 함께 PR로 올리지 않고, 0계층 변경만 별도 worktree로 분리합니다.
- 단, 3계층 task silo의 `goal.md`, 실행 보고, handoff, PR 본문은 PR 전 임시 상태와 evidence로 허용합니다.
- 후보 위치가 둘 이상이면 쓰기 전에 `기준 SSoT`, `기준 아님`, `위험`, `사용자 판단 필요`로 분리해 보고합니다.
- task 번호는 실제 project SSoT의 task registry가 있으면 먼저 확인하고, 없으면 기존 task 파일과 README/index를 확인한 뒤 비어 있는 번호만 사용합니다.
- 번호가 superseded, candidate, done, draft PR 본문에서 이미 쓰였으면 새 task 번호로 재배정하고 registry에 이유를 남깁니다.

## 금지

- 0계층 `system/`에 프로젝트 issue/task를 직접 저장하지 않습니다.
- 프로젝트 내부 자료를 root `main-v2`에 기본 커밋하지 않습니다.
- 사일로 local finding을 PR 전 project SSoT에 바로 승격하지 않습니다.
- project SSoT를 root 문서로 덮어쓰지 않습니다.
- 기준 SSoT 확인 없이 제품 repo 내부 `obs/` 또는 submodule에 프로젝트 task/issue/QA를 작성하지 않습니다.
- `project/<project-id>` 브랜치가 있는 프로젝트의 task/issue/QA/decision/dashboard/source doc 원문을 `docs/*`, `chore/*`, `silo/*`, 또는 `main-v2` 파생 공통 규칙 브랜치에서 직접 작성하지 않습니다.
- project SSoT 원문이 포함된 브랜치를 `main-v2` 대상 PR로 제안하지 않습니다.

## 프로젝트 자료 정책

프로젝트 내부 자료는 기본적으로 아래 중 하나로 연결합니다.

- fork
- `project/<project-id>` 장기 브랜치
- git submodule
- external clone
- project registry
- secret/config reference

root 저장소 `main-v2`에는 공통 운영 규칙만 둡니다.

`project/*` 브랜치는 별도 fork를 만들지 않을 때 쓰는 프로젝트별 정보 보관 브랜치입니다. 이 브랜치는 root `main-v2`로 머지할 기능 브랜치가 아니며, 프로젝트별 코드 분석, repo 연결 상태, SSoT 색인, 운영 메모를 보관합니다.

프로젝트 내부 task, issue, QA, decision, dashboard, source doc처럼 2계층 project SSoT를 생성하거나 수정하는 작업은 해당 project의 `project/<project-id>`에서 판 별도 worktree의 파생 브랜치에서만 수행합니다. `project/<project-id>` 장기 브랜치에는 직접 커밋하지 않습니다. 공통 템플릿, scaffold 로직, repo skill, agent prompt처럼 0계층 규칙 자체를 수정하는 작업은 `main-v2` 파생 단기 브랜치에서 수행합니다.

`project/*` 브랜치가 최신 `main-v2` 위로 rebase되어 있지 않아 rebase할 때는, rebase 전후로 최신 `main-v2`에서 변경된 공통 규칙, AGENTS.md, system 문서, 프롬프트, skill 초안을 확인합니다. rebase 후에는 현재 project SSoT, task, issue, 실행 방식이 새 `main-v2` 규칙과 맞지 않는 부분을 `규칙 불일치`와 `조치 후보`로 분리해 보고합니다.

프로젝트 자료를 root 저장소 `main-v2`에 추가해야 한다면 `project/*` 브랜치 내용을 그대로 합치지 않습니다. 공통 운영 규칙으로 승격할 항목만 별도 `main-v2` 업데이트 후보로 분리하고, PR description에 이유를 적습니다.

project SSoT의 dashboard, task format, issue format, L 기준이 필요하면 실제 project 산출물을 root `main-v2`에 커밋하지 않습니다. 대신 `setup.sh` 셋업 흐름이나 `system/20-skills/`의 repo skill을 추가하고, 생성 결과는 project SSoT에 둡니다.

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
