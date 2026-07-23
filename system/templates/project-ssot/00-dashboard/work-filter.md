---
type: dashboard
id: DASH-WORK-FILTER
status: active
dashboardTitle: 전체 작업
dashboardScope:
  paths:
    - 30-work-items/issues/
    - 30-work-items/tasks/
---

# 작업 멀티필터

프로젝트의 issue/task를 종류, 상태, 레벨, 태그, 담당 사일로, 브랜치, PR, 가설/실패 이력, 날짜, 검색어로 조합해서 본다. 각 multiselect 필터 안에서는 OR/AND를 고를 수 있고, 필터 그룹끼리도 OR/AND를 고를 수 있다.

이 파일을 복제한 뒤 `dashboardTitle`과 `dashboardScope.paths`만 바꾸면 BE, FE, ops처럼 프로젝트 안에 여러 작업 대시보드를 둘 수 있다.

```dataviewjs
const dashboardFolder = dv.current().file.folder;
const projectRoot = dashboardFolder.replace(/(^|\/)00-dashboard$/, "");
const projectPath = (child) => projectRoot ? projectRoot + "/" + child : child;
const scope = dv.current().dashboardScope ?? {};
const scopePaths = scope.paths?.length ? scope.paths : ["30-work-items/issues/", "30-work-items/tasks/"];
const projectPaths = scopePaths.map(projectPath);
const templateNames = new Set([
  "ISSUE-template",
  "ISSUE-template.md",
  "TASK-template",
  "TASK-template.md",
]);
const isTemplatePage = (page) => templateNames.has(page.file.name) || page.file.name.endsWith("-template");
const pages = dv.pages()
  .where((page) => projectPaths.some((path) => page.file.path.startsWith(path)))
  .where((page) => !isTemplatePage(page))
  .array();

const normalize = (value) => {
  if (value == null) return [];
  if (Array.isArray(value)) return value.flatMap(normalize);
  if (typeof value === "object") {
    if (value.path) return [value.path];
    if (value.values) return normalize(value.values);
    return [String(value)];
  }
  return [String(value)];
};
const first = (...values) => values.flatMap(normalize).find((value) => String(value).trim());
const stripHash = (value) => String(value).replace(/^#/, "");
const pageTags = (page) => normalize(page.tags ?? page.file.tags).map(stripHash).filter(Boolean);
const unique = (values) => Array.from(new Set(values.flatMap(normalize).filter(Boolean))).sort();

function itemId(page) {
  if (page.type === "task") return first(page.taskID, page.taskId, page.id, page.file.name);
  if (page.type === "issue") return first(page.issueID, page.issueId, page.id, page.file.name);
  return first(page.id, page.taskID, page.issueID, page.file.name);
}

function itemTitle(page) {
  if (page.type === "task") return first(page.taskTitle, page.title, page.file.name);
  if (page.type === "issue") return first(page.issueTitle, page.title, page.file.name);
  return first(page.title, page.taskTitle, page.issueTitle, page.file.name);
}

const optionSets = {
  type: unique(pages.map((page) => page.type)).filter(Boolean),
  status: unique(pages.map((page) => page.status)).filter(Boolean),
  level: unique(pages.flatMap((page) => normalize(page.level_target))).filter(Boolean),
  tags: unique(pages.flatMap(pageTags)).filter(Boolean),
  ownerSilo: unique(pages.flatMap((page) => normalize(page.owner_silo))).filter(Boolean),
  branch: unique(pages.flatMap((page) => normalize(page.branch))).filter(Boolean),
  pr: unique(pages.flatMap((page) => normalize(page.pr))).filter(Boolean),
  promotionStatus: unique(pages.flatMap((page) => normalize(page.promotion_status))).filter(Boolean),
  hypothesisLimitStatus: unique(pages.flatMap((page) => normalize(page.hypothesis_limit_status))).filter(Boolean),
  hadFailedRun: unique(pages.map((page) => page.had_failed_run)).filter(Boolean),
  resolvedByHypothesis: unique(pages.map((page) => page.resolved_by_hypothesis)).filter(Boolean),
  dashboardFlags: unique(pages.flatMap((page) => normalize(page.dashboard_flags))).filter(Boolean),
};

const state = {
  type: new Set(),
  typeMode: "or",
  status: new Set(),
  statusMode: "or",
  level: new Set(),
  levelMode: "or",
  tags: new Set(),
  tagsMode: "or",
  ownerSilo: new Set(),
  ownerSiloMode: "or",
  branch: new Set(),
  branchMode: "or",
  pr: new Set(),
  prMode: "or",
  promotionStatus: new Set(),
  promotionStatusMode: "or",
  hypothesisLimitStatus: new Set(),
  hypothesisLimitStatusMode: "or",
  hadFailedRun: new Set(),
  hadFailedRunMode: "or",
  resolvedByHypothesis: new Set(),
  resolvedByHypothesisMode: "or",
  dashboardFlags: new Set(),
  dashboardFlagsMode: "or",
  groupMode: "and",
  dateField: "updated",
  dateFrom: "",
  dateTo: "",
  query: "",
};

const root = dv.container;
root.classList.add("work-filter-dashboard");

const style = root.createEl("style");
style.textContent = `
.work-filter-dashboard {
  --wf-border: var(--background-modifier-border);
  --wf-muted: var(--text-muted);
}
.work-filter-dashboard .wf-panel {
  display: grid;
  gap: 7px;
  margin: 10px 0 12px;
}
.work-filter-dashboard .wf-row {
  display: grid;
  gap: 8px;
  align-items: center;
}
.work-filter-dashboard .wf-row-main {
  grid-template-columns: repeat(4, minmax(120px, 1fr)) auto auto;
}
.work-filter-dashboard .wf-row-date {
  grid-template-columns: 120px 170px auto 170px 1fr;
}
.work-filter-dashboard .wf-row-search {
  grid-template-columns: 72px minmax(220px, 420px) auto auto 1fr;
}
@media (max-width: 900px) {
  .work-filter-dashboard .wf-row-main,
  .work-filter-dashboard .wf-row-date,
  .work-filter-dashboard .wf-row-search {
    grid-template-columns: 1fr;
  }
}
.work-filter-dashboard .wf-label {
  color: var(--wf-muted);
  font-size: 13px;
  white-space: nowrap;
}
.work-filter-dashboard .wf-filter {
  position: relative;
}
.work-filter-dashboard .wf-filter-button,
.work-filter-dashboard .wf-button,
.work-filter-dashboard .wf-mode,
.work-filter-dashboard .wf-input,
.work-filter-dashboard .wf-date-field {
  min-height: 30px;
  border: 1px solid var(--wf-border);
  border-radius: 6px;
  padding: 4px 8px;
  background: var(--background-primary);
  color: var(--text-normal);
  font: inherit;
  font-size: 13px;
}
.work-filter-dashboard .wf-filter-button {
  width: 100%;
  min-width: 108px;
  text-align: left;
  cursor: pointer;
}
.work-filter-dashboard .wf-popover {
  position: absolute;
  z-index: 20;
  top: calc(100% + 4px);
  left: 0;
  min-width: 190px;
  max-width: 240px;
  border: 1px solid var(--wf-border);
  border-radius: 8px;
  padding: 8px;
  background: var(--background-primary);
  box-shadow: 0 8px 18px rgba(0, 0, 0, 0.22);
}
.work-filter-dashboard .wf-popover[hidden] {
  display: none;
}
.work-filter-dashboard .wf-popover-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 8px;
  margin-bottom: 6px;
}
.work-filter-dashboard .wf-options {
  display: grid;
  gap: 4px;
  max-height: 210px;
  overflow: auto;
}
.work-filter-dashboard .wf-option {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 13px;
  line-height: 1.25;
}
.work-filter-dashboard .wf-input {
  width: 100%;
}
.work-filter-dashboard .wf-summary {
  color: var(--wf-muted);
  font-size: 13px;
}
.work-filter-dashboard .wf-table {
  width: 100%;
  border-collapse: collapse;
}
.work-filter-dashboard .wf-table th,
.work-filter-dashboard .wf-table td {
  border-bottom: 1px solid var(--wf-border);
  padding: 5px 7px;
  text-align: left;
  vertical-align: top;
  font-size: 13px;
}
.work-filter-dashboard .wf-table th {
  color: var(--wf-muted);
  font-weight: 600;
}
`;

const controls = root.createDiv({ cls: "wf-panel" });
const result = root.createDiv();
const filterControls = [];
const mainRow = controls.createDiv({ cls: "wf-row wf-row-main" });
const dateRow = controls.createDiv({ cls: "wf-row wf-row-date" });
const searchRow = controls.createDiv({ cls: "wf-row wf-row-search" });

function makeModeSelect(value, onChange) {
  const select = createEl("select", { cls: "wf-mode" });
  ["or", "and"].forEach((mode) => {
    const option = select.createEl("option", { text: mode.toUpperCase(), value: mode });
    option.selected = mode === value;
  });
  select.addEventListener("change", () => onChange(select.value));
  return select;
}

function addDropdownFilter({ key, title, values }) {
  const wrapper = mainRow.createDiv({ cls: "wf-filter" });
  const button = wrapper.createEl("button", { cls: "wf-filter-button", text: title + ": 전체" });
  const popover = wrapper.createDiv({ cls: "wf-popover", attr: { hidden: true } });
  const head = popover.createDiv({ cls: "wf-popover-head" });
  head.createSpan({ text: title });
  const modeSelect = makeModeSelect(state[key + "Mode"], (mode) => {
    state[key + "Mode"] = mode;
    render();
    updateButton();
  });
  head.appendChild(modeSelect);

  const options = popover.createDiv({ cls: "wf-options" });
  const checkboxes = [];
  values.forEach((value) => {
    const label = options.createEl("label", { cls: "wf-option" });
    const checkbox = label.createEl("input", { type: "checkbox" });
    checkbox.addEventListener("change", () => {
      if (checkbox.checked) state[key].add(value);
      else state[key].delete(value);
      render();
      updateButton();
    });
    label.createSpan({ text: value });
    checkboxes.push(checkbox);
  });

  function updateButton() {
    const selected = Array.from(state[key]);
    const suffix = selected.length ? selected.length + "개 " + state[key + "Mode"].toUpperCase() : "전체";
    button.textContent = title + ": " + suffix;
  }

  button.addEventListener("click", (event) => {
    event.stopPropagation();
    root.querySelectorAll(".wf-popover").forEach((node) => {
      if (node !== popover) node.hidden = true;
    });
    popover.hidden = !popover.hidden;
  });
  popover.addEventListener("click", (event) => event.stopPropagation());
  filterControls.push({ key, button, modeSelect, checkboxes, popover, updateButton });
}

addDropdownFilter({ key: "type", title: "종류", values: optionSets.type });
addDropdownFilter({ key: "status", title: "상태", values: optionSets.status });
addDropdownFilter({ key: "level", title: "레벨", values: optionSets.level });
addDropdownFilter({ key: "tags", title: "태그", values: optionSets.tags });
addDropdownFilter({ key: "ownerSilo", title: "담당 사일로", values: optionSets.ownerSilo });
addDropdownFilter({ key: "branch", title: "브랜치", values: optionSets.branch });
addDropdownFilter({ key: "pr", title: "PR", values: optionSets.pr });
addDropdownFilter({ key: "promotionStatus", title: "승격 상태", values: optionSets.promotionStatus });
addDropdownFilter({ key: "hypothesisLimitStatus", title: "가설 상태", values: optionSets.hypothesisLimitStatus });
addDropdownFilter({ key: "hadFailedRun", title: "실패 이력", values: optionSets.hadFailedRun });
addDropdownFilter({ key: "resolvedByHypothesis", title: "가설 해결", values: optionSets.resolvedByHypothesis });
addDropdownFilter({ key: "dashboardFlags", title: "대시보드 플래그", values: optionSets.dashboardFlags });

document.addEventListener("click", () => {
  root.querySelectorAll(".wf-popover").forEach((node) => node.hidden = true);
});

mainRow.createSpan({ cls: "wf-label", text: "그룹" });
const groupMode = makeModeSelect(state.groupMode, (mode) => {
  state.groupMode = mode;
  render();
});
mainRow.appendChild(groupMode);

const dateField = dateRow.createEl("select", { cls: "wf-date-field" });
[
  ["updated", "수정일"],
  ["created", "생성일"],
  ["closed", "종료일"],
  ["file.mtime", "파일수정일"],
].forEach(([value, label]) => dateField.createEl("option", { value, text: label }));
dateField.addEventListener("change", () => {
  state.dateField = dateField.value;
  render();
});

const from = dateRow.createEl("input", { type: "date", cls: "wf-input" });
from.addEventListener("change", () => {
  state.dateFrom = from.value;
  render();
});
dateRow.createSpan({ cls: "wf-label", text: "~" });
const to = dateRow.createEl("input", { type: "date", cls: "wf-input" });
to.addEventListener("change", () => {
  state.dateTo = to.value;
  render();
});

searchRow.createSpan({ cls: "wf-label", text: "검색" });
const query = searchRow.createEl("input", {
  type: "search",
  cls: "wf-input",
  attr: { placeholder: "검색" },
});
query.addEventListener("input", () => {
  state.query = query.value.trim().toLowerCase();
  render();
});

const reset = searchRow.createEl("button", { cls: "wf-button", text: "초기화" });
const summary = searchRow.createSpan({ cls: "wf-summary" });
reset.addEventListener("click", () => {
  for (const key of [
    "type",
    "status",
    "level",
    "tags",
    "ownerSilo",
    "branch",
    "pr",
    "promotionStatus",
    "hypothesisLimitStatus",
    "hadFailedRun",
    "resolvedByHypothesis",
    "dashboardFlags",
  ]) state[key].clear();
  state.typeMode = state.statusMode = state.levelMode = state.tagsMode = "or";
  state.ownerSiloMode = state.branchMode = state.prMode = state.promotionStatusMode = "or";
  state.hypothesisLimitStatusMode = state.hadFailedRunMode = state.resolvedByHypothesisMode = state.dashboardFlagsMode = "or";
  state.groupMode = "and";
  state.dateField = "updated";
  state.dateFrom = state.dateTo = state.query = "";
  filterControls.forEach((control) => {
    control.checkboxes.forEach((checkbox) => checkbox.checked = false);
    control.modeSelect.value = "or";
    control.updateButton();
  });
  groupMode.value = "and";
  dateField.value = "updated";
  from.value = "";
  to.value = "";
  query.value = "";
  render();
});

function getDate(page) {
  if (state.dateField === "file.mtime") return page.file.mtime;
  return page[state.dateField];
}

function toDateKey(value) {
  if (!value) return "";
  if (value.toISODate) return value.toISODate();
  return String(value).slice(0, 10);
}

function matchMulti(pageValues, selected, mode) {
  if (selected.size === 0) return true;
  const values = new Set(normalize(pageValues).map(stripHash));
  if (mode === "and") return Array.from(selected).every((value) => values.has(value));
  return Array.from(selected).some((value) => values.has(value));
}

function activeGroupMatches(page) {
  const checks = [
    [state.type, matchMulti(page.type, state.type, state.typeMode)],
    [state.status, matchMulti(page.status, state.status, state.statusMode)],
    [state.level, matchMulti(page.level_target, state.level, state.levelMode)],
    [state.tags, matchMulti(pageTags(page), state.tags, state.tagsMode)],
    [state.ownerSilo, matchMulti(page.owner_silo, state.ownerSilo, state.ownerSiloMode)],
    [state.branch, matchMulti(page.branch, state.branch, state.branchMode)],
    [state.pr, matchMulti(page.pr, state.pr, state.prMode)],
    [state.promotionStatus, matchMulti(page.promotion_status, state.promotionStatus, state.promotionStatusMode)],
    [state.hypothesisLimitStatus, matchMulti(page.hypothesis_limit_status, state.hypothesisLimitStatus, state.hypothesisLimitStatusMode)],
    [state.hadFailedRun, matchMulti(page.had_failed_run, state.hadFailedRun, state.hadFailedRunMode)],
    [state.resolvedByHypothesis, matchMulti(page.resolved_by_hypothesis, state.resolvedByHypothesis, state.resolvedByHypothesisMode)],
    [state.dashboardFlags, matchMulti(page.dashboard_flags, state.dashboardFlags, state.dashboardFlagsMode)],
  ].filter(([selected]) => selected.size > 0).map(([, matched]) => matched);

  if (checks.length === 0) return true;
  if (state.groupMode === "or") return checks.some(Boolean);
  return checks.every(Boolean);
}

function matches(page) {
  if (!activeGroupMatches(page)) return false;

  const dateKey = toDateKey(getDate(page));
  if (state.dateFrom && (!dateKey || dateKey < state.dateFrom)) return false;
  if (state.dateTo && (!dateKey || dateKey > state.dateTo)) return false;

  if (state.query) {
    const haystack = [
      itemId(page),
      itemTitle(page),
      page.id,
      page.title,
      page.taskID,
      page.taskTitle,
      page.issueID,
      page.issueTitle,
      page.file.name,
      page.file.path,
      page.status,
      page.priority,
      page.severity,
      page.level_target,
      page.owner_silo,
      page.branch,
      page.pr,
      page.promotion_status,
      page.hypothesis_attempt_count,
      page.hypothesis_limit_status,
      page.had_failed_run,
      page.resolved_by_hypothesis,
      page.failed_run_count,
      page.resolved_attempt_no,
      page.latest_failed_report,
      page.latest_retry_report,
      page.blocked_reason,
      page.latest_resolution_summary,
      page.dashboard_flags,
      page.type,
      ...pageTags(page),
    ].filter(Boolean).join(" ").toLowerCase();
    if (!haystack.includes(state.query)) return false;
  }

  return true;
}

function pageLink(page) {
  const link = createEl("a", { text: itemId(page), href: page.file.path });
  link.addEventListener("click", (event) => {
    event.preventDefault();
    if (typeof app !== "undefined" && app.workspace) {
      app.workspace.openLinkText(page.file.path, "", false);
    }
  });
  return link;
}

function compactPair(label, value) {
  const text = first(value);
  return text ? label + " " + text : "";
}

function hypothesisSummary(page) {
  return [
    compactPair("시도", page.hypothesis_attempt_count),
    first(page.hypothesis_limit_status),
  ].filter(Boolean).join(" / ");
}

function failureSummary(page) {
  return [
    compactPair("이력", page.had_failed_run),
    compactPair("해결", page.resolved_by_hypothesis),
    compactPair("실패", page.failed_run_count),
    compactPair("시도", page.resolved_attempt_no),
  ].filter(Boolean).join(" / ");
}

function render() {
  const rows = pages
    .filter(matches)
    .sort((a, b) => String(b.updated ?? b.file.mtime).localeCompare(String(a.updated ?? a.file.mtime)));

  summary.textContent = rows.length + " / " + pages.length + "개";
  result.empty();

  const table = result.createEl("table", { cls: "wf-table" });
  const thead = table.createEl("thead");
  const headRow = thead.createEl("tr");
  ["ID", "제목", "종류", "상태", "우선순위", "레벨", "담당 사일로", "브랜치", "PR", "승격", "가설", "실패 이력", "가설 해결", "실패 수", "해결 시도", "최근 실패", "재시도", "차단 사유", "해결 요약", "태그", "수정일"].forEach((heading) => {
    headRow.createEl("th", { text: heading });
  });

  const tbody = table.createEl("tbody");
  rows.forEach((page) => {
    const row = tbody.createEl("tr");
    row.createEl("td").appendChild(pageLink(page));
    row.createEl("td", { text: itemTitle(page) ?? "" });
    row.createEl("td", { text: page.type ?? "" });
    row.createEl("td", { text: page.status ?? "" });
    row.createEl("td", { text: page.priority ?? page.severity ?? "" });
    row.createEl("td", { text: normalize(page.level_target).join(", ") });
    row.createEl("td", { text: normalize(page.owner_silo).join(", ") });
    row.createEl("td", { text: normalize(page.branch).join(", ") });
    row.createEl("td", { text: normalize(page.pr).join(", ") });
    row.createEl("td", { text: page.promotion_status ?? "" });
    row.createEl("td", { text: hypothesisSummary(page) });
    row.createEl("td", { text: failureSummary(page) });
    row.createEl("td", { text: page.resolved_by_hypothesis ?? "" });
    row.createEl("td", { text: page.failed_run_count ?? "" });
    row.createEl("td", { text: page.resolved_attempt_no ?? "" });
    row.createEl("td", { text: page.latest_failed_report ?? "" });
    row.createEl("td", { text: page.latest_retry_report ?? "" });
    row.createEl("td", { text: page.blocked_reason ?? "" });
    row.createEl("td", { text: page.latest_resolution_summary ?? "" });
    row.createEl("td", { text: pageTags(page).map((tag) => "#" + tag).join(", ") });
    row.createEl("td", { text: toDateKey(page.updated ?? page.file.mtime) });
  });
}

render();
```
