---
name: add-shared-runtime
description: 프로젝트별 shared runtime set, 공용 backend/frontend/worker/mock runtime, 여러 task silo가 참조하는 장기 실행 repo 묶음을 등록하거나 준비해야 할 때 사용합니다.
---

# Add Shared Runtime

이 스킬은 task silo가 매번 clone하지 않고 함께 참조하는 프로젝트별 shared runtime workspace를 등록하고 준비합니다.

## 적용 시점

아래 요청이 나오면 이 스킬을 사용합니다.

- shared runtime 추가
- 공용 runtime set 생성
- 여러 task가 함께 쓰는 backend, frontend, worker, DB emulator, external service mock 등록
- 특정 프로젝트의 runtime repo 묶음을 workspace root 아래 장기 checkout으로 준비
- task silo `goal.md`에 참조할 runtime branch, commit, port, health check를 정리

프로젝트별 실제 runtime 구성은 프로젝트마다 다릅니다. 어떤 프로젝트는 backend와 frontend만 필요하고, 어떤 프로젝트는 worker, local DB emulator, external service mock, generator repo를 함께 쓸 수 있습니다.

## 계층 판단

- shared runtime 운영 규칙과 registry 템플릿은 0계층 `system/`에 둡니다.
- 특정 프로젝트의 실제 runtime 등록값은 1계층 project registry/config 또는 2계층 `Project Work SSoT`에 둡니다.
- task 실행 중 사용한 runtime branch, commit, port, health check 결과는 3계층 silo local `goal.md`, handoff, PR 본문에 기록합니다.
- 실제 제품 소스코드 clone은 `projects/` 아래에 두지 않습니다.

## 권장 workspace

기본 경로 후보:

```text
<workspace>/shared-runtime/<runtime-name>/
```

이전 다중 프로젝트 workspace나 호환 설정에서는 `shared-runtime/<project-id>/<runtime-name>/`을 사용할 수 있습니다. 다른 로컬 정책이 있으면 project registry/config, 2계층 `Project Work SSoT`, 또는 gitignore된 local config에 명시합니다. root `main-v3/main`에는 특정 프로젝트의 실제 경로, 내부 repo URL, secret 값을 복사하지 않습니다.

## registry 필드

shared runtime registry/status에는 최소 아래 후보 필드를 둡니다.

| 필드 | 설명 |
|---|---|
| `project_id` | runtime을 사용하는 프로젝트 id |
| `runtime_set` | 함께 준비하거나 참조할 runtime 묶음 이름 |
| `runtime_name` | 사람이 구분할 수 있는 runtime 이름 |
| `runtime_kind` | `server`, `source-checkout`, `service-mock`, `db-emulator`, `other` 같은 runtime 성격 |
| `role` | `backend`, `frontend`, `worker`, `db-emulator`, `service-mock`, `generator`, `other` 같은 역할 |
| `workspace_path` | workspace root 기준 runtime checkout 위치 |
| `repo_remote` | token 없는 remote URL, project registry/config의 repo reference, 또는 1계층 Project SSoT의 repo/source reference |
| `branch` | 현재 checkout branch |
| `commit` | task가 참조한 기준 commit |
| `purpose` | 어떤 task silo가 왜 참조하는지 |
| `ports` | 노출 port 목록과 용도 |
| `env_file_policy` | env 파일 경로와 주입 방식. 실제 secret 값은 쓰지 않음 |
| `requires_health_check` | 서버형 runtime처럼 실행 전 health gate가 필요한지 여부 |
| `health_check` | registry/status에서는 `command`, `url`, `expected`, `timeout_seconds`, `on_fail`을 담는 구조화 객체. `requires_health_check: false`이면 `skipped_reason`을 기록 |
| `owner` | 관리 주체. 예: `main-orchestrator`, `project-maintainer` |
| `last_checked` | 마지막 확인 시각 또는 확인 필요 상태 |
| `linked_tasks` | 이 runtime을 참조한 task/issue/silo 목록 |
| `status` | `active`, `needs-check`, `archived` 중 하나 |

