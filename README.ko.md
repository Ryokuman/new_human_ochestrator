# New-Human Orchestrator 사용 방법

이 저장소는 여러 프로젝트에서 재사용할 수 있는 에이전트 운영 규칙, SSoT 구조, 사일로 실행 방식, PR 리뷰 루프, 퍼스널리티 갱신 규칙을 관리합니다.

최종 정의와 재사용 가능한 문서는 `system/`을 기준으로 봅니다. `main-v2`는 공통 규칙과 reusable infrastructure를 관리하고, `project/<project-id>` 브랜치는 프로젝트별 지식과 증거를 관리합니다.

## 처음 읽는 순서

1. `AGENTS.md`
2. `system/README.md`
3. `system/00-system-overview/계층-구조와-관리-원칙.md`
4. `system/00-system-overview/전체-시스템-개요.md`
5. `system/10-ssot/SSoT-스키마-초안.md`
6. `system/10-agents/main.md`
7. `system/20-skills/README.md`
8. `system/10-agents/main-orchestrator/main-prompt.md`

## 기본 사용 흐름

1. 요청을 0/1/2/3계층으로 판정합니다.
2. 공통 규칙, 역할별 agent 프롬프트, repo skill은 `system/`에서 관리합니다.
3. 프로젝트별 상태, issue, task, QA 결과는 project SSoT에서 관리합니다.
4. 실제 구현 작업은 task silo에서 분리 실행합니다.
5. 사일로 결과는 PR 본문에 검증 결과, SSoT 승격 후보, 승격하지 않을 항목을 분리해 제출합니다.
6. 사용자 피드백은 현재 작업 수정, 사일로 전용 규칙, 전역 규칙 후보를 구분해 처리합니다.

## 계층별 저장 위치

| 계층 | 저장 위치 | 내용 |
|---|---|---|
| 0계층 | `system/` | 공통 규칙, 프롬프트, repo skill, 셋업 템플릿 |
| 1계층 | project registry/config, `project/*` 브랜치 | 프로젝트 등록, 연결 방식, SSoT 위치 |
| 2계층 | project SSoT | 프로젝트 내부 issue, task, QA, decision, coverage, dashboard |
| 3계층 | task silo workspace | 임시 발견, 실험 로그, PR 전 작업 상태 |

## 초기 셋업

이 저장소를 fork 또는 clone한 뒤 공통 작업 스킬을 설치하려면 루트의 `setup.sh`를 실행합니다.

```bash
./setup.sh
```

비대화형 전체 설치:

```bash
./setup.sh --all --yes
```

설치 위치는 기본적으로 `$CODEX_HOME/skills`이며, `CODEX_HOME`이 없으면 `~/.codex/skills`를 사용합니다.

config local 초안은 아래 명령으로 생성합니다.

```bash
./setup.sh --init-config --yes
```

## Project SSoT 초안 생성

새 project SSoT scaffold는 루트 `setup.sh`로 생성합니다.

```bash
./setup.sh --create-project-ssot \
  --project-id <project-id> \
  --project-name "<project-name>" \
  --target <project-ssot-path> \
  --yes
```

이 명령은 dashboard, dictionary, issue, task, decision, handoff, coverage, templates 기본 폴더와 문서 초안을 생성합니다. 실제 프로젝트 issue/task/QA 원문은 root `main-v2`에 만들지 않습니다.

## Project Contract 작성 기준

`project-contract.md`는 프로젝트를 실행 가능한 작업 단위로 쪼개기 전에 확인하는 제품 계약입니다. 기능 task를 만들기 전에 아래 항목이 최소한으로 닫혀 있어야 합니다.

- 제품 정의: 무엇을 만드는 프로젝트인지
- 현재 버전 목표와 비목표: 이번 버전에서 할 것과 하지 않을 것
- 핵심 사용자 흐름: 사용자가 어떤 순서로 가치를 얻는지
- 데이터 저장과 동기화 경계: 로컬, 서버, 외부 API, DB가 맡는 역할
- repo 역할: FE, BE, DB, harness, submodule, external clone의 책임
- 디자인과 런타임 정본 위치: 화면 기준, 실행 방법, 검증 방법
- 추정 금지 정보: schema, auth, production 데이터, secret처럼 확인 전 쓰면 안 되는 값

