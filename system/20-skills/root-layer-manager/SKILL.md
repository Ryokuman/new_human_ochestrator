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
- Project SSoT와 Project Work SSoT 기본 구조 생성 방법
- 공통 YOLO 정책
- 보호 브랜치 정책
- secret/config 주입 방식
- User Layer schema, template, setup, 라우팅과 public guard
- 승인된 반복 사용자 기준의 공통 승격 규칙
- 공통 skill
- 프로젝트 등록/연결/분리/승격 규칙

## 계층 분류

요청을 받으면 먼저 계층을 판정합니다.

```text
0계층: 공통 규칙, skill, config template, 역할별 agent prompt, 계층 운영 방식
1계층 User SSoT: 사용자별 유저 퍼스널리티, Feedback, 갱신 세션
1계층 Project SSoT: `project-registry.md`의 project 등록과 repo/source 위치, Project AGENTS의 project contract, `10-requirements/`의 기능/사용자 흐름별 요구사항과 runtime/DB/API/auth 계약, `50-decisions/`의 decision/ADR, project-level 운영 기준, 2계층 위치 index
2계층: Project Work SSoT. 1계층 요구사항을 구현하기 위한 project 내부 issue/task/QA/runbook/coverage/handoff
3계층: silo local finding, 사용자 승인 전 `<workspace>/local/<작업명>/` 검수 초안, local task, 실험 로그, PR 전 임시 상태
```

## 저장 위치

```text
0계층 -> system/
1계층 User -> workspace의 `user-layer/` User SSoT 디렉터리
1계층 Project -> Project SSoT, project registry/config, fork/submodule reference
2계층 -> 해당 Project Work SSoT
3계층 -> `<workspace>/local/<작업명>/`, silo local workspace, PR description
```

## User Layer 판정 순서

User Layer 관련 요청은 파일 경로나 `user-layer`라는 용어부터 해석하지 않고 아래 순서로 판정합니다.

1. **요청 목적**: 실제 사용자 판단 기준이나 Feedback을 갱신하려는지, User Layer를 다루는 공통 System 룰을 수정하려는지, 저장·PR 위치를 조사하려는지 먼저 구분합니다. System 룰 수정이 목적이면 실제 퍼스널리티 갱신 세션으로 바꾸지 않습니다.
2. **산출물 의미와 소유 계층**: 실제 유저 퍼스널리티·Feedback·갱신 세션은 1계층 User SSoT가 소유하고, schema·template·setup·라우팅·public guard는 0계층이 소유합니다.
3. **Git 추적 branch와 checkout 계층**: 파일이 어떤 Git branch와 checkout 계층에서 추적되는지 확인합니다. project 계층 checkout의 루트 `user-layer/`는 1계층 산출물일 수 있으므로 경로만 보고 0계층 산출물로 단정하지 않습니다.
4. **runtime 물리 경로**: `$CODEX_HOME/AGENTS.md`, workspace `AGENTS.md`, setup의 workspace root를 확인해 실제 runtime 정본을 찾습니다. 물리 경로는 앞선 목적·의미·추적 계층 판정을 뒤집는 단독 근거가 아닙니다.

금지선:

- `user-layer`라는 단어만으로 퍼스널리티 갱신을 시작하지 않습니다.
- 물리 경로 또는 `.git` 유무만으로 저장·PR 위치를 확정하지 않습니다.
- project 계층 checkout의 루트 `user-layer/`를 0계층 산출물로 자동 판정하지 않습니다.
- 대상 Feedback을 읽기 전에 승격 목적을 추정하지 않습니다.
- 신호가 충돌하면 새 저장소나 정본 위치를 상상하지 않고 확인 가능한 네 판단 축을 먼저 대조합니다. 그래도 소유권이 닫히지 않을 때만 `사용자 판단 필요`로 보고합니다.

## 계층 기준 브랜치

branch base는 먼저 계층으로 판단합니다. GitHub PR target/base branch는 이 판단 결과가 반영된 최종 머지 대상일 뿐입니다.

```text
0계층 공통 변경 -> 목표 계층 메인 브랜치 `main-v3/main`, 작업 브랜치 `main-v3/{taskname}`, main-v3/main 대상 PR
1계층 이상 project 변경 -> 목표 계층 메인 브랜치 `project-{projectName}/main`, 작업 브랜치 `project-{projectName}/{taskname}`, project-{projectName}/main 대상 PR
```

