# 리뷰 정책

## PR 유형별 Codex 리뷰 조건

PR을 올리라는 지시는 먼저 현재 브랜치의 계층과 PR 유형을 판정하라는 뜻으로 해석합니다.

- PR 전에는 현재 브랜치 diff를 0계층 공통 변경과 project 계층 변경으로 나눕니다.
- 0계층 공통 규칙, `AGENTS.md`, `system/`, repo skill, agent prompt 변경은 `main-v2` 기준 브랜치와 `main-v2` 대상 PR로 올립니다.
- 1계층 project 등록/색인, 2계층 project SSoT, task, issue, QA, decision, coverage, runbook 변경은 해당 `project/<project-id>`를 기준 브랜치로 삼되, 별도 worktree의 파생 브랜치에서 커밋하고 `project/<project-id>` 대상 PR로 올립니다. 사용자가 “1계층 PR”이라고 말하면 이 project 계층 PR까지 포함해 판정합니다.
- project 변경을 Codex review gate 때문에 `main-v2`로 retarget하지 않습니다.
- 하나의 작업 브랜치에 0계층 변경과 1계층 이상 변경이 함께 있으면, 0계층 변경은 별도 `main-v2` worktree/브랜치/PR로 분리하고 project 변경은 `project/<project-id>`에서 판 별도 worktree의 파생 브랜치와 `project/<project-id>` 대상 PR로 분리합니다.
- PR 생성 직후에는 0계층 PR과 project 계층 PR 모두 [`codex-pr-review-loop`](../20-skills/codex-pr-review-loop/SKILL.md)로 no-major 목표를 세팅하고, PR 댓글의 수동 `@codex review`를 호출합니다.
- 제품 소스가 독립 git submodule로 분리된 경우 상위 제품 repo PR에서 submodule gitlink만 리뷰받는 것으로는 충분하지 않습니다. 변경된 각 submodule repo도 보호 브랜치 직접 커밋을 금지하고, submodule repo별 파생 브랜치와 별도 PR, Codex no-major 또는 동등한 리뷰 gate를 거칩니다.
- 상위 제품 repo PR은 no-major 또는 동등 리뷰가 끝난 submodule commit만 gitlink로 pin합니다. 상위 PR의 리뷰 범위는 submodule commit pin, host repo 설정, submodule 선언, 실행 경로 연결이 의도한 submodule PR 결과를 가리키는지로 제한하고, submodule 내부 코드 품질과 API 동작 평가는 해당 submodule repo PR에서 수행합니다.
- 새 submodule repo는 먼저 repo를 만들고, 기본 브랜치에는 빈 기준 또는 최소 단일 후보 파일만 둡니다. 실제 적용 후보 코드는 PR로 올리고, PR 본문에 repo 존재 목적, 제품 적용 기준, 평가 기준, 검증 한계, pin 조건을 적습니다.
- 기능 단위 BE/FE 분리는 곧바로 service/MSA로 승격하지 않습니다. 기본 시작점은 제품 적용 후보를 리뷰하는 `patch/evidence submodule` 또는 제품 repo가 submodule path에서 실제 import/register하는 `runtime submodule`입니다. 별도 배포, DB, auth, observability가 독립적으로 필요하다는 증거가 있을 때만 service/MSA 후보로 승격합니다.
- 호출 댓글에는 가능하면 `한국어로 리뷰해 주세요.` 또는 이에 준하는 한국어 요청과 최신 head 기준 리뷰 요청만 적습니다. 외부 리뷰 봇의 고정 안내 템플릿 언어까지 보장하지는 못하지만, repo 운영 언어와 맞추기 위한 기본 요청 문구로 둡니다.
- `Didn't find any major issues` 또는 그와 동등하게 최신 head에 major/actionable 지적이 없다는 Codex 명시 응답은 통과로 봅니다. 반복 조건과 통과 판정은 외부 리뷰 댓글에 강제하지 않고, PR 본문, task silo의 `goal.md`, 메인 에이전트 내부 상태에서 관리합니다.
- 같은 PR에서 현재 head push 이후에 작성된 최신 `@codex review` 호출 댓글에 `eyes` 반응이 있으면 Codex 리뷰가 접수 또는 진행 중인 상태로 봅니다. 같은 head commit에 추가 요청을 보내지 않고 `eyes` 확인 시점부터 최대 15분까지 응답을 기다립니다.
- 현재 head push 이후에 `@codex review`를 호출했지만 3분 동안 해당 호출 댓글에 `eyes` 반응이 붙지 않으면 리뷰 요청이 접수되지 않은 것으로 보고, 같은 head 기준으로 `@codex review`를 재호출합니다. 재호출 전에는 그 사이에 Codex 리뷰 결과가 도착했는지 먼저 확인합니다.
- `eyes` 반응을 확인한 뒤 15분 동안 Codex 응답이 없으면 루프를 중단하고 `Codex 리뷰 응답 대기 timeout`으로 보고합니다. 이 경우 중복 호출이나 임의 수정 없이 PR URL, head SHA, 호출 댓글, 대기 시간을 남깁니다.
- 재호출 전에는 PR 댓글, 리뷰 제출, 최신 head commit, 최신 head push 이후 작성된 리뷰 요청 여부를 함께 확인합니다. 최신 head에 대한 리뷰 결과가 아직 없고 현재 head 이후 호출 댓글에 `eyes`가 있으면 중복 호출이 아니라 대기 상태로 기록합니다.
- 리뷰는 변경 diff, task 목표, 검증 결과, 남은 위험, SSoT 승격 후보를 기준으로 합니다.
- Codex 응답이 no-major 통과 응답이 아니면 actionable 지적의 타당성을 판단합니다. 타당한 major/critical/P1/P2 또는 보호 절차 위반 지적은 수정, 검증, 커밋, push 후 새 head 기준으로 `@codex review`를 재호출합니다.
- PR 생성 후에는 `codex-pr-review-loop` 기준으로 최신 head에 대한 no-major Codex 응답이 나올 때까지 수정, 검증, 재리뷰를 반복합니다. task silo의 `goal.md`가 확인되면 no-major 목표를 `goal.md`에 세팅하고, 그렇지 않으면 PR 본문, 리뷰 thread, 현재 사용자 요청을 재리뷰 컨텍스트로 사용합니다.
- 기본 중단 기준은 호출 횟수가 아니라 리뷰 결과입니다.
- 반복 이후에도 남은 major/critical 또는 보호 절차 P1/P2 항목은 횟수 기준으로 중단하지 않고, 실제 blocker 여부와 사용자 승인 gate 필요 여부를 분리합니다.
- 사용자가 `~PR을 리뷰 대기 에이전트로 돌려주세요`, `이 PR 리뷰 대기 에이전트로 맡겨주세요`, `Sartre처럼 돌려주세요`처럼 명시하면 `review-waiter-agent`가 별도 루프로 관리합니다. 사용자가 이번 PR에 명시한 상한이 있을 때만 그 상한을 따릅니다.
- 도구 실행 실패 또는 생략 시 실패 원인과 대체 검토 범위를 분리합니다.

