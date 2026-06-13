#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import process from "node:process";

const DEFAULT_DATAVIEW_VERSION = "0.5.70";

function usage() {
  return `Usage:
  node system/scripts/create-project-ssot.mjs --project-id <id> --target <dir> [options]

Options:
  --project-name <name>        사람이 읽는 프로젝트명. 기본값은 project-id.
  --force                      기존 파일을 덮어쓴다.
  --dry-run                    생성할 파일만 출력한다.
  --skip-dataview              Obsidian Dataview plugin release 파일 다운로드를 건너뛴다.
  --dataview-version <tag>     Dataview release tag. 기본값: ${DEFAULT_DATAVIEW_VERSION}
  --help                       도움말을 출력한다.
`;
}

function parseArgs(argv) {
  const args = {
    projectId: "",
    projectName: "",
    target: "",
    force: false,
    dryRun: false,
    installDataview: true,
    dataviewVersion: DEFAULT_DATAVIEW_VERSION,
  };

  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === "--project-id") args.projectId = argv[++i] || "";
    else if (arg === "--project-name") args.projectName = argv[++i] || "";
    else if (arg === "--target") args.target = argv[++i] || "";
    else if (arg === "--force") args.force = true;
    else if (arg === "--dry-run") args.dryRun = true;
    else if (arg === "--install-dataview") args.installDataview = true;
    else if (arg === "--skip-dataview") args.installDataview = false;
    else if (arg === "--dataview-version") args.dataviewVersion = argv[++i] || DEFAULT_DATAVIEW_VERSION;
    else if (arg === "--help" || arg === "-h") {
      console.log(usage());
      process.exit(0);
    } else {
      throw new Error(`Unknown argument: ${arg}`);
    }
  }

  if (!args.projectId) throw new Error("--project-id is required.");
  if (!args.target) throw new Error("--target is required.");
  if (!/^[a-zA-Z0-9][a-zA-Z0-9._-]*$/.test(args.projectId)) {
    throw new Error("--project-id must use letters, numbers, dot, underscore, or dash.");
  }
  if (!args.projectName) args.projectName = args.projectId;
  args.target = path.resolve(args.target);
  return args;
}

function today() {
  return new Date().toISOString().slice(0, 10);
}

