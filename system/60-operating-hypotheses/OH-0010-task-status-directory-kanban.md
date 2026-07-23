# Task 상태 디렉터리와 칸반 동기화 가설

## ID

OH-0010

## 상태

draft

## 기간

- 시작: 2026-07-10
- 종료 또는 폐기:

## 상태 재검증

- 최근 재검증: 2026-07-10
- 최근 근거: 사용자가 Task 디렉터리를 다섯 상태별로 나누고 전용 칸반보드를 추가하는 방식을 승인했습니다.
- 다음 재검증 조건: 첫 project 마이그레이션 뒤 상태 전환 누락, 경로와 frontmatter 불일치, 칸반 누락 또는 탐색 비용을 확인합니다.
- 외부 PR 근거: 0계층과 첫 project 적용 PR이 머지된 뒤 기록합니다.

## 상태 변경 추적

- 이전 상태: 없음
- 현재 상태: draft
- 변경일: 2026-07-10
- 변경 PR:
- 검증 링크 또는 명령: 구현 계획에서 확정합니다.
- README count 변경: draft 8개에서 9개로 변경
- 상태 변경 이유: 승인된 설계를 구현하고 첫 project에서 검증하기 전입니다.

## 운영 가설

Task 파일을 `todo`, `in_progress`, `blocked`, `review`, `done` 디렉터리로 나누고 파일 경로와 frontmatter `status`를 같은 변경 단위로 관리하면, 작업 상태를 파일 탐색기와 칸반에서 즉시 파악하면서도 문서 기반 필터와 자동화를 유지할 수 있습니다.

## 채택 이유

현재 기본 scaffold는 모든 Task를 `30-work-items/tasks/` 한 디렉터리에 두고 frontmatter `status`로만 구분합니다. 멀티필터 대시보드는 상태 조회를 지원하지만, 파일 트리에서는 작업 흐름이 드러나지 않습니다. 사용자는 상태별 디렉터리와 전용 칸반을 함께 요청했고, 다섯 상태 디렉터리와 DataviewJS 전용 칸반 방식을 승인했습니다.

별도 칸반 플러그인 없이 기존 Dataview 전제 안에서 구현하면 추가 설치와 플러그인별 데이터 동기화를 피할 수 있습니다. 칸반은 조회 화면으로 한정하고, 상태 전환은 Task 파일 이동과 frontmatter 갱신으로 명시합니다.

## 취합한 정보

- 기존 Task 상태 집합은 `todo`, `in_progress`, `blocked`, `review`, `done`입니다.
- 현재 scaffold는 `tasks/` 단일 디렉터리, `TASK-template.md`, DataviewJS `work-filter.md`, Obsidian Base `work-items.base`를 생성합니다.
- 기존 대시보드의 scope는 `30-work-items/tasks/`를 기준으로 하며 하위 경로를 재귀 수집할 수 있습니다.
- 사용자는 다섯 상태 디렉터리와 별도 `00-dashboard/kanban.md`를 선택했습니다.
- 사용자는 필요하면 플러그인 사용을 허용했지만 Dataview만으로 충분하면 Dataview 사용을 요청했습니다.
- 첫 적용 대상은 별도 project 계층 메인 브랜치의 Project Work SSoT입니다.

## 기존 방식의 문제

- 파일 트리만 보면 Task의 현재 상태를 구분할 수 없습니다.
- 상태별 작업량과 흐름을 한눈에 보는 칸반 화면이 없습니다.
- Task 상태 변경 규칙이 frontmatter 수정에만 집중되어 있어 상태별 디렉터리를 도입하면 경로와 metadata가 어긋날 수 있습니다.
- 실제 Task와 템플릿이 같은 live 디렉터리에 있어 재귀 조회와 검증에서 반복적인 예외 처리가 필요합니다.

## 예상 병목

- 상태 변경 시 파일 이동과 frontmatter 수정 중 하나만 수행할 수 있습니다.
- 기존 링크가 파일 경로를 고정 문자열로 참조하면 이동 뒤 깨질 수 있습니다.
- 완료 Task가 계속 쌓이면 기본 칸반의 `done` 열이 지나치게 길어질 수 있습니다.
- DataviewJS는 조회 화면이므로 카드 드래그로 상태를 변경할 수 없습니다.
- 기존 project마다 상태 집합이나 Task 경로가 다르면 일괄 마이그레이션을 그대로 적용할 수 없습니다.

