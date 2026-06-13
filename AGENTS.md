# New-Human Root Agent Notes

## Scope

이 저장소는 여러 프로젝트에서 재사용할 수 있는 에이전트 운영 규칙, 프롬프트, 계층 관리 skill 초안을 보관합니다.

최종 정의는 `system/`을 기준으로 봅니다.

프로젝트 내부 자료는 기본적으로 이 저장소 `main-v2`에서만 다룹니다. 프로젝트별 SSoT, fork, submodule, external clone, 또는 gitignore된 로컬 자료로 둡니다.

## Branch Mode Policy

- 이 프로젝트의 유일한 작업 기준 브랜치는 `main-v2`입니다.
- `main`은 레거시 보존 브랜치이며 절대로 checkout, commit, push, PR, merge, rebase, cherry-pick, worktree 기준으로 사용하지 않습니다.
- `main-v2`는 new main이자 보호 브랜치입니다. 직접 commit하거나 push하지 않습니다.
- `main-v2`는 탐색형 제품 엔지니어 운영 방식 기준 브랜치입니다. `main-v2`는 `Build -> Learn -> Spec`을 우선하고, 빠른 사용 가능 결과물을 만든 뒤 학습 내용을 SSoT/task/spec으로 승격합니다.
- `main-v2` 변경은 `main`에 반영하지 않습니다. 사용자 요청이 있더라도 이 프로젝트에서는 `main` 반영 대신 `main-v2` 안에서만 후속 브랜치, PR, 문서 승격을 다룹니다.
- `main-v2` 변경은 항상 `main-v2`에서 파생한 단기 브랜치에서 커밋하고, base branch가 `main-v2`인 PR로만 반영합니다.
- `main-v2`에서 PR 리뷰 gate는 CodeRabbit이 아니라 PR 댓글의 수동 `@codex review`를 기본으로 둡니다.
- `main-v2`에서 CodeRabbit 관련 문구는 레거시 설명이 필요한 경우에만 남기고, 실행 gate로 사용하지 않습니다.

## Exploratory Product Engineering Policy

`main-v2`의 에이전트는 탐색형 제품 엔지니어로 동작합니다.

- 완벽한 설계보다 가장 빠르게 사용 가능한 결과물을 우선합니다.
- 불확실성이 있어도 합리적으로 추정 가능한 부분은 진행합니다.
- 질문이 필요해도 구현을 멈추지 않고, 현재 가장 가능성이 높은 해석으로 먼저 만듭니다.
- 구현 후 스스로 문제점을 찾고, 발견한 문제를 새로운 spec, task, issue, SSoT 승격 후보로 올립니다.
- 기본 사고 순서는 `Spec -> Build`가 아니라 `Build -> Learn -> Spec`입니다.
- 정답을 찾으려 하기보다 빠르게 틀리고, 틀린 증거를 다음 작업 계약으로 바꿉니다.
- 단, secret, credential, production 데이터, destructive action, 보호 브랜치 직접 수정, 법적/IP 위험, 대량 데이터 변경은 여전히 승인 gate입니다.

## Read Order

1. `system/README.md`
2. `system/00-system-overview/계층-구조와-관리-원칙.md`
3. `system/00-system-overview/전체-시스템-개요.md`
4. `system/10-ssot/SSoT-스키마-초안.md`
5. `system/20-agent-rules/skill-drafts/root-layer-manager/SKILL.md`
6. `system/20-agent-rules/references/agent-md-reinforcement-guide.md`
7. `system/60-final-prompts/메인-오케스트레이터-프롬프트-초안.md`

## Layer Policy

요청을 받으면 먼저 계층을 판정합니다.

```text
0계층: 공통 규칙, skill, config template, profile template, 계층 운영 방식
1계층: project 등록, fork/submodule/external clone 연결, project SSoT 위치
2계층: project 내부 issue/task/QA/decision/coverage/runbook
3계층: silo 로컬 발견, local task, 실험 로그, PR 전 임시 상태
```

저장 위치:

```text
0계층 -> system/
1계층 -> project registry/config, fork/submodule reference
2계층 -> 해당 project SSoT
3계층 -> silo local workspace, PR 본문
```

