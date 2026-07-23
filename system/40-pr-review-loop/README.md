# PR 리뷰 루프

`40-pr-review-loop/`는 사일로 결과가 PR로 올라온 뒤, 리뷰, 재작업, SSoT 승격 판단, 머지 보고까지 이어지는 기준을 관리합니다.

PR은 단순히 코드를 머지하는 절차가 아닙니다. 사일로가 발견한 로컬 issue/task 중 무엇을 0계층 System SSoT, 1계층 Project SSoT, 2계층 Project Work SSoT, 3계층 local/evidence/feedback으로 둘지 판단하는 시점입니다. 2계층 Project Work SSoT에는 issue/task/QA/evidence 원문을 올리고, 반복 가능한 공통 규칙, skill, prompt 후보만 0계층 승격 대상으로 분리하며, 1계층 Project SSoT에는 project-level 계약, decision/ADR, 색인, 정본 위치 참조처럼 여러 작업이 공유하는 기준만 올립니다.

## 읽는 순서

1. [`01-pr-description.md`](01-pr-description.md)
2. [`02-review-policy.md`](02-review-policy.md)
3. [`03-promotion-decision.md`](03-promotion-decision.md)
4. [`04-branch-safety-and-lifecycle.md`](04-branch-safety-and-lifecycle.md)
5. [`05-merge-report.md`](05-merge-report.md)
6. [`06-pr-template.md`](06-pr-template.md)

## 핵심 원칙

