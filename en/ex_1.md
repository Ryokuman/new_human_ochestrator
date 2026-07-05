# Example 1: Adopt an Existing Project

Use this when a codebase already exists and you want the orchestrator workflow around it.

## Q&A

Ask these first:

1. Where is the existing project source?
2. What does the project do today?
3. What is the first user outcome we want to improve or verify?
4. Where are the DB schema, API/auth contract, runtime instructions, and test commands?
5. Is `project-contract-gate` installed and usable?
6. What must not be inferred?

## Flow

1. Inspect the existing project.
2. Create or confirm the project SSoT scaffold.
3. Draft `project-contract.md` from the real codebase and user answers.
4. Use Q&A, preferably `project-contract-gate`, to close unknown goals and boundaries.
5. Create the first task from the contract.
6. Run the task in a silo.
7. Verify, open a PR, and promote reusable findings back into the SSoT.

## Setup Readiness

Before running this flow, confirm:

- `setup.sh --create-project-ssot` can create or refresh the SSoT scaffold
- repo skills are installed
- `project-contract-gate` exists or an equivalent Q&A skill is available
- source repo path or GitHub repo is accessible
- project branch policy is clear
- task and silo templates exist

If these are true, the orchestrator can run the flow. If the project contract is still empty, the system can prepare the structure but should not create implementation tasks yet.
