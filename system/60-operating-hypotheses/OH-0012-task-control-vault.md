# 고정 Task Control Vault와 승인 후 번호 발급 가설

## ID

OH-0012

## 상태

draft

## 기간

- 시작: 2026-07-21
- 종료 또는 폐기:

## 상태 재검증

- 최근 재검증: 2026-07-21
- 최근 근거: 사용자는 보호 브랜치 직접 커밋 금지와 실제 Obsidian 검수 요구를 함께 유지해야 하며, 5개 이상의 병렬 세션이 Task를 작성·갱신할 때 단일 전환형 Vault와 현재 번호 탐색 방식이 병목이 된다고 확인했습니다.
- 다음 재검증 조건: 고정 Task Control Vault prototype에서 서로 다른 신규 Task 5개와 같은 Task 갱신 요청 5개를 병렬 처리하고, 승인·번호 발급·PR 승격·merge 후 정본 동기화까지 한 번 이상 완료합니다.
- 외부 PR 근거:

## 상태 변경 추적

- 이전 상태: 없음
- 현재 상태: draft
- 변경일: 2026-07-21
- 변경 PR:
- 검증 링크 또는 명령: `bash system/tests/core/run.sh`, `bash system/tests/general/run.sh`
- README count 변경: draft 10개에서 11개로 변경
- 상태 변경 이유: 사용자와 구조·lease·번호 발급·승격 설계를 승인했지만 구현과 실제 병렬 사용 검증 전입니다.

## 운영 가설

일반 Workspace Local 계약 아래 `local/task-control/<작업명>/`을 Task 특화 검수 공간으로 사용하고, 모든 세션이 Project Work SSoT 원문 대신 생성·갱신 요청을 제출하며, 사용자가 revision/hash를 승인한 뒤에만 정식 Task 번호와 독립 작업 브랜치를 발급하면 보호 브랜치를 우회하지 않으면서 병렬 Task 검수·번호 충돌·편집 충돌을 관리할 수 있습니다.

## 채택 이유

Task 문서를 작업 브랜치별 worktree에서 작성하면 보호 브랜치 규칙은 지킬 수 있지만 사용자가 평소 여는 Obsidian Vault에서는 merge 전 결과가 보이지 않습니다. 단일 고정 worktree의 브랜치를 전환하는 방식은 여러 세션을 동시에 검수할 수 없고 열린 문서, Dataview 결과와 workspace 상태가 전환 대상에 따라 흔들립니다.

태스크별 Vault를 늘리는 방식은 병렬성은 확보하지만 사용자가 검수 대상을 찾고 Vault를 정리해야 하는 비용이 세션 수에 비례해 증가합니다. 반대로 고정 Task Control Vault가 로컬 요청·검수 상태만 소유하고 Git 정본 승격을 별도 작업 브랜치로 분리하면 사용자는 한곳에서 검수하면서도 unrelated Task가 하나의 브랜치나 PR에 결합되는 문제를 피할 수 있습니다.

## 취합한 정보

- 보호 브랜치와 계층 메인 브랜치에는 직접 commit하거나 push하지 않습니다.
- Project Work SSoT의 Task 원문은 project 계층 작업 브랜치와 PR을 통해서만 변경합니다.
- 사용자는 merge된 결과가 아니라 승인 전에 실제 Obsidian에서 문서와 dashboard를 검수하려 합니다.
- 5개 이상의 세션이 서로 다른 Task를 동시에 작성하거나 같은 Task의 갱신 근거를 제출할 수 있습니다.
- 기존 번호 관리 방식은 최신 project main, 열린 PR과 sibling worktree의 신규 ID를 모두 확인하고 merge 직전에 다시 검증합니다.
- 병렬 브랜치가 같은 번호를 선택하면 Git 파일 충돌 없이 중복 Task ID가 생길 수 있습니다.
- Task의 `todo`, `in_progress`, `blocked`, `done`은 실행 상태이므로 문서가 작성 중인지 사용자 검토 중인지를 표현하는 필드로 재사용할 수 없습니다.