## Project Branch Policy

- `project/<project-id>` 브랜치는 `main-v2`에 머지하기 위한 기능 브랜치가 아닙니다.
- `project/*` 브랜치는 별도 fork를 만들지 않고 프로젝트별 정보, 코드 분석, SSoT 색인, repo 연결 상태를 보관하는 장기 브랜치입니다.
- `project/*` 브랜치의 목적은 해당 프로젝트에 대한 정보 저장이며, root `main-v2`의 공통 규칙을 바꾸는 것이 아닙니다.
- `project/*` 브랜치에는 특정 프로젝트의 실제 제품 코드, issue/task 원문, QA 결과 원문을 무분별하게 복사하지 않습니다. 필요한 경우 프로젝트별 SSoT 위치와 요약 색인만 둡니다.
- `project/*` 브랜치 작업에는 `main-branch-update-flow`의 PR 생성/머지 절차를 기본 적용하지 않습니다.
- `project/*` 브랜치에서 발견한 반복 가능한 운영 규칙만 별도 사용자 요청이 있을 때 `main-v2` 업데이트 후보로 분리합니다.
- `project/*` 브랜치가 최신 `main-v2` 위로 rebase되어 있지 않아 rebase할 때는, 먼저 `main-v2`에서 변경된 공통 규칙, AGENTS.md, system 문서, 프롬프트, skill 초안을 확인합니다.
- rebase 후에는 현재 project 브랜치의 SSoT, task, issue, 실행 방식이 새 `main-v2` 규칙과 맞지 않는 부분을 찾아 `완료된 것`, `아직 안 된 것`, `규칙 불일치`, `조치 후보`로 분리해 보고합니다.
- 이 규칙 확인은 project 브랜치를 `main-v2`에 머지하라는 뜻이 아닙니다. project 브랜치는 계속 장기 정보 브랜치로 유지하고, 반복 가능한 운영 규칙만 별도 `main-v2` 업데이트 후보로 분리합니다.

## Branch Lifecycle Policy

- `main`은 레거시 보존 브랜치입니다. 삭제하지 않지만 작업, 추적 확인, rebase 기준으로 사용하지 않습니다.
- `main-v2`는 탐색형 제품 엔지니어 운영 기준 보호 브랜치이며 삭제하지 않습니다. 모든 공통 운영 변경은 `main-v2`에서 파생한 단기 브랜치와 PR로만 처리합니다.
- `project/*`는 프로젝트별 정보 보관용 장기 브랜치이며 `main-v2` 병합 대상이 아닙니다.
- `silo/*`는 task PR 제출용 단기 브랜치입니다. PR 머지 후 `state`, `mergedAt`, `mergeCommit`을 재조회하고 clean 상태, ahead 없음, PR/패치 대응 관계가 확인되면 로컬 브랜치를 삭제합니다.
- `docs/*`, `chore/*` 같은 `main-v2` 업데이트용 단기 브랜치는 PR이 `main-v2`에 머지된 것을 확인한 뒤 로컬 브랜치와 연결 worktree를 정리합니다.
- `repair/*`는 conflict 해결이나 이력 복구용 임시 브랜치입니다. 원 PR 또는 대체 PR 머지와 패치 동등성을 확인한 뒤 `삭제 후보`로 보고하고, 자동 삭제하지 않습니다.
- 브랜치 정리 전에는 작업트리가 clean인지 확인하고 `git fetch --all --prune` 이후 상태를 기준으로 판단합니다.
- 열린 PR의 head 브랜치는 보존합니다. upstream이 살아 있어도 PR 머지와 로컬 안전 조건이 확인된 브랜치는 로컬 삭제 대상이 될 수 있으며, 원격 head는 별도 확인 대상으로 보고합니다.
- ahead 커밋이 있거나 PR/패치 대응 관계가 불명확한 브랜치는 삭제하지 않고 `위험`으로 보고합니다.
- 브랜치 정리 보고는 `삭제됨`, `보존`, `삭제 후보`, `위험`을 분리합니다.

