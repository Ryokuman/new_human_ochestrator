---
name: main-v3-pr-scope-gate
description: 목표 main-v3/main 또는 현재 호환 main-v3/main 대상 0계층 PR을 제안, 작성, 생성, 리뷰하거나 작업 브랜치를 push하기 전 사용합니다. project SSoT 파일, system 외 diff, docs/chore 브랜치명, project 브랜치의 공통 승격 여부가 걸린 경우 사용합니다.
---

# Main-v3 PR Scope Gate

0계층 PR은 공통 운영 규칙만 반영합니다. PR 제안, PR 본문 초안, push, `gh pr create` 직전에 이 gate로 diff와 브랜치명을 먼저 분류합니다.

목표 모델에서 0계층 계층 메인 브랜치는 `main-v3/main`이고 작업 브랜치는 `main-v3/{taskname}`입니다. `main-v3` 자체는 브랜치로 만들지 않는 Git ref namespace입니다.

현재 `main-v3/main`는 마이그레이션 전 호환 메인 브랜치입니다. `main-v3/main/<branch-name>`은 `main-v3/main` leaf branch와 Git ref namespace가 충돌하므로 생성할 수 없습니다. `main-v3/main` 마이그레이션 전에는 0계층 호환 작업 브랜치명으로 `main-v3/{taskname}`을 사용합니다.

여기서 branch base는 계층 기준 브랜치입니다. GitHub PR target/base branch는 계층 판단 후 정해지는 머지 대상입니다.

```text
0계층 공통 변경 목표 -> main-v3/main
0계층 공통 변경 현재 호환 -> main-v3/main
1계층 이상 project 변경 목표 -> project-{projectName}/main
1계층 이상 project 변경 현재 호환 -> project-{projectName}
```

## 실행 조건

- `main-v3/main` 대상 PR을 만들거나 제안할 때
- `docs/*`, `chore/*`, `repair/*`, `project/*`, `project-{projectName}`, `project-{projectName}-*`, 또는 귀속 prefix가 없는 브랜치에서 PR 가능성을 판단할 때
- project SSoT, project contract, decision/ADR, issue/task/QA/coverage 자료가 diff에 보일 때
- project 브랜치에서 발견한 내용을 공통 규칙으로 승격하려 할 때
- 하나의 작업 브랜치에 0계층 변경과 1계층 이상 project 변경이 섞여 worktree 또는 PR 분리가 필요한지 판단할 때

## 필수 확인

```bash
base_branch="main-v3/main"
git fetch --no-tags origin "$base_branch"
git branch --show-current
git diff --name-only "origin/$base_branch"...HEAD
git diff --stat "origin/$base_branch"...HEAD
```

파일을 아래로 분류합니다.

```text
0계층 공통 변경: system/, AGENTS.md, root README, setup.sh, 공통 config/template/example
1계층 project SSoT 원문: projects/<project-id>/01-project-ssot/, project-registry.md, project-contract.md, 50-decisions/
2계층 Project Work SSoT 원문: projects/<project-id>/README.md에 선언된 Project Work SSoT 경로, projects/<project-id>/ssot/, projects/<project-id>/02-project-internal/
3계층 local/silo 임시 자료: task-*/, local/, sources/, evidence, projects/<project-id>/03-silo-local/, 실행 로그
```

## 차단 조건

아래 중 하나라도 있으면 `main-v3/main` PR 제안, push, PR 생성을 중단합니다.

- 1계층 project SSoT 원문이 diff에 포함됨
- 2계층 Project Work SSoT 원문이 diff에 포함됨
- 3계층 local/silo 임시 자료가 diff에 포함됨
- `project/*` 호환 브랜치, `project-{projectName}` 기준 브랜치, 또는 `project-{projectName}/main` 기준 브랜치 전체를 0계층으로 합치려는 형태임
- `docs/*` 또는 `chore/*` 브랜치인데 공통 규칙 변경 없이 project 자료만 있음
- 0계층으로 올릴 공통 승격 후보가 설명되지 않음
- 0계층 변경과 1계층 이상 project 변경이 한 PR에 함께 포함됨
- 새 0계층 작업인데 브랜치명이 `main-v3/{taskname}` 형식으로 설명되지 않음
- project 계층 작업인데 브랜치명이 `project-{projectName}/{taskname}` 작업 브랜치 모델과 맞지 않고, 호환 `project-{projectName}-{taskname}` 또는 slash 기반 `project/<project-id>` 브랜치로도 설명되지 않음

