# 사일로 출력과 종료 상태

## 출력

사일로는 작업 후 다음을 남깁니다.

- 사일로 유형
- 수정 branch 목록
- 필요한 repo별 PR
- 테스트 사일로인 경우 개별 보고서, evidence 위치, 삭제 가능 여부
- 테스트 사일로 execution window 종료인 경우 전체 사일로 보고서와 issue/task 승격 후보
- 작업 요약
- 검증 결과
- criteria별 검증 결과
- 리뷰 gate 결과 또는 생략 사유
- 새로 발견한 로컬 issue/task
- SSoT 승격 후보
- 승격하지 않을 로컬 전용 항목
- 사용자 또는 메인에게 필요한 질문

## 내부 이슈와 task 후보

사일로는 작업 중 새 문제를 발견할 수 있습니다. 이 문제들은 바로 메인 SSoT에 쓰지 않고 우선 사일로 로컬 발견으로 기록합니다.

PR 또는 보고 시점에는 아래처럼 분리합니다.

- 현재 task 안에서 처리한 것
- 일반 사일로에서 현재 task의 `Hypothesis Chain`에 남긴 것
- issue/task 승격 후보
- 메인 오케스트레이터 판단 필요
- 승격하지 않을 로컬 전용 항목

원래 task 가설이 실패했다는 이유만으로 새 task를 자동 생성하지 않습니다.

테스트 사일로는 `Hypothesis Chain`을 쓰지 않습니다. 테스트 실패는 개별 보고서, evidence, 전체 사일로 보고서, issue/task 승격 후보로만 정리합니다.

## 종료 상태

| 상태 | 의미 |
|---|---|
| `report-promoted` | 테스트 사일로의 개별 보고서와 evidence 승격 확인 완료 |
| `window-reported` | 테스트 사일로 execution window의 전체 사일로 보고서 작성 및 승격 후보 정리 완료 |
| `deleted` | 보고서/evidence 승격 gate와 dirty status 확인 뒤 사일로 디렉토리 삭제 완료 |
| `codex-review-passed` | PR 유형별 target/base에서 `codex-pr-review-loop` 기준 최신 head에 대한 `Didn't find any major issues` 또는 동등한 no-major 명시 응답이 있고, 현재 head 대상 지적이 없거나 모두 근거 있는 `수비 가능`으로 기록됐으며, `수정 필요`와 `사용자 판단 필요`가 남아 있지 않음 |
| `user-review-pending` | 브랜치별 리뷰 gate 종결 후 사용자 재리뷰 대기 |
| `pr-opened` | PR 생성 완료, 메인 리뷰 대기 |
| `needs-rework` | 메인 리뷰 또는 사용자 피드백으로 재작업 필요 |
| `merged` | PR 머지 완료 |
| `blocked` | 사일로 단독으로 해결 불가 |
| `abandoned` | scope 변경 또는 중복으로 폐기 |