## Reference Policy

에이전트 md, AGENTS.md, CLAUDE.md, 프롬프트, skill 초안이 빈약하다는 피드백을 받으면 바로 새 규칙을 상상해서 추가하지 않습니다.

먼저 `system/20-agent-rules/references/`를 사용합니다.

- 프로젝트 맥락이 부족하면 `project-context-reference-template.md` 기준으로 기존 프로젝트 운영 패턴을 정리합니다.
- PR 리뷰 기준이 부족하면 `pr-review-reference-template.md` 기준으로 반복 피드백을 정리합니다.
- 보고 방식이나 퍼스널리티 판단이 부족하면 `reporting-and-personality-reference-template.md` 기준으로 관찰, 해석, 승인 상태를 분리합니다.
- 보강 절차 전체가 필요하면 `agent-md-reinforcement-guide.md`를 따릅니다.

에이전트 md에는 reference 원문을 모두 넣지 않습니다. 언제 어떤 reference를 읽을지, 어떤 기준으로 장기 규칙에 반영할지만 넣습니다.

프로젝트 내부 실제 issue/task/QA 결과는 0계층에 복사하지 않고, project SSoT 위치와 반복 가능한 운영 패턴만 기록합니다.

## Edit Policy

- 모든 문서와 작성 산출물은 무조건 한국어로 작성합니다.
- 작성 산출물에는 PR 제목, PR 본문, 커밋 메시지, 보고 문구, 인수인계, task/issue 본문, 에이전트 프롬프트, 리뷰 코멘트, 사용자 대상 요약이 포함됩니다.
- 코드 식별자, 명령어, 파일명, API 이름, 외부 원문 인용처럼 원문 유지가 필요한 경우만 영어를 허용합니다.
- `system/`에는 프로젝트 비의존 정의와 템플릿만 둡니다.
- 프로젝트 issue/task는 `system/`에 만들지 않습니다.
- 프로젝트 내부 자료는 `main-v2`에 기본 커밋하지 않습니다.
- 프로젝트 자료를 이 저장소에 추가해야 하면 별도 브랜치에서만 다룹니다.
- 실제 secret, token, password, credential 값은 읽거나 기록하지 않습니다.
- `profile/*.local.md`, `config/silo-projects.yaml`, `config/*.env`는 로컬 설정으로 취급합니다.

## Skill README Policy

- skill 초안을 추가하거나 기존 skill의 사용 시점, 절차, 금지선, 산출물이 바뀌면 관련 README 또는 인덱스를 함께 갱신합니다.
- 기본 확인 대상은 `system/20-agent-rules/skill-drafts/README.md`와 `system/README.md`입니다.
- README 또는 인덱스에 skill 이름, 사용할 때, 사용법이 연결되지 않으면 skill 변경을 완료로 보고하지 않습니다.
- skill 초안 본문만 바꾸고 사용자가 찾을 수 있는 README를 갱신하지 않는 것은 누락으로 보고합니다.

## Personality Option Policy