## 절차

1. 계층을 판정합니다. 공통 규칙 변경이면 `main-branch-update-flow`, 특정 프로젝트 runtime 등록이면 project registry/config 또는 2계층 `Project Work SSoT`에서 처리합니다.
2. `project_id`, runtime set 이름, 필요한 repo 역할, clone/worktree 방식, 기준 branch, 보호 브랜치, owner를 확인합니다.
3. 프로젝트별 실제 repo URL과 runtime 조합은 project registry/config, 1계층 Project SSoT의 repo/source reference, 2계층 `Project Work SSoT`의 Runtime Set/Run Set, 또는 gitignore된 local config에서 읽습니다. root `main-v3/main`에 실제 프로젝트 자료를 복사하지 않습니다.
4. registry/status 항목을 작성합니다. secret, token, password, credential 값은 기록하지 않고 env 파일 path 또는 secret provider 정책만 기록합니다.
5. workspace root 아래 `shared-runtime/<runtime-name>/` 또는 프로젝트가 정한 local path를 준비합니다. 이전 다중 프로젝트 workspace는 `shared-runtime/<project-id>/<runtime-name>/`을 호환 경로로 쓸 수 있습니다.
6. clone 또는 worktree 준비 전 기존 checkout, dirty state, 실행 중인 server/process, port 충돌을 확인합니다.
7. 보호 브랜치에서 직접 runtime 변경을 시작하지 않습니다. shared runtime 자체 변경이 필요하면 별도 task, branch, PR로 분리합니다.
8. health check command와 예상 port를 기록하고 실행 가능하면 확인합니다.
9. task silo `goal.md` 또는 handoff에는 참조한 runtime set, branch, commit, port, health check 결과를 적습니다.
10. 완료 보고에는 등록 위치, workspace path, branch/commit, health check 결과, secret 미기록 여부, 다음 task silo 참조 방법을 분리합니다.

## task silo 참조 방식

task silo는 shared runtime을 소유하지 않고 참조합니다.

`goal.md`에는 아래처럼 기록합니다.

```text
Shared runtime:
- project_id: <project-id>
- runtime_set: <runtime-set-name>
- runtime_name: <runtime-name>
- workspace_path: shared-runtime/<runtime-name>/
- branch: <branch>
- commit: <commit>
- ports: <port-purpose>
- health_check: <command> -> <result>
- env_policy: <env file path or secret provider policy, no secret values>
```

위 `goal.md`의 `health_check: <command> -> <result>`는 사람이 읽는 요약입니다. registry/status 원본에는 `requires_health_check`와 구조화된 `health_check` 객체를 사용하고, `system/config/shared-runtime-registry.example.yaml`의 `command`, `url`, `expected`, `timeout_seconds`, `on_fail` 또는 `skipped_reason` 형식을 따릅니다.

shared runtime 자체 수정이 필요하면 현재 task PR에 섞지 않고 별도 task/branch/PR 후보로 보고합니다.

## 금지

- secret, token, password, credential 값을 registry, status, `goal.md`, PR 본문에 기록하지 않습니다.
- 특정 프로젝트의 실제 issue/task/QA 결과를 0계층 `system/`에 복사하지 않습니다.
- shared runtime checkout을 `projects/` 아래 제품 소스코드처럼 두지 않습니다.
- 보호 브랜치에서 직접 runtime 변경을 commit하거나 push하지 않습니다.
- 실행 중인 server/process를 확인하지 않고 port를 재사용하지 않습니다.

## 검증

가능한 범위에서 아래를 확인합니다.

```bash
git -C shared-runtime/<runtime-name> status --short --branch
git -C shared-runtime/<runtime-name> rev-parse --short HEAD
<health-check-command>
```

검증을 실행하지 못했다면 이유와 남은 위험을 registry/status와 완료 보고에 남깁니다.
