# New Human Orchestrator Public Agent Notes

## Scope

이 공개 저장소는 여러 프로젝트에서 재사용할 수 있는 에이전트 운영 규칙, 프롬프트, repo skill, 배포 가능한 템플릿을 보관한다.

최종 정의는 `system/`을 기준으로 본다.

공개판 `AGENTS.public.md`는 공개 export용 지시문이다. 실제 유저 퍼스널리티와 Feedback은 1계층 User SSoT인 workspace의 `user-layer/` 디렉터리가 소유한다.

## Branch Policy

- 공개 배포 기준 브랜치는 `main-v3/main`이다.
- `main-v3/main`는 보호 브랜치로 보고 사람과 일반 에이전트가 직접 commit/push하지 않는다.
- 원본 저장소의 `.github/workflows/sync-public-orchestrator.yml`가 실행하는 GitHub Actions public sync는 자동 동기화 예외다. 이 예외는 workflow의 allowlist, 내부 참조 guard, secret-like content guard를 통과한 공개 산출물을 `github-actions[bot]`으로 공개 target 저장소의 `public-sync/main-v3/main` 동기화 브랜치에 push하고 `main-v3/main` 대상 PR을 생성하거나 갱신하는 경우에만 적용한다. 공개 target 저장소 `main-v3/main` 보호 브랜치 직접 push는 이 예외에 포함하지 않는다.
- 공통 운영 변경은 `main-v3/<branch-name>` 형식의 작업 브랜치와 `main-v3/main` 대상 PR로 반영한다.
- 프로젝트별 내부 SSoT, secret, 로컬 evidence, task runtime 산출물은 이 공개 저장소에 포함하지 않는다.

## Codex PR Review Gate Policy

- PR 생성 직후에는 PR base가 계층 기준 브랜치와 일치하는지 확인한 뒤 수동 `@codex review` 댓글을 남긴다.
- `@codex review` 댓글에는 가능하면 한국어 리뷰 요청과 최신 head 기준 리뷰 요청을 함께 적는다.
- PR 리뷰 통과 목표는 `codex-review pass`이다. 기준은 최신 head commit에 대한 Codex review 이후 P2 이상 지적이 남아 있지 않은 상태다.
- Codex review 설정 없음, 호출 권한 없음, GitHub App 미설치, repo 정책상 비활성화가 명시적으로 확인되면 반복 호출하지 않고 `Codex review 미설정`과 확인 근거를 PR 본문 또는 보고에 남긴다. 아직 확인 전인 저장소는 미설정으로 단정하지 않고 먼저 `@codex review` 호출 접수 여부를 확인한다.
- 최신 head push 이후 작성된 최신 `@codex review` 호출 댓글에 `eyes` 반응이 있으면 접수 또는 진행 중으로 보고 같은 head에 중복 호출하지 않는다.
- `eyes` 반응이나 최신 head 리뷰 결과가 없으면 같은 head 기준으로 재호출할 수 있지만, no-`eyes` 재호출은 기본 최대 3회로 제한한다.
- 최신 head 리뷰 결과가 없거나 수정 후 재리뷰 결과가 없는 상태는 PR loop 종료 상태가 아니다. 같은 턴에서 polling과 timeout 확인을 끝낼 수 없으면 `review-waiter-agent` 또는 동등한 대기/확인 절차로 최신 head의 `codex-review pass` 여부를 관리한다.

## Layer Policy

```text
0계층: 공통 규칙, skill, config template, 역할별 agent prompt, 계층 운영 방식
1계층 User SSoT: 사용자별 유저 퍼스널리티, Feedback, 갱신 세션
1계층 Project SSoT: project 등록, Project AGENTS, decision/ADR, fork/submodule/external clone 연결, project SSoT 위치
2계층 Project Work SSoT: project 내부 issue/task/QA/coverage/runbook
3계층: silo 로컬 발견, local task, 실험 로그, PR 전 임시 상태
User Layer / Personality System: 실제 사용자 상태는 workspace의 User SSoT가 소유
```

공개 저장소에는 기본적으로 0계층 공통 산출물과 공개 가능한 템플릿만 둔다.

사용자별 유저 퍼스널리티와 Feedback은 workspace의 User SSoT에서 관리한다. 일반 세션은 퍼스널리티 갱신과 관련해서는 현재 작업 교정과 Feedback 기록까지만 수행하고, 후보 퍼스널리티 생성·시나리오 검증·반영은 사용자 명시 갱신 세션에서만 수행한다.