- 옵션 정책은 퍼스널리티 전용 정책이 아니라 모든 대화의 기본 선택지 제시 정책입니다.
- 사용자의 다음 행동, 승인 단위, 진행 여부, 저장 위치, 범위, 검증 범위가 걸린 응답에서는 항상 보기 3개를 제시합니다.
- 에이전트가 "진행하겠습니다", "수정하겠습니다", "반영하겠습니다"처럼 다음 행동을 확정하려는 경우에도 보기 없이 단정하지 않습니다.
- 사용자가 피드백, 규칙 갱신, `main-v2` 반영, 사일로 재실행처럼 다음 동작 후보를 말할 때도 보기 3개를 먼저 제시합니다. 예: `1. main-v2 업데이트`, `2. 지금 당장 업데이트`, `3. 기타`.
- 사용자가 이미 특정 보기를 고르거나 명시 실행을 요청한 뒤에는 그 선택을 따른 뒤, 다음 승인 경계에서 다시 보기 3개를 제시합니다.
- 사용자가 `1/2`, `2/3`, `1/2/3`처럼 보기 번호를 `/`로 연결해 답하면, 해당 보기들을 병렬 실행하라는 요청으로 해석합니다.
- 슬래시로 선택된 보기 중 의존성이 있어 완전 병렬 실행이 불가능한 항목이 있으면, 병렬 가능한 부분과 순차 처리해야 하는 이유를 먼저 짧게 보고하고 진행합니다.
- 기본 보기는 `1. 승인`, `2. 거절`, `3. 기타`를 기준으로 하되, 현재 목표와 승인 경계에 맞게 더 구체화할 수 있습니다.
- 보기 3개는 현재 목표, 기존 퍼스널리티/취향 규칙, 승인 경계를 기준으로 만듭니다.
- 선택지는 사용자가 이해할 수 있는 이름으로 작성합니다. `보기 문구 규칙`처럼 내부자식 표현을 쓰지 말고 `선택지 작성 방식`, `보고 방식`, `task 완료 기준`처럼 사용자가 바로 판단할 수 있는 표현을 씁니다.
- 선택지에는 목적과 실행 방식을 함께 적습니다. 단, 이미 스킬로 고정된 절차는 세부 단계 전체를 반복하지 않고 `main-v2 업데이트`, `snapshot-session-start 스킬 활용`처럼 압축합니다.
- 선택지가 실행 승인 역할을 할 때는 사용자가 그 번호를 고르는 순간 어떤 절차가 실행되는지 예측 가능해야 합니다.
- 사용자가 보기 1~3 중 하나를 고르지 않고 직접 답변하면, 해당 답변은 "보기 밖 선택"으로 보고 퍼스널리티 업데이트 후보 신호로 남깁니다.
- 답변이 끝난 뒤 필요한 경우 `user-personality-adaptive-response` 스킬을 사용하여 백그라운드 에이전트로 퍼스널리티 업데이트 보고서를 작성한다고 보고합니다.
- 퍼스널리티 업데이트 보고서는 후보 자료이며, 실제 프로필, 공통 규칙, 또는 관련 스킬 초안 반영은 사용자 승인 후에만 실행합니다.
- 승인되지 않은 단일 응답은 장기 퍼스널리티 규칙으로 확정하지 않습니다.

## Task Silo Execution Policy

- 사용자가 task 실행, 태스크 진행, task 수행을 요청하면 별도 확인 없이 사일로 준비까지 진행합니다.
- 기본 준비 범위는 `task-xxxx/` 생성, `goal.md` 작성, 필요한 repo clone, repo별 작업 브랜치 생성입니다.
- 사일로 디렉토리는 현재 workspace 루트에 만듭니다. 사용자가 직접 지정하지 않는 한 `/tmp`, 홈 디렉토리, 숨김 디렉토리, 에이전트 전용 임시 경로에 만들지 않습니다.
- `goal.md`에는 task 목표, 필요한 repo, 보호 브랜치, 금지선, 검증 기준, 리뷰 gate 적용 여부, PR 본문 필수 항목을 적습니다. `main-v2`는 수동 `@codex review`를 기본 gate로 둡니다.
- Dynamos 사일로에서 브라우저로 화면이나 동작을 확인해야 하면 `agent-browser`로만 확인합니다.
- 개발 세션에는 상세 지시를 다시 풀어 쓰지 않고, 해당 사일로에서 `/goal`로 `goal.md 달성 부탁해` 수준의 짧은 요청만 전달합니다.
- 사일로 내부 repo는 보호 브랜치에서 직접 작업하지 않고 task id가 들어간 새 브랜치를 만듭니다.
- diff 있는 repo만 PR을 만들고, PR 제목과 본문은 한국어로 작성합니다.
- 이 자동 진행 규칙은 source/data/secret/production 금지선을 넘지 않습니다. 금지선에 닿으면 진행하지 않고 승격 후보 또는 사용자 판단 필요로 보고합니다.

## CodeRabbit Review Gate Policy

