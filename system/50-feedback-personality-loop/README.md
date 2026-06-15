# 피드백 기반 규칙 갱신

`50-feedback-personality-loop/`는 사용자 피드백이 현재 작업 수정, 사일로 전용 규칙, 프로젝트 규칙, 전역 사용자 규칙으로 어떻게 갈라지는지 관리합니다.

피드백은 단순 수정 요청이 아닙니다. 현재 PR 또는 사일로의 작업 방향을 바꿀 수 있고, 반복되면 메인 오케스트레이터 또는 역할별 agent 규칙 후보가 될 수 있습니다.

## 읽는 순서

1. [`01-feedback-types.md`](01-feedback-types.md)
2. [`02-update-flow.md`](02-update-flow.md)
3. [`03-scope-and-storage.md`](03-scope-and-storage.md)
4. [`04-evidence-and-promotion.md`](04-evidence-and-promotion.md)
5. [`05-current-rules.md`](05-current-rules.md)
6. [`personality-update-report.template.md`](personality-update-report.template.md)

## 핵심 원칙

- 단일 피드백을 장기 규칙으로 바로 확정하지 않습니다.
- 현재 작업 지시와 장기 규칙 후보를 분리합니다.
- 실제 규칙 반영은 사용자 승인 후에만 수행합니다.
- 프로젝트 내부 실제 산출물은 root `main-v2`에 복사하지 않습니다.
- 증거 로그는 `local/personality-feedback-log/`에 저장하고 기본적으로 커밋하지 않습니다.
- 장기 업데이트 검토는 세션 종료 전, PR 생성 전, 같은 유형 증거 3건 누적, 사용자 명시 요청, 주 1회 유지보수 시점에 수행합니다.
