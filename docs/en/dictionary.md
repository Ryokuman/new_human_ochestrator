# System Dictionary

This document defines shared New-Human Orchestrator terminology. Each Project Work SSoT owns its project-specific domain vocabulary.

| Term | Definition |
|---|---|
| Layer 0 System SSoT | The canonical source for cross-project layer structure, agent guidance, skills, templates, and operating rules. |
| Codex-home AGENTS | The global router installed at `$CODEX_HOME/AGENTS.md` so Codex sessions using the same Codex home locate the Layer 0 root AGENTS router and User Layer source of truth. |
| User Layer | A Layer 1 User SSoT directory in the workspace that owns user-specific judgment criteria and Feedback history. |
| User Personality | The current judgment criteria recorded in the User Layer `AGENTS.md` after repeated friction is reviewed and validated through scenarios. |
| Feedback | A correction event involving the response contract or decision direction between the user and the agent during a normal work session. Recording it is not a gate that blocks the current task. |
| Candidate Personality | A candidate user decision principle extracted after multiple Feedback records are routed by scope in a user-initiated personality update session. |
| Validation Scenario | A question used to check whether a Candidate Personality predicts the user's judgment in a nearby case, a boundary case, and a transfer case. |
| Validation Result | A record of the user's choice and reasoning, whether the candidate prediction matched, and why the candidate was revised or rejected. |
| Project SSoT | The Layer 1 canonical source for durable project information such as product definition, Project Contract, repository and source locations, requirements, and decisions or ADRs. |
| Project Contract | The contract that defines the product, goals and non-goals, user flows, data boundaries, and product invariants. In the target structure, `<workspace>/<projectName>/01-project-ssot/AGENTS.md` is canonical. |
| Project Work SSoT | The Layer 2 canonical source for Tasks, Issues, QA, Runbooks, Coverage, and Handoffs that implement and verify the Project Contract. |
| Task | A canonical work record that turns confirmed requirements into an implementable goal, scope, contract, acceptance criteria, and verification plan. |
| Issue | A record that tracks a confirmed problem, its impact, cause candidates, and related Tasks discovered during implementation or verification. |
| Silo | A dynamic isolated execution unit for one Task or Issue. It is distinct from the product source repository itself. |
| Operating Hypothesis | A system operating hypothesis that experiments with Layer 0 operating methods such as task handling, information gathering, silos, and PR or review loops. |
| Task `hypothesis_chain` | A chronological execution record of failure-cause candidates and retry results within a Task. It is distinct from an Operating Hypothesis. |

## Terminology Boundaries

- `Feedback` is a correction event; `evidence` is support for that event or for a validation result.
- Candidate Personality and User Personality do not use the term `hypothesis`.
- Project product rules belong to the Project Contract, not User Personality.
- Execution conditions specific to one Task belong to the Task and its `goal.md`, not the User Layer or Project Contract.
