# 시스템 범위 라우팅 감사

## 목적

이 문서는 system SSoT에 들어온 피드백이나 agent 감사 결과가 너무 좁은 스코프인지 판정하고, 올바른 저장 계층으로 내리는 기준을 정합니다.

`system/`은 상황별 실행 처방을 모으는 곳이 아니라 판단 근거, 계층 분류, 반영 검토 기준을 모으는 하네스입니다. 따라서 특정 프로젝트, provider, 화면, 테스트 데이터, 실행 harness의 실제 방법은 system SSoT에 고정하지 않습니다.

## 좁은 스코프 신호

아래 신호가 보이면 0계층 전역 규칙이 아니라 project SSoT, task 계약, 또는 silo local evidence 후보로 먼저 분류합니다.

- 특정 외부 서비스나 provider 이름이 들어간다.
- 특정 인증 전환, token, identity, account, redirect, claim 같은 인증 구현 세부가 들어간다.
- 특정 화면 버튼, 인증 이후 전환 화면, 실패 UI, 취소 UI처럼 제품 화면 구조가 들어간다.
- 특정 DB row, seed, fixture, mock, 개발용 인증, 컨테이너 구성처럼 프로젝트 실행 수단이 들어간다.
- 특정 L 단계 이름, runner 이름, merge 전 QA gate처럼 프로젝트별 검증 체계가 들어간다.
- 특정 repo, route, schema, table, store method, API endpoint가 들어간다.

이 항목들은 system에서 금지된 주제가 아닙니다. 다만 system에는 실제 값과 절차를 쓰지 않고, 그 항목이 왜 외부 통제 요소인지, 어떤 계층에 기록해야 하는지, 완료 보고에서 무엇을 섞으면 안 되는지만 남깁니다.

DB schema, API contract, auth/session contract, runtime DB/harness DB 계약처럼 task 작성과 mock data 정의에 필수인 중요 제품 정보는 project registry/config 또는 project SSoT에 정본 위치나 요약이 있어야 합니다. 특히 초기 DB 목데이터가 필요한 task에서 schema 참조가 없으면 테이블, 컬럼, FK, 날짜 테이블, profile, goal 같은 제품 구조를 추정하지 않고 `project SSoT schema 계약 누락`으로 분류합니다.

DB를 사용하는 프로젝트는 등록/setup 시 DB schema 정본 위치 또는 schema 요약 위치를 project registry/config 또는 project SSoT에 기록해야 합니다. Docker, compose, migration, startup script로 DB가 자동 생성되거나 갱신되는 프로젝트는 setup 문서에 schema 적용 경로도 함께 기록합니다. 이 setup 기록이 없으면 task-writer가 schema 관련 프롬프트나 초기 DB 목데이터 계약을 쓰기 전에 `project setup schema 계약 누락`으로 보고합니다.

1계층 project overview, registry, config에는 특정 task/silo의 구현 준비 상태를 올리지 않습니다. 특정 `TASK-NNNN`, 단일 API/page 실행 계약, endpoint 추가 필요성, task 고유 `Initial Mock Data`/`Test Inputs`는 task 문서, runbook, 사일로 `goal.md`로 내려보내고, 1계층에는 정본 위치와 하위 SSoT 인덱스만 둡니다.

## 계층 라우팅

| 발견한 내용 | system에 남길 것 | 내려보낼 위치 |
|---|---|---|
| 외부 서비스나 인증 provider별 동작 | 통제 가능성, 증명 가능성, 사용자 승인 필요 여부 | project SSoT의 service policy, auth runbook, task 계약 |
| 실제 계정, redirect, secret, credential, token 관련 조건 | secret 원문 미기록, 승인 gate, evidence 분리 기준 | secret manager, project registry/config, project SSoT 참조 |
| 화면별 버튼, 인증 전환 화면, error UI | 실제 사용자 경로와 agent 통제 경로를 분리하는 기준 | project task, QA checklist, 화면별 acceptance |
| DB schema, API contract, auth/session contract | 중요 제품 정보의 정본 위치를 먼저 확인하고 없으면 추정하지 않는 기준 | project registry/config, project SSoT의 contract 요약 또는 정본 링크 |
| DB 사용 프로젝트의 등록/setup | schema 정본 위치, schema 요약 위치, schema 적용 경로를 setup 때 기록해야 한다는 기준 | project registry/config, project SSoT, setup 문서 |
| seed, fixture, mock, 개발용 인증, 컨테이너 DB | 통제된 대체 검증과 실제 사용자 경로를 섞지 않는 기준 | project test contract, runtime/runbook, task Test Plan |
| L 단계, runner, coverage gate | system에 고정하지 않는다는 원칙 | project SSoT의 L 기준, run set, QA gate |
| 특정 task에서 반복 발견된 문제 | evidence/follow-up 판단 기준 | project issue/task 또는 silo PR 본문 |

## 처리 절차

1. 피드백이나 agent 감사 결과에서 실제 값, 구현 수단, 프로젝트 고유 명사를 분리합니다.
2. 해당 내용이 여러 프로젝트에서 반복 가능한 판단 근거인지, 특정 프로젝트의 실행 처방인지 판정합니다.
3. 반복 가능한 판단 근거만 system 반영 follow-up으로 남깁니다.
4. 실제 실행 처방은 project SSoT, task 계약, runbook, QA checklist 중 하나로 내려보냅니다.
5. DB를 사용하는 프로젝트의 setup 기록에 schema 정본 위치, schema 요약 위치, schema 적용 경로가 없으면 task 계약으로 진행하기 전에 `project setup schema 계약 누락`으로 보고합니다.
6. DB schema, API contract, auth/session contract처럼 task 작성의 입력이 되는 중요 제품 정보가 project registry/config와 project SSoT 어디에도 없으면 system에 임시 처방을 쓰지 않고 `project SSoT schema 계약 누락`, `project SSoT API 계약 누락`, `project SSoT auth/session 계약 누락`처럼 누락 정의로 보고합니다.
7. project SSoT 위치나 기준 브랜치가 불명확하면 system에 임시 처방을 쓰지 않고 `project SSoT 위치 누락` 또는 `task 계약 누락`으로 보고합니다.
8. PR 본문에는 `evidence/follow-up`, `현재 PR에서 처리한 항목`, `처리하지 않고 남긴 항목`을 분리해, 좁은 스코프 항목이 system으로 들어오지 않은 이유를 적습니다.

## 보고 기준

보고할 때는 아래처럼 분리합니다.

```text
system에 남길 판단 근거
- ...

project SSoT로 내려보낼 실행 처방
- ...

현재 PR에서 처리하지 않고 evidence/follow-up으로 남길 항목
- ...

누락된 project SSoT 정의
- ...
```

`system에 없음`은 누락을 뜻하지 않을 수 있습니다. 특정 provider, 화면, fixture, L gate가 system에 없고 project SSoT 또는 task 계약으로 라우팅되어 있다면 의도된 분리입니다.

## 금지선

- project 내부 task, issue, QA 결과, runbook 원문을 system SSoT에 복사하지 않습니다.
- 특정 프로젝트의 provider별 checklist를 전역 규칙처럼 쓰지 않습니다.
- 통제된 mock/dev 검증 통과를 실제 사용자 provider 경로 통과로 보고하지 않습니다.
- project SSoT 위치가 불명확한 상태에서 system 문서에 임시 실행 절차를 고정하지 않습니다.
