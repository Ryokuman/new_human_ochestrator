# 테스트 사일로 Workflow

테스트 사일로 workflow는 report/evidence 생성과 승격을 목표로 합니다.

```text
1. 테스트 요청과 Run Set을 확인한다.
2. task/issue에서 시작된 테스트 사일로라면 project SSoT의 원본 task/issue 상태를 `in_progress`로 갱신한다.
3. 사일로 유형이 테스트 사일로인지 판정한다.
4. 사일로 root와 report/evidence 위치를 정한다.
5. 필요한 runtime set을 확인한다.
6. 서버형 runtime이 있으면 health gate를 통과했는지 확인한다.
7. lifecycle/E2E/runtime/탐색 검증을 실행한다.
8. evidence를 수집한다.
9. 개별 보고서를 작성한다.
10. report/evidence가 project SSoT 또는 지정 위치에 승격됐는지 확인한다.
11. execution window가 있으면 전체 사일로 보고서와 issue/task 승격 후보를 만든다.
12. 삭제 전 gate를 확인하고 정리 가능 여부를 보고한다.
```

2번 상태 갱신은 task/issue 원본이 있는 테스트 사일로의 시작 gate입니다. 상태 갱신이 불가능하면 사일로 root와 report/evidence 위치를 만들기 전에 멈추고, 갱신 불가 사유를 보고합니다.

테스트 사일로는 `Hypothesis Chain`을 갱신하지 않습니다.

테스트 실패는 아래 위치에 남깁니다.

- 개별 보고서
- evidence
- 전체 사일로 보고서
- issue/task 승격 후보
