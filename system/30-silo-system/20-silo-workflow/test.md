# 테스트 사일로 Workflow

테스트 사일로 workflow는 report/evidence 생성과 승격을 목표로 합니다.

```text
1. 테스트 요청과 Run Set을 확인한다.
2. 사일로 유형이 테스트 사일로인지 판정한다.
3. 사일로 root와 report/evidence 위치를 정한다.
4. 필요한 runtime set을 확인한다.
5. 서버형 runtime이 있으면 health gate를 통과했는지 확인한다.
6. lifecycle/E2E/runtime/탐색 검증을 실행한다.
7. evidence를 수집한다.
8. 개별 보고서를 작성한다.
9. report/evidence가 project SSoT 또는 지정 위치에 승격됐는지 확인한다.
10. execution window가 있으면 전체 사일로 보고서와 issue/task 승격 후보를 만든다.
11. 삭제 전 gate를 확인하고 정리 가능 여부를 보고한다.
```

테스트 사일로는 `Hypothesis Chain`을 갱신하지 않습니다.

테스트 실패는 아래 위치에 남깁니다.

- 개별 보고서
- evidence
- 전체 사일로 보고서
- issue/task 승격 후보
