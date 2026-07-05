# 사일로 리뷰 Gate

사일로 작업은 브랜치 정책에 맞는 리뷰 gate가 종결되기 전에는 완료로 보고하지 않습니다.

## PR 유형별 Codex Gate

사일로가 PR을 올릴 때는 먼저 현재 브랜치의 diff를 계층별로 판정합니다.

- 0계층 공통 변경은 목표 모델에서 `main-v3/main`, 현재 호환 상태에서 `main-v3/main` 대상 PR로 올립니다.
- project 계층 변경은 목표 모델에서 해당 `project-{projectName}/main`을 기준 브랜치로 삼되, `project-{projectName}/{taskname}` 작업 브랜치에서 커밋하고 `project-{projectName}/main` 대상 PR로 올립니다. 현재 호환 상태에서는 `project-{projectName}`와 `project-{projectName}-{taskname}`을 사용합니다.
- 0계층과 project 계층 변경이 함께 있으면 목표 모델에서는 0계층을 `main-v3/{taskname}` worktree/브랜치/PR로, project 계층을 `project-{projectName}/{taskname}` 작업 브랜치와 project 대상 PR로 분리합니다. 현재 호환 상태에서는 `main-v3/{taskname}`와 `project-{projectName}-{taskname}`을 사용합니다.

PR 생성 직후에는 [`codex-pr-review-loop`](../../20-skills/codex-pr-review-loop/SKILL.md)를 사용해 `codex-review pass` 목표를 세팅하고, 수동 `@codex review`를 호출합니다. 단, Codex review 설정 없음, 호출 권한 없음, GitHub App 미설치, repo 정책상 비활성화가 명시적으로 확인되면 수동 `@codex review`를 반복 호출하지 않고 `Codex review 미설정`과 확인 근거를 PR 본문 또는 보고에 남깁니다. 아직 확인 전인 repo는 미설정으로 단정하지 않고 먼저 `@codex review` 호출 접수 여부를 확인합니다.

제품 repo가 독립 git submodule의 commit을 pin하는 구조라면 상위 제품 repo PR만으로 리뷰 gate가 끝나지 않습니다. 변경된 각 submodule repo는 보호 브랜치 직접 커밋 없이 submodule repo별 파생 브랜치와 별도 PR을 만들고, `codex-review pass` 또는 동등 리뷰를 먼저 통과해야 합니다. 상위 제품 repo PR은 리뷰 통과한 submodule commit의 gitlink pin, host repo 설정, submodule 선언, 실행 경로 연결만 검증합니다.

새 submodule repo를 평가용으로 만들 때는 기본 브랜치에 빈 기준 또는 최소 단일 후보 파일만 두고, 실제 코드는 PR로 올립니다. PR 본문에는 submodule 유형을 `patch/evidence`, `runtime`, `service/MSA` 중 하나로 표시하고, 제품 적용 목적, 평가 기준, 검증 한계, 제품 repo가 pin할 수 있는 조건을 적습니다. 기능 단위 BE/FE 분리는 기본적으로 service/MSA가 아니라 `runtime submodule` 또는 `patch/evidence submodule`에서 시작합니다.

현재 head push 이후에 작성된 최신 `@codex review` 호출 댓글에 `eyes` 반응이 있으면 Codex 리뷰가 접수 또는 진행 중인 상태로 보고, 같은 head commit에 추가 `@codex review`를 호출하지 않고 `eyes` 확인 시점부터 최대 15분까지 기다립니다.

현재 head push 이후에 작성된 최신 `@codex review` 호출 댓글에 3분 동안 `eyes` 반응이 붙지 않고 최신 head 리뷰 결과도 없으면 접수 실패로 보고, 같은 head 기준으로 `@codex review`를 재호출한 뒤 새 호출 댓글 기준으로 다시 확인합니다. 같은 head의 no-`eyes` 재호출은 기본 최대 3회로 제한하고, 3회 모두 `eyes` 반응과 리뷰 결과가 없으면 `Codex 리뷰 접수 실패 timeout`으로 중단해 사용자 판단 필요로 보고합니다.

`eyes` 반응을 확인한 뒤 15분 동안 Codex 응답이 없으면 `Codex 리뷰 응답 대기 timeout`으로 중단하고 PR URL, head SHA, 호출 댓글, 대기 시간을 보고합니다.

