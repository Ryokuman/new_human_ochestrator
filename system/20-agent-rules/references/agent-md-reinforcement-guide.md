# 에이전트 md 보강 가이드

## 목적

이 문서는 에이전트 md가 빈약할 때 무엇을 보강해야 하는지, 어떤 reference를 근거로 삼아야 하는지 정합니다.

핵심은 에이전트 md 자체를 두껍게 만드는 것이 아닙니다. 에이전트 md는 다음 행동을 결정할 수 있을 만큼의 운영 규칙과 reference 읽기 순서를 가져야 합니다.

## 빈약함의 신호

아래 중 하나가 있으면 에이전트 md 보강이 필요합니다.

- 기존 프로젝트 맥락을 어디서 읽어야 하는지 모호함
- PR 리뷰 피드백을 단순 수정 요청으로만 처리함
- 사용자 피드백을 장기 규칙 후보로 분류하지 못함
- 보고 형식이 매번 달라져 사용자가 현재 상태를 빠르게 파악하지 못함
- 프로젝트 내부 자료를 0계층 `system/`에 직접 가져올지 판단 기준이 없음
- 사일로 작업과 메인 오케스트레이터 작업의 책임 경계가 흐림

## 보강 절차

### 1. 부족한 영역 분류

먼저 부족한 영역을 분류합니다.

| 영역 | 질문 | 우선 reference |
|---|---|---|
| 프로젝트 맥락 | 기존 프로젝트의 SSoT, 작업 방식, 보호 브랜치, 검증 기준을 어디서 읽는가 | `project-context-reference-template.md` |
| PR 리뷰 | 어떤 기준으로 PR을 보고, 무엇을 SSoT 후보로 올리는가 | `pr-review-reference-template.md` |
| 보고 방식 | 완료/미완료/목표 밖/다음 행동을 어떻게 분리하는가 | `reporting-and-personality-reference-template.md` |
| 퍼스널리티 | 사용자 취향을 확정/후보/제외로 어떻게 나누는가 | `reporting-and-personality-reference-template.md` |
| 계층 관리 | 0~3계층 중 어디에 저장할지 어떻게 판단하는가 | `../skill-drafts/root-layer-manager/SKILL.md` |

### 2. reference로 근거 만들기

보강하려는 규칙마다 최소 하나의 근거를 남깁니다.

근거는 아래 중 하나여야 합니다.

- 사용자가 명시한 피드백
- 여러 PR 리뷰에서 반복된 지적
- 기존 프로젝트 문서에서 확인되는 운영 패턴
- 이미 `system/` 문서에 정의된 계층/SSoT/사일로 정책

단일 대화에서 나온 추측은 바로 확정 규칙으로 만들지 않고 후보로 둡니다.

### 3. 에이전트 md에 넣을 내용과 reference에 둘 내용 분리

에이전트 md에 넣을 것:

- 처음 읽을 문서 순서
- 계층 판정 규칙
- reference를 읽어야 하는 조건
- 금지 사항
- 보고 형식
- 사용자 승인 필요 조건

reference에 둘 것:

- 프로젝트별 반복 패턴 요약
- PR 리뷰 체크리스트의 근거
- 사용자 피드백 사례와 해석
- 보강 후보와 승인 상태
- 장문 템플릿과 세부 점검표

### 4. 승격 전 점검

에이전트 md에 새 규칙을 넣기 전에 확인합니다.

- 이 규칙이 특정 프로젝트에만 유효하지 않은가
- 사용자 승인 없이 퍼스널리티를 확정하고 있지 않은가
- 실제 secret이나 프로젝트 내부 자료를 복사하지 않았는가
- 기존 계층 정책과 충돌하지 않는가
- 에이전트가 다음 행동을 더 명확히 결정하게 만드는가

## 권장 에이전트 md 섹션

에이전트 md에는 아래 섹션을 두는 것을 권장합니다.

```text
Scope
Read Order
Layer Policy
Reference Policy
Edit Policy
PR Review Policy
Personality Option Policy
Reporting
Forbidden Actions
```

## Reference Policy 예시

```text
에이전트 md가 현재 작업을 판단하기에 부족하면 먼저 reference를 찾는다.

- 프로젝트 맥락이 부족하면 project-context reference를 읽는다.
- PR 리뷰 기준이 부족하면 pr-review reference를 읽는다.
- 보고 방식이나 퍼스널리티 판단이 부족하면 reporting/personality reference를 읽는다.
- reference에서 반복 근거가 확인된 내용만 공통 규칙으로 승격한다.
- 단일 피드백은 후보로 기록하고, 사용자 승인 전에는 장기 규칙으로 확정하지 않는다.
```

## 완료 기준

에이전트 md 보강은 아래를 만족해야 완료로 봅니다.

- 부족했던 영역이 어떤 reference로 보강됐는지 추적 가능함
- 에이전트 md가 모든 세부 자료를 품지 않고 reference 읽기 조건을 제공함
- 프로젝트 내부 실제 자료를 0계층에 복사하지 않음
- 퍼스널리티 규칙은 승인 상태가 분리됨
- PR description에 승격 후보와 승격하지 않을 항목을 보고할 수 있음