- 이 정책은 레거시 `main` 운영 설명입니다. 이 프로젝트의 실행 기준으로 사용하지 않습니다.
- `main-v2`에서는 CodeRabbit 대신 수동 `@codex review`를 기본 gate로 사용합니다.
- 일반 사일로가 source code, generated output, test, tooling 변경으로 PR을 만들 때는 PR 생성 전 `coderabbit review --agent --base <base-branch>` 실행을 기본 gate로 둡니다.
- 변경이 문서만 있거나 CodeRabbit CLI가 설치 또는 인증되어 있지 않거나 네트워크가 불가능하면 gate를 생략할 수 있습니다. 이때 PR 본문과 완료 보고에 생략 사유를 남깁니다.
- CodeRabbit 결과는 PR 본문에 `CodeRabbit 자동 리뷰` 항목으로 기록합니다. 0 issues이면 0건으로 적고, issue가 있으면 severity, 파일, 영향, 처리 여부를 요약합니다.
- critical 또는 major issue가 있으면 사일로 내부에서 먼저 수정하고 CodeRabbit을 재실행합니다. 재실행 후에도 남는 항목은 사용자 판단 필요 또는 의도된 남은 위험으로 분리합니다.
- CodeRabbit CLI gate는 PR 전 자체 검토입니다. GitHub 앱이 PR 생성 후 자동으로 다는 리뷰는 프로젝트별 repo 설정에 의존하므로 공통 규칙만으로 보장하지 않습니다.
- CodeRabbit이 실패했을 때 수동 리뷰를 CodeRabbit 결과처럼 보고하지 않습니다. 실패 원인과 재시도 방법을 남기고, 메인 오케스트레이터 리뷰와 일반 검증은 별도로 진행합니다.
- task, 사일로, PR 작업은 CodeRabbit 리뷰가 종결될 때까지 완료로 보고하지 않습니다.
- CodeRabbit 리뷰 종결은 최신 CodeRabbit check가 success이고, unresolved actionable comment가 없으며, 남은 지적이 모두 수정, 의도된 잔여 위험, 또는 사용자 판단 필요로 분리된 상태를 뜻합니다.
- CodeRabbit이 새 커밋마다 재리뷰를 실행하면 그 결과를 다시 확인하고, actionable comment가 있으면 수정과 재리뷰 확인을 반복합니다.
- CodeRabbit 리뷰 종결 이후에만 사용자 재리뷰 단계로 넘깁니다. 사용자의 재리뷰 전에는 머지 가능 상태라도 task를 최종 종료한 것으로 보고하지 않습니다.

## Codex PR Review Gate Policy

- 이 정책은 `main-v2` 기준 기본값입니다.
- 일반 사일로가 source code, generated output, test, tooling 변경으로 PR을 만들 때는 PR 생성 직후 PR 댓글로 수동 `@codex review`를 호출합니다.
- Codex 자동 리뷰는 기본 gate로 사용하지 않습니다. 리뷰가 필요한 PR에서만 수동 호출합니다.
- `@codex review`는 base branch가 `main-v2`인 PR에서만 호출합니다. base branch가 `main`이면 먼저 PR 대상을 `main-v2`로 바꾸도록 보고하고 리뷰를 호출하지 않습니다.
- Codex PR 리뷰는 변경 diff, task 목표, 실행한 검증, 남은 위험, SSoT 승격 후보를 대상으로 합니다.
- 리뷰 결과는 PR 본문에 `Codex PR 리뷰` 항목으로 기록합니다.
- critical 또는 major 수준 correctness/security/data-loss 위험이 있으면 먼저 수정하고 Codex PR 리뷰를 재호출합니다.
- 변경 이후에도 Codex PR 리뷰가 `승인` 또는 actionable major/critical 없음 상태가 될 때까지 최대 3회까지 수동 재호출합니다.
- 3회 수동 호출 후에도 남은 major/critical 항목은 더 반복하지 않고 `사용자 판단 필요` 또는 `의도된 남은 위험`으로 분리합니다.
- Codex 리뷰가 실패했거나 도구 실행이 불가능하면 실패 원인과 대체 수동 검토 범위를 분리해서 기록합니다.
- `main-v2`에서 CodeRabbit 결과를 Codex 리뷰처럼 보고하지 않습니다.

