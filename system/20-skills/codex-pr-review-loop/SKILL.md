---
name: codex-pr-review-loop
description: PR 유형을 계층별로 판정한 뒤 목표 0계층 main-v3/main PR, 현재 호환 main-v3/main PR, 또는 project 계층 PR에 Codex 리뷰 gate가 필요하거나, codex-review pass와 최신 head 기준 P2 이상 지적의 수정·수비·사용자 판단 분류를 관리해야 할 때 사용합니다.
---

# Codex PR 리뷰 루프

이 skill은 PR 유형이 판정된 뒤 `codex-review pass` 목표를 실제 실행 계약으로 세팅하고, 최신 head의 Codex 리뷰 결과가 종료 가능한 상태인지 판정할 때까지 응답 대기, 수정, 검증, 재리뷰를 반복하게 합니다.

`Didn't find any major issues` 문구만으로 루프를 종료하지 않습니다. 현재 head를 대상으로 한 Codex 댓글, review body, inline review comment를 함께 보고 남은 P2/P1/major/critical 지적을 `수정 필요`, `수비 가능`, `사용자 판단 필요`로 분류한 뒤 종료 여부를 결정합니다.

branch base는 먼저 계층으로 판단합니다. 목표 모델에서 0계층 공통 변경은 `main-v3/main`, project 등록/색인, project contract, decision/ADR, task, issue, QA, coverage 같은 project 계층 변경은 해당 `project-{projectName}/main`이 기준입니다. 현재 마이그레이션 전 호환 기준은 0계층 `main-v3/main`, project 계층 `project-{projectName}`입니다. GitHub PR target/base branch는 이 계층 판단 결과를 반영한 최종 머지 대상입니다. project 변경을 이 skill 때문에 0계층 PR로 retarget하지 않습니다. project 계층 PR은 계층 메인 브랜치에 직접 커밋한 PR이 아니라, 목표 모델에서는 `project-{projectName}/{taskname}`, 현재 호환 상태에서는 `project-{projectName}-{taskname}` 작업 브랜치에서 커밋한 PR이어야 합니다.

사용자가 “PR을 올려 주세요”라고 말하면 아래 순서가 기본입니다.

1. 현재 브랜치의 0계층 공통 변경과 project 계층 변경을 판정합니다.
2. 올려야 할 PR 유형을 `0계층 PR`, `project 계층 PR`, `복합 PR 분리 필요`로 나눕니다. 목표 0계층 대상은 `main-v3/main`, 현재 호환 대상은 `main-v3/main`입니다.
3. 0계층과 project 계층이 섞여 있으면 worktree와 브랜치를 나눠 서로 다른 PR로 올립니다.
4. project 계층 PR이면 PR head branch가 project 계층 메인 브랜치와 같은지, 또는 현재 로컬 작업 위치가 해당 기준 브랜치 직접 checkout인지 확인합니다. 둘 중 하나라도 해당하면 `@codex review`를 호출하지 않고 project 작업 브랜치로 PR을 재생성해야 한다고 보고합니다. 목표 모델에서는 `project-{projectName}/{taskname}`, 현재 호환 상태에서는 `project-{projectName}-{taskname}`을 사용합니다.
5. 제품 repo PR이 독립 git submodule의 gitlink를 pin한다면 변경된 submodule repo마다 별도 PR과 `codex-review pass` 또는 동등 리뷰 gate가 있는지 확인합니다. submodule repo 자체 리뷰가 없으면 상위 제품 repo PR의 pass만으로 완료 처리하지 않습니다.
6. 새 submodule repo PR이면 repo 생성 의의, submodule 유형, 제품 적용 기준, 평가 기준, 검증 한계, pin 조건이 PR 본문에 있는지 확인합니다. 기본 브랜치에는 빈 기준 또는 최소 후보만 두고 실제 코드는 PR에서 평가하는 흐름을 우선합니다.
7. PR을 만든 뒤 해당 PR의 target/base branch가 계층 판단과 맞는지 확인하고 Codex review 설정 여부를 확인합니다.
8. Codex review 설정이 동작하는 저장소라면 `@codex review`를 호출하고 사용자 응답을 기다리지 않고 이 skill의 대기/수정/재요청 루프를 수행합니다.
9. Codex review 설정 없음, 호출 권한 없음, GitHub App 미설치, repo 정책상 비활성화가 명시적으로 확인되면 PR review loop를 돌리지 않습니다. 아직 확인 전인 repo는 먼저 `@codex review`를 호출해 `eyes` 반응 또는 Codex 응답을 확인합니다. review loop를 생략하는 경우 PR head, 검증 결과, 남은 위험을 기록한 뒤 사일로 PR이면 `silo-runtime-handoff`만 수행합니다.