## 기존 방식의 문제

- merge 전 Task를 보려면 사용자가 작업 worktree를 별도 Vault로 열거나 브랜치를 전환해야 합니다.
- 태스크별 Vault는 병렬 세션 수만큼 Vault 목록과 Obsidian workspace 상태를 늘립니다.
- 고정 worktree에서 여러 Task 변경을 함께 관리하면 unrelated 변경이 하나의 브랜치와 PR에 결합됩니다.
- 같은 Task를 여러 세션이 직접 수정하면 마지막 writer가 앞선 근거를 덮거나 사용자가 검토 중인 문서가 자동으로 바뀔 수 있습니다.
- 신규 Task가 초안 단계부터 영구 번호를 사용하면 병렬 초안 간 번호 충돌과 폐기된 번호의 재사용 여부를 계속 관리해야 합니다.
- 세션 중단 후 편집 주체와 진행 상태를 알 수 없으면 영구 잠금 또는 무단 takeover가 발생할 수 있습니다.

## 예상 병목

- Task Control Vault가 단일 승격 지점이 되어 승인된 항목이 몰릴 때 promotion queue가 길어질 수 있습니다.
- 사용자 검토 중 새 요청을 검수본에 자동 합치지 않으므로 다음 revision까지 반영이 지연될 수 있습니다.
- 로컬 lease는 같은 workspace의 병렬 세션을 조정할 수 있지만 외부 머신이 규칙을 우회해 Task 번호를 직접 발급하면 merge 직전 재검증이 여전히 필요합니다.
- 승인 뒤 최신 main에서 같은 Task가 변경되면 검수본을 다시 합성해야 합니다.
- `DRAFT`를 정식 Task ID로 치환할 때 파일명, frontmatter와 내부 참조를 빠짐없이 바꾸는 검증기가 필요합니다.
- 고정 Vault의 로컬 상태와 Project Work SSoT 정본이 시각적으로 섞이면 사용자가 검수본을 정본으로 오해할 수 있습니다.

## 적용한 작업 방식

### 1. 소유권과 계층

Task Control Vault는 별도 Obsidian vault가 아니라 workspace 단일 vault 안의 `local/task-control/` 하위 사용 사례이며, Git 정본이 아닌 3계층 검수·조정 표면입니다. 아래 자료만 소유합니다.

```text
Task Control Vault
├── inbox/       세션별 불변 생성·갱신 요청
├── drafts/      사용자가 Obsidian에서 보는 검수본
├── editing/     Task별 편집 상태와 lease
└── dashboard/   대기·작성·검토·승격 현황
```

구현 세션은 Project Work SSoT의 Task 원문을 직접 수정하지 않고 고유 요청 ID를 가진 파일을 `inbox/`에 제출합니다. 요청 파일은 접수 후 수정하지 않으며 같은 요청이 재전송되면 요청 ID로 중복 제거합니다.

Task Control Vault의 local 파일은 Git diff, 0계층 PR과 project PR에 포함하지 않습니다. 사용자 승인 뒤에만 승인된 검수본 하나를 project 계층 전용 worktree와 작업 브랜치로 승격합니다.

### 2. 생성과 갱신 흐름

신규 Task는 승인 전까지 `DRAFT-<날짜>-<고유ID>`를 사용합니다.

```text
병렬 세션의 요청
→ 고정 Vault inbox
→ DRAFT 검수본 합성
→ Obsidian 사용자 검토
→ 특정 revision과 hash 승인
→ 최신 project main 확인
→ 정식 TASK-NNNN 발급
→ 독립 작업 브랜치와 PR
```

기존 Task 갱신은 정식 ID를 그대로 사용합니다.

