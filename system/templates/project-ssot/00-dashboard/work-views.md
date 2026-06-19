---
type: dashboard
id: DASH-WORK-VIEWS
status: active
---

# 작업 필터

Notion처럼 종류, 상태, 레벨, 태그, 날짜, 검색어를 조합하려면 [[work-filter|작업 멀티필터]]를 사용한다. `work-filter.md`는 `taskID`/`taskTitle`, `issueID`/`issueTitle`을 별도 컬럼으로 보여준다.

BE, FE, ops처럼 작업 대시보드를 나누려면 [[../templates/work-filter-dashboard|작업 대시보드 템플릿]]을 `00-dashboard/` 아래로 복제하고 `dashboardTitle`, `dashboardScope.paths`를 바꾼다.

아래 Base는 Obsidian 기본 view/filter 기능을 직접 쓸 때 사용한다.

![[work-items.base]]

## 사용 기준

- 좌측 상단 dropdown은 필터가 아니라 저장된 view 선택 메뉴다.
- 즉석 필터는 `전체 - 즉석 필터` view를 연 뒤 상단 Filter에서 추가한다.
- 필터는 여러 개 걸 수 있다. 예: `status = in_progress` + `file.tags contains filter` + `updated >= 2026-05-27`.
- 여러 필터는 Filter 메뉴의 `All`, `Any`, `None` 그룹으로 AND/OR/NOT 조합한다.
- 자주 쓰는 조건은 Base view로 저장한다. 기본 view는 `진행 중 Task`, `완료 Task`, `열린 Issue`다.
- 날짜 필터는 `updated`, `created`, `closed`, `file.mtime` 중 목적에 맞는 필드를 고른다.
- task는 `taskID`와 `taskTitle`, issue는 `issueID`와 `issueTitle`을 우선 사용한다.
- 기존 문서 호환을 위해 `id`와 `title`도 유지할 수 있지만, 새 문서는 식별자와 제목을 분리한다.
- 사람이 읽는 제목과 설명은 한국어로 작성하고, `status`, `tags`, `level_target` 같은 구조화 필드는 기존 영어 키를 유지한다.
