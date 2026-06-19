# 사일로 시스템

사일로는 메인 오케스트레이터가 특정 issue, task, page, 검증 실행을 처리하기 위해 만드는 격리 작업 단위입니다.

사일로는 역할 이름이 아니라 작업 단위 이름으로 만듭니다. 기본 디렉토리 이름은 task면 `task-<TASK-ID>/`, issue면 `issue-<ISSUE-ID>/`, page면 `page-<PAGE-ID>/`를 씁니다.

## 문서 구성

| 문서 | 역할 |
|---|---|
| `README.md` | 사일로 시스템 입구와 전체 원칙 |
| `01-silo-type.md` | 테스트 사일로와 일반 사일로 구분 |
| `02-silo-goal.md` | 사일로 입력, 자동 준비 범위, `goal.md` 필수 항목 |
| `03-silo-workspace.md` | 사일로 root, source workspace, clone/branch 규칙 |
| `10-silo-lifecycle/test.md` | 테스트 사일로 생명주기 |
| `10-silo-lifecycle/normal.md` | 일반 사일로 생명주기 |
| `10-silo-lifecycle/hypothesis-chain.md` | 일반 사일로 전용 가설 체인 |
| `20-silo-workflow/test.md` | 테스트 사일로 실행 workflow |
| `20-silo-workflow/normal.md` | 일반 사일로 실행 workflow |
| `20-silo-workflow/yolo-mode.md` | 일반 사일로 기본 실행 모드와 금지선 |
| `20-silo-workflow/review-gate.md` | PR 리뷰 gate와 완료 판정 |
| `30-silo-output.md` | 산출물, 종료 상태, 승격 후보 |
| `40-silo-runtime-set/README.md` | shared runtime과 runtime set |
| `40-silo-runtime-set/run-set.md` | 테스트 사일로 실행 묶음인 Run Set |

## 기본 원칙

- 사일로는 SSoT와 메인 오케스트레이터 규칙을 따릅니다.
- 사일로 루트와 제품 repo/source workspace는 다른 개념입니다.
- 사일로는 현재 workspace 루트의 보이는 디렉토리에 만듭니다.
- 사용자가 명시하지 않는 한 `/tmp`, 홈 디렉토리, 숨김 디렉토리, 에이전트 전용 임시 경로를 기본 위치로 쓰지 않습니다.
- 사일로는 보호 브랜치에서 직접 작업하지 않고 새 작업 브랜치를 만듭니다.
- task 또는 issue 사일로를 실제로 시작하는 순간 project SSoT의 원본 task/issue 상태를 `in_progress`로 갱신합니다. 사일로 root, `goal.md`, repo clone, 작업 브랜치 중 하나라도 생성했으면 시작으로 봅니다.
- 상태 갱신을 할 수 없으면 사일로를 계속 진행하지 않고, 갱신 불가 이유와 임시 evidence 위치를 보고합니다.
- 격리 clone 내부에서는 문제 해결에 필요한 source code, generated output, test, tooling 수정을 허용합니다.
- 결과는 PR, report, evidence, handoff, SSoT 승격 후보로 메인 오케스트레이터에게 돌아와야 합니다.
- secret, credential, production 데이터, destructive action, 보호 브랜치 직접 수정, data SSoT 임의 변경은 사일로에서도 승인 gate입니다.
