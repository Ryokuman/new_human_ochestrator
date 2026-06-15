---
name: command-intent-preflight
description: lifecycle, run, E2E, 다건 테스트 사일로, destructive/data/production 위험 실행 전에 사용자 명령이 시스템 안에서 실행 가능한 형태로 변환되었는지 확인합니다. main-v2의 저위험 prototype에는 강제하지 않습니다.
---

# Command Intent Preflight

사용자 명령을 실제 실행으로 넘기기 전에 실행 가능한 계약으로 변환되었는지 확인합니다.

`main-v2`에서는 이 skill을 모든 작업의 선행 gate로 쓰지 않습니다. 저위험 prototype, fixture 작성, 문서 보강, 로컬 코드 변경은 합리적 가정으로 먼저 실행하고, 누락 정의를 learn 결과로 기록할 수 있습니다.

## 적용 시점

아래 요청이 나오면 이 skill을 사용합니다.

- lifecycle 실행
- run 실행
- E2E 실행
- page 단위 테스트 사일로 실행
- 여러 page나 task를 묶은 테스트 실행
- agent-browser 기반 L 확인
- destructive action, production 데이터, data SSoT 변경, 대량 import/export, 보호 브랜치 직접 변경 가능성이 있는 실행
- 사용자가 실행 결과가 이상하다고 지적하며 원인과 재발방지를 요구하는 경우

## 핵심 질문

문제를 단순한 잘못이나 태도 문제로 처리하지 않습니다.

핵심 질문은 아래입니다.

```text
왜 사용자 명령이 시스템 안에서 실행 가능한 형태로 전달되지 않았는가?
```

이 질문에 답할 때는 명령 전달 경로, 누락된 gate, 시스템 보강안을 함께 정리합니다.

## Preflight Gate

정식 실행 전 아래 항목을 확인합니다.

- 요청 계층
- 실행 대상 목록
- 제외 대상과 제외 사유
- Run Set
- `runtime_set`
- 서버형 shared runtime health gate
- 사일로 유형: 테스트 사일로 또는 일반 사일로
- 사일로 단위: 예: `1 page = 1 test silo`
- 사일로 root
- `goal.md` 생성 기준
- L별 evidence 기준
- execution window 또는 scheduler 기준
- report 위치
- evidence 승격 위치
- destructive boundary
- 종료 gate

## 누락 처리

필수 항목이 하나라도 없으면 정식 실행을 시작하지 않습니다.

단, `main-v2`의 저위험 build 작업은 정식 lifecycle/run/E2E 실행으로 보고하지 않고 prototype 또는 preflight-free build로 진행할 수 있습니다. 이때 누락된 정의는 `Learn`에 남기고 후속 spec/task 후보로 승격합니다.

보고는 아래처럼 분리합니다.

```text
완료된 것
아직 안 된 것
누락된 정의
실행하면 위험한 이유
사용자에게 물어볼 항목
다음 행동
```

## 정식 실행으로 보지 않는 것

아래는 preflight 또는 폐기 후보 산출물일 수 있지만 정식 사일로 실행으로 보고하지 않습니다.

- 사일로 root 없이 runner만 직접 실행한 것
- `goal.md` 없이 shell command만 실행한 것
- Run Set 없이 여러 page를 임의로 묶은 것
- `runtime_set` 없이 browser smoke만 실행한 것
- report/evidence 위치 없이 L 확인을 시도한 것

## 용어 처리

여러 page나 task를 묶어 실행하는 단위는 사일로가 아닙니다.

이 단위는 scheduler 또는 execution window로 기록합니다.

새 용어를 만들기 전에는 기존 dictionary, SSoT, skill 초안에 같은 개념이 있는지 확인합니다.
