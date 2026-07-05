# 피드백 기반 규칙 갱신

`50-feedback-personality-loop/`는 사용자 feedback이 현재 작업 수정, 사일로 전용 규칙, 프로젝트 규칙, User Layer evidence, 승인된 공통 규칙 후보로 어떻게 갈라지는지 관리합니다.

feedback은 단순 수정 요청이 아닙니다. 현재 PR 또는 사일로의 작업 방향을 바꿀 수 있고, feedback update를 통해 User Layer의 퍼스널리티/evidence와 승인된 0계층 공통 기준, 1계층 project 기준을 개인화할 수 있습니다.

`personality`, `feedback evidence`, `hypothesis`의 실제 사용자별 상태는 User Layer가 소유합니다. 이 디렉토리는 실제 사용자 데이터를 저장하는 위치가 아니라, User Layer로 수집하고 승격하는 공통 절차와 template을 정의합니다.

3계층은 Silo Local / Test Evidence / Feedback 계층입니다. test evidence, 현재 local feedback 기록, 사일로 실행 중 발견한 임시 판단, 아직 공통 규칙으로 확정하지 않은 follow-up 자료를 보관합니다. 이 계층의 자료는 기본적으로 `local/` 또는 사일로 로컬 공간에 두며, 장기 규칙이나 project 기준으로 반영하려면 별도 검토와 승인 절차를 거칩니다.

## 읽는 순서

1. [`01-feedback-types.md`](01-feedback-types.md)
2. [`02-update-flow.md`](02-update-flow.md)
3. [`03-scope-and-storage.md`](03-scope-and-storage.md)
4. [`04-evidence-and-promotion.md`](04-evidence-and-promotion.md)
5. [`05-current-rules.md`](05-current-rules.md)
6. [`06-system-scope-routing-audit.md`](06-system-scope-routing-audit.md)
7. [`personality-update-report.template.md`](personality-update-report.template.md)

## 핵심 원칙

- 단일 피드백을 장기 규칙으로 바로 확정하지 않습니다.
- 현재 작업 지시와 장기 규칙 후보를 분리합니다.
- 실제 규칙 반영은 사용자 승인 후에만 수행합니다.
- 프로젝트 내부 실제 산출물은 root `main-v3/main`에 복사하지 않습니다.
- 너무 좁은 실행 처방은 system SSoT에 고정하지 않고 project SSoT, task 계약, runbook, QA checklist로 내립니다.
- 응답 계약에 영향을 주는 사건은 장기 반영 여부와 무관하게 feedback으로 남깁니다.
- feedback update는 `active/`의 열린 feedback을 기준으로 수행하고, `applied/`와 `closed/`는 기본 제외합니다.
- 보류 feedback은 `active/`에 남기되 `status: hold`, `hold_reason`, `review_after` metadata를 기록합니다.
- 증거 로그는 `local/personality-feedback-log/`에 저장하고 기본적으로 커밋하지 않습니다.
- 장기 업데이트 검토는 사용자가 원하는 주기로 별도 검토 세션을 열어 수행합니다.
