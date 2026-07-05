---
name: silo-runtime-handoff
description: 사일로 PR이 codex-review pass를 통과했거나 Codex review 설정이 없어 review loop를 생략한 뒤 사용자 재리뷰를 호출하기 전에 runtime, 서버 주소, E2E 확인 절차, 실행 불가 사유를 정리해 PR 댓글로 남길 때 사용합니다. task silo, goal.md, vite-harness, shared BE/API, Docker DB, browser/manual QA, 실행 URL handoff가 있는 작업에서 사용합니다.
---

# Silo Runtime Handoff

## 목적

사일로 PR 리뷰 루프가 `codex-review pass`로 통과했거나 Codex review 설정이 없어 review loop를 생략해야 할 때, 사용자가 직접 확인할 수 있는 실행 상태와 E2E 절차를 PR 댓글로 남긴다.

이 skill은 리뷰 루프가 아니다. `codex-review pass` 이후 또는 Codex review 미설정 fallback에서 사용자 재리뷰를 부르기 전의 runtime handoff만 담당한다.

## 실행 조건

아래 조건을 모두 만족할 때 실행한다.

- task silo 또는 유사한 사일로 root가 있다.
- 최신 PR head가 `codex-pr-review-loop` 기준 `codex-review pass`를 통과했거나, Codex review 설정이 없어 PR review loop를 생략한다고 기록했다.
- PR diff에 `.ts`, `.tsx`, `.js`, `.jsx`, `.java`, `.kt`, `.swift`, `.go`, `.py`, `.rb`, `.rs`, `.cs`, `.php` 같은 실제 제품 코드 파일 변경이 있다.
- `goal.md`, task contract, PR 본문 중 하나에 runtime, browser, manual QA, E2E, vite-harness, shared BE/API, Docker DB, dev server 확인이 있다.

조건을 만족하지 않으면 실행하지 말고 생략 사유를 보고한다.

문서, skill, project SSoT, config example, PR 본문 템플릿만 바꾼 PR은 실행 조건을 만족하지 않는다.

## 입력 확인

먼저 아래를 확인한다.

1. 사일로 root와 `goal.md`
2. PR URL, base/head, 최신 head SHA
3. Codex review gate 근거 URL. Codex review 설정이 동작하는 PR이면 `codex-review pass` 댓글 또는 review URL을 확인하고, Codex review 미설정 fallback이면 `Codex review 미설정`을 기록한 PR 본문, 보고, 또는 댓글 URL과 미설정/권한 없음 확인 근거를 확인한다.
4. `shared-runtime-health-check` 결과 또는 Runtime Set 결정 근거
5. 실제 제품 코드 변경 파일 목록
6. 필요한 runtime 목록
7. 실행할 runtime의 command, working directory, port, URL, health check
8. 테스트 계정, dev session, seed/test input 구분
9. 금지선: secret, credential, production data, destructive action
10. `system/config/silo-runtime.env` 또는 이에 대응하는 local env의 `SILO_PROJECTS_CONFIG`, `SILO_WORK_ROOT`, `SILO_BRANCH_PREFIX`, `SILO_EXECUTION_MODE`
11. `silo-projects.yaml`의 project repo, protected branch, service policy, DB schema 정본 위치
12. `shared-runtime-registry.yaml`의 `runtime_set`, shared BE/API, Docker DB, FE/harness, health check, port, env file policy

`goal.md`와 task contract가 충돌하면 task contract를 우선하고, 충돌을 PR 댓글의 남은 위험에 적는다.

사일로에 Runtime Set이 필요한데 `shared-runtime-health-check` 결과가 없으면 먼저 해당 skill을 실행한다. Runtime Set은 `run_set.required_runtime_set`, `task.runtime_set`, `qa_or_runbook.runtime_set`, `project.common_runtime_set` 순서로 찾는다. `runtime_set`이 없거나 어떤 set을 써야 하는지 불명확하면 임의로 서버 구성을 추정하지 않고 `runtime 정의 누락`, `runtime_set 정의 누락`, 또는 `add-shared-runtime 필요`를 실행 불가 항목에 남긴다.

## Runtime 준비

사일로 `goal.md`, task contract, QA/runbook, project SSoT 또는 local config에서 우선순위로 결정된 `runtime_set`에 명시된 것만 켠다. 무엇이 필요한지는 task contract만으로 추정하지 않고 Run Set, config와 registry를 함께 본다.

- Docker DB
- shared BE/API
- vite-harness 또는 제품 FE dev server
- task contract에 명시된 추가 서버

서버형 runtime은 `shared-runtime-health-check`의 health command 또는 URL을 기준으로 확인한다. health check가 실패하면 성공처럼 포장하지 않고 실행 불가 항목에 실패 runtime, 실패 명령 또는 URL, 대체 증거, 남은 확인을 적는다.