## 리뷰 라운드

```text
사일로 내부 검증
-> PR 전 Codex 리뷰 조건 확인
-> 사일로 PR 생성
-> 리뷰 결과 확인
-> actionable comment가 있으면 수정 후 재리뷰 반복
-> 리뷰 조건 종결
-> 사용자 재리뷰 대기
-> 메인 리뷰
-> 재작업 요청
-> 사일로 수정
-> PR 업데이트
-> 메인 재리뷰
-> 머지 또는 추가 재작업
```

각 라운드는 PR 기록에 남깁니다.

## 메인 리뷰 체크리스트

- 원래 issue/task 해결 여부
- 변경 범위가 허용 scope 안인지
- 보호 브랜치에 직접 손대지 않았는지
- 새 작업 브랜치에서 작업했는지
- 변경된 submodule repo가 있으면 각 submodule repo에도 별도 PR과 리뷰 gate가 있는지
- 상위 제품 repo가 리뷰 통과한 submodule commit만 gitlink로 pin했는지
- submodule repo 기본 브랜치가 제품 코드 우회 머지 경로가 아니라 빈 기준 또는 최소 후보 기준으로 유지됐는지
- submodule 유형이 `patch/evidence`, `runtime`, `service/MSA` 중 무엇인지 PR 본문에 명시됐는지
- service/MSA 승격이라면 별도 배포, DB, auth, observability 필요 증거가 있는지
- 검증 결과가 acceptance criteria를 덮는지
- criteria별 검증 방법이 unit, integration, runner, E2E, agent-browser, manual 중 무엇인지 명시됐는지
- 자동 검증이 보장하는 것과 보장하지 못하는 것이 분리됐는지
- agent가 통제한 대체 검증 경로 통과를 실제 사용자 설치/로그인/네트워크 경로 통과로 보고하지 않았는지
- 사용자 화면, 설치, 서버 실행, 앱 다운로드 가능 상태가 acceptance에 포함될 때 `Pre-QA Gate`와 사용자 QA 리스트가 있는지
- 실행 불가한 runner, E2E, agent-browser, 외부 도구가 있으면 실행 불가 사유, 대체 증거, 남은 수동 확인 범위가 기록됐는지
- 화면 동작 변경에 E2E 또는 agent-browser 증거가 있는지
- 신규/변경 로직에 unit test 또는 테스트 생략 사유가 있는지
- `명사 설명` 또는 첫 등장 위치에서 특수용어, 고유명사, 내부 약어, runner 용어, coverage 용어가 정의됐는지
- 내부 판단을 함축하는 표현이 실제 예시와 함께 설명됐는지
- 제외 판단이 제외 대상, 제외 기준, 제외하지 않는 예외, 예시 page/item, 후속 검증 위치를 모두 포함하는지
- dictionary를 생성하거나 용어를 추가/수정/삭제한 PR에 `새로 추가된 단어` 섹션이 있는지
- 사용자 취향 규칙을 위반하지 않았는지
- 사일로 발견 항목 중 승격해야 할 것이 빠지지 않았는지
- 승격하지 않을 항목의 이유가 충분한지
- 다음 사일로로 넘길 작업이 있는지