function yamlString(value) {
  return String(value).replace(/"/g, '\\"');
}

function templates(args) {
  const date = today();
  const projectId = args.projectId;
  const projectName = args.projectName;
  return {
    "README.md": `---
type: guide
id: ${projectId.toUpperCase()}-PROJECT-SSOT
status: active
created: ${date}
updated: ${date}
---

# ${projectName} Project SSoT

이 폴더는 ${projectName} 프로젝트 내부 운영 SSoT입니다.

## 폴더

- \`00-dashboard/\`: 현재 상태, 활성 Issue/Task, 다음 행동
- \`10-dictionary/\`: 프로젝트 용어, 고유명사, 내부 약어, 공통 승격 후보
- \`20-issues/\`: 문제, 원인 가설, 영향, 연결 Task
- \`30-tasks/\`: 실제 수행 가능한 작업 단위
- \`50-decisions/\`: 프로젝트 결정과 ADR
- \`70-handoff/\`: 세션 종료/인수인계
- \`90-coverage/\`: L 기준, runner 계약, report 위치

## 태스크 확인/읽는 법

대시보드는 \`00-dashboard/project-overview.md\`를 먼저 연다.

1. frontmatter의 \`id\`, \`title\`, \`status\`, \`priority\`, \`level_target\`, \`issue\`, \`source\`를 먼저 확인한다.
2. \`# 개요\`에서 목적과 기준 evidence를 확인한다.
3. \`# 수행 계획\`에서 실행 순서를 확인한다.
4. \`# 대상 Page\`나 page-aware table이 있으면 영향 범위를 확인한다.
5. \`## 사용자 처리 명령\`이 있으면 구현 전 우선 반영한다.
6. \`# 예상 위험 및 대응책\`에서 승인 경계와 회귀 위험을 확인한다.
7. \`# Output & Acceptance Criteria\`를 완료 조건으로 삼고, 검증 결과를 남긴다.

## 상태값

Issue/Task 공통 status:

\`todo\`, \`in_progress\`, \`blocked\`, \`review\`, \`done\`, \`closed\`
`,
    ".obsidian/community-plugins.json": `[
  "dataview"
]
`,
    ".obsidian/core-plugins.json": `{
  "file-explorer": true,
  "global-search": true,
  "switcher": true,
  "graph": true,
  "backlink": true,
  "outgoing-link": true,
  "tag-pane": true,
  "properties": true,
  "page-preview": true,
  "templates": true,
  "command-palette": true,
  "bookmarks": true,
  "outline": true,
  "word-count": true,
  "bases": true
}
`,
    "00-dashboard/project-overview.md": `---
type: dashboard
id: ${projectId.toUpperCase()}-DASH-PROJECT-OVERVIEW
status: active
created: ${date}
updated: ${date}
---

# Project Overview

Dataview가 꺼져 있으면 아래 정적 링크를 먼저 본다.

- 작업 멀티필터: [[work-filter|작업 멀티필터]]
- 프로젝트 dictionary: [[../10-dictionary/project-dictionary|Project Dictionary]]
- 태스크 목록: [[../30-tasks/TASK-NOTION-FORMAT|Task Format]]
- L 기준: [[../90-coverage/scoring-criteria|Scoring Criteria]]

## 프로젝트 전반 설명

### 프로젝트 목적

-

### 주요 사용자/운영자

| 구분 | 대상 | 역할 |
|---|---|---|
| 사용자 |  |  |
| 운영자 |  |  |

### repo/SSoT 위치

| 항목 | 위치 | 비고 |
|---|---|---|
| 제품 repo |  |  |
| Project SSoT | 현재 \`02-project-internal/\` | 필요하면 외부 SSoT 위치를 함께 적는다 |
| Silo local |  |  |

### 주요 workflow

| workflow | 시작 조건 | 주요 산출물 | 검증 방법 |
|---|---|---|---|
|  |  |  |  |

### 검증/배포/운영 경계

- 검증:
- 배포:
- 운영:

### 금지선/주의사항

- secret, token, password, credential 값을 기록하지 않는다.
- production 데이터 쓰기나 보호 브랜치 직접 수정이 필요하면 사용자 승인을 먼저 받는다.
- 프로젝트 전용 자료는 project SSoT에 두고, root main-v2에는 반복 가능한 공통 규칙만 승격한다.

## 다음 행동

\`\`\`dataview
TABLE WITHOUT ID
  link(file.path, id) AS 항목,
  title AS 제목,
  type AS 타입,
  status AS 상태,
  priority AS 우선순위,
  dateformat(updated, "yyyy-MM-dd") AS 수정일
FROM "20-issues" OR "30-tasks"
WHERE contains(["todo", "in_progress", "blocked", "review"], status)
SORT priority ASC, updated DESC
LIMIT 10
\`\`\`

## 승인 필요

\`\`\`dataview
TABLE WITHOUT ID
  link(file.path, id) AS 항목,
  title AS 제목,
  type AS 타입,
  status AS 상태,
  source AS 출처,
  dateformat(updated, "yyyy-MM-dd") AS 수정일
FROM "20-issues" OR "30-tasks" OR "50-decisions"
WHERE status = "review" OR contains(file.name, "approval")
SORT updated DESC
\`\`\`

## 막힌 항목

\`\`\`dataview
TABLE WITHOUT ID
  link(file.path, id) AS 항목,
  title AS 제목,
  type AS 타입,
  status AS 상태,
  blocked_reason AS 사유,
  dateformat(updated, "yyyy-MM-dd") AS 수정일
FROM "20-issues" OR "30-tasks"
WHERE status = "blocked"
SORT updated DESC
\`\`\`

## 최근 인수인계

\`\`\`dataview
LIST
FROM "70-handoff"
SORT updated DESC
LIMIT 5
\`\`\`
`,
    "10-dictionary/project-dictionary.md": `---
type: dictionary
id: ${projectId.toUpperCase()}-PROJECT-DICTIONARY
status: active
created: ${date}
updated: ${date}
---

# Project Dictionary

프로젝트에서 쓰는 용어, 고유명사, 내부 약어, runner 용어, coverage 용어를 기록합니다.

PR 본문 \`명사 설명\`에 반복해서 등장한 용어는 이 문서의 승격 후보로 남깁니다. 여러 프로젝트에서 반복되거나 에이전트 공통 행동 규칙에 영향을 주는 용어만 root \`main-v2\` 공통 규칙 승격 후보로 분리합니다.

| 용어/고유명사/내부 약어 | 뜻 | 사용 맥락 | 예시 | 출처 또는 확인 상태 | 프로젝트 전용인지 공통 승격 후보인지 |
|---|---|---|---|---|---|
|  |  |  |  | 사용자 확인 필요 | 프로젝트 전용 |

## 작성 기준

- 추정한 뜻은 확정처럼 쓰지 않고 \`사용자 확인 필요\` 또는 \`source 확인 필요\`로 표시한다.
- \`제외\`, \`보정\`, \`surface\`, \`inventory\`, \`extra\`, \`runner\`처럼 내부 판단을 함축하는 표현은 실제 예시와 함께 적는다.
- 공통 승격 후보는 바로 root main-v2에 쓰지 않고, 반복 근거와 사용자 승인을 분리한다.

## PR 보고 기준

이 dictionary 파일을 새로 만들거나 용어를 추가/수정/삭제하는 PR은 PR 본문에 \`새로 추가된 단어\` 섹션을 둔다.

최소 컬럼:

| 변경 유형 | 용어 | 뜻 | 사용 맥락 | 프로젝트 전용/공통 후보 | dictionary 위치 |
|---|---|---|---|---|---|
| 추가 / 수정 / 삭제 |  |  |  | 프로젝트 전용 / 공통 후보 |  |

\`명사 설명\`은 해당 PR을 이해하기 위한 즉시 설명이고, \`새로 추가된 단어\`는 이 dictionary SSoT에 실제 반영된 변경 목록이다.
`,
    "00-dashboard/snapshot-status.md": `---
type: dashboard
id: ${projectId.toUpperCase()}-DASH-SNAPSHOT
status: active
created: ${date}
updated: ${date}
---

# Snapshot Status

프로젝트의 coverage, runner, L 기준 상태를 추적하는 보조 대시보드입니다. 전체 작업 큐는 [[project-overview|Project Overview]]를 먼저 봅니다.

## 활성 태스크

\`\`\`dataview
TABLE WITHOUT ID
  link(file.path, id) AS 태스크,
  status AS 상태,
  priority AS 우선순위,
  level_target AS 레벨,
  choice(issue, join(issue, ", "), "") AS 이슈,
  dateformat(updated, "yyyy-MM-dd") AS 수정일
FROM "30-tasks"
WHERE type = "task" AND contains(["todo", "in_progress", "blocked", "review"], status)
SORT priority ASC, updated DESC
\`\`\`

## 활성 이슈

\`\`\`dataview
TABLE WITHOUT ID
  link(file.path, id) AS 이슈,
  status AS 상태,
  severity AS 중요도,
  area AS 영역,
  root_cause_status AS 원인상태,
  choice(linked_tasks, join(linked_tasks, ", "), "") AS 태스크
FROM "20-issues"
WHERE type = "issue" AND contains(["todo", "in_progress", "blocked", "review"], status)
SORT severity ASC, updated DESC
\`\`\`
`,
    "00-dashboard/work-filter.md": `---
type: dashboard
id: ${projectId.toUpperCase()}-DASH-WORK-FILTER
status: active
created: ${date}
updated: ${date}
---

# 작업 멀티필터

## 필터 섹션

섹션별 선택에는 항상 \`전체\`를 둔다.

| 섹션 | 선택지 | 섹션 내부 관계 |
|---|---|---|
| 유형 | 전체, issue, task | OR |
| 상태 | 전체, todo, in_progress, blocked, review, done, closed | OR |

유형 섹션과 상태 섹션 사이 관계는 사용자가 작업 목적에 따라 AND 또는 OR로 본다.
제목 검색은 전체 파일 검색이 아니라, 유형/상태 필터 결과 안에서 \`title\`을 추가로 좁히는 조건이다.

## 플러그인 없이 보는 작업 큐

Dataview가 꺼져 있거나 Obsidian vault 설정이 맞지 않으면 \`30-tasks/\`, \`20-issues/\`, \`90-coverage/scoring-criteria.md\`를 직접 연다.

## AND 보기

유형 조건과 상태 조건을 함께 만족하는 항목을 본다. 아래 쿼리는 기본값으로 전체 유형 중 활성 상태만 보여준다.

\`\`\`dataview
TABLE WITHOUT ID
  link(file.path, id) AS 항목,
  title AS 제목,
  type AS 타입,
  status AS 상태,
  priority AS 우선순위,
  severity AS 중요도,
  level_target AS 레벨,
  dateformat(updated, "yyyy-MM-dd") AS 수정일
FROM "20-issues" OR "30-tasks"
WHERE contains(["todo", "in_progress", "blocked", "review"], status)
SORT priority ASC, severity ASC, updated DESC
\`\`\`

## 필터 결과 내 제목 검색

아래 쿼리에서 \`검색어\`만 바꾼다. 유형/상태 필터를 먼저 적용하고, 그 결과 안에서 제목을 검색한다.

\`\`\`dataview
TABLE WITHOUT ID
  link(file.path, id) AS 항목,
  title AS 제목,
  type AS 타입,
  status AS 상태,
  priority AS 우선순위,
  severity AS 중요도,
  level_target AS 레벨,
  dateformat(updated, "yyyy-MM-dd") AS 수정일
FROM "20-issues" OR "30-tasks"
WHERE contains(["todo", "in_progress", "blocked", "review"], status)
  AND contains(lower(string(title)), lower("검색어"))
SORT priority ASC, severity ASC, updated DESC
\`\`\`

## OR 보기

유형 조건 또는 상태 조건 중 하나라도 맞는 항목을 본다. 아래 쿼리는 예시로 issue 전체와 blocked 상태 항목을 함께 보여준다.

\`\`\`dataview
TABLE WITHOUT ID
  link(file.path, id) AS 항목,
  title AS 제목,
  type AS 타입,
  status AS 상태,
  priority AS 우선순위,
  severity AS 중요도,
  level_target AS 레벨,
  dateformat(updated, "yyyy-MM-dd") AS 수정일
FROM "20-issues" OR "30-tasks"
WHERE type = "issue" OR status = "blocked"
SORT priority ASC, severity ASC, updated DESC
\`\`\`
`,
    "00-dashboard/work-items.base": `filters:
  and:
    - file.ext == "md"
    - or:
        - file.inFolder("20-issues")
        - file.inFolder("30-tasks")
properties:
  id:
    displayName: ID
  title:
    displayName: 제목
  type:
    displayName: 타입
  status:
    displayName: 상태
  priority:
    displayName: 우선순위
  severity:
    displayName: 중요도
  level_target:
    displayName: 레벨
  updated:
    displayName: 수정일
views:
  - type: table
    name: 전체
    order:
      - id
      - title
      - type
      - status
      - priority
      - severity
      - level_target
      - updated
  - type: table
    name: 유형 - 전체
    order:
      - id
      - title
      - type
      - status
      - priority
      - severity
      - level_target
      - updated
  - type: table
    name: 유형 - issue
    filters:
      and:
        - 'type == "issue"'
    order:
      - id
      - title
      - type
      - status
      - priority
      - severity
      - level_target
      - updated
  - type: table
    name: 유형 - task
    filters:
      and:
        - 'type == "task"'
    order:
      - id
      - title
      - type
      - status
      - priority
      - severity
      - level_target
      - updated
  - type: table
    name: 상태 - 전체
    order:
      - id
      - title
      - type
      - status
      - priority
      - severity
      - level_target
      - updated
  - type: table
    name: 상태 - 활성
    filters:
      and:
        - '["todo", "in_progress", "blocked", "review"].contains(status)'
    order:
      - id
      - title
      - type
      - status
      - priority
      - severity
      - level_target
      - updated
  - type: table
    name: 상태 - blocked
    filters:
      and:
        - 'status == "blocked"'
    order:
      - id
      - title
      - type
      - status
      - priority
      - severity
      - level_target
      - updated
  - type: table
    name: 관계 - AND 기본
    filters:
      and:
        - '["issue", "task"].contains(type)'
        - '["todo", "in_progress", "blocked", "review"].contains(status)'
    order:
      - id
      - title
      - type
      - status
      - priority
      - severity
      - level_target
      - updated
  - type: table
    name: 관계 - OR 예시
    filters:
      or:
        - 'type == "issue"'
        - 'status == "blocked"'
    order:
      - id
      - title
      - type
      - status
      - priority
      - severity
      - level_target
      - updated
`,
    "20-issues/ISSUE-FORMAT.md": `---
type: issue-format
id: ISSUE-FORMAT
title: Issue Format
status: active
created: ${date}
updated: ${date}
---

# Issue Format

Issue는 문제, 원인 가설, 영향, 필요한 수정 방향을 설명한다. 실제 실행 단위는 Task로 분리한다.

## 필수 섹션

- Frontmatter: \`id\`, \`title\`, \`status\`, \`severity\`, \`source\`, \`updated\`
- Symptom
- Evidence
- Cause Hypotheses
- Impact
- Required Fix
- Linked Tasks
`,
    "30-tasks/TASK-NOTION-FORMAT.md": `---
type: task-format
id: TASK-NOTION-FORMAT
title: Task Notion Format
status: active
created: ${date}
updated: ${date}
---

# Task Notion Format

## 태스크 읽기 순서

1. frontmatter의 \`id\`, \`title\`, \`status\`, \`priority\`, \`source\`, \`updated\`
2. \`# 개요\`
3. \`# 수행 계획\`
4. \`# 대상 Page\` 또는 page-aware table
5. \`## 사용자 처리 명령\`
6. \`# 예상 위험 및 대응책\`
7. \`# Output & Acceptance Criteria\`
8. \`# Test Plan\`
9. \`# 자가검수\`

## 필수 본문 양식

\`\`\`markdown
---
type: task
id: TASK-0000
title: 태스크 제목
status: todo
priority: P2
source:
issue:
level_target:
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

# 개요

-

# 미팅

Meetings

# 수행 계획

-

# 예상 위험 및 대응책

-

# 기타

-

---

# Output & Acceptance Criteria

Output은 task가 완료되었을 때 사용자, 시스템, 운영자가 확인할 수 있는 결과입니다.
Acceptance Criteria는 완료로 인정할 검수 기준입니다. 각 기준은 검증 방법과 연결해야 합니다.

## Output

-

## Acceptance Criteria

| 기준 | 검증 방법 | 필수 여부 | 결과 |
|---|---|---|---|
|  | unit / runner / E2E / agent-browser / manual | 필수 | 미검증 |

# Test Plan

| 테스트 종류 | 대상 | 명령 또는 증거 | 필수 여부 |
|---|---|---|---|
| Unit | 함수, 변환기, 렌더러, 정책 로직 |  | 조건부 |
| Static/Runner | coverage runner, generated output, parity check |  | 조건부 |
| E2E | 실제 사용자 흐름, 화면 동작, 버튼/모달/그리드 조작 |  | 화면 동작 변경 시 필수 |
| Coverage | 신규/변경 코드 |  | 조건부 |

## Coverage Target

- 신규/변경 코드에 테스트를 우선 추가한다.
- 전체 coverage 90%는 프로젝트가 적용 가능한 repo와 측정 방식을 정한 뒤 단계적으로 적용한다.
- coverage를 측정하지 못한 경우 이유를 \`# Verification\` 또는 PR 본문에 남긴다.

# 자가검수

- [ ] Symptom-as-Cause 없음
- [ ] Scope Overreach 없음
- [ ] Premature Conclusion 없음
- [ ] Missing Causal Step 없음
- [ ] Effect Drift 없음
- 남은 위험:
\`\`\`
`,
    "90-coverage/scoring-criteria.md": `---
type: coverage-doc
id: SCORING-CRITERIA
status: draft
created: ${date}
updated: ${date}
---

# Scoring Criteria

프로젝트별 L 기준은 이 문서에서 관리한다. 아래는 기본 템플릿이며, 프로젝트가 실제 사용하는 runner 계약에 맞춰 좁혀 쓴다.

| Level | 기본 의미 | 증거 |
|---|---|---|
| L0 | 생성 또는 기본 산출물 존재 | generated files, build artifact |
| L1 | button 제외 static surface parity | filters, grid, columns, labels |
| L2 | button static surface parity | button inventory, generated button surface |
| L3 | Agent Browser read/search runtime | browser snapshot, request, grid surface |
| L4 | Agent Browser action/CUD runtime | click evidence, API payload, modal/confirm, state change |

## Runner 계약

- runner command:
- run JSON 위치:
- report 위치:
- pass/fail 기준:
- deprecated artifact:
`,
  };
}

function writeFile(file, content, args, written) {
  if (args.dryRun) {
    written.push(file);
    return;
  }
  if (fs.existsSync(file) && !args.force) {
    throw new Error(`Refusing to overwrite existing file without --force: ${file}`);
  }
  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.writeFileSync(file, content);
  written.push(file);
}

async function download(url, file) {
  const response = await fetch(url, {
    headers: { "user-agent": "projects-setup" },
  });
  if (!response.ok) throw new Error(`Download failed ${response.status}: ${url}`);
  fs.mkdirSync(path.dirname(file), { recursive: true });
  const arrayBuffer = await response.arrayBuffer();
  fs.writeFileSync(file, Buffer.from(arrayBuffer));
}

async function installDataview(args, written) {
  const assets = ["main.js", "manifest.json", "styles.css"];
  const pluginDir = path.join(args.target, ".obsidian/plugins/dataview");
  for (const asset of assets) {
    const url = `https://github.com/blacksmithgu/obsidian-dataview/releases/download/${args.dataviewVersion}/${asset}`;
    const file = path.join(pluginDir, asset);
    if (args.dryRun) {
      written.push(file);
      continue;
    }
    if (fs.existsSync(file) && !args.force) {
      throw new Error(`Refusing to overwrite existing file without --force: ${file}`);
    }
    await download(url, file);
    written.push(file);
  }
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  const written = [];
  for (const [relativePath, content] of Object.entries(templates(args))) {
    writeFile(path.join(args.target, relativePath), content, args, written);
  }
  if (args.installDataview) await installDataview(args, written);
  console.log(JSON.stringify({
    projectId: args.projectId,
    projectName: args.projectName,
    target: args.target,
    dryRun: args.dryRun,
    installDataview: args.installDataview,
    files: written.map((file) => path.relative(process.cwd(), file).split(path.sep).join("/")),
  }, null, 2));
}

main().catch((error) => {
  console.error(error.message);
  process.exit(1);
});
