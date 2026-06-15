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
- required runtime set
- report 위치
- evidence 위치
- destructive boundary

## runtime set 연결

`Run Set.required_runtime_set`은 사용할 runtime set id를 참조합니다.

runtime set이 없거나 어떤 set을 써야 하는지 불명확하면 lifecycle, run, E2E, 다건 테스트 사일로 실행을 시작하지 않습니다.

## 정식 실행이 아닌 것

아래는 preflight 또는 폐기 후보 산출물일 수 있지만 정식 사일로 실행으로 보고하지 않습니다.

- 사일로 root 없이 runner만 직접 실행한 것
- `goal.md` 없이 shell command만 실행한 것
- Run Set 없이 여러 page를 임의로 묶은 것
- runtime set 없이 browser smoke만 실행한 것
