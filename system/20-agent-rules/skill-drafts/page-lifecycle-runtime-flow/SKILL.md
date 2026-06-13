---
name: page-lifecycle-runtime-flow
description: page-lifecycle, L0-L6 채점, 단일 page 테스트 사일로, dynamos-snapshot generate, dynavite runtime, agent-browser 확인 흐름을 정해야 할 때 사용합니다.
---

# Page Lifecycle Runtime Flow

## 목적

이 skill은 page-lifecycle에서 한 page를 실제로 띄워 L 점수를 얻는 runtime 흐름을 고정합니다.

`Run Set`은 무엇을 돌릴지 정하고, `runtime_set`은 그것을 돌리기 위해 무엇이 떠 있어야 하는지 정합니다. 이 skill은 그 둘이 확정된 뒤 각 page 테스트 사일로가 어떤 순서로 실행되는지 다룹니다.

## 사용 시점

아래 상황에서 사용합니다.

- page-lifecycle L0~L6 채점 실행
- 단일 page를 생성하고 브라우저로 확인해야 하는 테스트 사일로
- 10개 page execution window를 돌리기 전 runtime 흐름 확인
- `dynamos-snapshot`, `dynavite`, `agent-browser`의 책임이 헷갈릴 때

## 전제

- `command-intent-preflight`를 통과해야 합니다.
- `Run Set`에는 대상 page, 제외 기준, execution window 크기, 사일로 단위가 있어야 합니다.
- `runtime_set`에는 공용 runtime과 사일로별 runtime이 구분되어 있어야 합니다.
- 공용 runtime health check가 필요한 경우 먼저 통과해야 합니다.

## 기본 runtime_set 해석

Dynamos page-lifecycle의 기본 해석은 아래와 같습니다.

| runtime | 소유자 | 공유 여부 | 역할 |
|---|---|---|---|
| `dynamos-back` | `main-orchestrator` | 공용 | API/DB를 제공하는 main BE |
| `dynavite` | `page-test-silo` | 사일로별 | 단일 generated page를 띄우는 runtime |
| `dynamos-snapshot` | `page-test-silo` | 사일로별 | 단일 page generate와 report/evidence 기준 workspace |

공용 runtime은 execution window 전체가 함께 사용합니다. 사일로별 runtime은 page 테스트 사일로마다 따로 준비합니다.

## 단일 page 실행 흐름

각 page 테스트 사일로는 아래 1~6을 수행합니다.

```text
1. silo setup
2. generate single page by using dynamos-snapshot
3. start dynavite
4. agent-browser check
5. get L score
6. done
```

### 1. Silo Setup

- page 하나당 테스트 사일로 하나를 만듭니다.
- `goal.md`에 page id/name, target level, `Run Set`, `runtime_set`, report/evidence 위치, 금지선을 기록합니다.
- 공용 runtime인 `dynamos-back`은 사일로가 직접 소유하지 않습니다.

### 2. Generate Single Page

- `dynamos-snapshot`으로 해당 page 하나만 생성합니다.
- 전체 page generate를 정식 page 사일로 실행으로 섞지 않습니다.
- 생성 실패는 L hard gate에서 stop 조건으로 기록합니다.

### 3. Start Dynavite

- `dynavite`는 방금 생성한 단일 page output을 로드합니다.
- page별 port, session, evidence 위치가 섞이지 않게 사일로별 runtime으로 다룹니다.
- smoke 실패는 정식 L 채점 전에 runtime gate 실패로 기록합니다.

### 4. Agent-Browser Check

- `agent-browser`로 `dynavite` URL에 진입합니다.
- 필요한 경우 auth/session은 secret 값을 기록하지 않는 참조 방식으로 주입합니다.
- 화면, 상호작용, evidence를 수집합니다.

### 5. Get L Score

- L0부터 L6까지 hard gate로 판정합니다.
- 어떤 level에서 실패하면 다음 level로 진행하지 않고 직전 통과 level을 `passed_level`로 기록합니다.
- 모두 통과하면 `status: pass`, `passed_level: L6`로 기록합니다.

### 6. Done

- page report, evidence index, agent-browser evidence를 지정 위치에 승격합니다.
- report/evidence 승격 전에는 테스트 사일로를 삭제하지 않습니다.
- 반복 원인이 보이면 Issue/Task 승격 후보로 분리합니다.
- page가 한 번이라도 실패 report를 만든 뒤 retry 또는 보정으로 최종 pass가 되면, 최종 pass report만 남기지 않습니다.
- 해당 page의 task 또는 run report에는 `had_failed_run: true`, `resolved_by_hypothesis: true`, `failed_run_count`, `resolved_attempt_no`, `latest_failed_report`, `latest_retry_report`, `latest_resolution_summary`를 기록합니다.
- 실패를 해결하기 위해 세운 가설은 task 내부 `Hypothesis Chain` 또는 run report의 failure chain section에 attempt 단위로 남깁니다.
- attempt에는 실패 run, 관찰, 원인 가설, 확인한 evidence, 실행한 조치, retry run, 결과, 다음 판단을 적습니다.
- 가설 시도는 task당 최대 3회입니다. 3회 이후에는 자동 retry를 멈추고 사용자 판단 필요로 보고합니다.

## Execution Window

execution window는 사일로가 아닙니다. 여러 page 테스트 사일로를 동시에 또는 순차로 실행하는 스케줄링 단위입니다.

기본 window 흐름:

```text
10개 page 선택
-> page별 테스트 사일로 10개 생성
-> 각 사일로가 1~6 실행
-> 10개 report/evidence 승격 확인
-> window report 작성
-> 다음 10개 page로 이동
```

사용자가 10개 병렬 처리를 지시한 경우, 한 execution window 안의 10개 page 테스트 사일로는 병렬 실행할 수 있습니다. 다만 다음 window로 넘어가기 전에는 10개 모두의 report/evidence 승격 여부를 확인합니다.

window report는 최신 결과 요약과 실패 이력 요약을 분리합니다.

- 최신 결과: `pass`, `failed`, `pending`
- 실패 이력: `had_failed_run=true`
- 가설 해결: `resolved_by_hypothesis=true`
- 미해결 실패: `status=failed`

예를 들어 100개 page 중 3개가 중간 실패 후 가설로 해결되어 최종 100 pass가 되면, window report는 `pass 100`만 쓰지 않고 `had_failed_run 3`, `resolved_by_hypothesis 3`을 별도 표와 필터 가능한 컬럼으로 남깁니다.

## 금지

- `Run Set` 없이 여러 page를 임의로 고르지 않습니다.
- `runtime_set` 없이 lifecycle 실행을 시작하지 않습니다.
- 10개 묶음을 하나의 사일로로 부르지 않습니다.
- `dynamos-back`을 page 테스트 사일로가 소유하는 runtime으로 기록하지 않습니다.
- 단일 page 테스트에서 전체 page generate를 섞지 않습니다.
- runner나 browser smoke만 실행하고 정식 page 테스트 사일로를 돌렸다고 보고하지 않습니다.
