# Silo Runtime Set

runtime set은 사일로가 실행될 때 이미 떠 있거나 준비되어야 하는 runtime 묶음입니다.

Runtime Set은 project가 시작된 뒤 생기는 2계층 `Project Work SSoT`의 실행 계약 일부입니다. task, issue, QA, runbook, coverage, work dashboard, Run Set과 함께 project SSoT에 둘 수 있으며, root `main-v3/main`에는 실제 runtime set 실데이터를 두지 않습니다.

## Runtime Set 결정 우선순위

사일로, lifecycle, run, E2E, runtime 검증은 아래 순서로 Runtime Set을 찾습니다.

1. `run_set.required_runtime_set`
2. `task.runtime_set`
3. `qa_or_runbook.runtime_set`
4. `project.common_runtime_set`
5. 없으면 `runtime 정의 누락`

더 높은 우선순위에 값이 있으면 낮은 우선순위 값으로 덮어쓰지 않습니다. 어떤 값도 없으면 임의로 shared runtime 조합을 만들지 않고 `runtime 정의 누락`, `add-shared-runtime 필요`, 또는 project SSoT 보강 필요로 보고합니다.

## Shared Runtime

shared runtime은 workspace root 아래 여러 task silo가 함께 참조하는 공용 실행 repo 묶음입니다. task silo의 폐기 가능한 clone과 다르게 장기 checkout일 수 있으며, project SSoT 또는 local config의 registry/status로 관리합니다.

기본 경로 후보:

```text
shared-runtime/<project-id>/<runtime-name>/
```

registry/status에는 project id, runtime set, runtime name, runtime kind, repo/remote, branch/commit, purpose, port, env file policy, health check command 또는 URL, owner, last checked, linked tasks를 기록합니다.

secret 값은 기록하지 않고 env 파일 path나 secret provider 정책만 기록합니다.

## 관련 skill

- shared runtime 추가 또는 준비: `add-shared-runtime`
- lifecycle, run, E2E 실행 전 runtime 상태 확인: `shared-runtime-health-check`
- shared runtime 삭제 또는 archive 처리: `delete-shared-runtime`

runtime 상태가 검증 전제가 되는 사일로는 시작 전에 `shared-runtime-health-check`를 사용합니다. 우선순위에 따라 찾은 대상 프로젝트의 `runtime_set`이 없으면 lifecycle을 시작하지 않고, `add-shared-runtime` 또는 project runtime_set 정의가 먼저 필요하다고 보고합니다.

## 공용 서비스

사일로별로 매번 clone하거나 수정하지 않는 공용 서비스가 있을 수 있습니다.

예:

- backend API
- shared DB proxy
- 공용 dev server

공용 서비스 운영 기준:

- 메인 오케스트레이터가 세션 동안 하나만 띄웁니다.
- 사일로는 해당 서비스를 검증 대상으로 사용할 수 있습니다.
- 사일로는 기본적으로 공용 서비스를 직접 clone하거나 수정하지 않습니다.
- 공용 서비스 수정 필요성이 발견되면 PR 본문에 `feedback/follow-up 후보` 또는 `메인 오케스트레이터 판단 필요`로 남깁니다.