```text
TASK-NNNN 갱신 요청
→ Task별 편집 lease
→ 현재 정본과 모든 미반영 요청 합성
→ Obsidian 사용자 검토
→ 특정 revision과 hash 승인
→ TASK-NNNN 전용 작업 브랜치와 PR
```

서로 다른 Task는 동시에 편집할 수 있습니다. 같은 Task의 여러 요청은 모두 보존하되 검수본 writer는 Task별 lease 하나로 직렬화합니다.

### 3. 편집 상태와 lease

Task 문서 편집 상태는 Task 실행 상태와 분리합니다.

```text
Task 실행 상태: todo / in_progress / blocked / done
Task 편집 상태: queued / editing / awaiting_review / approved / promoting / merged / stale
```

편집 레지스트리는 최소한 아래 값을 가집니다.

```yaml
target: TASK-0009
edit_state: editing
lease_id: lease-20260721-ab12
lease_owner: session-abc
acquired_at: 2026-07-21T17:00:00+09:00
heartbeat_at: 2026-07-21T17:05:00+09:00
expires_at: 2026-07-21T17:20:00+09:00
base_sha: 3c39dddb
draft_revision: 3
included_requests:
  - request-session-abc-001
  - request-session-def-004
```

기본 편집 lease는 15분이며 writer가 5분마다 heartbeat를 갱신합니다. heartbeat 없이 만료되면 상태를 `stale`로 바꾸되 요청과 마지막 검수본은 삭제하지 않습니다. 다음 writer는 마지막 revision과 미반영 요청에서 이어갑니다.

`awaiting_review`에서는 자동 편집을 멈춥니다. 새 요청은 inbox에 쌓고 dashboard에 대기 건수를 표시하되 사용자가 보고 있는 revision을 바꾸지 않습니다. 사용자 검토 자체에는 자동 만료를 적용하지 않습니다.

사용자 승인은 검수본의 revision과 내용 hash에 연결합니다. 승인 뒤 내용이 바뀌면 기존 승인을 무효화하고 `awaiting_review`로 되돌립니다.

### 4. 번호 발급

신규 Task 번호는 사용자 승인 직후, 승격 worktree를 만들기 직전에 프로젝트 단위 allocation lease 아래 발급합니다.

- 비어 있는 과거 번호를 재사용하지 않습니다.
- 정본, 승격 중인 예약과 열린 PR에서 확인되는 가장 큰 번호 다음 값을 사용합니다.
- 발급 결과는 `draft_id`, `task_id`, 승인 revision/hash, 기준 SHA, 승격 브랜치와 상태를 함께 기록합니다.
- 기존 Task 갱신에는 새 번호를 발급하지 않습니다.

```yaml
draft_id: DRAFT-20260721-AB12
task_id: TASK-0032
approved_revision: 4
approved_hash: sha256:example
allocated_from_sha: 3c39dddb
promotion_branch: project-example/task-0032-example
allocation_state: promoting
```

승격 직전과 merge 직전에 최신 project main, 열린 PR과 sibling worktree를 다시 확인합니다. 같은 번호가 먼저 사용됐으면 다음 번호로 재발급하고 이전 번호는 `superseded` 이력으로 남겨 재사용하지 않습니다.

내용 변경 없이 ID만 기계적으로 바뀌면 사용자 내용 재검토를 요구하지 않습니다. dependency, 연결 Task나 본문 의미가 바뀌면 최신 정본과 다시 합성해 `awaiting_review`로 돌립니다.

### 5. 정본 승격과 승인 경계

승인된 신규 Task 하나 또는 기존 Task 갱신 하나마다 독립된 project 계층 작업 브랜치와 PR을 만듭니다. 고정 Vault의 다른 검수본이나 요청을 함께 넣지 않습니다.

신규 Task 승격기는 파일명, `id`, `taskID`와 내부 자기 참조를 정식 ID로 치환하고 Work Item 검증을 실행합니다. 기존 Task는 승인 검수본의 기준 SHA 이후 같은 원문이 main에서 바뀌었는지 확인합니다.

