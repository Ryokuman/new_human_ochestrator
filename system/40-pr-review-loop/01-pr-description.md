# PR 본문 작성 기준

## 필수 섹션

사일로가 PR을 만들 때 본문에는 아래 섹션이 있어야 합니다. 필수 섹션은 조건부로 생략하지 않습니다. 해당 변경이나 기록 대상이 없으면 섹션을 유지하고 `해당 없음`으로 적습니다.

이 목록은 실제 PR 제출 전 기준입니다. `setup.sh --create-project-ssot`이 만드는 `templates/pr-description.md`는 프로젝트별 PR 본문을 빠르게 시작하기 위한 최소 템플릿이므로 이 목록 전체를 생성 시점에 모두 포함하지 않아도 됩니다. 사일로 결과를 실제 PR로 올릴 때는 [`06-pr-template.md`](06-pr-template.md)의 확장 템플릿 또는 아래 목록으로 본문을 보강하고, 해당 없는 섹션도 `해당 없음` 또는 생략 사유를 남깁니다.

```markdown
## 무엇을 했는가

## 연결된 SSoT 항목

## 작업 공간과 브랜치

## 명사 설명

## 새로 추가된 단어

## 변경 상세

## 그래서 무엇이 되었는가

## Criteria 검증 결과

## 자동 검증 범위

## Pre-QA Gate

## Submodule 변경 검토

## Mock/Stub/API 계약과 Version-up 후보

## 실행 불가 또는 대체 증거

## 검증

## Codex PR 리뷰

## Runtime Handoff 결과

## PR Completion Gate 결과

## 사용자 재리뷰 대기 상태

## 사일로에서 새로 발견한 항목

## feedback/follow-up 후보

## 처리하지 않고 남긴 항목

## 메인 오케스트레이터 판단 필요

## 사용자 피드백 반영 여부
```

## 설명 기준

PR 본문은 결과만 나열하지 않고, 처음 보는 리뷰어가 변경 이유와 안전성을 판단할 수 있게 씁니다.

특히 converter, renderer, runner, generated output, data mapping, coverage 보정처럼 원인 추적이 중요한 작업은 아래 흐름을 기본 구조로 삼습니다.

```text
명사 설명
-> 문제 정의
-> 기존 동작
-> 문제가 된 이유
-> 변경 상세
-> 결과
-> 검증
-> 남은 위험
```

## 명사 설명

- 특수용어, 고유명사, 내부 약어, runner 용어, coverage 용어를 첫 등장 또는 `명사 설명` 섹션에서 정의합니다.
- `제외`, `보정`, `surface`, `inventory`, `extra`, `runner`처럼 내부 판단을 함축하는 표현은 실제 예시와 함께 설명합니다.
- 이 섹션은 해당 PR을 즉시 이해하기 위한 설명입니다.

## 새로 추가된 단어

필수 섹션은 항상 존재합니다. dictionary SSoT에 실제 추가/수정/삭제된 용어가 있으면 표로 작성하고, 변경이 없으면 `해당 없음`으로 적습니다.

최소 컬럼은 아래와 같습니다.

| 변경 유형 | 용어 | 뜻 | 사용 맥락 | 프로젝트 전용/공통 후보 | dictionary 위치 |
|---|---|---|---|---|---|

## 변경 상세

- 어떤 coverage/task/issue를 줄이거나 종결하려는지 적습니다.
- 초기 수치, 현재 수치, 목표 수치를 적습니다.
- 기존 코드가 어떤 입력을 어떻게 처리했는지 적습니다.
- 실제 실패 evidence를 증상 대신 누락/과다/오분류/불안정 파싱 같은 방향으로 설명합니다.
- 파일별 변경과 함수/정책 역할을 적습니다.
- 제외 판단이 있으면 제외 대상, 제외 기준, 제외하지 않는 예외, 예시 page/item, 후속 검증 위치를 함께 적습니다.

## 검증

- 실행 명령과 통과 수치만 나열하지 않습니다. 사용자가 테스트 코드를 읽지 않아도 테스트의 의도, 방법, 성공 기준과 한계를 판단할 수 있는 테스트 계약을 먼저 적습니다.
- 각 테스트 계약에는 `테스트 목적`, `준비 조건과 입력`, `실행 방법`, `기대 결과`, `실제 결과`, `검증 한계`, `재실행 명령`을 포함합니다.
- 실행 전 초안의 `실제 결과`는 `미실행`으로 두고, 실행 뒤 관찰한 결과와 증거로만 갱신합니다.
- 정상 조건만 확인하지 않고 해당 변경에서 중요한 실패 조건, 경계값 또는 거부 시나리오를 어떤 입력으로 만들었는지 설명합니다.
- 각 acceptance criteria를 어떤 테스트 계약이 덮는지 연결합니다.
- 이번 변경을 직접 검증하는 테스트, 함께 동기화된 공통 규칙의 회귀 테스트, lint·공백 같은 형식 검사를 구분합니다.
- 자동 검증이 보장하는 것과 보장하지 못하는 것을 테스트별 `검증 한계`에 적습니다.
- 명령은 기본 판단 자료가 아니라 결과를 재현하려는 독자를 위한 세부 정보로 둡니다.
- 사용자 화면, 설치, 서버 실행, 앱 다운로드 가능 상태가 acceptance에 포함되면 `Pre-QA Gate`와 사용자 QA 리스트를 적습니다.
- 실행하지 않은 검증이 있으면 이유를 적습니다.
- runner, E2E, agent-browser, 외부 도구를 실행할 수 없으면 실행 불가 사유, 대체 증거, 남은 수동 확인 범위를 적습니다.

