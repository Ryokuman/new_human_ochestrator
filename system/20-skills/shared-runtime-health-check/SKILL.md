---
name: shared-runtime-health-check
description: page-lifecycle, run, E2E, runtime 검증 전 runtime_set 유무나 shared runtime 서버 상태가 불명확할 때 사용합니다.
---

# Shared Runtime Health Check

이 스킬은 task silo나 page-lifecycle 실행 전에 project별 Runtime Set이 준비되어 있는지, 서버형 shared runtime이 실행 가능한 상태인지 확인합니다.

## 적용 시점

아래 요청이나 상황이 나오면 이 스킬을 사용합니다.

- page-lifecycle, run, E2E, runtime 검증을 시작하기 전에 Runtime Set 확인이 필요함
- shared runtime registry/status에 등록된 서버형 runtime health를 확인해야 함
- 사용자가 lifecycle 실행을 요청했지만 `runtime_set` 유무나 상태가 불명확함
- task silo `goal.md`, handoff, PR 본문에 runtime health gate 결과를 남겨야 함

## 계층 판단

- runtime health gate 규칙과 registry 템플릿은 0계층 `system/`에 둡니다.
- 특정 프로젝트의 실제 `runtime_set`, workspace path, env policy, health command는 project registry/config 또는 2계층 `Project Work SSoT`에 둡니다. root `main-v3/main`에는 실제 project runtime 실데이터를 두지 않습니다.
- lifecycle 실행 전 확인 결과는 silo local `goal.md`, 실행 보고, handoff, PR 본문에 기록합니다.
- secret, token, password, credential 값은 읽거나 기록하지 않습니다. env 파일 path 또는 secret provider 정책만 기록합니다.

## 핵심 규칙

1. lifecycle, run, E2E 실행 전에 먼저 Runtime Set 결정 우선순위에 따라 대상 project의 `runtime_set` 존재 여부를 확인합니다.
2. 결정 우선순위는 `run_set.required_runtime_set`, `task.runtime_set`, `qa_or_runbook.runtime_set`, `project.common_runtime_set`, 없으면 `runtime 정의 누락`입니다.
3. `runtime_set`이 없으면 lifecycle을 시작하지 않습니다. `add-shared-runtime` 또는 project runtime_set 정의가 먼저 필요하다고 보고합니다.
4. `runtime_set`에 서버형 runtime이 있으면 health command, URL, port, env policy를 확인합니다.
5. 서버형 runtime이 없으면 health check를 생략할 수 있습니다. 생략 이유를 `goal.md`나 보고서에 기록합니다.
6. health check가 실패하면 lifecycle 시작을 중단하고 실패 runtime, 실패 명령 또는 URL, 다음 조치 후보를 보고합니다.
7. health check가 통과하면 runtime_set 상태를 요약해 `goal.md`, handoff, PR 본문에 기록할 수 있게 출력합니다.

## 서버형 runtime 판단

아래 중 하나에 해당하면 서버형 runtime으로 봅니다.

- `runtime_kind: server` 또는 `requires_health_check: true`
- `ports`가 있고 lifecycle, E2E, browser, API 검증에서 접근해야 함
- `health_check_command` 또는 `health_check_url`이 등록되어 있음
- 공용 backend, frontend dev server, worker API, service mock, DB emulator처럼 프로세스 실행 상태가 검증 전제임

단순 source checkout, generator repo, 정적 reference repo처럼 실행 중인 port나 server process가 없으면 서버형 runtime이 아닐 수 있습니다.

## 절차

1. project registry/config 또는 Project Work SSoT에서 아래 우선순위로 대상 project의 `runtime_set`을 찾습니다.
   - `run_set.required_runtime_set`
   - `task.runtime_set`
   - `qa_or_runbook.runtime_set`
   - `project.common_runtime_set`
   - 없으면 `runtime 정의 누락`
2. `runtime_set` 이름, runtime 목록, 역할, workspace path, branch, commit, port, env policy를 확인합니다.
3. `runtime_set`이 없거나 어떤 set을 써야 하는지 불명확하면 여기서 중단합니다.
4. 각 runtime이 서버형인지 판정합니다.
5. 서버형 runtime이 없으면 `health_check: skipped`와 생략 이유를 기록하고 다음 실행으로 넘어갈 수 있습니다.
6. 서버형 runtime마다 health command 또는 URL을 확인합니다.
7. env 관련 정보는 파일 경로, 주입 정책, secret provider 이름까지만 확인하고 값은 읽거나 기록하지 않습니다.
8. health command 또는 URL을 실행 가능한 범위에서 확인합니다.
9. 실패가 있으면 lifecycle, run, E2E를 시작하지 않고 실패 runtime과 다음 조치를 보고합니다.
10. 모두 통과하면 아래 요약 형식으로 결과를 남깁니다.

## 결과 요약 형식

```text
Shared runtime health:
- runtime_set: <runtime-set-name>
- checked_at: <YYYY-MM-DD HH:MM TZ 또는 run id>
- server_runtimes:
  - <runtime-name>: pass, <command-or-url>, port <port>, branch <branch>, commit <commit>
- skipped_runtimes:
  - <runtime-name>: 서버형 runtime 아님
- env_policy: <env file path or secret provider policy, no secret values>
```

실패 시:

```text
Shared runtime health failed:
- runtime_set: <runtime-set-name>
- failed_runtime: <runtime-name>
- check: <command-or-url>
- reason: <exit code, timeout, port closed, unavailable 등>
- next_action: add-shared-runtime 실행, runtime_set 정의 보강, 서버 시작, port/env policy 확인 중 하나
```

## 금지

- `runtime_set`이 없는데 lifecycle, run, E2E를 먼저 시작하지 않습니다.
- health 실패를 무시하고 page-lifecycle을 진행하지 않습니다.
- secret 파일 내용을 확인하거나 출력하지 않습니다.
- 프로젝트별 실제 issue/task/QA 원문을 root `main-v3/main` `system/`에 복사하지 않습니다.
- shared runtime 자체 수정이 필요할 때 현재 task PR에 섞지 않습니다. 별도 task, branch, PR 후보로 분리합니다.