## 실패 압력

정책 문서만 고치고 신규 skill을 만들지 않으면 실패입니다. 이 skill을 사용했다면 아래 중 하나 이상의 실행 흔적이 남아야 합니다.

- Codex review 동작 가능 또는 미확인 PR에서는 task silo의 `goal.md`에 `codex-review pass` 목표가 추가됨
- Codex review 미설정 또는 권한 없음이 명시된 PR에서는 pass 목표 대신 fallback 상태와 확인 근거가 기록됨
- PR 댓글에 외부 리뷰 요청문으로 `@codex review`가 호출됨
- PR 본문 `Codex PR 리뷰` 항목에 최신 head 기준 리뷰 상태가 기록됨

## 내부 목표 문구

기본 `/goal`은 아래 문구입니다. 이 문구는 메인 에이전트가 루프를 운영하기 위한 내부 실행 계약이며, `@codex review` 댓글에 그대로 붙이지 않습니다.

```text
codex review가 최신 head 기준으로 Didn't find any major issues 또는 동등하게 P2 이상 actionable 지적이 없다는 응답을 남기고, 현재 head를 대상으로 남은 Codex P2/P1/major/critical 지적이 없거나 모두 근거 있는 수비 가능으로 기록되며, 수정 필요 항목은 실제로 반영되고 사용자 판단 필요 항목은 남지 않을 때까지 수정을 반복해 주세요. 횟수제한은 두지 않겠습니다.
```

Codex 실제 응답은 현재 head와 같은 commit에 대한 `Didn't find any major issues` 또는 그와 동등하게 최신 head에 P2 이상 actionable 지적이 없다는 명시 응답이어야 합니다. exact phrase 존재 여부와 동등 pass 판정은 보고에서 분리합니다. 단순 `추가 수정 없음`, `다음 행동 없음`, 사람이 추정한 pass 상태는 통과로 보지 않습니다.

## P2 이상 지적 분류

Codex가 pass 응답을 남겼더라도 현재 head를 대상으로 한 댓글, review body, inline review comment에 P2/P1/major/critical 성격의 지적이 있으면 아래처럼 분류합니다.

inline review comment는 comment 객체의 현재 `commit_id`만으로 현재 head 대상 여부를 판단하지 않습니다. GitHub가 오래된 inline comment의 `commit_id`를 최신 diff 위치로 재매핑할 수 있으므로, `pull_request_review_id`로 연결된 부모 review의 대상 commit 또는 comment의 `original_commit_id`를 함께 확인합니다.

- `수정 필요`: 실제 버그, 회귀, 보안/데이터 손상, 보호 브랜치·계층·secret 금지선 위반, project contract 또는 사용자 요구와 충돌하는 지적입니다. 수정, 검증, 커밋, push 후 재리뷰합니다.
- `수비 가능`: 지적 자체는 P2 이상처럼 보이지만 현재 PR의 명시 목표, 사용자 결정, project contract, repo별 예외, 의도된 동작, PR scope 밖이라는 근거로 반박 가능한 항목입니다. 예: 특정 프로젝트가 project contract 작성 예외로 승인된 상태라면 "contract 누락" 지적은 수비 가능합니다.
- `사용자 판단 필요`: 사용자 결정, project contract, `goal.md`, PR scope, 코드/문서 링크 중 수비에 필요한 근거가 부족하거나, 수비하면 제품·운영 위험을 사용자가 받아들여야 하는 항목입니다. 이 경우 loop를 통과로 종료하지 않습니다.

`수비 가능`으로 닫으려면 PR 본문 `Codex PR 리뷰` 항목 또는 해당 리뷰 thread에 아래 근거를 남깁니다.