## Submodule 변경 검토

- submodule 변경이 없으면 `해당 없음`으로 적습니다.
- 기존 submodule gitlink가 바뀌면 submodule repo별 PR URL, head SHA, pin한 commit, submodule 유형(`patch/evidence`, `runtime`, `service/MSA`), 상위 repo에서 검증한 host 설정/실행 경로 연결을 적습니다.
- 신규 submodule이면 repo 존재 목적, 제품 적용 기준, 평가 기준, 검증 한계, pin 조건, service/MSA 승격 근거 또는 비승격 근거를 적습니다.

## Mock/Stub/API 계약과 Version-up 후보

- mock/stub/API 임시 계약이 없으면 `해당 없음`으로 적습니다.
- 임시 계약이 있으면 slice, mock/stub/API 위치, 목적, mock 데이터 출처, 응답 shape, 실제 service 연결 예정 위치, 제거 조건, 제거 상태를 적습니다.
- mock 제거 대조표는 `제거 완료`, `실제 service 연결 완료`, `다음 버전까지 유지`, `폐기 후보`, `사용자 판단 필요`로 분류합니다.
- version-up 후보는 대상 버전, 포함 slice PR, mock 제거 상태, service 연결 상태, 남은 QA, Project SSoT 갱신 필요 위치를 적습니다.

## Codex PR 리뷰

- exact pass phrase 존재 여부와 동등 pass 판정 근거를 분리합니다.
- `Codex review 미설정` fallback이면 확인 근거 URL/사유, 최신 head, 남은 수동 리뷰 필요를 적습니다.
- 호출 댓글 URL, `eyes` 반응 확인 시각, no-`eyes` 3회 접수 실패 여부, `eyes` 이후 15분 응답 대기 timeout 여부를 적습니다.
- 호출 댓글마다 URL, 댓글 작성 시각, 호출 댓글에 적은 head SHA, 대상 head SHA 일치 여부를 이력으로 남깁니다.
- `수비 가능` 항목은 지적, 수비 근거, 근거 출처, 남은 위험, 사용자 판단 필요 여부를 함께 적습니다. 근거 출처는 project contract에 한정하지 않고 사용자 결정, `goal.md`, PR scope, 코드/문서 근거, runtime/evidence 근거를 함께 허용합니다.
- codex-review pass가 없는 실패 라운드에서도 현재 head 대상 P1/P2/major/critical 수집 상태와 분류 상태를 남깁니다.

## Runtime Handoff 결과

- runtime handoff 대상이 아니면 이유와 함께 `해당 없음`으로 적습니다.
- 대상이면 `runtime_set`, shared runtime health 결과, handoff 댓글 URL, 실행 불가 사유, 남은 사용자 QA 항목을 적습니다.

## PR Completion Gate 결과

- gate별 최소 필드는 `status`, `headSha`, `evidence`, `failureReason`, `nextProcess`입니다.
- `pr-codex-review-gate`, `pr-agent-browser-e2e-gate`, `pr-runtime-handoff-gate` 중 적용한 gate와 생략한 gate를 분리합니다.
- 새 head가 push되면 이전 head의 gate 결과를 stale로 표시하고 최신 head 근거로 재사용하지 않습니다.

## feedback/follow-up 후보

- 후보마다 저장 위치, 대상 계층, 대상 종류, evidence grade, 적용 범위, promotion status를 적습니다.
- 1계층 후보는 Project SSoT의 project contract/decision/ADR/요구사항 위치로, 2계층 후보는 Project Work SSoT의 task/issue/QA/runbook/coverage/Run Set 위치로 분리합니다.

## 좋지 않은 본문

- 변경 결과만 쓰고 어떤 입력이 왜 버려졌는지 설명하지 않습니다.
- 내부자 표현만 쓰고 파싱/변환/렌더링/runner 중 어디에서 일어나는지 설명하지 않습니다.
- coverage 수치가 줄었다고만 쓰고 기준 run, 변경 후 run, 남은 목표를 적지 않습니다.

## 좋은 본문

- 헷갈릴 수 있는 용어를 실제 예시와 함께 정의합니다.
- 기존 코드의 제외 조건과 그 조건이 문제를 만든 이유를 분리합니다.
- 제외 판단은 무엇을 제외했는가, 왜 제외했는가, 무엇은 제외하지 않는가, 어디서 다시 검증하는가를 함께 적습니다.
- 변경 파일, 함수 역할, 변경 메커니즘, 결과 수치, 남은 위험을 한 흐름으로 연결합니다.