- 목표 Project SSoT 계층 메인 브랜치 모델은 `project-{projectName}/main`입니다. 기존 slash 기반 `project/<project-id>` 브랜치 모델은 전환/호환 필요 항목으로 보고, 이미 존재하는 브랜치나 PR 링크는 기준성을 먼저 확인합니다.
- `main-v3`나 `project-{projectName}` 자체는 브랜치로 만들지 않습니다. 이 이름들은 Git ref namespace입니다.
- Git ref namespace에서는 `main-v3/main` 브랜치가 존재하면 `main-v3/main/{taskname}`을 만들 수 없습니다. 따라서 0계층 작업 브랜치 `main-v3/{taskname}`는 dash 형식이 아니라 slash namespace 형식입니다. project 작업 브랜치는 목표 모델에서 `project-{projectName}/{taskname}` slash namespace 형식을 쓰고, 마이그레이션 전 현재 호환 상태에서만 `project-{projectName}-{taskname}` dash 형식을 사용합니다.
- 특정 project의 Project SSoT, Project Work SSoT, task, issue, QA, runbook, coverage 같은 project 내부 변경은 목표 모델에서 `project-{projectName}/main`을 기준 브랜치로 삼되, `project-{projectName}/<branch-name>` 작업 브랜치에서 커밋하고 `project-{projectName}/main` 대상 PR로 처리합니다. 마이그레이션 전 호환 상태에서는 `project-{projectName}`와 `project-{projectName}-<branch-name>`을 사용합니다.
- 작업 중 공통 system update가 발견되면 그 변경만 목표 모델에서는 `main-v3/{taskname}`, 현재 호환 상태에서는 `main-v3/{taskname}` 작업 브랜치와 worktree로 분리합니다.
- 하나의 브랜치에 0계층 변경과 project 변경이 섞이면 계층별 커밋을 분리하고, 서로 다른 PR로 제출합니다.
- 0계층 PR이 계층 메인 브랜치에 머지되면 관련 project 계층 메인 브랜치와 진행 중인 project 작업 브랜치를 최신 0계층 메인 위로 rebase한 뒤 project 작업을 이어갑니다. 현재 호환 기준은 `main-v3/main`, 목표 모델 기준은 `main-v3/main`입니다.

## Project SSoT 쓰기 전 확인

프로젝트 내부 task, issue, QA, runbook, coverage, dashboard, source doc을 새로 만들거나 크게 수정하기 전에는 실제 저장 위치를 추정하지 않습니다. project contract, 기능/사용자 흐름별 요구사항, decision/ADR은 1계층 Project SSoT 기준 정보로 보고, 그 요구사항을 구현하기 위한 task/issue/QA/runbook/coverage는 2계층 Project Work SSoT로 분리합니다.

아래 순서로 기준 SSoT와 기준 worktree를 먼저 확인합니다.

1. `<workspace>/<projectName>/01-project-ssot/`와 `<workspace>/<projectName>/02-project-work-ssot/`가 있는지 확인합니다.
2. Project SSoT의 project contract, 기능/사용자 흐름별 요구사항, decision/ADR, 2계층 위치 index를 확인합니다.
3. 이전 호환 구조만 있으면 `projects/<project-id>/README.md`를 확인합니다.
4. README에 선언된 Project SSoT 경로 또는 호환 scaffold인 `projects/<project-id>/02-project-internal/README.md`를 확인합니다.
5. project dashboard는 2계층 Project Work SSoT의 작업 대시보드 위치를 확인합니다.
6. task 작성이면 실제 Project Work SSoT 아래 `30-work-items/tasks/`와 task registry 또는 기존 task 목록
7. issue/QA/runbook/coverage 작성이면 실제 Project Work SSoT 아래 해당 index 또는 README
8. 목표 모델의 `project-{projectName}/main` 브랜치가 존재하는지 확인합니다.
9. 마이그레이션 전 호환 `project-{projectName}` 또는 기존 slash 기반 `project/<project-id>` 브랜치가 있으면 전환/호환 상태와 기준성을 확인합니다.
10. 기준 project 브랜치가 있으면 목표 모델의 `project-{projectName}/{taskname}` 또는 현재 호환 `project-{projectName}-{taskname}` 작업 브랜치가 현재 작업 기준인지 확인합니다.

