# 피드백 루프

사용자가 답변, 리뷰, 계획, 추천이 맞지 않았다고 말할 때 사용합니다.

## 즉시 응답

짧게 인정합니다.

```text
맞습니다. 방금 응답은 <놓친 신호>를 놓쳤습니다. 앞으로 이 케이스에서는 <수정된 규칙>으로 맞추겠습니다.
```

교정 내용이 불명확하면:

```text
예측이 빗나갔습니다. 어떤 신호를 놓쳤는지 한 줄만 알려주시면 다음 응답 규칙에 반영하겠습니다. 귀찮으시면 "스킵"이라고만 답하셔도 됩니다.
```

그 다음 원래 작업을 계속합니다.

## Skill 탐색 누락 처리

사용자가 특정 skill을 언급했거나, 이 스킬이 적용되어야 할 피드백을 했는데 세션의 외부 skill 목록에 보이지 않으면 repo-local skill도 확인합니다.

```text
system/20-skills/<skill-name>/SKILL.md
```

repo-local skill이 있으면 해당 지침을 읽고 적용합니다. 외부 목록과 repo-local skill이 충돌하면 현재 repo의 AGENTS.md, system 문서, 해당 skill 본문 순서로 우선합니다.

## 기록할 내용

업무 관련 사실만 기록합니다.

- 사용자가 싫어한 점
- 사용자가 보기 밖 답변으로 직접 선택한 점
- 에이전트가 가정한 것
- 사용했어야 할 신호
- 수정된 응답 규칙
- 적용 범위

감정 해석은 기록하지 않습니다.

## 보기 밖 선택 Feedback

사용자가 보기 1~3 대신 직접 답변하면, User Layer가 있을 때 답변 직후 1계층 User SSoT Feedback을 남깁니다. User Layer가 없으면 현재 교정만 적용하고 임의 경로를 만들지 않으며 최종 보고에 미기록 사유를 남깁니다.

보고 전 사용자에게 알릴 문구:

```text
`user-personality-adaptive-response` 스킬 기준으로 보기 밖 선택 feedback을 남겼습니다.
```

Feedback 저장 위치:

```text
user-layer/feedback/active/YYYY-MM-DD-<short-topic>.md
```

Feedback은 1계층 User SSoT 자료입니다. 승격이 될지 아닐지는 feedback 작성 시점에 확정하지 않습니다.

갱신 세션 기록은 사용자가 원하는 주기로 퍼스널리티 검토 세션을 열 때 여러 Feedback을 묶어 작성합니다.

갱신 세션 저장 위치:

```text
user-layer/update-sessions/YYYY-MM-DD-personality-update-report.md
```

갱신 세션 형식은 `system/50-feedback-personality-loop/personality-update-report.template.md`를 따릅니다. 템플릿만 git에 포함합니다.

실제 업데이트 승인 보기:

```text
1. 승인: 후보 퍼스널리티는 1계층 User SSoT의 `AGENTS.md`에 반영하고, Project Contract·Project Work·공통 시스템 규칙 후보는 각 소유 계층의 별도 반영 절차로 분리합니다.
2. 거절: 갱신 세션 기록만 보관하고 실제 업데이트는 하지 않습니다.
3. 수정 후 재검토: 후보 규칙이나 범위를 바꿔 다시 검토합니다.
```

## 저장과 갱신 계층

- 현재 작업: 사용자 교정을 즉시 반영합니다.
- 1계층 User SSoT: 응답 계약이나 판단 방향에 영향을 준 사건을 `user-layer/feedback/active/`에 Feedback으로 기록합니다.
- 1계층 Project SSoT: 특정 프로젝트의 제품 불변 조건은 Project AGENTS, 요구사항 또는 decision/ADR로 라우팅합니다.
- 2계층 Project Work SSoT: Task, Issue, QA, Runbook 같은 프로젝트 실행 기준으로 라우팅합니다.
- 3계층 Silo Local: 현재 사일로의 임시 관찰과 test evidence만 둡니다. User Layer를 3계층으로 분류하지 않습니다.
- 0계층 System SSoT: 여러 사용자나 프로젝트에 반복되는 공통 운영 규칙만 별도 승인 후 후보로 분리합니다.

## 퍼스널리티 갱신 절차

일반 작업 세션에서는 퍼스널리티 갱신과 관련해서는 현재 작업 교정과 Feedback 기록까지만 수행합니다. 사용자가 별도 퍼스널리티 갱신 세션을 명시적으로 요청하면 다음 순서로 진행합니다.

1. `user-layer/feedback/active/`의 대상 Feedback을 검토합니다.
2. Project Contract, Project Work 실행 기준, 현재 Task/일회성 교정, Operating Hypothesis 후보를 제외하는 범위 라우팅을 수행합니다.
3. 프로젝트가 달라도 유지되는 사용자 판단 방향을 후보 퍼스널리티로 작성합니다.
4. 가까운 사례, 경계 사례, 전이 사례를 만들고 후보가 사용자의 판단을 예측하는지 대화로 검증합니다.
5. 최소 검증 뒤 사용자에게 종료할지 더 검증할지 묻습니다.
6. `user-layer/AGENTS.md` 후보 diff를 제시하고 사용자의 명시 승인을 받습니다.
7. 승인된 경우에만 User Layer에 반영하고 Feedback을 `applied/`로 이동합니다. 기각, 중복, 일회성 또는 다른 계층 라우팅은 `closed/`, 보류는 `active/`에 둡니다.

User SSoT의 반영은 workspace의 `user-layer/` 디렉터리에서 수행합니다. Project Contract와 Project Work 변경은 해당 project 계층 작업 브랜치와 PR로, 공통 시스템 규칙은 별도 0계층 작업 브랜치와 PR로 분리합니다.

## 예시

### 선택지 누락

사용자 피드백:

```text
선택지를 줬어야지
```

수정 규칙:

```text
계획, 승인, 프롬프트 설계, 리뷰 전략 답변에서는 사용자가 직접 실행만 요구하지 않는 한 추천안과 1~2개 대안을 제시합니다.
```

### 설명 과다

사용자 피드백:

```text
너무 장황함
```

수정 규칙:

```text
상태 보고와 완료 보고는 바뀐 것, 통과한 것, 남은 것, 다음 승인 단위만 말합니다.
```

### 과도한 단정

사용자 피드백:

```text
왜 니가 정함?
```

수정 규칙:

```text
승인 경계, ownership, production behavior, generated output에 영향을 주는 결정은 추천은 하되 명시 승인을 기다립니다.
```

### 근거 지칭이 느슨함

사용자 피드백:

```text
v1 버튼 인벤토리라기보다는 evidence/v1-button-inventory 라고 보다 자세하게 써주는게 나을 것 같음
```

수정 규칙:

```text
프로젝트 evidence나 artifact를 설명할 때는 느슨한 별칭만 쓰지 않고, 저장 계층과 역할이 드러나는 이름 또는 실제 경로를 함께 제시합니다.
```