- PR 생성 승인과 PR 머지 승인은 별개입니다.
- PR의 검증 섹션은 실행 명령과 pass 수치만 나열하지 않습니다. 테스트 목적, 준비 조건과 입력, 실행 방법, 기대 결과, 실제 결과, 검증 한계, 재실행 명령을 사람이 읽는 테스트 계약으로 제공해 사용자가 테스트 코드를 직접 읽지 않고도 안전성을 판단할 수 있게 합니다.
- `main`은 레거시 보존 브랜치이며 작업 기준으로 쓰지 않습니다.
- `main-v3/main`는 보호 브랜치이며 직접 commit/push하지 않습니다.
- PR 생성 요청을 받으면 현재 브랜치의 0계층/project 계층을 판정합니다. 목표 모델에서 0계층은 `main-v3/main`, project 계층은 `project-{projectName}/{taskname}` 작업 브랜치에서 커밋한 뒤 해당 `project-{projectName}/main` 대상 PR로 올립니다. 현재 호환 상태에서는 0계층은 `main-v3/main`, project 계층은 `project-{projectName}-{taskname}` 작업 브랜치와 `project-{projectName}` 대상 PR을 사용합니다. 복합 변경은 worktree와 브랜치를 나눠 별도 PR로 올립니다.
- 1계층 Project SSoT에는 project 등록/색인, project contract, 기능/사용자 흐름별 요구사항, decision/ADR, project-level 운영 기준을 둡니다. 2계층 Project Work SSoT에는 task, issue, QA, coverage, runbook, work dashboard, Run Set/Runtime Set 같은 실행 단위 기록을 둡니다.
- 제품 repo가 독립 git submodule commit을 pin하는 경우 변경된 submodule repo마다 별도 PR과 codex-review pass 또는 동등 리뷰 gate를 확인합니다. 상위 제품 repo PR은 리뷰 통과 commit의 gitlink pin, host 설정, submodule 선언, 실행 경로 연결만 검증합니다.
- 새 submodule repo는 빈 기준 또는 최소 후보 기준에서 시작하고, 실제 코드는 PR에서 `patch/evidence`, `runtime`, `service/MSA` 유형과 평가 기준을 명시해 리뷰합니다. 기능 단위 BE/FE 분리는 기본적으로 service/MSA가 아니라 runtime 또는 patch/evidence submodule에서 시작합니다.
- 병렬 slice, mock/stub/API 임시 계약, mock 제거, 실제 service 연결, version-up 후보가 있는 PR은 정식 PR 템플릿에 해당 상태를 남깁니다. 개별 PR의 no-major만으로 버전 단위 통합이나 mock 제거 완료를 주장하지 않습니다.
- PR 생성 직후에는 0계층 PR과 project 계층 PR 모두 `codex-pr-review-loop` skill로 codex-review pass 목표를 세팅한 뒤 수동 `@codex review`를 호출하는 것을 기본 리뷰 조건으로 둡니다. 단, Codex review 설정 없음, 호출 권한 없음, GitHub App 미설치, repo 정책상 비활성화가 명시적으로 확인되면 review loop를 억지로 돌리지 않고 `Codex review 미설정`과 확인 근거를 PR 본문 또는 보고에 남깁니다. 아직 확인 전인 repo는 미설정으로 단정하지 않고 먼저 `@codex review` 호출 접수 여부를 확인합니다.
- Codex 응답은 사용자 응답을 기다리지 않고 확인합니다. 호출 뒤 3분 동안 `eyes` 반응이 없으면 접수 실패로 보고 같은 head 기준으로 최대 3회까지 재호출한 뒤 새 호출 댓글 기준으로 다시 확인합니다. 3회 모두 접수되지 않으면 `Codex 리뷰 접수 실패 timeout`으로 중단합니다. `eyes` 반응을 확인한 뒤 15분 동안 응답이 없으면 `Codex 리뷰 응답 대기 timeout`으로 중단합니다. codex-review pass 응답이 없거나 현재 head 대상 P1/P2/major/critical 지적이 남아 있으면 타당한 지적을 수정, 검증, push한 뒤 재리뷰를 요청합니다.
- 일반 task summary는 formal pass 증거가 아닙니다. 단, `Codex Review` 완료 표지, exact phrase, 최신 head reviewed commit을 함께 가진 no-finding comment는 exact pass 후보입니다. 대기 중 actionable issue comment도 수집하고 네 evidence 표면 안정화 뒤 pass를 확정합니다.
- 각 PR completion gate 결과는 최소 `status`, `headSha`, `evidence`, `failureReason`, `nextProcess`로 남깁니다. 새 commit이 push되면 이전 head의 review/E2E/handoff gate 결과는 최신 head 통과 근거로 재사용하지 않습니다.
- 최신 head 리뷰 결과가 없는 `eyes` 진행 중 상태, 리뷰 호출 직후 접수 확인 전 상태, 수정 후 push했지만 재리뷰 결과가 없는 상태는 PR loop 종료 상태가 아닙니다. 메인 에이전트가 같은 턴에서 polling/timeout 확인을 끝낼 수 없으면 기본적으로 `review-waiter-agent`가 최신 head에 대한 `Didn't find any major issues` 또는 동등한 codex-review pass 명시 응답과 현재 head 대상 지적의 `수정 필요`/`수비 가능`/`사용자 판단 필요` 분류까지 백그라운드 루프로 관리합니다. 이전 head 리뷰가 새 push 이후 늦게 게시되어도 작성 시각만으로 현재 head 지적에 섞지 않습니다. task silo의 `goal.md`가 확인되면 codex-review pass 목표를 세팅하고, 그렇지 않으면 PR 본문, 리뷰 thread, 현재 사용자 요청을 컨텍스트로 사용합니다. 반복 한도는 사용자가 이번 PR에 명시한 경우에만 적용합니다.
- `review-waiter-agent`의 최신성 기준은 review-waiter README/prompt를 우선하며, PR loop README는 그 요약만 둡니다. README/prompt와 다르면 review-waiter 문서 기준으로 최신 head, exact phrase, 동등 pass, no-`eyes` 3회, 15분 timeout을 다시 대조합니다.
- 사일로 발견 사항은 2계층 Project Work SSoT에 올릴 task/issue/QA/runbook 후보, 1계층 Project SSoT에 올릴 project contract/decision/ADR 후보, 0계층 공통 규칙 후보, 3계층 local/evidence/feedback 유지 항목으로 나눈 뒤 `feedback/follow-up 후보`와 `처리하지 않고 남긴 항목`에 분리 기록합니다.