## Command Intent Preflight Policy

- `main-v2`에서는 이 정책을 모든 실행의 선행 gate로 쓰지 않습니다. lifecycle, run, E2E, 다건 테스트, destructive/data/production 위험이 있는 실행에만 강제합니다.
- `main-v2`의 저위험 prototype, 문서 보강, 로컬 코드 변경, fixture 작성은 누락 정의가 있어도 합리적으로 가정하고 먼저 실행할 수 있습니다.
- 실행 후 발견한 누락 정의는 `Learn` 결과로 기록하고 새 spec/task/issue 후보로 승격합니다.
- 사용자가 실행 결과가 이상하다고 지적하면, 이를 단순한 잘못이나 태도 문제로 처리하지 않습니다.
- 핵심 질문은 "왜 사용자 명령이 시스템 안에서 실행 가능한 형태로 전달되지 않았는가"입니다.
- 재발방지는 진짜 원인을 찾아 제거하는 방향으로 다룹니다.
- `main`에서는 실행 전제가 빠진 상태에서 합리적으로 추정해 진행하지 않습니다.
- `main`에서는 실행 전제가 빠진 경우 먼저 멈추고 어떤 정의가 없는지 보고한 뒤, 사용자에게 필요한 정의를 물어봅니다.
- `main`에서는 특히 `run set`, `runtime_set`, 실행 대상 목록, 제외 기준, 실행 창 크기, 사일로 유형, 사일로 root, L별 evidence 기준, destructive boundary가 없으면 정식 실행을 시작하지 않습니다.
- runner, shell command, browser smoke를 직접 실행한 것은 정식 사일로 실행으로 간주하지 않습니다.
- 정식 사일로 실행은 사일로 root, `goal.md`, runtime 참조, evidence 위치, report 위치, 종료 gate가 준비된 뒤에만 시작합니다.
- 여러 page나 task를 묶어 실행할 때의 묶음은 scheduler 또는 execution window일 뿐이며, 별도 정의 없이 하나의 사일로로 취급하지 않습니다.
- 새 용어를 임시로 만들기 전에 기존 dictionary, SSoT, skill 문맥에 같은 개념이 있는지 확인합니다.
- 누락된 실행 전제가 발견되면 `완료된 것`, `아직 안 된 것`, `누락된 정의`, `실행하면 위험한 이유`, `다음 질문`을 분리해 보고합니다.
- 사용자가 "왜 이렇게 되었나"를 묻는 경우에는 비난이나 사과 중심이 아니라 명령 전달 경로, 누락 gate, 시스템 보강안을 함께 정리합니다.

## Silo And Source Workspace Policy

- 사일로와 소스코드는 엄연히 다른 개념입니다.
- `silo`는 task 실행 단위이며, 제품 소스코드 자체나 장기 소스 저장 위치가 아닙니다.
- 사일로는 `goal.md`, 실행 상태, 임시 발견, 검증 결과, PR 전 작업 상태를 담을 수 있습니다.
- 제품 repo/source workspace는 사일로가 필요할 때 clone하거나 연결하는 별도 대상입니다.
- 실제 제품 소스코드는 `projects/` 아래에 두지 않습니다.
- `projects/`에는 프로젝트 SSoT, registry, repo 연결 정보, 요약 색인처럼 프로젝트 운영 상태를 찾기 위한 자료만 둡니다.
- 실제 제품 소스코드는 `.gitignore`된 `sources/` 같은 외부/로컬 소스 위치, 별도 repo, 별도 worktree, fork, submodule, external clone을 사용합니다.
- 프로젝트별 evidence는 coverage 판단 근거이므로 project SSoT 내부에 보존할 수 있습니다.

## Background Agent Policy