확인 결과와 다른 위치가 보이면 아래처럼 처리합니다.

- 제품 repo 내부 `obs/`, `.obsidian`, `docs/`, submodule, external clone, 오래된 vault가 있어도 기준 SSoT라고 추정하지 않습니다.
- 기준 SSoT가 아닌 제품 repo 내부 `obs/`, `.obsidian`, `docs/`, submodule, external clone, 오래된 vault에는 새 project task, issue, QA, dashboard, source doc, project handoff를 만들지 않습니다.
- `project-{projectName}/main`, 현재 호환 `project-{projectName}`, 또는 호환 slash 기반 `project/<project-id>` 브랜치가 있는데 현재 브랜치가 `docs/*`, `chore/*`, `silo/*`, 0계층 공통 규칙 브랜치, 또는 귀속 prefix가 없는 브랜치라면 Project SSoT 기준 정보나 Project Work SSoT 원문을 직접 쓰지 않습니다.
- 현재 브랜치에 Project SSoT 또는 Project Work SSoT diff가 이미 있으면 기준 worktree로 이어 쓰지 않고 `기준 아님`, `이관 후보`, `위험`, `사용자 판단 필요`로 분리해 보고합니다.
- 0계층 대상 PR을 제안하거나 생성하려는 순간에는 [`main-v3-pr-scope-gate`](../main-v3-pr-scope-gate/SKILL.md)를 먼저 적용합니다. 현재 skill 이름은 `main-v3/main` 호환 상태를 반영하지만 목적은 0계층 PR scope gate입니다. Project SSoT 기준 정보나 Project Work SSoT 원문이 diff에 있으면 PR 제안을 중단합니다.
- project 작업 브랜치에서 0계층 대상 공통 승격 후보가 생기면 Project SSoT 기준 정보나 Project Work SSoT 원문과 함께 PR로 올리지 않고, 0계층 변경만 별도 worktree로 분리합니다.
- 단, 3계층 task silo의 `goal.md`, 실행 보고, handoff, PR 본문은 PR 전 임시 상태와 evidence로 허용합니다.
- 후보 위치가 둘 이상이면 쓰기 전에 `기준 SSoT`, `기준 아님`, `위험`, `사용자 판단 필요`로 분리해 보고합니다.
- task 번호는 실제 Project Work SSoT의 task registry가 있으면 먼저 확인하고, 없으면 기존 task 파일과 README/index를 확인한 뒤 비어 있는 번호만 사용합니다.
- 번호가 superseded, candidate, done, draft PR 본문에서 이미 쓰였으면 새 task 번호로 재배정하고 registry에 이유를 남깁니다.

## 금지

- 0계층 `system/`에 프로젝트 issue/task를 직접 저장하지 않습니다.
- 프로젝트 내부 자료를 root 0계층 계층 메인 브랜치에 기본 커밋하지 않습니다.
- 사일로 local finding을 PR 전 Project SSoT나 Project Work SSoT에 바로 승격하지 않습니다.
- Project SSoT나 Project Work SSoT를 root 문서로 덮어쓰지 않습니다.
- 기준 SSoT 확인 없이 제품 repo 내부 `obs/` 또는 submodule에 프로젝트 task/issue/QA를 작성하지 않습니다.
- `project-{projectName}/main`, 현재 호환 `project-{projectName}`, 또는 호환 slash 기반 `project/<project-id>` 브랜치가 있는 프로젝트의 task/issue/QA/runbook/coverage/dashboard/source doc 원문을 `docs/*`, `chore/*`, `silo/*`, 0계층 공통 규칙 브랜치, 또는 귀속 prefix가 없는 브랜치에서 직접 작성하지 않습니다.
- Project SSoT 기준 정보나 Project Work SSoT 원문이 포함된 브랜치를 0계층 대상 PR로 제안하지 않습니다.

## 프로젝트 자료 정책

프로젝트 내부 자료는 기본적으로 아래 중 하나로 연결합니다.

- fork
- 목표 `project-{projectName}/main` 장기 계층 메인 브랜치
- 현재 호환 `project-{projectName}` 장기 브랜치
- 호환 중인 기존 slash 기반 `project/<project-id>` 장기 브랜치
- git submodule
- external clone
- project registry
- secret/config reference

root 저장소 0계층 계층 메인 브랜치에는 공통 운영 규칙만 둡니다. 현재 호환 기준은 `main-v3/main`, 목표 기준은 `main-v3/main`입니다.