아래 항목이 있으면 `codex-pr-review-loop` 기준으로 수정, 검증, 재호출을 반복합니다. 기본 중단 기준은 호출 횟수가 아니라 최신 head에 대한 `codex-review pass`입니다. `codex-review pass`는 최신 head에 대한 `Didn't find any major issues` 또는 동등하게 P2 이상 actionable 지적이 없다는 명시 응답이 있고, 현재 head 대상 남은 P2/P1/major/critical 지적을 모두 `수정 필요`/`수비 가능`/`사용자 판단 필요`로 분류한 뒤 `수정 필요`와 `사용자 판단 필요`가 남지 않는 상태입니다. Codex review 설정 없음/권한 없음이 명시적으로 확인되어 review loop를 생략한 경우에는 pass로 표현하지 않고 `Codex review 미설정` fallback으로 분리합니다. 이전 head 리뷰가 새 push 이후 늦게 게시되어도 작성 시각만으로 현재 head 지적에 섞지 않습니다.

- actionable major/critical issue
- 보호 절차를 깨는 P2 이상 지적
- 보호 브랜치 직접 commit/push 위험

P2 이상처럼 보이는 지적이라도 사용자 결정, project contract, `goal.md`, PR scope, 의도된 동작 근거가 있으면 `수비 가능`으로 분류할 수 있습니다. 이 경우 PR 본문 또는 review thread에 지적, 수비 근거, 남은 위험, 사용자 판단 필요 여부를 기록합니다. 근거가 부족하거나 사용자가 위험을 받아들여야 하는 항목은 `사용자 판단 필요`로 남기고 완료로 보고하지 않습니다.

0계층 PR과 project 계층 PR 모두 반복 재리뷰 대상입니다. branch base는 계층 기준 브랜치이며, project 계층은 기준 브랜치에 직접 커밋하지 않습니다. 목표 모델에서는 `project-{projectName}/{taskname}`, 현재 호환 상태에서는 `project-{projectName}-{taskname}` 작업 브랜치에서만 커밋합니다. GitHub PR target/base branch가 계층 기준과 다르거나 두 계층이 섞인 PR은 `@codex review`를 호출하지 않고 계층 분리 필요로 보고한 뒤 종료합니다.

사용자가 이번 PR에 명시한 반복 한도가 있으면 그 한도를 따릅니다. secret, credential, production 데이터, destructive action, data SSoT 임의 변경, 보호 브랜치 직접 수정에 닿으면 반복보다 승인 gate를 우선합니다.

반복 이후에도 남는 항목은 횟수 기준으로 중단하지 않고, 의도된 잔여 위험 또는 사용자 판단 필요로 분리합니다.

재호출 전에도 최신 head push 이후에 작성된 호출 댓글의 `eyes` 반응과 최신 head commit 리뷰 결과를 확인합니다. 최신 head 리뷰 결과가 아직 없고 현재 head 이후 호출 댓글에 `eyes`가 있으면 중복 호출하지 않고 `eyes` 확인 시점부터 15분 한도 안에서 기존 요청을 기다립니다. 최신 호출 댓글에 3분 동안 `eyes` 반응이 없고 최신 head 리뷰 결과도 없으면 접수 실패 재호출로 분류하되, 같은 head의 no-`eyes` 재호출 기본 상한 3회를 넘기지 않습니다.

## 사용자 재리뷰

Codex PR 리뷰 gate가 종결됐거나 Codex review 미설정 fallback 근거를 기록한 뒤에는 사용자 재리뷰를 다음 gate로 둡니다.

task 실행 결과인 사일로 PR이 실제 제품 코드 파일을 바꾸고 runtime, browser, manual QA, E2E, vite-harness, shared BE/API, Docker DB 확인이 남아 있으면 `codex-review pass` 이후 또는 Codex review 미설정 fallback 기록 이후 사용자 재리뷰를 호출하기 전에 [`shared-runtime-health-check`](../../20-skills/shared-runtime-health-check/SKILL.md)로 Runtime Set과 서버형 runtime 상태를 확인합니다. Runtime Set은 `run_set.required_runtime_set`, `task.runtime_set`, `qa_or_runbook.runtime_set`, `project.common_runtime_set` 순서로 찾고, 없으면 `runtime 정의 누락`으로 분류합니다. 그 결과를 바탕으로 [`silo-runtime-handoff`](../../20-skills/silo-runtime-handoff/SKILL.md)를 사용해 현재 서버 주소, E2E 확인 방법, 실행 불가 사유를 PR 댓글로 남깁니다. 문서, skill, project SSoT, config example만 바꾼 PR에는 runtime handoff를 붙이지 않습니다. `runtime_set`이 없거나 어떤 서버를 켤지 불명확하면 임의 서버 조합을 만들지 않고 정의 누락 또는 `add-shared-runtime` 필요를 댓글에 남깁니다.

PR 생성 승인과 PR 머지 승인은 별개입니다.
