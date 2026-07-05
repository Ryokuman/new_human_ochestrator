# New-Human Orchestrator Usage Guide

This guide is intentionally short.

Use `setup.sh` to create the reusable operating surface. Then use Q&A to choose and define the actual flow.

The tracked canonical state in this repository is the Layer 0 System SSoT. Real Layer 1 Project SSoT, Layer 2 Project Work SSoT, and Layer 3 Silo Local / Test Evidence / Feedback data are not canonical tracked data here yet.

Top-level functions:

1. layer operations
2. main/work branch operations
3. Layer 1 Project SSoT management
4. Project Contract Gate
5. Task/Issue/Silo operations
6. Runtime Set management
7. PR Review Loop
8. feedback/personality loop
9. setup/support surface management

Risky execution precondition checks are not a standalone feature. They are absorbed as lower gates under Task/Issue/Silo operation and Runtime Set management. `hypothesis chain` is outside this stabilization scope.

## Setup

Interactive setup:

```bash
./setup.sh
```

Common non-interactive setup:

```bash
./setup.sh --all --yes
./setup.sh --repo-skills --using-superpowers --yes
./setup.sh --init-config --yes
```

Create a project SSoT scaffold:

```bash
./setup.sh --create-project-ssot \
  --project-id <project-id> \
  --project-name "<project-name>" \
  --target <project-ssot-path> \
  --yes
```

## What Setup Can Create

`setup.sh` can create most repeatable structure:

- repo skills
- local config drafts
- project SSoT folders
- dashboard files
- issue/task templates
- project contract template
- handoff and PR templates
- coverage folders

`setup.sh` cannot honestly fill project-specific knowledge by itself. Product intent, real user flows, DB/API/auth boundaries, and architecture meaning still need repository analysis, LLM-assisted research, and user confirmation.

## Choose a Flow

Start with these questions:

1. Is there already a codebase?
2. Do you want to operate on one project or summarize many projects?
3. Is the immediate goal to create tasks, create a project knowledge base, or start a new product?
4. Is `project-contract-gate` available?
5. After the flow is defined, can the current setup actually run that flow?

## Examples

1. [`ex_1.md`](ex_1.md): adopt an existing project.
2. [`ex_2.md`](ex_2.md): research existing projects into a project knowledge base.
3. [`ex_3.md`](ex_3.md): start a new project.

## Readiness Check

After choosing a flow, check:

- required repo skills are installed
- project SSoT location exists or can be scaffolded
- source repository or GitHub input is available
- `project-contract-gate` or an equivalent Q&A process can close unknowns
- task creation rules are available
- silo execution rules are available
- branch target matches the layer: the target Layer 0 main branch is `main-v3/main`, the target Layer 1 main branch is `project-{projectName}/main`, and target work branches use `main-v3/{taskname}` or `project-{projectName}/{taskname}`. Before migration, the current Layer 0 compatibility base is `main-v3/main` with `main-v3/{taskname}` work branches.
- `main-v3` and `project-{projectName}` are namespaces, not leaf branches
- the previous slash-based `project/<project-id>` model is treated as compatibility or migration context, not the target canonical model