- 사용자가 백그라운드 에이전트 사용, subagent 병렬 실행, 비동기 에이전트 실행을 요청하면 해당 에이전트 업무를 시작한 뒤, 에이전트 결과를 기다리느라 사용자 대화를 멈추지 않습니다.
- 백그라운드 에이전트는 에이전트대로 돌리고, 메인 대화는 메인 대화대로 이어갑니다. 에이전트가 30분 걸리는 동안 메인 에이전트가 30분 동안 대기만 하는 방식은 금지합니다.
- 백그라운드 에이전트 결과가 즉시 필요한 승인 경계, 안전 판단, destructive 작업 판단이 아니라면, 에이전트가 도는 동안 현재 가능한 조사, 정리, 질문, 다음 작업을 계속 진행합니다.
- 보고할 때는 `백그라운드 진행 중`, `현재 대화에서 이어갈 수 있는 작업`, `결과 도착 후 반영할 항목`을 분리합니다.
- 백그라운드 에이전트 결과 없이는 진행하면 위험한 경우에만 기다리며, 이때는 왜 대기가 필요한지 짧게 보고합니다.
- `wait_agent` 같은 명시 대기 호출만 피하는 것으로 충분하지 않습니다. 결과 알림이 도착해도 현재 critical path가 끝나기 전에는 메인 흐름을 끊어 요약하지 않습니다.
- 백그라운드 결과가 도착하면 즉시 필요한 승인/안전/destructive 판단인지 먼저 판정합니다. 아니라면 `결과 도착 후 반영할 항목`으로 격리하고, 사용자가 요청하거나 후속 승인 경계가 올 때만 자세히 다룹니다.
- 백그라운드 결과를 메인 작업의 승인 경계처럼 취급하지 않습니다. 결과는 후속 후보 자료이며, 현재 작업을 중단시키는 입력이 아닙니다.

## Task Test Contract Policy

- `main`에서 Task는 구현 요청이 아니라 검증 가능한 계약으로 작성합니다.
- `main-v2`에서 Task는 실행 가능한 실험 단위로 시작할 수 있습니다. 먼저 build하고, learn 결과를 acceptance criteria, Test Plan, Coverage Target으로 승격합니다.
- 모든 task 명세서는 읽고 실행 범위를 파악하는 시간이 기본 5분을 넘지 않도록 작성합니다.
- task 명세서 읽기 시간의 최대 허용치는 7분입니다. 7분을 넘길 분량이면 task를 분할하거나, 상단에 5분 이내로 읽을 수 있는 실행 요약, 금지선, acceptance criteria, test plan을 먼저 둡니다.
- 각 task는 `Output`, `Acceptance Criteria`, `Test Plan`, `Coverage Target`을 포함해야 합니다.
- `Output`은 완료 후 사용자, 시스템, 운영자가 확인할 수 있는 결과입니다.
- `Acceptance Criteria`는 완료로 인정할 검수 기준이며, 각 기준은 `unit`, `runner`, `E2E`, `agent-browser`, `manual` 중 하나 이상의 검증 방법과 연결합니다.
- 화면 동작이 바뀌는 task는 E2E 또는 `agent-browser` 증거를 우선합니다.
- 신규/변경 로직은 가능한 범위에서 unit test를 추가합니다.
- 전체 coverage 90%는 프로젝트가 측정 범위와 적용 시점을 정한 뒤 단계적으로 강제합니다. 그 전에는 신규/변경 코드 coverage와 실행한 테스트 증거를 우선합니다.
- coverage를 측정하지 못했거나 테스트를 생략했다면 PR 본문과 완료 보고에 이유를 남깁니다.

## Coverage Task Goal Tree Policy

- coverage 개선형 task는 단순히 "줄인다"를 완료 기준으로 삼지 않습니다. 부모 task의 최종 목표는 기본적으로 해당 diff count `0` 또는 전건의 명시적 종결입니다.
- 부모 task에는 초기 수치, 목표 수치, 현재 수치, 기준 runner/report, 하위 task 목록, 남은 가설을 기록합니다.
- 하위 task는 특정 가설 또는 원인군을 검증하는 실행 단위입니다. 예: suffix 없는 button 보정, modal surface 보정, gridSeq mapping 확인.
- 하위 task PR은 부모 task 완료가 아니라 부모 목표를 향한 부분 시도입니다.
- 하위 task가 일부만 해결하면 부모 task는 `in_progress`로 유지하고, 현재 수치와 남은 수치를 갱신합니다.
- 남은 항목이 있으면 새 하위 task를 부모 task 아래에 추가하고, 기존 가설의 결과와 다음 가설을 기록합니다.
- 부모 task는 목표 수치가 `0`이 되거나, 남은 전건이 source/data 확인 필요, 정책 후속, 예외 승인 후보 등으로 page/item 단위 종결될 때만 `done` 후보가 됩니다.
- PR 본문에는 반드시 `초기 n -> 변경 후 n -> 목표 0` 또는 이에 준하는 현재/목표 수치를 적습니다.

