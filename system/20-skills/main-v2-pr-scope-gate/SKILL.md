---
name: main-v2-pr-scope-gate
description: main-v2 대상 PR을 제안, 작성, 생성, 리뷰하거나 작업 브랜치를 push하기 전 사용합니다. project SSoT 파일, system 외 diff, docs/chore 브랜치명, project 브랜치의 공통 승격 여부가 걸린 경우 사용합니다.
---

# Main-v2 PR Scope Gate

`main-v2` PR은 공통 운영 규칙만 반영합니다. PR 제안, PR 본문 초안, push, `gh pr create` 직전에 이 gate로 diff와 브랜치명을 먼저 분류합니다.

0계층 작업 브랜치명은 `main-v2-<branch-name>` 형식을 사용합니다. `main-v2/<branch-name>`은 계층 귀속을 설명하는 사고 모델로는 읽을 수 있지만, 이 repo에서는 `main-v2` 보호 브랜치가 실제 Git ref로 존재하므로 생성할 수 없습니다.

여기서 branch base는 계층 기준 브랜치입니다. GitHub PR target/base branch는 계층 판단 후 정해지는 머지 대상입니다.

```text
0계층 공통 변경 -> main-v2
1계층 이상 project 변경 -> project/<project-id>
```

## 실행 조건

- `main-v2` 대상 PR을 만들거나 제안할 때
- `docs/*`, `chore/*`, `repair/*`, `project/*`, 또는 귀속 prefix가 없는 브랜치에서 PR 가능성을 판단할 때
- project SSoT, issue/task/QA/decision/coverage 자료가 diff에 보일 때
- project 브랜치에서 발견한 내용을 공통 규칙으로 승격하려 할 때
- 하나의 작업 브랜치에 0계층 변경과 1계층 이상 project 변경이 섞여 worktree 또는 PR 분리가 필요한지 판단할 때

## 필수 확인

```bash
git fetch --no-tags origin main-v2
git branch --show-current
git diff --name-only origin/main-v2...HEAD
git diff --stat origin/main-v2...HEAD
```

파일을 아래로 분류합니다.

```text
0계층 공통 변경: system/, AGENTS.md, root README, setup.sh, 공통 config/template/example
1계층 project 등록/색인: projects/<project-id>/README.md 같은 registry/config reference
2계층 project SSoT 원문: projects/<project-id>/README.md에 선언된 project SSoT 경로, projects/<project-id>/ssot/, projects/<project-id>/02-project-internal/
3계층 local/silo 임시 자료: task-*/, local/, sources/, evidence, projects/<project-id>/03-silo-local/, 실행 로그
```

## 차단 조건

아래 중 하나라도 있으면 `main-v2` PR 제안, push, PR 생성을 중단합니다.

- 2계층 project SSoT 원문이 diff에 포함됨
- 3계층 local/silo 임시 자료가 diff에 포함됨
- `project/*` 브랜치 전체를 `main-v2`로 합치려는 형태임
- `docs/*` 또는 `chore/*` 브랜치인데 공통 규칙 변경 없이 project 자료만 있음
- `main-v2`로 올릴 공통 승격 후보가 설명되지 않음
- 0계층 변경과 1계층 이상 project 변경이 한 PR에 함께 포함됨
- 새 0계층 작업인데 브랜치명이 `main-v2-<branch-name>` 형식이 아님

## 허용 조건

`main-v2` PR은 아래처럼 공통화 가능한 diff만 남았을 때 제안합니다.

- repo skill, agent prompt, `AGENTS.md`, `system/` 문서 변경
- project SSoT scaffold를 만드는 공통 템플릿이나 `setup.sh` 변경
- secret 값을 포함하지 않는 공통 config example
- project 자료를 직접 담지 않는 일반 운영 규칙

project 작업 중 공통 규칙 변경이 발생한 경우에는 해당 0계층 변경만 `main-v2-<branch-name>` 작업 브랜치와 worktree로 분리한 뒤 `main-v2` PR로 제안합니다. project SSoT 변경은 해당 `project/<project-id>` 기준 브랜치에서 판 `project/<project-id>-<branch-name>` 작업 브랜치로 분리하고, `project/<project-id>` 대상 PR로 제안합니다.

## 압력 사례

- `project/<project-id>` 브랜치에 `projects/<project-id>/ssot/` 또는 `projects/<project-id>/02-project-internal/` 아래 dashboard, dictionary, task, decision, handoff, coverage, template, README가 있고 사용자가 PR 준비를 요청하면 `main-v2` PR을 쓰지 않습니다.
- `project/<project-id>` 브랜치에 `projects/<project-id>/03-silo-local/` 아래 사일로 로컬 README, PR 본문 템플릿, 실행 로그가 있고 사용자가 PR 준비를 요청하면 `main-v2` PR을 쓰지 않습니다.
- `docs/*` 브랜치인데 diff가 project SSoT 원문뿐이면 브랜치명 불일치로 보고하고, `main-v2`로 올릴 공통 규칙이 없다고 말합니다. 새 0계층 PR은 `main-v2-<branch-name>`로 다시 만듭니다.
- `setup.sh` 또는 project SSoT scaffold 템플릿처럼 여러 프로젝트에서 반복 가능한 생성 규칙만 남았을 때만 `main-v2` PR을 제안합니다.
- `project/onjump-add-login` 같은 귀속이 불명확한 project 작업 브랜치에서 system update와 onjump SSoT update가 함께 발생하면, system update만 `main-v2-<branch-name>` 기준 worktree로 분리하고 onjump SSoT update는 `project/onjump-<branch-name>` 작업 브랜치와 `project/onjump` 대상 PR로 분리합니다.

## 보고 형식

```text
main-v2 PR 가능 여부:
브랜치명 적합성:
0계층 공통 변경:
1계층 등록/색인:
2계층 project SSoT 원문:
3계층 local/silo 자료:
차단 사유:
다음 행동:
```

`main-v2 PR 가능 여부`가 `불가`이면 PR 제목/본문을 쓰지 않습니다. 대신 `project 브랜치 유지`, `공통 승격 후보 분리`, `브랜치명 수정 또는 재생성` 중 하나를 다음 행동으로 제시합니다.
