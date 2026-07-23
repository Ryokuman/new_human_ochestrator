# 피드백 기반 규칙 갱신

`50-feedback-personality-loop/`는 사용자 Feedback이 현재 작업 수정, Project Contract, Project Work SSoT 실행 처방, User Layer 후보 퍼스널리티, 공통 시스템 규칙 후보로 어떻게 갈라지는지 관리합니다.

Feedback은 단순 수정 요청이 아닙니다. 현재 작업을 교정하고, 별도 갱신 세션에서 검증된 사용자 공통 판단 방향을 User Layer에 반영하는 입력입니다.

실제 유저 퍼스널리티와 Feedback은 1계층 User SSoT인 workspace의 `user-layer/` 디렉터리가 소유합니다. 이 0계층 디렉터리는 실제 사용자 데이터를 저장하지 않고 공통 절차와 template을 정의합니다.

3계층 Silo Local / Test Evidence / Temporary Feedback은 사일로 실행 중 임시 판단, 사일로 임시 feedback과 test evidence를 보관합니다. 사용자 공통 판단 방향에 관한 Feedback은 1계층 User SSoT가 소유하며, Project Work `60-feedback-update/`는 프로젝트 실행 Feedback으로 별도 유지합니다.

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
- 너무 좁은 실행 처방은 system SSoT에 고정하지 않고 성격에 따라 1계층 Project SSoT의 project contract/요구사항/ADR, 2계층 Project Work SSoT의 task/issue/QA/runbook, 또는 3계층 사일로 feedback으로 내립니다.
- 응답 계약에 영향을 주는 사건은 장기 반영 여부와 무관하게 feedback으로 남깁니다.
- feedback update는 `active/`의 열린 feedback을 기준으로 수행하고, `applied/`와 `closed/`는 기본 제외합니다.
- 보류 feedback은 `active/`에 남기되 `status: hold`, `hold_reason`, `review_after` metadata를 기록합니다.
- 일반 작업 세션의 Feedback은 `user-layer/feedback/active/`에 기록합니다.
- 장기 업데이트 검토는 사용자가 원하는 주기로 별도 검토 세션을 열어 수행합니다.