권장 위치:

```text
projects/<project-id>/02-project-internal/00-dashboard/project-contract.md
```

## 예시 1: 이미 존재하는 프로젝트에 적용

목표는 기존 repo를 바로 고치기 전에, agent가 반복해서 참조할 제품 계약과 작업 경계를 먼저 만드는 것입니다.

1. 기존 프로젝트의 source repo, 실행 명령, DB/schema 위치, 배포 방식, 주요 화면을 확인합니다.
2. `project/<project-id>` 브랜치에서 project SSoT scaffold를 만들거나 기존 SSoT 위치를 확인합니다.
3. `project-contract.md`에 현재 동작 기준을 요약합니다.
4. 확인되지 않은 항목은 추정하지 않고 `확인 필요`로 둡니다.
5. 이후 기능 task는 `project-contract.md`를 참조해 사용자 흐름 기준으로 작성합니다.

예시 구조:

```text
projects/shop-admin/
  README.md
  02-project-internal/
    00-dashboard/
      project-overview.md
      project-contract.md
    20-issues/
    30-tasks/
```

예시 contract 요약:

```markdown
# Project Contract: shop-admin

## 제품 정의
소규모 커머스 운영자가 주문, 상품, 재고를 관리하는 내부 admin입니다.

## 현재 버전 목표
- 주문 목록 조회와 주문 상태 변경
- 상품 재고 수량 확인
- 운영자 로그인 유지

## 비목표
- 결제 연동 변경
- 고객용 storefront UI 변경
- 대량 재고 import

## 핵심 사용자 흐름
운영자가 로그인한 뒤 주문 목록을 필터링하고, 주문 상세에서 상태를 변경한 뒤 변경 결과를 목록에서 다시 확인합니다.

## 정본 위치
- source repo: `../shop-admin`
- DB schema: `../shop-admin/db/schema.sql`
- 실행 방법: `../shop-admin/README.md`
- E2E 기준: `../shop-admin/tests/e2e/`

## 확인 필요
- production role별 권한 차이
- staging seed 데이터 생성 방식
```

## 예시 2: 기존 프로젝트를 스캔해 포트폴리오 또는 이력서용 LLM wiki로 사용

목표는 여러 기존 프로젝트를 agent가 검색 가능한 증거 패키지로 정리해, 포트폴리오 문장과 이력서 bullet을 만들 때 같은 근거를 재사용하는 것입니다.

1. 포트폴리오용 project SSoT를 하나 만듭니다.
2. 각 프로젝트를 evidence package로 나눕니다.
3. source repo에서 architecture, ownership, issue, metric, screenshot 후보를 스캔합니다.
4. 원문 전체를 복사하지 않고 요약, 근거 위치, 재확인 방법을 남깁니다.
5. LLM에게 질문할 때는 project별 SSoT와 evidence 경로를 기준으로 답하게 합니다.

예시 구조:

```text
projects/portfolio/
  00-project/
    project-contract.md
  10-projects/
    delivery-platform/
      README.md
      10-summary/
      20-architecture/
      30-issues/
      40-ownership/
      50-metrics/
      60-drafts/
    ai-scheduler/
      README.md
      10-summary/
      20-architecture/
      30-issues/
      40-ownership/
      50-metrics/
      60-drafts/
  20-resume/
  30-portfolio-copy/
  40-applications/
```

예시 contract 요약:

```markdown
# Project Contract: portfolio-wiki

## 제품 정의
개인 프로젝트와 업무 경험을 LLM이 질의응답할 수 있는 포트폴리오 evidence wiki입니다.

## 현재 버전 목표
- 프로젝트별 한 문단 요약 생성
- 기술적 난점, 해결 방식, 본인 기여 증거 분리
- 이력서 bullet과 포트폴리오 copy 초안 생성

## 비목표
- 원본 source repo 전체 복제
- confidential 데이터 저장
- 채용 사이트별 자기소개서 자동 제출

## 핵심 사용자 흐름
사용자가 "이 프로젝트에서 내가 뭘 했지?"라고 물으면 agent가 project summary, issue history, ownership evidence를 읽고 근거 있는 답변과 resume bullet 후보를 생성합니다.

## 증거 분류
- architecture: 설계 결정과 tradeoff
- issue: 문제, 원인, 해결, 재발 방지
- ownership: 본인이 직접 맡은 범위와 증거
- metric: 성능, 사용자, 비용, 안정성 변화
- draft: 외부 공개용 문장 후보

## 추정 금지
- 회사 내부 수치
- private customer 이름
- 확인되지 않은 성과 지표
```

## 예시 3: 새 프로젝트를 0부터 만들기

목표는 코드를 먼저 많이 만들기보다, 첫 구현 slice를 agent가 끝까지 검증할 수 있게 project contract와 task 경계를 같이 만드는 것입니다.

1. 제품 아이디어를 한 문장으로 적습니다.
2. 현재 버전 목표와 비목표를 분리합니다.
3. 핵심 사용자 흐름 하나를 고릅니다.
4. FE/BE/DB/auth/harness 역할을 정합니다.
5. `setup.sh --create-project-ssot`으로 SSoT scaffold를 만듭니다.
6. `project-contract.md`가 충분히 닫힌 뒤 첫 task를 작성합니다.
7. 첫 task는 사용자 가치가 보이는 가장 작은 full-stack slice로 잡습니다.

예시 구조:

```text
projects/meal-planner/
  README.md
  02-project-internal/
    00-dashboard/
      project-overview.md
      project-contract.md
      work-filter.md
    20-issues/
    30-tasks/
    40-decisions/
```

예시 contract 요약:

```markdown
# Project Contract: meal-planner

## 제품 정의
개인이 냉장고 재료와 식단 목표를 바탕으로 일주일 식단을 계획하는 웹 앱입니다.

## 현재 버전 목표
- 사용자가 보유 재료를 입력합니다.
- 식단 목표를 선택합니다.
- 7일치 식단 초안을 생성합니다.
- 생성 결과를 수정하고 저장합니다.

## 비목표
- 장보기 결제 연동
- 영양사 검수 workflow
- 모바일 앱 출시

## 핵심 사용자 흐름
사용자가 재료와 목표를 입력하면 앱이 7일 식단을 제안하고, 사용자는 일부 메뉴를 바꾼 뒤 저장합니다.

## repo 역할
- FE: 식단 입력, 생성 결과 편집, 저장 화면
- BE: 식단 생성 요청, 저장 API, 사용자별 식단 조회
- DB: 사용자, 재료, 식단, 식단 항목
- harness: seed user와 sample ingredient로 반복 검증

## 첫 task 후보
재료 입력부터 7일 식단 초안 저장까지 한 명의 테스트 사용자 기준으로 검증합니다.

## 확인 필요
- 실제 AI provider
- 사용자 인증 방식
- 영양 정보 데이터 출처
```

## Main-v2 업데이트 규칙

공통 규칙, `AGENTS.md`, `system/` 문서, 프롬프트, repo skill을 바꿀 때는 현재 작업 브랜치에서 직접 수정하지 않습니다.

`main-branch-update-flow`에 따라 `main-v2` 기준 파생 브랜치를 만들고, 수정 후 `main-v2` 대상 PR로 반영합니다. PR 생성 승인과 PR 머지 승인은 별개입니다. 레거시 `main`은 이 프로젝트에서 작업 대상으로 사용하지 않습니다.

## 주의

- 프로젝트 내부 issue/task/QA 원문은 root `main-v2`에 복사하지 않습니다.
- 실제 secret, token, password, credential 값은 읽거나 기록하지 않습니다.
- `config/silo-projects.yaml`, `config/*.env`는 로컬 설정으로 취급합니다.
- 프로젝트 자료를 이 저장소에 추가해야 하면 root `main-v2`가 아니라 project 전용 브랜치나 project SSoT에서 다룹니다.