`shared-runtime-registry.yaml`에 같은 `runtime_set`으로 묶인 서버형 runtime이 있으면 E2E 전제에 포함한다. 예를 들어 화면 E2E가 shared BE/API 응답을 필요로 하면 shared BE/API health check가 통과해야 E2E 가능으로 보고한다. Docker DB, mock service, worker, FE dev server도 같은 방식으로 판단한다.

config 기준 분기:

- `runtime_set`이 있고 서버형 runtime health check가 모두 통과함: PR 댓글에 실행 URL과 E2E 절차를 적는다.
- `runtime_set`은 있지만 shared BE/API, DB, FE/harness 중 일부가 꺼져 있거나 health check가 실패함: E2E를 실행 가능으로 쓰지 않고 실패 runtime, 실패 명령 또는 URL, 대체 증거, 남은 확인을 적는다.
- `runtime_set`이 없거나 어떤 set을 써야 하는지 불명확함: E2E handoff가 아니라 config 누락 handoff로 보고하고 `add-shared-runtime` 또는 project runtime_set 정의가 필요하다고 적는다.
- `silo-projects.yaml`에서 `allowed_for_silo`가 아니거나 protected branch 정책이 불명확함: runtime을 켜기 전에 사일로 설정 누락으로 중단하고 PR 댓글 또는 보고에 남긴다.

이미 실행 중인 서버가 있으면 재사용하기 전에 포트, command, working directory, dirty 상태, 실행 프로세스의 최신 head 반영 여부를 확인한다. 최신 head 반영 여부가 불명확하면 재시작한다.

새로 실행할 때는 아래를 기록한다.

- command
- working directory
- port
- URL
- log 위치 또는 확인 명령
- health check 결과
- stop/restart 방법

Docker, 포트, 의존성, 환경변수 문제로 실행하지 못하면 임시로 우회하지 않는다. 실패 사유와 대체 증거를 남긴다.

## E2E 확인 절차 작성

사용자가 그대로 따라 할 수 있게 작성한다.

- 시작 URL
- 로그인 또는 dev session 경로
- seed 또는 초기 상태
- 사용자가 넣을 테스트 입력
- 클릭/입력 순서
- 기대 결과
- DB/API에서 확인할 값
- 재진입 또는 새로고침 확인

task scope 밖의 화면이나 검증은 새로 만들지 않는다.

## PR 댓글 작성

Runtime 준비가 끝났거나 실행 불가 사유가 정리되면 PR에 한국어 댓글을 남긴다.

```markdown
## 사일로 Runtime Handoff

최신 head: `<head-sha>`
Codex review: <codex-review-pass-url 또는 Codex review 미설정 fallback>

### Config 기준

- silo env: `<silo-runtime.env path 또는 확인 불가>`
- project config: `<silo-projects.yaml path 또는 확인 불가>`
- runtime registry: `<shared-runtime-registry.yaml path 또는 확인 불가>`
- runtime_set: `<runtime-set-id 또는 없음>`

### 실행 중인 서버

| 대상 | 주소 | 상태 | 실행/로그/재시작 |
|---|---|---|---|
| Docker DB |  |  |  |
| shared BE/API |  |  |  |
| vite-harness 또는 FE |  |  |  |

### Runtime Set

- runtime_set:
- source: `run_set.required_runtime_set` / `task.runtime_set` / `qa_or_runbook.runtime_set` / `project.common_runtime_set` / local config
- health_check:

### E2E 확인 방법

1. `<step>`
2. `<step>`
3. `<step>`

### 테스트 입력

-

### 확인해야 할 결과

-

### 남은 수동 확인

-

### 실행 불가 항목

| 항목 | 사유 | 대체 증거 | 남은 확인 |
|---|---|---|---|
|  |  |  |  |
```

실행 불가 항목이 없으면 표에 `해당 없음`을 적는다.

## 종료 기준

아래 중 하나를 만족해야 사용자 재리뷰 호출로 넘어갈 수 있다.

- runtime이 켜져 있고 PR 댓글에 서버 주소와 E2E 방법이 있다.
- runtime을 켤 수 없고 PR 댓글에 실행 불가 사유, 대체 증거, 남은 수동 확인이 있다.
- `runtime_set` 또는 config가 누락됐고 PR 댓글에 정의 누락, 필요한 registry 항목, `add-shared-runtime` 또는 project SSoT 보강 필요, 남은 수동 확인이 있다.

댓글 없이 최종 보고만 하고 끝내지 않는다.

## 금지

- PR을 머지하지 않는다.
- Codex review 설정이 동작하는 PR에서는 `codex-review pass` 전 실행하지 않는다.
- Codex review 설정이 없어 review loop를 생략한 PR에서는 `codex-review pass`로 표현하지 않는다. `Codex review 미설정 fallback`으로 분리한다.
- task scope 밖 QA를 추가하지 않는다.
- secret, token, password, credential 값을 댓글이나 `goal.md`에 쓰지 않는다.
- Docker/서버 실패를 성공처럼 표현하지 않는다.
- shared BE/API, DB, FE/harness가 필요한 E2E를 config health 확인 없이 가능하다고 쓰지 않는다.
