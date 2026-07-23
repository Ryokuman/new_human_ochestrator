# PR 본문 템플릿

```markdown
## 무엇을 했는가

-

## 연결된 SSoT 항목

- Issue:
- Task:
- Silo:

## 작업 공간과 브랜치

- Clone 대상 레포:
- 기준 브랜치:
- 작업 브랜치:
- 보호 브랜치 직접 수정 여부: 없음
- 보호 브랜치 직접 push 여부: 없음

## 명사 설명

| 용어 | 뜻 | 실제 예시 |
|---|---|---|
|  |  |  |

## 새로 추가된 단어

Dictionary 변경이 있을 때 작성합니다. Dictionary 변경이 없으면 `해당 없음`으로 적습니다.

| 변경 유형 | 용어 | 뜻 | 사용 맥락 | 프로젝트 전용/공통 후보 | dictionary 위치 |
|---|---|---|---|---|---|
| 추가 / 수정 / 삭제 |  |  |  | 프로젝트 전용 / 공통 후보 |  |

## 변경 상세

### 문제 정의

-

### 기존 동작

-

### 문제가 된 이유

-

### 변경한 것

| 파일 | 변경 | 이유 |
|---|---|---|
|  |  |  |

### 제외 판단

| 제외 대상 | 제외 기준 | 제외하지 않는 예외 | 예시 page/item | 후속 검증 위치 |
|---|---|---|---|---|
|  |  |  |  |  |

## 그래서 무엇이 되었는가

-

- 기준:
- 변경 후:
- 목표:

## Criteria 검증 결과

| Criteria | 검증 방법 | 결과 | 증거 |
|---|---|---|---|
|  | unit / integration / runner / E2E / agent-browser / manual | pass / fail / skipped |  |

## 자동 검증 범위

- 보장하는 것:
- 보장하지 못하는 것:

## Pre-QA Gate

- 적용 여부:
- 실행 가능한 runtime:
- runtime_set:
- shared runtime health:
- runtime handoff 필요 여부:
- handoff 댓글 URL:
- E2E/user flow 출처: goal.md / task contract / PR criteria / Project SSoT / 사용자 지정 / 해당 없음
- E2E/user flow 요약:
- 접근 방법:
- 사용자 QA 리스트:

## Submodule 변경 검토

| submodule | 변경 유형 | repo PR URL | gitlink pin/head SHA | 유형 | 목적/평가 기준 | 검증 한계 | pin 조건 |
|---|---|---|---|---|---|---|---|
| 해당 없음 | 기존 / 신규 / 삭제 |  |  | patch/evidence / runtime / service/MSA |  |  |  |

## Mock/Stub/API 계약과 Version-up 후보

| slice | mock/stub/API 위치 | 목적 | mock 데이터 출처 | 응답 shape/API 계약 | 실제 service 연결 예정 위치 | 제거 조건 | 제거/연결 상태 |
|---|---|---|---|---|---|---|---|
| 해당 없음 |  |  |  |  |  |  | 제거 완료 / 실제 service 연결 완료 / 다음 버전까지 유지 / 폐기 후보 / 사용자 판단 필요 |

| version-up 후보 | 포함 slice PR | mock 제거 상태 | service 연결 상태 | 남은 QA | Project SSoT 갱신 필요 위치 | 사용자 판단 필요 |
|---|---|---|---|---|---|---|
| 해당 없음 |  |  |  |  |  |  |

## 실행 불가 또는 대체 증거

| 대상 | 실행 불가 사유 | 대체 증거 | 남은 수동 확인 |
|---|---|---|---|
|  |  |  |  |

## 검증

테스트 코드를 읽지 않아도 목적과 방법을 판단할 수 있게 테스트마다 아래 계약을 복사해 작성합니다. 이번 변경 직접 검증, 함께 동기화된 공통 회귀 검증, 형식 검사를 구분합니다.

### 테스트 계약

<details>
<summary>사용자가 이해할 수 있는 테스트 이름</summary>

- 테스트 목적:
- 준비 조건과 입력:
- 실행 방법:
- 기대 결과:
- 실제 결과: 미실행 / pass / fail / skipped와 관찰한 수치·증거
- 검증 한계:
- 재실행 명령:

</details>

- Criteria 연결:
- 실행하지 않은 검증과 이유:
- 대체 증거와 남은 수동 확인:

## Codex PR 리뷰

- 호출 여부:
- 결과:
- 최신 head:
- exact phrase 존재 여부:
- 동등 pass 판정:
- fallback 상태:
- fallback 확인 근거 URL/사유:
- 호출 댓글 URL:
- eyes 반응 확인 시각:
- 3분 no-eyes 접수 실패:
- 15분 응답 대기 timeout:
- 남은 P1/P2 또는 major/critical:
- 실패 라운드 P1/P2 수집 상태:
- 호출 댓글/head 이력:
  | 호출 댓글 URL | 호출 시각 | 호출 댓글 head SHA | 대상 head SHA 일치 | eyes 시각 | 결과 |
  |---|---|---|---|---|---|
  |  |  |  | yes/no |  |  |
- 수정 필요:
- 수비 가능:
  - 지적:
  - 수비 근거:
  - 근거 출처: 사용자 결정 / project contract / goal.md / PR scope / 코드·문서 근거 / runtime·evidence 근거
  - 남은 위험:
  - 사용자 판단 필요 여부:
- 사용자 판단 필요:
- 재호출 횟수:

## Runtime Handoff 결과

- 적용 여부:
- runtime_set:
- shared runtime health:
- handoff 댓글 URL:
- 실행 불가 사유:
- 남은 사용자 QA:

## PR Completion Gate 결과

| gate | status | headSha | evidence | failureReason | nextProcess |
|---|---|---|---|---|---|
| pr-codex-review-gate | pass / fail / skipped / timeout / stale |  |  |  |  |
| pr-agent-browser-e2e-gate | pass / fail / skipped / blocked / stale |  |  |  |  |
| pr-runtime-handoff-gate | pass / skipped / blocked / stale |  |  |  |  |

## 사용자 재리뷰 대기 상태

- 상태:
- 전이 근거: codex-review-pass / Codex review 미설정 fallback / runtime handoff 완료 / runtime handoff 비대상
- 사용자에게 확인이 필요한 항목:

## 사일로에서 새로 발견한 항목

| 항목 | 근거 | 현재 처리 |
|---|---|---|
|  |  |  |

## feedback/follow-up 후보

| 후보 | 승격 이유 | 대상 계층 | 대상 종류 | 저장 위치 | evidence grade | 적용 범위 | promotion status |
|---|---|---|---|---|---|---|---|
|  |  | 0/1/2/3계층 | issue/task/rule/decision/ADR/QA/runbook/feedback |  | low/medium/high | project/common/user | proposed/needs-user-approval/accepted/rejected/deferred |

## 처리하지 않고 남긴 항목

| 항목 | 이유 |
|---|---|
|  |  |

## 메인 오케스트레이터 판단 필요

-

## 사용자 피드백 반영 여부

-
```
