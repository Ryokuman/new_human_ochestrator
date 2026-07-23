---
type: dashboard
id: DASH-WORK-VIEWS
status: active
---

# 작업 필터

상태별 흐름은 [[kanban|Task 칸반]]에서 확인한다. 칸반은 읽기 전용이며 상태 변경은 Task 파일 이동과 frontmatter `status`, `updated` 갱신으로 처리한다.

Notion처럼 종류, 상태, 레벨, 태그, 담당 사일로, 브랜치, PR, 가설/실패 이력, 날짜, 검색어를 조합하려면 [[work-filter|작업 멀티필터]]를 사용한다. `work-filter.md`는 `taskID`/`taskTitle`, `issueID`/`issueTitle`을 별도 컬럼으로 보여주고, task 추적 필드와 실패 이력 상세 컬럼을 함께 보여준다.

BE, FE, ops처럼 작업 대시보드를 나누려면 [[../templates/work-filter-dashboard|작업 대시보드 템플릿]]을 `00-dashboard/` 아래로 복제하고 `dashboardTitle`, `dashboardScope.paths`를 바꾼다. 이 템플릿은 setup scaffold가 tracked `work-filter.md`를 `templates/work-filter-dashboard.md`로 복사해 만든 생성물이다.

아래 Base는 Obsidian 기본 view/filter 기능을 직접 쓸 때 사용한다.

![[work-items.base]]

## 사용 기준

- 좌측 상단 dropdown은 필터가 아니라 저장된 view 선택 메뉴다.
- 즉석 필터는 `전체 - 즉석 필터` view를 연 뒤 상단 Filter에서 추가한다.
- 필터는 여러 개 걸 수 있다. 예: `status = in_progress` + `file.tags contains filter` + `updated >= 2026-05-27`.
- 여러 필터는 Filter 메뉴의 `All`, `Any`, `None` 그룹으로 AND/OR/NOT 조합한다.
- 자주 쓰는 조건은 Base view로 저장한다. 기본 view는 `진행 중 Task`, `실패 이력 Task`, `완료 Task`, `열린 Issue`다.
- 날짜 필터는 `updated`, `created`, `closed`, `file.mtime` 중 목적에 맞는 필드를 고른다.
- task는 `taskID`와 `taskTitle`, issue는 `issueID`와 `issueTitle`을 우선 사용한다.
- task 추적은 `owner_silo`, `branch`, `pr`, `promotion_status`를 우선 보고, 가설 원문은 `hypothesis_chain` 대신 `hypothesis_attempt_count`, `hypothesis_limit_status`, `dashboard_flags` 요약 필드로 훑는다.
- 실패 이력이 있는 task는 `had_failed_run = true`로 필터링하고, `had_failed_run`, `resolved_by_hypothesis`, `failed_run_count`, `resolved_attempt_no`, `latest_failed_report`, `latest_retry_report`, `blocked_reason`, `latest_resolution_summary`를 필터 또는 표시 컬럼으로 확인한다.
- 기존 문서 호환을 위해 `id`와 `title`도 유지할 수 있지만, 새 문서는 식별자와 제목을 분리한다.
- 사람이 읽는 제목과 설명은 한국어로 작성하고, `status`, `tags`, `level_target` 같은 구조화 필드는 기존 영어 키를 유지한다.