## 적용한 작업 방식

### 디렉터리 계약

```text
30-work-items/tasks/
├── _templates/
│   └── TASK-template.md
├── todo/
├── in_progress/
├── blocked/
├── review/
└── done/
```

- 실제 Task는 다섯 상태 디렉터리 중 하나에만 둡니다.
- `TASK-template.md`는 실제 작업과 분리된 `_templates/`에 둡니다.
- 파일의 직계 상위 디렉터리 이름과 frontmatter `status`는 일치해야 합니다.
- Task 상태 전환은 파일 이동과 `status`, `updated` 갱신을 한 변경 단위로 처리합니다.
- 상태 디렉터리 밖의 실제 Task와 경로·status 불일치는 검증 실패로 처리합니다.

### 칸반 계약

- `00-dashboard/kanban.md`를 별도 DataviewJS 대시보드로 생성합니다.
- 열 순서는 `todo`, `in_progress`, `blocked`, `review`, `done`으로 고정합니다.
- 카드는 Task ID, 제목, 우선순위, 담당 사일로, 수정일과 Task 문서 링크를 표시합니다.
- 칸반은 읽기 전용이며 상태 변경은 원본 Task 문서와 파일 경로에서 수행합니다.
- 별도 Kanban 플러그인은 기본 의존성에 추가하지 않습니다.
- `work-filter.md`와 `work-items.base`는 상태 하위 디렉터리를 포함해 기존 표·필터 기능을 유지합니다.

### scaffold와 문서 계약

- `setup.sh --create-project-ssot`은 다섯 상태 디렉터리, `_templates/TASK-template.md`, `00-dashboard/kanban.md`를 생성합니다.
- SSoT 스키마, `projects-setup` skill, `system/README.md`, `system/20-skills/README.md`에서 새 구조와 상태 전환 규칙을 찾을 수 있게 합니다.
- repo skill의 사용 시점이나 산출물이 바뀌므로 관련 README와 인덱스를 같은 변경에서 갱신합니다.

### 첫 project 마이그레이션 계약

- 0계층 PR이 `main-v3/main`에 머지된 뒤 첫 적용 project 작업 브랜치를 별도로 만듭니다.
- 해당 `project-{projectName}/main`의 Task를 각 frontmatter `status`에 해당하는 디렉터리로 이동합니다.
- 첫 적용 project의 칸반, 안내 문서, 검증 규칙을 새 0계층 계약과 맞춥니다.
- 기존 사용자 dirty diff가 있는 대화 worktree는 마이그레이션에 사용하지 않습니다.
- 이동 전후 Task 수, ID 집합, status 집합, 문서 본문 checksum을 비교해 내용 유실을 확인합니다.

## 적용 범위

- 0계층 Project Work SSoT 공통 scaffold와 운영 문서
- 새로 생성되는 project의 Task 디렉터리와 작업 대시보드
- 첫 호환 적용 대상 project의 Project Work SSoT

Issue, runbook, handoff, coverage의 상태 디렉터리화는 이번 범위에 포함하지 않습니다. 카드 드래그, 자동 파일 이동, 외부 칸반 서비스 연동도 포함하지 않습니다.

## 실행 결과

- 설계 승인 완료
- 0계층 공통 검증기, 다섯 상태 디렉터리 scaffold, DataviewJS 칸반, Obsidian Base 상태 경로 필터를 구현했습니다.
- 검증기는 파일명 형식과 무관하게 frontmatter `type: task`인 문서를 수집하고, 유효 경로, 경로·status 불일치, 상태 디렉터리 밖 Task, 알 수 없는 status를 자동 검사합니다.
- 임시 Project Work SSoT smoke에서 상태 디렉터리, `.gitkeep`, `_templates/TASK-template.md`, 칸반, Base 상태별 경로, 기존 work-views 링크 생성을 확인했습니다.
- 첫 project 마이그레이션은 0계층 PR 머지 뒤 실행합니다.