검수본 승인은 작업 브랜치 생성, 검증, commit, push와 PR 생성을 허용합니다. PR merge는 기존 명시 승인 경계를 유지합니다. merge 후에는 정본의 merge commit과 파일 hash를 검수본에 연결하고 상태를 `merged`로 바꿉니다.

### 6. 오류 처리

| 상황 | 처리 |
| --- | --- |
| 같은 요청 재전송 | 요청 ID로 중복 제거 |
| 같은 Task 동시 편집 | 기존 lease 유지, 후속 writer는 queue 대기 |
| writer 중단 | lease 만료 후 `stale`, 마지막 revision에서 복구 |
| 사용자 검토 중 추가 요청 | 현재 revision 고정, 다음 revision 대기로 표시 |
| 승인 hash 이후 파일 변경 | 승인 무효화, `awaiting_review` 복귀 |
| 같은 Task의 main 변경 | 자동 승격 중단, 최신 정본과 재합성 |
| Task 번호 충돌 | 다음 번호 재발급, 이전 번호 `superseded` |
| ID 외 의미 변경 | 사용자 재검토 |
| Git 인증 또는 원격 조회 실패 | 정식 번호 발급과 승격 중단, local draft 유지 |
| PR merge 실패 또는 보류 | `promoting` 유지, 정본으로 표시하지 않음 |

### 7. 검증 설계

다음 압력 시나리오를 자동 검증합니다.

1. 서로 다른 신규 Task 5개를 동시에 접수해 요청과 검수본이 섞이지 않습니다.
2. 같은 Task에 5개 세션이 갱신 요청을 제출해 요청은 모두 남고 writer는 하나뿐입니다.
3. 편집 세션 종료 후 lease가 만료되고 마지막 revision에서 복구됩니다.
4. 사용자 검토 중 추가 요청이 들어와도 현재 revision과 hash가 바뀌지 않습니다.
5. 승인 뒤 파일이 바뀌면 승인이 무효화됩니다.
6. 비어 있는 과거 번호를 재사용하지 않습니다.
7. 동시에 승인된 신규 Task가 서로 다른 정식 번호를 받습니다.
8. 열린 PR과 번호가 충돌하면 다음 번호로 재발급됩니다.
9. 같은 Task가 main에서 먼저 바뀌면 자동 승격이 중단됩니다.
10. merge 후 검수본의 승인 hash, 정식 Task 파일과 merge commit의 대응 관계를 확인합니다.
11. Task Control Vault의 local 상태가 Git diff에 포함되지 않습니다.
12. 계층 메인 브랜치에 직접 commit하거나 push하지 않습니다.

## 적용 범위

- 여러 세션이 동시에 Task를 생성·갱신하는 workspace의 공통 운영 방식
- Project Work SSoT Task 원문과 Obsidian 검수 표면의 분리
- 신규 Task 임시 ID, 정식 번호 발급과 재번호화
- Task 문서 편집 lease, 사용자 검토 revision과 장애 복구
- 승인된 Task의 project 계층 작업 브랜치·PR 승격
- 상위 preflight, local-only 쓰기 경계, Obsidian 링크와 일반 승격 순서는 `system/00-system-overview/workspace-local-review-and-promotion.md`를 따름

Project별 Task template, 실제 저장 경로, status schema, 번호 자릿수와 Work Item 검증 명령은 각 Project Contract와 Project Work SSoT가 소유합니다.

## 실행 결과

- 사용자가 단일 전환형 Vault와 태스크별 Vault의 병렬 검수 문제를 확인했습니다.
- 고정 Task Control Vault, Task별 lease, 사용자 검토 revision, 승인 후 번호 발급과 독립 PR 승격 설계를 순서대로 승인했습니다.
- 구현, prototype 압력 검증과 실제 project 적용은 아직 수행하지 않았습니다.

