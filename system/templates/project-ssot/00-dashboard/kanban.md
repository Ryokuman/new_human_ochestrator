---
type: dashboard
id: DASH-TASK-KANBAN
status: active
dashboardTitle: Task 칸반
dashboardScope:
  path: 30-work-items/tasks/
---

# Task 칸반

이 칸반은 읽기 전용이다. 상태를 바꿀 때는 Task 파일을 대응하는 상태 디렉터리로 이동하고 frontmatter `status`와 `updated`를 함께 갱신한다.

```dataviewjs
const dashboardFolder = dv.current().file.folder;
const projectRoot = dashboardFolder.replace(/(^|\/)00-dashboard$/, "");
const configuredPath = dv.current().dashboardScope?.path ?? "30-work-items/tasks/";
const taskRoot = projectRoot ? `${projectRoot}/${configuredPath}` : configuredPath;
const columns = [
  { status: "todo", label: "할 일" },
  { status: "in_progress", label: "진행 중" },
  { status: "blocked", label: "차단" },
  { status: "review", label: "리뷰" },
  { status: "done", label: "완료" },
];
const tasks = dv.pages()
  .where((page) => page.type === "task")
  .where((page) => page.file.path.startsWith(taskRoot))
  .where((page) => !page.file.path.includes("/_templates/"))
  .array();
const text = (value, fallback = "-") => value == null || value === "" ? fallback : String(value);
const taskId = (task) => text(task.taskID ?? task.id, task.file.name);
const taskTitle = (task) => text(task.taskTitle ?? task.title, task.file.name);
const root = dv.container;
root.classList.add("task-kanban");
const style = root.createEl("style");
style.textContent = `
.task-kanban .tk-board { display: grid; grid-template-columns: repeat(5, minmax(220px, 1fr)); gap: 12px; overflow-x: auto; }
.task-kanban .tk-column { min-width: 220px; padding: 10px; border: 1px solid var(--background-modifier-border); border-radius: 10px; background: var(--background-secondary); }
.task-kanban .tk-heading { display: flex; justify-content: space-between; margin-bottom: 8px; font-weight: 700; }
.task-kanban .tk-list { display: grid; gap: 8px; }
.task-kanban .tk-card { padding: 9px; border: 1px solid var(--background-modifier-border); border-radius: 8px; background: var(--background-primary); }
.task-kanban .tk-meta { margin-top: 6px; color: var(--text-muted); font-size: 12px; }
`;
const board = root.createDiv({ cls: "tk-board" });
columns.forEach((column) => {
  const items = tasks
    .filter((task) => task.status === column.status)
    .sort((left, right) => taskId(left).localeCompare(taskId(right)));
  const section = board.createDiv({ cls: "tk-column" });
  const heading = section.createDiv({ cls: "tk-heading" });
  heading.createSpan({ text: column.label });
  heading.createSpan({ text: String(items.length) });
  const list = section.createDiv({ cls: "tk-list" });
  items.forEach((task) => {
    const card = list.createDiv({ cls: "tk-card" });
    const link = card.createEl("a", {
      cls: "internal-link",
      href: task.file.path,
      text: `${taskId(task)} · ${taskTitle(task)}`,
    });
    link.dataset.href = task.file.path;
    card.createDiv({
      cls: "tk-meta",
      text: `우선순위 ${text(task.priority)} · 담당 ${text(task.owner_silo)} · 수정 ${text(task.updated)}`,
    });
  });
});
```