```text
수비 항목:
- 지적:
- 분류: 수비 가능
- 근거: <사용자 결정, project contract, goal.md, PR scope, 코드/문서 링크>
- 남은 위험:
- 사용자 판단 필요 여부: 없음
```

수비 근거가 사용자 결정, project contract, `goal.md`, PR scope, 코드/문서 링크 중 하나로 확인되지 않으면 agent 추론만으로 `수비 가능` 처리하지 않습니다.

## 외부 리뷰 댓글 문구

`@codex review` 호출 댓글은 리뷰어에게 전달할 요청만 담습니다.

```text
@codex review

한국어로 리뷰해 주세요.

최신 head `<head-sha>` 기준으로 변경사항을 리뷰해 주세요.
```

반복 횟수, exact pass phrase, 통과 판정 방식은 외부 리뷰어에게 강제하지 않고, PR 본문 `Codex PR 리뷰` 항목이나 task silo의 `goal.md`에서 메인 에이전트가 관리합니다.

## Codex review 설정 권장과 fallback

PR loop를 안정적으로 쓰려면 저장소 또는 organization에 Codex review 호출 경로를 먼저 세팅해 두는 것을 권장합니다. 이 설정은 PR에 `@codex review`를 호출했을 때 최신 head 기준 리뷰가 접수되고, `eyes` 반응 또는 Codex 응답을 확인할 수 있는 상태를 뜻합니다.

설정 확인 대상:

- GitHub PR 댓글에서 `@codex review` 호출이 가능한지
- 호출 댓글에 `eyes` 반응 또는 Codex 응답이 붙는지
- Codex 응답이 최신 head SHA를 기준으로 해석 가능한지
- repo 권한이나 GitHub App 설치 문제로 호출이 무시되지 않는지

Codex review 설정이 명시적으로 없거나 권한 없음이 확인되면 아래처럼 처리합니다. 아직 확인 전인 저장소는 미설정으로 단정하지 않고 먼저 `@codex review`를 한 번 호출해 `eyes` 반응 또는 Codex 응답을 확인합니다.

1. `codex-pr-review-loop`의 호출, 대기, 수정, 재호출 루프를 시작하지 않습니다.
2. PR 본문 또는 보고에 `Codex review 미설정`과 확인한 근거를 적습니다.
3. task 실행 결과인 사일로 PR이 실제 제품 코드 파일을 바꾸고 runtime/browser/manual QA/E2E 확인이 남아 있으면 `shared-runtime-health-check`와 `silo-runtime-handoff`를 실행합니다.
4. handoff는 리뷰 통과가 아니라 사용자가 PR을 확인할 수 있도록 runtime, URL, E2E 방법, 실행 불가 사유를 정리하는 절차로 분리합니다.

즉, Codex review 설정이 있는 PR은 `review loop -> 필요 시 handoff`로 진행하고, 설정이 없는 PR은 `review loop 생략 -> PR handoff`로 진행합니다. 단, 보호 브랜치 직접 수정, secret, production data, destructive action 같은 승인 gate는 Codex review 설정 여부와 무관하게 유지합니다.

## 실행 절차