## 실제 병목

- Base의 상위 폴더 필터가 상태 하위 디렉터리를 포함한다고 가정하면 viewer 버전별 동작 차이를 놓칠 수 있어, scaffold가 다섯 상태 경로를 각각 명시하도록 했습니다.
- 첫 project 마이그레이션의 링크 보존과 기존 dirty worktree 충돌 가능성은 project 적용 뒤 추가 기록합니다.
- 오래된 project 계층 메인 브랜치에 최신 0계층 ancestry를 선행 PR로 분리하면, 선행 PR 머지 직후 새 검증 규칙과 아직 이관되지 않은 project 데이터가 일시적으로 불일치할 수 있습니다.
- 선행 ancestry PR 뒤 dependent project PR을 즉시 머지하면 이전 base의 mergeable·검증·리뷰 결과를 재사용할 위험이 있어, 최신 base 반영, 검증 재실행, 최신 head 재리뷰 gate가 필요합니다.

## 사람 확인 지점

- 다섯 상태 열과 카드 정보가 실제 운영에 충분한지 확인합니다.
- 읽기 전용 칸반에서 Task 문서를 열어 상태를 전환하는 흐름이 불편하지 않은지 확인합니다.
- `done` 열의 기본 표시량 제한이나 archive 상태가 필요한지 첫 사용 뒤 판단합니다.

## 유지할 것

- 기존 frontmatter `status`를 필터와 자동화 호환 필드로 유지합니다.
- 기존 DataviewJS와 Obsidian Base 대시보드를 유지합니다.
- 상태 경로와 metadata의 일치 여부를 기계적으로 검증합니다.
- 선행 PR로 base가 바뀌면 dependent PR의 base 반영, 검증, 최신 head 리뷰를 다시 실행합니다.

## 버릴 것

- 모든 Task를 단일 `tasks/` 디렉터리에 두는 기본 구조
- 실제 Task와 템플릿을 같은 live 디렉터리에 두는 구조
- 추가 기능 없이 별도 Kanban 플러그인을 기본 의존성으로 넣는 방식

## 0계층 반영 위치

- 반영 완료:
  - 문서: `system/README.md`, `system/10-ssot/SSoT-스키마-초안.md`
  - README/index: `system/20-skills/README.md`, `system/60-operating-hypotheses/README.md`
  - skill: `system/20-skills/projects-setup/SKILL.md`
  - scaffold: `setup.sh`
  - template: `system/templates/project-ssot/00-dashboard/kanban.md`, `system/templates/project-ssot/00-dashboard/work-views.md`
- 반영 후보:
  - project 적용: 첫 적용 대상의 `project-{projectName}/main` Project Work SSoT
- 미구현 후보:
  - 다른 기존 project의 상태 디렉터리 마이그레이션
  - 카드 드래그 기반 상태 전환
- 문서: 0계층 반영 완료, project 적용 전
- skill: `projects-setup` 반영 완료
- agent prompt: 현재 변경 후보 없음
- 적용 단계: 0계층 구현·검증 완료, PR 전
- 검증 상태: 공통 검증기 Minitest, 임시 Project Work SSoT scaffold smoke, DataviewJS 문법 검사 통과
- PR 번호:
- 적용 단계 메모: 0계층 PR 머지 후 project 계층 작업을 별도 PR로 처리합니다.

## 후속 운영 가설 후보

- 완료 Task가 일정 수를 넘으면 `done`과 `archived`를 분리하는 편이 탐색 비용을 줄이는가
- 경로를 상태 정본으로 삼아 frontmatter `status`를 자동 보정하는 도구가 수동 동기화보다 안전한가

## 자가검수

- [x] `decision-doc-logic-audit` fallback 2차 콜드리드 수행
- [x] Symptom-as-Cause 없음
- [x] Scope Overreach 없음
- [x] Premature Conclusion 없음
- [x] Missing Causal Step 없음
- [x] Invented Meta Callout 없음
- [x] Effect Drift 없음
- 남은 위험: 첫 적용 project의 실제 링크 형태와 Dataview/Base의 재귀 경로 동작은 구현 검증에서 확인해야 합니다.
