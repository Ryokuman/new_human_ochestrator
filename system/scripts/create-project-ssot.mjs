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
  --install-dataview           Obsidian Dataview plugin release 파일을 target vault에 내려받는다.
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
    installDataview: false,
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
- \`20-issues/\`: 문제, 원인 가설, 영향, 연결 Task
- \`30-tasks/\`: 실제 수행 가능한 작업 단위
- \`50-decisions/\`: 프로젝트 결정과 ADR
- \`70-handoff/\`: 세션 종료/인수인계
- \`90-coverage/\`: L 기준, runner 계약, report 위치

## 태스크 확인/읽는 법

1. frontmatter의 \`status\`, \`priority\`, \`level_target\`, \`issue\`, \`source\`를 먼저 확인한다.
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
    "00-dashboard/snapshot-status.md": `---
type: dashboard
id: ${projectId.toUpperCase()}-DASH-SNAPSHOT
status: active
created: ${date}
updated: ${date}
---

# Snapshot Status

Dataview가 꺼져 있으면 아래 정적 링크를 먼저 본다.

- 태스크 목록: [[../30-tasks/TASK-NOTION-FORMAT|Task Format]]
- L 기준: [[../90-coverage/scoring-criteria|Scoring Criteria]]
- 작업 멀티필터: [[work-filter|작업 멀티필터]]

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

## 플러그인 없이 보는 작업 큐

Dataview가 꺼져 있거나 Obsidian vault 설정이 맞지 않으면 \`30-tasks/\`, \`20-issues/\`, \`90-coverage/scoring-criteria.md\`를 직접 연다.

## Dataview 작업 큐

\`\`\`dataview
TABLE WITHOUT ID
  link(file.path, id) AS 항목,
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
    name: 전체 - 즉석 필터
    order:
      - id
      - type
      - status
      - priority
      - severity
      - level_target
      - updated
  - type: table
    name: 상태 - 진행 중
    filters:
      and:
        - '["todo", "in_progress", "blocked", "review"].contains(status)'
    order:
      - id
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
status: active
created: ${date}
updated: ${date}
---

# Issue Format

Issue는 문제, 원인 가설, 영향, 필요한 수정 방향을 설명한다. 실제 실행 단위는 Task로 분리한다.

## 필수 섹션

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
status: active
created: ${date}
updated: ${date}
---

# Task Notion Format

## 태스크 읽기 순서

1. frontmatter
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
    headers: { "user-agent": "project-ssot-bootstrap" },
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
