# Run Set

`Run Set`은 이번 실행에서 무엇을 돌릴지 정의하는 실행 묶음입니다.

Run Set은 사일로 자체가 아닙니다. 여러 page나 task를 묶어 실행할 때의 묶음은 scheduler 또는 execution window이며, 그 안에서 개별 테스트 사일로가 생성될 수 있습니다.

## 필수 항목

- 대상 목록
- 제외 기준
- 실행 순서
- execution window 크기
- 사일로 단위
- target level 또는 target goal
- `required_runtime_set`
- report 위치
- evidence 위치
- destructive boundary

## runtime set 연결

`run_set.required_runtime_set`은 사용할 runtime set id를 참조합니다.

Runtime Set 결정 우선순위에서는 `run_set.required_runtime_set`이 가장 높습니다.

1. `run_set.required_runtime_set`
2. `task.runtime_set`
3. `qa_or_runbook.runtime_set`
4. `project.common_runtime_set`
5. 없으면 `runtime 정의 누락`

Run Set이 있는 실행에서 `run_set.required_runtime_set`이 있으면 task, QA/runbook, project common 값으로 덮어쓰지 않습니다. runtime set이 없거나 어떤 set을 써야 하는지 불명확하면 lifecycle, run, E2E, 다건 테스트 사일로 실행을 시작하지 않습니다.

Run Set은 2계층 `Project Work SSoT`의 일부입니다. root `main-v3/main`에는 실제 Run Set 실데이터를 두지 않고, project SSoT에서 실행 대상, report/test evidence 위치, required runtime set을 관리합니다.

## 정식 실행이 아닌 것

아래는 preflight 또는 폐기 후보 산출물일 수 있지만 정식 사일로 실행으로 보고하지 않습니다.

- 사일로 root 없이 runner만 직접 실행한 것
- `goal.md` 없이 shell command만 실행한 것
- Run Set 없이 여러 page를 임의로 묶은 것
- runtime set 없이 browser smoke만 실행한 것