1. repo, PR 번호, 현재 branch, dirty state, head SHA를 확인합니다.
2. 변경 내용을 0계층 공통 변경, project 계층 변경, 복합 변경으로 분류합니다.
3. GitHub PR target/base branch를 확인합니다. 목표 모델에서 0계층 PR은 `main-v3/main`, project 계층 PR은 해당 `project-{projectName}/main`이 target/base여야 합니다. 현재 호환 상태에서는 0계층 `main-v3/main`, project 계층 `project-{projectName}`를 사용합니다. target/base가 계층 판단과 맞지 않으면 `@codex review`를 호출하지 않고 계층 기준 브랜치 불일치로 보고합니다.
4. project 계층 PR이면 GitHub PR head branch와 로컬 현재 branch를 확인합니다. head branch나 로컬 현재 branch가 project 계층 메인 브랜치와 같으면 기준 브랜치 직접 커밋 위험이므로 `@codex review`를 호출하지 않고 project 작업 브랜치 PR로 재생성해야 한다고 보고합니다. 목표 모델에서는 `project-{projectName}/{taskname}`, 현재 호환 상태에서는 `project-{projectName}-{taskname}`을 사용합니다.
5. PR diff에 submodule gitlink 변경이 있으면 해당 submodule repo의 head commit이 별도 PR과 `codex-review pass` 또는 동등 리뷰를 통과했는지 확인합니다. 확인되지 않으면 상위 제품 repo PR은 pin/host 변경 검토만 남기고, submodule repo PR gate 미완료를 blocker로 보고합니다.
6. 새 submodule repo PR이면 기본 브랜치가 우회 머지 경로가 아닌지, PR 본문에 `patch/evidence`, `runtime`, `service/MSA` 중 유형이 있는지 확인합니다. service/MSA 유형이면 별도 배포, DB, auth, observability 필요 증거가 있어야 합니다.
7. 로컬에서 PR head를 수정하며 루프를 수행할 때는 `git rev-parse --git-dir`와 `git rev-parse --git-common-dir`가 다른 linked worktree인지 확인합니다. submodule이면 `git rev-parse --show-superproject-working-tree`로 구분합니다. project 계층 PR인데 linked worktree가 아니면 commit/push를 진행하지 않고 별도 worktree 전환 필요로 보고합니다.
8. Codex review 설정이 현재 PR에서 동작 가능한지 먼저 확인합니다. 호출 권한 없음, GitHub App 미설치, repo 정책상 비활성화처럼 미설정 또는 권한 없음이 명시적으로 확인되면 `codex-review pass` 내부 목표를 남기지 않고 `Codex review 미설정`과 확인 근거를 기록한 뒤 리뷰 호출, 대기, 수정, 재호출 루프를 시작하지 않습니다. 이 fallback 경로는 9번과 11번 이후를 건너뛰고 10번 handoff 평가만 수행합니다. 아직 확인 전이면 미설정으로 단정하지 않고 최신 head 기준 `@codex review` 호출과 접수 확인을 수행하는 경로로 진행합니다.
9. Codex review 설정이 동작 가능하거나 아직 확인 전이면 task silo의 `goal.md`에 `codex-review pass` 내부 목표 문구와 PR URL, head SHA, 검증 기준을 추가합니다. `goal.md`가 없으면 PR 본문 `Codex PR 리뷰` 항목에 내부 목표와 현재 상태를 남깁니다. 명시적 미설정 또는 권한 없음 fallback에서는 이 pass 목표를 쓰지 않고, PR 본문 또는 보고에 fallback 상태, 확인 근거, head SHA, 검증 결과, 남은 수동 리뷰 필요를 기록합니다.
10. 명시적 미설정 또는 권한 없음 fallback에서 task 실행 결과인 사일로 PR이 실제 제품 코드 파일을 바꾸고 runtime, browser, manual QA, E2E 확인이 남아 있으면 [`shared-runtime-health-check`](../shared-runtime-health-check/SKILL.md)와 [`silo-runtime-handoff`](../silo-runtime-handoff/SKILL.md)를 실행합니다. 문서, skill, project SSoT, config example, PR 본문 템플릿만 바꾼 PR이면 PR URL, head SHA, 검증 결과, 남은 수동 리뷰 필요를 handoff로 보고합니다.
11. 최신 head push 이후의 `@codex review` 호출 댓글, `eyes` 반응, Codex 리뷰 결과를 확인합니다.
12. 최신 head 이후 호출 댓글에 `eyes` 반응이 있고 아직 리뷰 결과가 없으면 중복 호출하지 않고 `eyes` 확인 시점부터 최대 15분까지 대기합니다.
13. 최신 head 이후 호출 댓글이 있지만 3분 동안 `eyes` 반응이 없고 아직 리뷰 결과도 없으면 리뷰 요청이 접수되지 않은 것으로 보고, 같은 head 기준으로 `@codex review`를 재호출한 뒤 11번으로 돌아갑니다. 같은 head의 no-`eyes` 재호출은 기본 최대 3회로 제한하고, 3회 모두 `eyes` 반응과 리뷰 결과가 없으면 `Codex 리뷰 접수 실패 timeout`으로 중단해 사용자 판단 필요로 보고합니다.
14. 최신 head에 대한 리뷰 요청이 없으면 PR 댓글로 `@codex review`를 호출하고, 외부 리뷰 댓글 문구만 적은 뒤 11번으로 돌아갑니다.
15. `eyes` 반응을 확인한 뒤 15분 동안 Codex 응답이 없으면 루프를 중단하고 PR URL, head SHA, 호출 댓글, 대기 시간을 보고합니다.
16. Codex 결과가 도착하면 최신 head에 대한 `codex-review pass` 응답인지 확인하고, exact phrase와 동등 pass를 분리해 기록합니다.
17. 현재 head commit SHA와 일치하는 Codex review body, 부모 review의 대상 commit 또는 `original_commit_id`가 현재 head와 일치하는 inline review comment, 또는 호출 댓글에 적힌 head SHA가 현재 head와 일치하는 Codex 댓글만 다시 훑어 P2/P1/major/critical 또는 보호 절차 위반 지적을 모두 수집합니다. inline comment의 현재 `commit_id`는 GitHub가 최신 diff 위치로 재매핑할 수 있으므로 단독 근거로 쓰지 않습니다. 이전 head를 대상으로 한 리뷰가 새 push 이후 늦게 게시된 경우 작성 시각이 최신 head 이후라도 현재 head 지적으로 섞지 않습니다.
18. 수집한 지적을 `수정 필요`, `수비 가능`, `사용자 판단 필요`로 분류합니다. 수비 가능한 지적은 PR 본문 또는 review thread에 근거를 남깁니다.
19. `수정 필요`가 있으면 해당 지적을 실제로 수정하고, 변경 범위에 맞는 검증을 실행한 뒤, 한국어 커밋 메시지로 커밋하고 push합니다. project 계층 PR에서는 이 커밋이 project 작업 브랜치에서 발생해야 하며, project 계층 메인 브랜치에는 직접 커밋하지 않습니다. 목표 모델에서는 `project-{projectName}/{taskname}`, 현재 호환 상태에서는 `project-{projectName}-{taskname}`을 사용합니다.
20. `사용자 판단 필요`가 있으면 loop를 통과로 종료하지 않고 PR URL, head SHA, 지적, 필요한 사용자 결정을 보고합니다.
21. `codex-review pass` 응답이고 모든 남은 P2 이상 지적이 없거나 `수비 가능`으로 근거 기록됐으며, 사일로 PR이 task 실행 결과이고 `.ts`, `.tsx`, `.js`, `.jsx`, `.java`, `.kt`, `.swift`, `.go`, `.py`, `.rb`, `.rs`, `.cs`, `.php` 같은 실제 제품 코드 파일을 바꿨고, runtime, browser, manual QA, E2E, vite-harness, shared BE/API, Docker DB 확인이 남아 있으면 사용자 재리뷰로 넘기기 전에 runtime handoff gate를 실행합니다. 문서, skill, project SSoT, config example, PR 본문 템플릿만 바꾼 PR에는 이 gate를 붙이지 않습니다. gate가 필요한 경우 먼저 [`shared-runtime-health-check`](../shared-runtime-health-check/SKILL.md)로 `run_set.required_runtime_set`, `task.runtime_set`, `qa_or_runbook.runtime_set`, `project.common_runtime_set` 순서의 Runtime Set과 서버형 runtime 상태를 확인합니다. `runtime_set`이 없거나 어떤 set을 써야 하는지 불명확하면 임의 서버 조합을 만들지 않고 `runtime 정의 누락`, `runtime_set 정의 누락` 또는 `add-shared-runtime 필요`로 분류합니다. health 확인 뒤 [`silo-runtime-handoff`](../silo-runtime-handoff/SKILL.md)를 실행해 실제 실행 중인 서버 주소, E2E 방법, 실행 불가 사유를 PR 댓글로 남긴 뒤 사용자 재리뷰로 넘깁니다.
22. PR 댓글 또는 본문에 수정 내용, 검증 결과, 수비 항목, 남은 위험, 새 head SHA를 기록하고 필요하면 11번으로 돌아갑니다.

