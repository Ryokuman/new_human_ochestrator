# 사일로 출력과 종료 상태

## 출력

사일로는 작업 후 다음을 남깁니다.

- 사일로 유형
- 수정 branch 목록
- 필요한 repo별 PR
- 테스트 사일로인 경우 개별 보고서, test evidence 위치, 삭제 가능 여부
- 테스트 사일로 execution window 종료인 경우 전체 사일로 보고서와 issue/task 승격 후보
- 작업 요약
- 검증 결과
- criteria별 검증 결과
- 리뷰 gate 결과 또는 생략 사유
- Codex review pass, `Codex review 미설정` fallback, 접수 실패 timeout, 응답 대기 timeout 중 현재 리뷰 상태와 확인 근거 URL
- runtime handoff 적용 여부, 완료 여부, handoff 댓글 URL, 실행 불가 사유
- 사용자 재리뷰 대기 전이 여부와 남은 사용자 판단 항목
- 2계층 `Project Work SSoT` 반영 대상: task, issue, QA, runbook, coverage, work dashboard, Run Set 중 해당 항목
- 2계층 `Project Work SSoT` 반영 경로: 실제로 기록하거나 갱신할 work data 원문 경로. 위치를 모르면 1계층 `Project SSoT`의 2계층 위치 index를 참조하고, 1계층 요구사항/계약 경로와 2계층 원문 반영 경로를 분리해 적습니다.
- 1계층 project index 참조: 2계층 원문 위치를 모를 때 확인한 Project SSoT index/계약 경로
- 새로 발견한 로컬 issue/task
- feedback/follow-up 후보
- 승격하지 않을 로컬 전용 항목
- 사용자 또는 메인에게 필요한 질문

## 내부 이슈와 task 후보

사일로는 작업 중 새 문제를 발견할 수 있습니다. 이 문제들은 바로 메인 SSoT에 쓰지 않고 우선 사일로 로컬 발견으로 기록합니다.

PR 또는 보고 시점에는 아래처럼 분리합니다.

- 현재 task 안에서 처리한 것
- 일반 사일로에서 선택적 `Hypothesis Chain` 또는 task-local evidence에 남긴 것
- issue/task 승격 후보
- 메인 오케스트레이터 판단 필요
- 승격하지 않을 로컬 전용 항목

원래 task 가설이 실패했다는 이유만으로 새 task를 자동 생성하지 않습니다.

테스트 사일로는 `Hypothesis Chain`을 쓰지 않습니다. 테스트 실패는 개별 보고서, test evidence, 전체 사일로 보고서, issue/task 승격 후보로만 정리합니다. 일반 사일로도 `Hypothesis Chain`을 필수 산출물로 만들지 않고, 실패 분석과 다음 시도 근거가 필요한 경우에만 기록합니다.

## 종료 상태

종료 상태는 사일로가 어떤 단계로 반환됐는지를 나타냅니다. 정리 가능 여부는 `system/10-ssot/SSoT-스키마-초안.md`의 `사일로 정리 상태`로 별도 판정합니다.

| 상태 | 의미 |
|---|---|
| `report-promoted` | 테스트 사일로의 개별 보고서와 test evidence 승격 확인 완료 |
| `execution-window-reported` | 테스트 사일로의 execution window 종료 상태. 전체 사일로 보고서 작성, 반복 원인 추출, issue/task 승격 후보 정리 완료 |
| `deleted` | 보고서/test evidence 승격 gate와 dirty status 확인 뒤 사일로 디렉토리 삭제 완료 |
| `preserved` | PR/patch, 검증, merge/cleanup 상태 확인 결과 일반 사일로 보존 필요 |
| `cleanup-candidate` | PR/patch 대응 관계와 clean 상태가 확인되어 일반 사일로 삭제 후보로 보고됨 |
| `cleanup-blocked` | 미커밋 변경, ahead commit, 원격 상태 불명확, repair/conflict 동등성 미확인 등으로 일반 사일로 삭제 금지 |
| `codex-review-pass` | PR 유형별 target/base에서 `codex-pr-review-loop` 기준 최신 head에 대한 `Didn't find any major issues` 또는 동등하게 P2 이상 actionable 지적이 없다는 명시 응답이 있고, 현재 head 대상 P2/P1/major/critical 지적이 없거나 모두 근거 있는 `수비 가능`으로 기록됐으며, `수정 필요`와 `사용자 판단 필요`가 남아 있지 않음 |
| `codex-review-fallback` | Codex review 설정 없음, 호출 권한 없음, GitHub App 미설치, repo 정책상 비활성화, no-`eyes` 3회 접수 실패 timeout, `eyes` 이후 15분 응답 대기 timeout 중 하나가 확인되어 pass가 아니라 fallback으로 기록됐고, PR URL/head SHA/확인 근거 URL/남은 수동 리뷰 필요가 남아 있음 |
| `runtime-handoff-complete` | task 실행 결과인 사일로 PR에서 실제 제품 코드 또는 runtime/browser/manual QA/E2E 확인이 남아 있고, `shared-runtime-health-check` 결과와 `silo-runtime-handoff` 댓글 URL 또는 실행 불가 사유가 PR에 기록됨 |
| `user-review-pending` | 최신 head `codex-review-pass` 또는 `codex-review-fallback` 기록이 있고, runtime handoff 대상이면 `runtime-handoff-complete`까지 끝났으며, `수정 필요` 없이 남은 `수비 가능`/남은 위험/사용자 판단 필요 항목을 사용자 재리뷰 대상으로 넘긴 상태 |
| `pr-opened` | PR 생성 완료, 메인 리뷰 대기 |
| `needs-rework` | 메인 리뷰 또는 사용자 피드백으로 재작업 필요 |
| `merged` | PR URL, state, `mergedAt`, merge commit, PR head branch, PR head SHA, GitHub target/base branch를 재조회해 머지 상태와 cleanup 가능 여부를 보고한 상태 |
| `blocked` | 사일로 단독으로 해결 불가 |
| `abandoned` | scope 변경 또는 중복으로 폐기 |

## 정리 상태와의 관계

`codex-review-pass`는 리뷰 gate 통과 상태이며 `cleanup-candidate`와 같은 뜻이 아닙니다. 일반 사일로는 `merged` 이후에도 PR/patch 대응 관계, clean 상태, 원격 상태를 별도 확인해야만 `cleanup-candidate`로 보고할 수 있습니다.

| 종료 상태 | 정리 상태 | 관계 |
|---|---|---|
| `report-promoted` | `report-promoted` | 같은 테스트 사일로 evidence 승격 완료 상태 |
| `execution-window-reported` | `execution-window-reported` | 같은 execution window 전체 보고 완료 상태 |
| `deleted` | `deleted` | 같은 테스트 사일로 삭제 완료 상태 |
| `codex-review-pass` | 해당 없음 | 리뷰 gate 통과 상태이며 삭제 후보 판정 전 단계 |
| `merged` | `cleanup-candidate` 후보 | merge 후 cleanup gate를 다시 확인해야 삭제 후보로 분류 가능 |
