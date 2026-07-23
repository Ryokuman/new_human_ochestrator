# Example 3: Start a New Project

Use this when there is no existing product code yet.

## Q&A

Ask these first:

1. What is the product idea in one sentence?
2. Who is the first user?
3. What is the first user outcome?
4. What is in scope for the first version?
5. What is explicitly out of scope?
6. What is the smallest end-to-end slice that proves value?
7. What FE, BE, DB, API/auth, harness/runtime, and submodule roles and data storage/sync boundaries are needed?

## Flow

1. Use Q&A to define the first user outcome and the smallest slice, not the whole design.
2. Create only the project SSoT scaffold that does not block the first usable build with `setup.sh`.
3. Write the first lightweight `AGENTS.md` with only the minimum contract: project id/name, repo or workspace location, first user outcome, smallest slice, explicit non-goals, verification method, data storage/sync boundaries, and FE/BE/DB/API/auth/harness/runtime/submodule execution roles. Do not infer roles or boundaries that are not confirmed; mark them explicitly unknown instead.
4. Create the first small task.
5. Run the task in a silo.
6. Follow `Build -> Learn -> Spec`: build, learn, and promote only what you learned back into the contract or follow-up tasks.

## Setup Readiness

Before running this flow, confirm:

- repo skills are installed
- project SSoT scaffold carries only the minimum contract that does not block the first build
- Q&A has closed the minimum initial product contract, execution roles, and data storage/sync boundaries with confirmed values. If any item is explicitly unknown, it can be routed to contract hardening or a non-feature setup task instead of the first feature task
- task template exists
- silo execution rules exist
- verification method for the first slice is known

If these are true, the orchestrator can run the new-project flow. For a new project, the project SSoT scaffold is not a full-system design before the first usable build; it is the minimum contract/scaffold gate that closes confirmed execution roles and boundaries enough to avoid blocking the first feature task in step 4. If a role or boundary is explicitly unknown, step 4 switches to contract hardening or a non-feature setup task instead.