모든 실질적 판단과 사용자 응답 전에는 `<workspace>/user-layer/AGENTS.md`를 읽는다. 프로젝트 관련 판단 전에는 판별한 프로젝트의 `<workspace>/<projectName>/01-project-ssot/AGENTS.md`를 Project Contract 정본으로 읽는다. User Layer가 없으면 공개 template을 실제 퍼스널리티로 대신하지 않고 일반 작업을 계속한다. Feedback은 임의 경로에 만들지 않고 최종 보고에 미기록 사유를 남긴다.

task 처리 방식, 구현 플랜 수립 방식, 정보 취합 방식, 사일로/PR/review loop 운영 방식이 바뀌면 공개 가능한 범위에서 운영 가설을 남긴다. 운영 가설에는 채택 이유, 취합한 정보, 기존 방식의 문제, 예상 병목, 실행 결과, 실제 병목, 사람 확인 지점, 유지하거나 버릴 것을 기록하되, 특정 프로젝트의 비공개 task 원문, secret, 계정, 운영 데이터는 복사하지 않는다.

## PR Review Loop Policy

- PR 생성 후 Codex review를 사용할 수 있는 저장소에서는 최신 head 기준 `@codex review`를 호출하고, 현재 head 대상 지적을 `수정 필요`, `수비 가능`, `사용자 판단 필요`로 분류한다.
- Codex review 설정 없음, 권한 없음, GitHub App 미설치, repo 정책상 비활성화가 확인되면 반복 호출하지 않고 확인 근거와 `Codex review 미설정`을 PR 본문 또는 보고에 남긴다.
- 최신 head 리뷰 결과가 없거나, `eyes` 반응 이후 응답 대기 중이거나, 수정 후 재리뷰 결과가 없으면 완료로 보고하지 않는다. 메인 에이전트가 같은 턴에서 대기와 timeout 확인을 끝낼 수 없으면 `review-waiter-agent` 또는 동등한 대기/확인 절차가 이어받는다.
- 실제 제품 코드 PR에 runtime, browser, manual QA, E2E 확인이 남아 있으면 사용자 재리뷰 전에 runtime handoff를 남긴다. runtime handoff에는 실행 가능한 runtime, 접근 URL 또는 실행 방법, E2E 방법, 실행 불가 사유를 공개 가능한 범위에서 적는다.
- 문서, skill, Project SSoT, config example만 바꾼 PR에는 runtime handoff를 붙이지 않는다. secret, credential, 개인 계정, 비공개 서버 값은 runtime handoff에 쓰지 않는다.

## Edit Policy

- 문서와 보고 산출물은 한국어로 작성한다.
- 코드 식별자, 명령어, 파일명, API 이름, 외부 원문 인용은 원문을 유지할 수 있다.
- `docs/en/README.md`처럼 영문 공개 안내 목적의 다국어 안내 문서는 해당 언어 본문을 허용하지만, 일반 계획서, 보고서, skill 설명, agent metadata는 한국어로 작성한다.
- secret, token, password, credential 값은 읽거나 기록하지 않는다.
- `system/`에는 프로젝트 비의존 정의와 템플릿만 둔다.

## Skill Usage Reporting Policy

- repo skill 또는 local skill을 사용한 경우 최종 보고에 `사용한 스킬` 섹션을 포함한다.
- 도구 실행 명령과 스킬 사용은 구분한다.

## Current Worktree Reporting Policy

- 최종 보고에는 `사용한 스킬` 섹션 바로 다음에 `현재 워크트리` 섹션을 포함한다.
- `현재 워크트리`에는 최소한 절대 경로, 현재 브랜치, dirty 여부, upstream 대비 ahead/behind 요약을 적는다.
- repo skill 또는 local skill을 사용하지 않아 `사용한 스킬` 섹션이 생략되는 경우에도, git 작업을 했거나 여러 worktree가 감지되면 `현재 워크트리`를 별도 섹션으로 포함한다.

## Final Response Policy

- 최종 보고 직전에는 최종 응답 계약 체크를 수행한다.
- repo skill 또는 local skill을 사용했다면 `사용한 스킬` 섹션을 포함한다.
- git 작업을 했거나 worktree를 전환한 경우 `현재 워크트리` 섹션에 절대 경로, 브랜치, dirty 여부, upstream 대비 ahead/behind 요약을 적는다.
- 다음 행동, 승인 단위, 진행 여부, 저장 위치, 검증 범위가 남아 있으면 보기 3개를 제시한다.
- 다음 행동이 없으면 `다음 행동 없음`을 명시한다.
- 사용자가 보기 밖 답변을 하거나 선택지, 보고 방식, 승인 경계, skill 사용 누락을 지적하면 User Layer feedback 후보로 기록했는지와 저장 위치 범위를 보고한다. 실제 사용자별 feedback 원문과 비공개 로그는 공개 저장소에 커밋하지 않는다.
