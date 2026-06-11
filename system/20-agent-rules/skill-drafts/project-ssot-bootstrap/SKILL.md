---
name: project-ssot-bootstrap
description: 프로젝트별 실제 SSoT 산출물을 main에 커밋하지 않고, system에 있는 공통 생성 스크립트로 태스크/이슈/L 기준/대시보드/Obsidian Dataview 설정을 새 project SSoT에 생성해야 할 때 사용합니다.
---

# Project SSoT Bootstrap

이 스킬은 프로젝트 내부 자료를 0계층 main에 직접 추가하지 않기 위한 생성 절차입니다.

## 원칙

- main에는 `system/`의 공통 규칙, 스크립트, skill draft만 둔다.
- 프로젝트별 실제 `README`, `Task`, `Issue`, `L 기준`, dashboard, `.obsidian` 설정은 project SSoT 위치에 생성한다.
- 프로젝트별 실제 page 목록, runner 결과, coverage report, issue/task 내용은 main으로 복사하지 않는다.
- Dataview 플러그인은 대시보드 렌더링에 필요한 경우가 맞다. 다만 main에 project vault 플러그인 파일을 직접 넣지 않고 생성 스크립트의 `--install-dataview` 옵션으로 설치한다.

## 기본 절차

1. 프로젝트 SSoT target path를 확인한다.
2. target이 프로젝트 내부 SSoT 위치인지 확인한다.
3. dry-run으로 생성 파일 목록을 확인한다.
4. 실제 생성한다.
5. 필요한 경우 Dataview plugin release 파일을 설치한다.
6. 생성된 산출물은 해당 project SSoT 또는 프로젝트 전용 PR에서만 커밋한다.

## 명령

```bash
node system/scripts/create-project-ssot.mjs \
  --project-id sample-project \
  --project-name "Sample Project" \
  --target /path/to/project-ssot \
  --dry-run
```

실제 생성:

```bash
node system/scripts/create-project-ssot.mjs \
  --project-id sample-project \
  --project-name "Sample Project" \
  --target /path/to/project-ssot
```

Dataview plugin까지 설치:

```bash
node system/scripts/create-project-ssot.mjs \
  --project-id sample-project \
  --project-name "Sample Project" \
  --target /path/to/project-ssot \
  --install-dataview
```

## 검증

```bash
node --check system/scripts/create-project-ssot.mjs
node system/scripts/create-project-ssot.mjs --project-id sample --target /tmp/sample-ssot --dry-run
```

생성 후에는 target에 아래가 있는지 확인한다.

- `README.md`
- `00-dashboard/project-overview.md`
- `00-dashboard/snapshot-status.md`
- `00-dashboard/work-filter.md`
- `00-dashboard/work-items.base`
- `20-issues/ISSUE-FORMAT.md`
- `30-tasks/TASK-NOTION-FORMAT.md`
- `90-coverage/scoring-criteria.md`
- `.obsidian/community-plugins.json`

## 금지

- 이 스킬을 이유로 0계층 main에 프로젝트별 실제 SSoT 산출물을 커밋하지 않는다.
- project report, run JSON, page별 task를 system 템플릿에 박지 않는다.
- 루트 `.obsidian/` workspace 상태를 커밋하지 않는다.
