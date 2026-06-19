# 테스트 사일로 생명주기

테스트 사일로는 변경 diff가 아니라 report/evidence가 주 산출물입니다.

생명주기는 `준비 -> 실행 -> 보고서 승격 -> 정리`를 중심으로 둡니다.

```text
1. 시작 gate: task/issue에서 시작된 테스트 사일로라면 project SSoT의 원본 task/issue 상태를 `in_progress`로 갱신한다.
2. 준비: goal, 대상, runtime 또는 runtime set, 금지선, report 위치를 명시한다.
3. 실행: lifecycle/E2E/runtime/탐색 검증을 수행하고 evidence를 수집한다.
4. 종료: 개별 보고서를 작성하고 evidence/보고서가 SSoT 또는 지정 위치로 승격됐는지 확인한다.
5. 삭제: 보고서 승격 gate와 dirty status 확인을 통과한 뒤 사일로 디렉토리를 삭제할 수 있다.
6. execution window 종료: 개별 보고서를 묶어 전체 사일로 보고서를 작성하고 반복 원인을 추출한 뒤 issue/task 생성 후보를 만든다.
```

시작 gate에서 상태 갱신을 할 수 없으면 테스트 사일로 실행을 계속하지 않고, 갱신 불가 사유와 사용자 판단 필요 여부를 보고합니다.

테스트 사일로에는 가설 체인을 적용하지 않습니다. 실패 원인 후보는 보고서와 issue/task 승격 후보에 남기며, 같은 task 안에서 새 구현 가설을 이어 실행하지 않습니다.

## 삭제 전 gate

- 개별 보고서가 작성되어 있어야 합니다.
- evidence 원본 또는 요약 위치가 project SSoT, report 저장소, 또는 사용자가 지정한 위치에 남아 있어야 합니다.
- 보고서에는 대상, 실행 조건, runtime/runtime set, 결과, 반복 원인 후보, issue/task 승격 후보가 있어야 합니다.
- 삭제 전 사일로 루트와 내부 repo의 dirty status를 확인해야 합니다.
- destructive action, upload/import, production mutation은 테스트 사일로라도 별도 승인이 필요합니다.