## 실제 병목

실사용 전이므로 실제 처리량, 사용자 검토 지연, stale lease 빈도와 번호 재발급 빈도는 아직 측정되지 않았습니다. 첫 prototype에서는 예상 병목과 별도로 아래를 기록합니다.

- inbox 접수부터 `awaiting_review`까지 걸린 시간
- 사용자 검토 중 추가 요청 수
- stale lease와 수동 복구 횟수
- 승인부터 PR 생성까지 걸린 시간
- 번호 충돌과 재발급 횟수
- 검수본과 정본의 drift 발생 횟수

## 사람 확인 지점

- 사용자가 하나의 고정 Vault에서 신규·갱신 검수본과 현재 상태를 구분할 수 있는지 확인합니다.
- `DRAFT`가 정본 Task가 아니라는 사실이 Obsidian 화면에서 분명한지 확인합니다.
- 사용자 검토 중 추가 요청을 다음 revision으로 미루는 방식이 예측 가능한지 확인합니다.
- 내용 변경 없는 기계적 재번호화에 재검토가 필요 없는지 확인합니다.
- 검수본 승인과 PR merge 승인을 분리한 경계가 과도한 반복 승인으로 느껴지는지 확인합니다.

## 유지할 것

- 보호 브랜치와 계층 메인 브랜치 직접 수정 금지
- Task 원문 변경의 project 계층 작업 브랜치·PR 분리
- 한곳에서 실제 Obsidian 검수를 수행하는 사용자 표면
- Task 실행 상태와 문서 편집 상태의 분리
- 요청 원문 보존과 Task별 단일 writer
- 승인 revision/hash 고정
- 승인 전 임시 ID와 승인 후 단조 증가 정식 번호 발급
- unrelated Task별 독립 PR

## 버릴 것

- 검수를 위해 계층 메인 브랜치에 직접 commit하는 방식
- 한 고정 worktree의 브랜치를 검수 대상마다 전환하는 방식
- 병렬 세션 수만큼 Vault를 수동 등록·정리하는 방식
- 모든 세션이 Project Work SSoT Task 원문을 직접 수정하는 방식
- Task 실행 `status`로 문서 편집 상태를 표현하는 방식
- 승인 전 영구 Task 번호를 선점하는 방식
- 사용자 검토 중인 검수본을 새 요청으로 자동 변경하는 방식

## 0계층 반영 위치

- 반영 완료: 승인된 운영 가설 설계와 카탈로그 등록
- 반영 후보: 공통 Task Control Vault scaffold, request·draft·lease schema, 번호 발급기, dashboard, 승격 skill과 압력 테스트
- 미구현 후보: Obsidian 검수본 바로가기, stale lease 복구 명령, merge 후 정본 hash 동기화
- 문서: `system/60-operating-hypotheses/OH-0012-task-control-vault.md`
- skill: Task 생성·갱신 라우팅용 신규 공통 skill 또는 기존 project/task 관리 skill 보강 후보
- agent prompt: main orchestrator와 Task 작성 역할의 직접 원문 수정 금지 및 inbox 제출 규칙 후보
- 적용 단계: 설계 승인, 0계층 구현 전
- 검증 상태: core baseline 통과, 설계 압력 시나리오 미구현
- PR 번호:
- 적용 단계 메모: 0계층 구현 이후 첫 project prototype에서 실제 병렬 요청과 Obsidian 검수 흐름을 재검증합니다.

## 후속 운영 가설 후보

- 사용자 검토 중 추가 요청을 별도 revision으로 미루는 방식이 검수 안정성과 처리 지연 사이에서 적절한가
- 승인된 Task promotion을 하나씩 직렬화해야 하는가, 번호 발급만 직렬화하고 PR 승격은 병렬화할 수 있는가
- Task 외 Issue, QA와 runbook에도 같은 Control Vault 요청·검수 모델을 확장할 가치가 있는가
