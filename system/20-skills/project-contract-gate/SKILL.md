---
name: project-contract-gate
description: Use when defining or refining a project's product contract before task creation. Guides a two-step interview: first natural-language product clarification, then feature-by-feature clarification using agent inferences and numbered answers. Use when requirements may already exist, when they are incomplete, or when no app description exists yet.
---

# Project Contract Gate

task를 만들기 전에 제품 계약을 구체화하는 skill입니다. 목적은 task가 제품 정의를 대신하지 않게 하는 것입니다.

## 언제 쓰나

- 사용자가 요구사항, 앱 세부사항, project contract, 유저 플로우를 정리하자고 할 때
- 기존 요구사항이 있지만 빠진 기능 경계나 모순을 더 확인해야 할 때
- 요구사항이 없고 어떤 앱인지부터 물어야 할 때
- task 작성 전에 제품 정의, MVP/후속, 데이터 경계, 주요 기능 흐름이 부족할 때

## 금지

- project contract gate 중에 task ID, acceptance, 사일로 `goal.md`를 먼저 만들지 않습니다.
- project SSoT에 없는 DB/API/auth/design/runtime 계약을 추정해 확정하지 않습니다.
- 구현 순서나 사일로 병렬화 정책을 제품 요구사항으로 쓰지 않습니다.

## 0. 기존 자료 확인

먼저 project SSoT와 기존 요구사항 위치를 찾습니다.

- project contract
- requirement/spec 문서
- 디자인 정본
- DB/API/auth/runtime 정본 위치
- 기존 task가 닫힌 이유와 재사용 금지 여부

기존 요구사항이 있으면 그 위에 추가 질문을 얹습니다. 없으면 새로 인터뷰합니다.

## 1. Gate 위치 보고

첫 질문 전에 현재 gate를 짧게 보고합니다.

- 현재 가설
- 현재 gate
- 다음 gate
- 근거
- 아직 task를 만들지 않는 이유 또는 task 작성 가능 조건

## 2. 자연어 구체화

아예 초기라면 먼저 사용자에게 자연어로 묻습니다.

```text
만들고 싶은 앱을 한 문단으로 설명해 주세요. 사용자가 누구이고, 어떤 순간에, 무엇을 끝내고 싶어 하는 앱인지가 중요합니다.
```

사용자 답변을 받으면 바로 문서화하지 말고 아래를 짧게 정리해 확인합니다.

- 제품 한 문장 정의
- 사용자
- 핵심 성공 순간
- MVP에 들어갈 것
- 후속으로 밀릴 것
- 모르는 것

## 3. 기능별 구체화

기능을 하나씩 다룹니다. 질문은 빈칸 채우기가 아니라 agent 추론을 먼저 제시합니다.

형식:

```text
질문 N
제가 추론하기에는 ... 입니다. 맞나요?

1. 추론 맞음
2. 좁게 수정
3. 더 논의
```

사용자가 `1`, `추론 맞음`, `전부 맞음`처럼 답하면 agent 추론을 확정 후보로 기록합니다. 사용자가 번호와 자유 답변을 섞으면 자유 답변을 우선합니다.

확인할 축:

- 진입/로그인/비로그인
- 목표 lifecycle
- 대시보드/캘린더
- 주요 기록 기능
- 완료/리추얼/상태 계산
- 저장/동기화/삭제
- 추천/LLM/외부 서비스
- 공유/알림/권한
- 구독/후속 기능
- 디자인 정본
- 플랫폼 경계

## 산출물

gate가 충분히 닫히면 project SSoT에 기능 또는 사용자 흐름별 요구사항 문서로 나눕니다.

쓰기 전에는 실제 SSoT 위치, 기준 브랜치 `project/<project-id>`, 작업 브랜치 `project/<project-id>-<branch-name>`을 확인합니다. 요구사항 원문은 `main-v2`나 임의 브랜치에 섞지 않습니다.

예:

```text
10-requirements/
  README.md
  entry-login.md
  goal.md
  dashboard-calendar.md
  diet.md
  workout.md
  sync-storage.md
```

project overview에는 원문을 복사하지 말고 요구사항 정본 위치만 연결합니다.

## 통과 기준

- 제품 정의가 한 문장으로 말해진다.
- MVP와 후속 범위가 분리됐다.
- 핵심 기능별 사용자 흐름이 있다.
- 데이터 저장/동기화 경계가 있다.
- 디자인, DB, API, auth, runtime 정본 위치 또는 누락 상태가 명시됐다.
- 사용자가 첫 task slice를 고를 수 있다.

통과 전에는 task를 만들지 말고 `Project Contract 보강 필요`로 보고합니다.