## 종료 기준

- Codex review 동작 가능 경로에서는 최신 head에 대한 Codex 결과가 `Didn't find any major issues` 또는 동등하게 P2 이상 actionable 지적이 없다는 pass 응답을 명시했습니다.
- Codex review 동작 가능 경로에서는 현재 head commit SHA와 일치하는 Codex review body, 부모 review의 대상 commit 또는 `original_commit_id`가 현재 head와 일치하는 inline review comment, 또는 호출 댓글에 적힌 head SHA가 현재 head와 일치하는 Codex 댓글에 남은 P2/P1/major/critical 지적이 없거나, 모두 `수비 가능`으로 근거가 PR 본문 또는 review thread에 기록됐습니다.
- Codex review 명시적 미설정 또는 권한 없음 fallback 경로에서는 pass 응답을 요구하지 않습니다. 대신 `Codex review 미설정`, 확인 근거, head SHA, 검증 결과, 남은 수동 리뷰 필요가 PR 본문, PR 댓글, 또는 보고에 기록됐고, task 실행 결과인 사일로 PR이면 필요한 runtime handoff 조건 평가까지 끝났을 때만 종료합니다.
- `수정 필요` 또는 `사용자 판단 필요`로 분류된 항목이 남아 있으면 종료하지 않습니다.
- 사일로 PR이 task 실행 결과이고 실제 제품 코드 파일을 바꿨으며 runtime, browser, manual QA, E2E 확인이 남아 있으면 `shared-runtime-health-check`로 Runtime Set 우선순위와 서버형 runtime 상태를 확인하고, 그 결과를 바탕으로 `silo-runtime-handoff` 댓글까지 남긴 뒤 종료합니다. 문서, skill, project SSoT, config example만 바꾼 PR은 runtime handoff 대상이 아닙니다. `runtime_set`이 없거나 서버를 켤 수 없으면 성공으로 종료하지 않고 실행 불가 사유, 대체 증거, 남은 수동 확인을 PR 댓글에 남겨야 합니다.
- 같은 head에 대해 진행 중인 `eyes` 반응이 있으면 종료가 아니라 `eyes` 확인 시점부터 15분 한도의 대기입니다.
- 같은 head에 대해 호출했지만 3분 동안 `eyes` 반응이 없고 리뷰 결과도 없으면 접수 실패로 보고 재호출합니다. 같은 head의 no-`eyes` 재호출은 기본 최대 3회이며, 모두 실패하면 `Codex 리뷰 접수 실패 timeout`으로 중단해 사용자 판단 필요로 보고합니다.
- `eyes` 반응을 확인한 뒤 15분 동안 Codex 응답이 없으면 `Codex 리뷰 응답 대기 timeout`으로 중단하고 보고합니다.
- 사용자가 명시한 반복 한도가 없으면 횟수 제한으로 중단하지 않습니다.

