# 반영 범위와 저장 위치

## User Layer 소유권

User Layer는 0계층이나 3계층 local이 아니라 1계층 User SSoT입니다. 실제 유저 퍼스널리티와 Feedback은 workspace의 `user-layer/` 디렉터리가 소유합니다.

```text
<workspace>/user-layer/
├── AGENTS.md
├── feedback/
│   ├── active/
│   ├── applied/
│   └── closed/
└── update-sessions/
```

0계층 public repo는 실제 사용자 데이터를 추적하지 않고 schema, template, setup, 라우팅과 public guard만 소유합니다.

## Feedback 범위 라우팅

| 범위 | 저장 위치 |
|---|---|
| 사용자 공통 판단 방향 | `user-layer/feedback/`에서 검토 후 `user-layer/AGENTS.md` |
| 특정 프로젝트의 제품 불변 조건 | 해당 Project AGENTS |
| 프로젝트 작업 실행 기준 | Project Work SSoT의 Task, Issue, QA, Runbook 또는 `60-feedback-update/` |
| 현재 Task 또는 Silo 전용 | Task 문서, `goal.md`, Silo Local 또는 PR 본문 |
| 공통 시스템 운영 방식 | 0계층 공통 규칙 또는 Operating Hypothesis 후보 |
| 일회성 교정 | 현재 작업에 반영한 뒤 Feedback 종료 후보 |

Project Work SSoT의 `60-feedback-update/feedback/`은 특정 프로젝트 실행 Feedback이므로 유지합니다. User Layer Feedback과 합치지 않습니다.

## 파일별 역할

| 경로 | 역할 |
|---|---|
| `AGENTS.md` | 검증과 사용자 승인을 마친 현재 유저 퍼스널리티 정본 |
| `feedback/active/` | 응답 계약 또는 판단 방향에 영향을 준 아직 검토 중인 Feedback |
| `feedback/applied/` | 승인된 반영을 완료한 Feedback |
| `feedback/closed/` | 기각, 중복, 일회성 또는 다른 계층으로 라우팅되어 종료된 Feedback |
| `update-sessions/` | 후보 퍼스널리티와 시나리오 검증, 후보 diff, 승인 결과 기록 |

## Feedback 최소 형식

```markdown
# Feedback

## 메타

- 날짜:
- 상태: active
- 트리거:
- 적용 범위 후보:

## 사용자 교정

## 발생한 불일치

## 현재 작업에 반영한 조치

## 범위 라우팅 후보
```

Feedback은 모든 대화 원문을 저장하는 장치가 아닙니다. 사건 판단에 필요한 사용자 교정, 놓친 신호, 현재 조치와 범위 후보만 기록합니다.

## 커밋과 공개 경계

- 실제 User Layer 반영은 workspace의 User SSoT 디렉터리에서 수행합니다.
- 실제 `user-layer/`는 0계층 public export에서 명시적으로 차단합니다.
- `system/templates/user-layer/`만 공개합니다.
- 유저 퍼스널리티 장기 갱신은 0계층 PR로 처리하지 않습니다.
- 여러 사용자나 프로젝트에 반복되는 공통 시스템 규칙만 별도 승인 후 0계층 PR 후보로 분리합니다.
- Project Contract는 해당 project 계층 PR로 반영합니다.
