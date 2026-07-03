# New-Human Orchestrator Usage Guide

This repository manages reusable agent operating rules, SSoT structure, silo execution flows, PR review loops, and feedback policies.

Canonical reusable definitions live under `system/`. Use `main-v2` for shared rules and reusable infrastructure. Use long-lived `project/<project-id>` branches for project-specific knowledge and evidence.

## Read Order

1. `AGENTS.md`
2. `system/README.md`
3. `system/00-system-overview/계층-구조와-관리-원칙.md`
4. `system/00-system-overview/전체-시스템-개요.md`
5. `system/10-ssot/SSoT-스키마-초안.md`
6. `system/10-agents/main.md`
7. `system/20-skills/README.md`
8. `system/10-agents/main-orchestrator/main-prompt.md`

## Basic Flow

1. Classify the request as layer 0, 1, 2, or 3.
2. Keep shared rules, role prompts, and repo skills under `system/`.
3. Keep project status, issues, tasks, and QA results in the project SSoT.
4. Run implementation work in isolated task silos.
5. Report silo outputs with verification results, SSoT promotion candidates, and non-promoted findings separated.
6. Treat user feedback as current-work fixes, silo-only rules, or global rule candidates.

## Layer Storage

| Layer | Storage | Content |
|---|---|---|
| Layer 0 | `system/` | Shared rules, prompts, repo skills, setup templates |
| Layer 1 | project registry/config, `project/*` branches | Project registration, connection model, SSoT location |
| Layer 2 | project SSoT | Project issues, tasks, QA, decisions, coverage, dashboards |
| Layer 3 | task silo workspace | Temporary findings, experiment logs, pre-PR state |

## Initial Setup

After forking or cloning this repository, run `setup.sh` from the root to install shared working skills.

```bash
./setup.sh
```

Non-interactive full setup:

```bash
./setup.sh --all --yes
```

The default install location is `$CODEX_HOME/skills`. If `CODEX_HOME` is not set, the script uses `~/.codex/skills`.

Create local config drafts with:

```bash
./setup.sh --init-config --yes
```

## Create a Project SSoT Draft

Create a new project SSoT scaffold from the repository root:

```bash
./setup.sh --create-project-ssot \
  --project-id <project-id> \
  --project-name "<project-name>" \
  --target <project-ssot-path> \
  --yes
```

This creates draft folders and documents for dashboards, dictionary, issues, tasks, decisions, handoffs, coverage, and templates. Do not place raw project issues, tasks, or QA results in root `main-v2`.

## Project Contract Standard

`project-contract.md` is the product contract checked before turning a project into executable tasks. Before writing feature tasks, close at least these fields:

- Product definition: what the project is
- Current version goals and non-goals: what this version will and will not do
- Core user flow: how the user gets value
- Data storage and synchronization boundaries: local, server, external API, and DB responsibilities
- Repository roles: FE, BE, DB, harness, submodule, external clone responsibilities
- Design and runtime sources of truth: screen standards, run method, verification method
- Do-not-infer information: schema, auth, production data, secrets, or any value that must be verified first

Recommended location:

```text
projects/<project-id>/02-project-internal/00-dashboard/project-contract.md
```

## Example 1: Apply It to an Existing Project

The goal is to create the product contract and work boundaries that agents can repeatedly reference before changing an existing repository.

1. Inspect the existing source repo, run commands, DB/schema location, deployment model, and main screens.
2. Create a project SSoT scaffold from a `project/<project-id>` branch, or locate the existing project SSoT.
3. Summarize the current behavior in `project-contract.md`.
4. Mark unknown items as `Needs confirmation` instead of guessing.
5. Write future feature tasks against the user flow described in `project-contract.md`.

Example structure:

```text
projects/shop-admin/
  README.md
  02-project-internal/
    00-dashboard/
      project-overview.md
      project-contract.md
    20-issues/
    30-tasks/
```

Example contract summary:

```markdown
# Project Contract: shop-admin

## Product Definition
An internal admin for small commerce operators to manage orders, products, and inventory.

## Current Version Goals
- View order lists and change order status
- Check product inventory counts
- Keep operator login sessions active

## Non-Goals
- Payment integration changes
- Customer storefront UI changes
- Bulk inventory import

## Core User Flow
The operator logs in, filters the order list, changes status in the order detail, and confirms the updated status back on the list.

## Sources of Truth
- source repo: `../shop-admin`
- DB schema: `../shop-admin/db/schema.sql`
- run method: `../shop-admin/README.md`
- E2E standard: `../shop-admin/tests/e2e/`

## Needs Confirmation
- production role differences
- staging seed data creation
```