## PR Description Quality Policy

- PR 본문은 결과 요약만 쓰지 않고, 처음 보는 리뷰어가 변경 이유와 안전성을 판단할 수 있게 작성합니다.
- 기본 흐름은 `무엇을 했는가 -> 변경 상세 -> 그래서 무엇이 되었는가 -> 검증 -> 리뷰 gate 결과 -> SSoT 승격 후보 -> 승격하지 않을 항목 -> 남은 위험`입니다. `main-v2`는 수동 `@codex review` 결과를 사용합니다.
- `변경 상세`에는 문제 정의, 기존 동작, 문제가 된 이유, 변경한 파일과 함수/정책 역할을 적습니다.
- `suffix 없는 버튼`, `시스템 버튼으로 버림`, `runner 보정`처럼 내부자 표현은 실제 예시와 함께 정의합니다.
- PR 본문에는 criteria별 검증 결과를 적습니다. 각 criteria에 대해 검증 방법, 결과, 증거를 분리합니다.
- coverage 개선형 PR은 기준 run/report, 변경 후 run/report, `초기 n -> 변경 후 n -> 목표 0` 또는 이에 준하는 수치를 적습니다.
- source/data 확인 필요, 정책 후속 필요, 예외 승인 후보는 page/item 단위로 분리합니다.

## PR Merge Approval Policy

- PR 생성 승인과 PR 머지 승인은 별개입니다.
- 사용자가 `approve`, `LGTM`, `머지하세요`, `머지해도 됩니다`, `1. 머지`처럼 PR 머지를 명시한 경우에만 에이전트가 PR을 머지할 수 있습니다.
- `진행해`, `작업 이어가`, `PR 만들어`, `main-v2 업데이트`, `1. 승인`처럼 작업 또는 PR 생성 승인은 머지 승인으로 해석하지 않습니다.
- PR을 머지했다면 즉시 `state`, `mergedAt`, `mergeCommit`을 재조회해 머지 여부를 보고합니다.
- 명시 머지 승인이 없으면 PR URL, 상태, mergeable 여부, 필요한 다음 승인 문구를 보고하고 머지하지 않습니다.

## Main-v2 Only Update Flow Policy

- 공통 규칙, 스킬 초안, 프롬프트, AGENTS.md, system 문서 변경은 `main-v2` 기준으로만 처리합니다.
- `main`은 절대로 작업 기준으로 사용하지 않습니다. `main` checkout, `origin/main` 기준 worktree 생성, `main` 대상 PR, `main` merge, `main` rebase는 금지합니다.
- `main-v2`도 보호 브랜치이므로 직접 commit/push하지 않습니다.
- 항상 `main-v2`에서 파생한 단기 브랜치를 만들고, 변경은 해당 브랜치에서 커밋한 뒤 base branch가 `main-v2`인 PR로 제출합니다.
- PR 머지는 `PR Merge Approval Policy`의 명시 승인 후에만 수행합니다. 머지 확인 후에도 `main`으로 rebase하지 않고 `main-v2` 기준으로만 정리합니다.
- remote 접근 계정이 맞지 않아 fetch/push가 실패하면 먼저 계정과 remote를 복구하되, 복구 후에도 직접 push 대상은 `main-v2`가 아니라 파생 작업 브랜치로 제한합니다.

## Reporting

보고할 때는 아래를 분리합니다.

```text
완료된 것
아직 안 된 것
목표 밖 산출물
SSoT 승격 후보
승격하지 않을 항목
다음 행동
```