## 허용 조건

`main-v3/main` PR은 아래처럼 공통화 가능한 diff만 남았을 때 제안합니다.

- repo skill, agent prompt, `AGENTS.md`, `system/` 문서 변경
- project SSoT scaffold를 만드는 공통 템플릿이나 `setup.sh` 변경
- secret 값을 포함하지 않는 공통 config example
- project 자료를 직접 담지 않는 일반 운영 규칙

project 작업 중 공통 규칙 변경이 발생한 경우에는 해당 0계층 변경만 `main-v3/{taskname}` 작업 브랜치와 worktree로 분리한 뒤 0계층 PR로 제안합니다. project SSoT 변경은 `project-{projectName}/main`에서 판 `project-{projectName}/{taskname}` 작업 브랜치로 분리하고, `project-{projectName}/main` 대상 PR로 제안합니다. 현재 호환 상태에서는 `project-{projectName}`와 `project-{projectName}-{taskname}`을 사용할 수 있습니다.

## 압력 사례

- `project-{projectName}/main` 또는 현재 호환 `project-{projectName}` 브랜치에 `projects/<project-id>/01-project-ssot/` 아래 project registry, project contract, decision/ADR이 있고 사용자가 PR 준비를 요청하면 0계층 PR을 쓰지 않습니다.
- `project-{projectName}/main` 또는 현재 호환 `project-{projectName}` 브랜치에 `projects/<project-id>/ssot/` 또는 `projects/<project-id>/02-project-internal/` 아래 dashboard, dictionary, task, handoff, coverage, template, README가 있고 사용자가 PR 준비를 요청하면 0계층 PR을 쓰지 않습니다.
- `project-{projectName}/main` 또는 현재 호환 `project-{projectName}` 브랜치에 `projects/<project-id>/03-silo-local/` 아래 사일로 로컬 README, PR 본문 템플릿, 실행 로그가 있고 사용자가 PR 준비를 요청하면 0계층 PR을 쓰지 않습니다.
- `docs/*` 브랜치인데 diff가 project SSoT 원문뿐이면 브랜치명 불일치로 보고하고, 0계층으로 올릴 공통 규칙이 없다고 말합니다. 새 0계층 PR은 `main-v3/{taskname}`로 다시 만듭니다.
- `setup.sh` 또는 project SSoT scaffold 템플릿처럼 여러 프로젝트에서 반복 가능한 생성 규칙만 남았을 때만 0계층 PR을 제안합니다.
- `project-example-add-login` 같은 귀속이 불명확한 project 작업 브랜치에서 system update와 특정 project SSoT update가 함께 발생하면, system update만 0계층 작업 브랜치 기준 worktree로 분리하고 project SSoT update는 목표 `project-{projectName}/{taskname}` 또는 현재 호환 `project-{projectName}-{taskname}` 작업 브랜치와 project 계층 메인 브랜치 대상 PR로 분리합니다.

## 보고 형식

```text
main-v3/main PR 가능 여부:
브랜치명 적합성:
0계층 공통 변경:
1계층 project SSoT 원문:
2계층 Project Work SSoT 원문:
3계층 local/silo 자료:
차단 사유:
다음 행동:
```

`main-v3/main PR 가능 여부`가 `불가`이면 PR 제목/본문을 쓰지 않습니다. 대신 `project 브랜치 유지`, `공통 승격 후보 분리`, `브랜치명 수정 또는 재생성` 중 하나를 다음 행동으로 제시합니다.