## Example 2: Scan Existing Projects into an LLM Wiki for Portfolio or Resume Work

The goal is to turn existing projects into searchable evidence packages so an agent can reuse the same source material for portfolio copy and resume bullets.

1. Create one project SSoT for portfolio knowledge.
2. Split each project into an evidence package.
3. Scan source repositories for architecture, ownership, issue, metric, and screenshot candidates.
4. Store summaries, evidence locations, and re-check methods instead of copying entire raw sources.
5. When asking the LLM questions, require answers to cite the project SSoT and evidence paths.

Example structure:

```text
projects/portfolio/
  00-project/
    project-contract.md
  10-projects/
    delivery-platform/
      README.md
      10-summary/
      20-architecture/
      30-issues/
      40-ownership/
      50-metrics/
      60-drafts/
    ai-scheduler/
      README.md
      10-summary/
      20-architecture/
      30-issues/
      40-ownership/
      50-metrics/
      60-drafts/
  20-resume/
  30-portfolio-copy/
  40-applications/
```

Example contract summary:

```markdown
# Project Contract: portfolio-wiki

## Product Definition
A portfolio evidence wiki that lets an LLM answer questions about personal projects and work experience.

## Current Version Goals
- Generate one-paragraph summaries per project
- Separate technical challenges, solutions, and ownership evidence
- Draft resume bullets and portfolio copy

## Non-Goals
- Copying full source repositories
- Storing confidential data
- Automatically submitting job applications

## Core User Flow
When the user asks "What did I do in this project?", the agent reads project summaries, issue history, and ownership evidence, then produces grounded answers and resume bullet candidates.

## Evidence Categories
- architecture: design decisions and tradeoffs
- issue: problem, cause, fix, prevention
- ownership: the user's owned scope and evidence
- metric: performance, user, cost, or reliability changes
- draft: externally publishable copy candidates

## Do Not Infer
- company-internal numbers
- private customer names
- unverified impact metrics
```

## Example 3: Start a New Project from Zero

The goal is to define the project contract and task boundary together so the first implementation slice can be verified end to end.

1. Write the product idea in one sentence.
2. Separate current version goals from non-goals.
3. Pick one core user flow.
4. Define FE, BE, DB, auth, and harness roles.
5. Create an SSoT scaffold with `setup.sh --create-project-ssot`.
6. Write the first task only after `project-contract.md` is concrete enough.
7. Choose the smallest full-stack slice that shows user value.

Example structure:

```text
projects/meal-planner/
  README.md
  02-project-internal/
    00-dashboard/
      project-overview.md
      project-contract.md
      work-filter.md
    20-issues/
    30-tasks/
    40-decisions/
```

Example contract summary:

```markdown
# Project Contract: meal-planner

## Product Definition
A web app that plans a weekly meal schedule from pantry ingredients and diet goals.

## Current Version Goals
- Let the user enter available ingredients
- Let the user choose meal goals
- Generate a seven-day meal plan draft
- Let the user edit and save the result

## Non-Goals
- Grocery checkout integration
- Nutritionist review workflow
- Native mobile app release

## Core User Flow
The user enters ingredients and goals, the app proposes a seven-day plan, and the user replaces some meals before saving.

## Repository Roles
- FE: ingredient input, generated plan editing, save screen
- BE: generation request, save API, user meal-plan query
- DB: users, ingredients, meal plans, meal plan items
- harness: repeatable verification with a seed user and sample ingredients

## First Task Candidate
Verify ingredient input through seven-day draft saving for one test user.

## Needs Confirmation
- actual AI provider
- user authentication model
- nutrition data source
```

## Main-v2 Update Rule

Do not modify shared rules, `AGENTS.md`, `system/` documents, prompts, or repo skills directly on the current working branch.

Follow `main-branch-update-flow`: create a branch from `main-v2`, make the change, then submit a PR targeting `main-v2`. PR creation approval and PR merge approval are separate. Legacy `main` is not used as a working target in this project.

## Cautions

- Do not copy raw project issues, tasks, or QA results into root `main-v2`.
- Do not read or record actual secrets, tokens, passwords, or credentials.
- Treat `config/silo-projects.yaml` and `config/*.env` as local configuration.
- If project-specific material must be added to this repository, handle it in a project branch or project SSoT, not root `main-v2`.