`project-{projectName}/main` 브랜치는 별도 fork를 만들지 않을 때 쓰는 프로젝트별 Project SSoT 장기 계층 메인 브랜치입니다. 이 브랜치는 root 0계층으로 머지할 기능 브랜치가 아니며, 프로젝트별 코드 분석, repo/source 연결 상태, SSoT 색인, project contract, 기능/사용자 흐름별 요구사항, decision/ADR, 운영 기준을 보관합니다. `project-{projectName}` 자체는 namespace이며 브랜치로 만들지 않습니다. 마이그레이션 전 호환 `project-{projectName}`와 기존 slash 기반 `project/<project-id>` 브랜치는 전환/호환 필요 항목으로 분류합니다.

프로젝트 내부 task, issue, QA, runbook, coverage, dashboard, source doc처럼 2계층 Project Work SSoT를 생성하거나 수정하는 작업은 목표 모델에서 해당 project의 `project-{projectName}/main`에서 판 `project-{projectName}/{taskname}` 작업 브랜치에서만 수행합니다. 현재 호환 상태에서는 `project-{projectName}`와 `project-{projectName}-{taskname}`을 사용합니다. 계층 메인 브랜치에는 직접 커밋하지 않습니다. 공통 템플릿, scaffold 로직, repo skill, agent prompt처럼 0계층 규칙 자체를 수정하는 작업은 목표 모델에서 `main-v3/{taskname}`, 현재 호환 상태에서 `main-v3/{taskname}` 작업 브랜치에서 수행합니다.

project 계층 메인 브랜치가 최신 0계층 계층 메인 브랜치 위로 rebase되어 있지 않아 rebase할 때는, rebase 전후로 최신 0계층에서 변경된 공통 규칙, AGENTS.md, system 문서, 프롬프트, skill 초안을 확인합니다. rebase 후에는 현재 Project SSoT, Project Work SSoT, task, issue, 실행 방식이 새 0계층 규칙과 맞지 않는 부분을 `규칙 불일치`와 `조치 후보`로 분리해 보고합니다.

프로젝트 자료를 root 저장소 0계층에 추가해야 한다면 `project-{projectName}/main`, 현재 호환 `project-{projectName}`, 또는 호환 slash 기반 `project/<project-id>` 브랜치 내용을 그대로 합치지 않습니다. 공통 운영 규칙으로 승격할 항목만 별도 0계층 업데이트 후보로 분리하고, PR description에 이유를 적습니다.

Project Work SSoT의 dashboard, task format, issue format, L 기준이 필요하면 실제 project 산출물을 root 0계층에 커밋하지 않습니다. 대신 `setup.sh` 셋업 흐름이나 `system/20-skills/`의 repo skill을 추가하고, 생성 결과는 Project Work SSoT에 둡니다.

## 승격 판단

### 승인 전 local 검수와 승격

- 사용자 검수가 필요한 Markdown, 계획, Task, Issue, decision 초안은 [`workspace-local-review`](../workspace-local-review/SKILL.md)로 라우팅합니다.
- 승인 전 저장 위치는 Git 비추적 영역인 `<workspace>/local/<작업명>/`이며, 이 단계의 산출물은 3계층 임시 상태입니다.
- 승인 전에는 `local/` 밖의 0/1/2계층 정식 문서나 worktree를 만들지 않습니다.
- 사용자가 검수 revision을 승인한 후에만 영향 범위를 다시 0/1/2계층으로 판정하고, 해당 계층 메인 브랜치에서 worktree와 작업 브랜치를 만든 뒤 PR로 승격합니다.
- local 파일 자체는 commit, PR, 정식 SSoT에 포함하지 않습니다. 승인된 revision과 hash는 승격 작업의 입력 근거로만 사용합니다.

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

계층 판단을 보고할 때는 루트 최종 응답 계약에 맞춰 `사용한 스킬`과 `현재 워크트리`를 함께 씁니다. `현재 워크트리`에는 절대 경로, 브랜치, dirty 여부, upstream 대비 ahead/behind를 포함합니다.

```text
사용한 스킬:
현재 워크트리:
- 경로:
- 브랜치:
- dirty:
- upstream 대비:
판정 계층:
저장 위치:
실행 주체:
승격 필요 여부:
커밋 대상 여부:
다음 행동:
```
