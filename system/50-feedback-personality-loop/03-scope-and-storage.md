# 반영 범위와 저장 위치

## 반영 위치

피드백은 범위에 따라 다르게 저장합니다.

| 범위 | 저장 위치 | 예시 |
|---|---|---|
| PR 전용 | PR record | 이번 PR의 특정 수정 요청 |
| 사일로 전용 | silo rules | 이 사일로가 QA를 얕게 한 문제 |
| 프로젝트 전용 | project context 또는 project SSoT | 특정 프로젝트만의 검증 규칙 |
| 전역 사용자 규칙 | `AGENTS.md`, 역할별 agent 프롬프트, 또는 관련 공통 규칙 | 모든 프롬프트는 한국어 |
| 메인 오케스트레이터 규칙 | `10-agents/main-orchestrator/` 또는 관련 skill | 목표 분류 후 작업 시작 |

## Project SSoT 산출물 피드백 처리

사용자가 project SSoT의 대시보드, 태스크 시스템, 이슈 관리, L 기준, viewer/plugin 설정이 필요하다고 피드백하면 다음처럼 처리합니다.

- project 산출물 자체를 root `main-v2`에 올리지 않습니다.
- 반복 가능한 구조라면 0계층 `system/`의 `setup.sh` 셋업 흐름, 템플릿, 스킬 초안으로 승격합니다.
- 생성된 실제 project 파일은 project SSoT 또는 project 전용 PR에서만 다룹니다.
- viewer/plugin 설정은 project별 필요가 확정될 때 별도 task로 다룹니다.

## 보고서 저장

퍼스널리티 업데이트 증거와 보고서는 실제 사용자 성향 데이터이므로 기본적으로 gitignore된 로컬 자료로 둡니다. 템플릿만 git에 포함합니다.

응답 계약에 영향을 주는 사건은 승격 여부와 무관하게 evidence로 남깁니다. 여기서 evidence는 모든 답변 원문 장기 저장이 아니라, 사건 판단에 필요한 사용자 발화 일부, 에이전트가 놓친 신호, 즉시 조치, 적용 범위 후보를 기록하는 자료입니다.

## 로컬 저장 위치

기본 저장 위치는 아래처럼 둡니다.

```text
local/personality-feedback-log/
├── evidence/
│   └── YYYY-MM-DD-<short-topic>.md
├── reports/
│   └── YYYY-MM-DD-personality-update-report.md
└── index.md
```

`local/`은 `system/.gitignore`에 포함된 로컬 전용 공간입니다. 이 경로의 실제 로그는 기본적으로 커밋하지 않습니다.

## 파일별 역할

| 경로 | 역할 |
|---|---|
| `evidence/` | 개별 피드백, 보기 밖 선택, 보기 누락, 스킬 보고 누락, 의사소통 mismatch를 원문 일부/해석/즉시 조치로 반드시 기록 |
| `reports/` | 사용자가 원하는 주기로 여는 검토 세션에서 여러 evidence를 묶어 장기 규칙 후보로 정리한 업데이트 보고서 |
| `index.md` | evidence 목록, 상태, 연결된 보고서, 승인 여부를 추적 |

## Evidence 최소 형식

```markdown
# Personality Feedback Evidence

## 메타

- 날짜:
- 세션:
- 트리거:
- 증거 등급: explicit | repeated | tentative | rejected
- 적용 범위 후보: 현재 작업 | 사일로 | 프로젝트 | 전역
- 상태: logged | reported | approved | rejected | revised

## 사용자 피드백 원문

## 발생한 불일치

## 즉시 반영한 조치

## 장기 규칙 후보

## 연결 보고서
```

## 커밋 기준

- `local/personality-feedback-log/`의 실제 evidence/report는 커밋하지 않습니다.
- 반복 가능한 구조, 템플릿, 승인된 전역 규칙만 `system/`에 반영합니다.
- project 전용 규칙은 project SSoT에 둡니다.