## 금지

- formal GitHub approve 리뷰 객체가 없다는 이유만으로 `Didn't find any major issues` 명시 응답을 무시하지 않습니다.
- 이전 head의 pass 결과를 현재 head의 승인으로 재사용하지 않습니다.
- pass 문구가 있다는 이유만으로 현재 head 대상 P2/P1/major/critical inline comment를 무시하지 않습니다.
- 이전 head를 대상으로 한 stale review/comment를 작성 시각만으로 현재 head 지적에 섞지 않습니다.
- agent 추론만으로 P2 이상 지적을 수비 가능 처리하지 않습니다. 사용자 결정, project contract, goal.md, PR scope, 코드/문서 근거 중 하나가 필요합니다.
- 최신 head 이후 `eyes` 반응이 붙은 호출이 있는데 같은 head에 중복 호출하지 않습니다. 단, 최신 head 이후 호출 댓글에 3분 동안 `eyes` 반응이 없고 리뷰 결과도 없으면 접수 실패 재호출로 분류하고, 재호출 뒤 최신 호출 댓글 기준으로 다시 확인합니다.
- PR을 머지하지 않습니다. 머지는 별도 명시 승인 뒤 메인 오케스트레이터가 처리합니다.
- `project-{projectName}/main`처럼 project 계층 기준 브랜치가 따로 있는 변경을 이 skill 때문에 0계층으로 retarget하지 않습니다. 현재 호환 `project-{projectName}`도 동일하게 봅니다.
- project 계층 PR에서 project 계층 메인 브랜치 자체를 head로 쓰거나, 기준 브랜치 checkout에서 직접 commit/push하지 않습니다.
