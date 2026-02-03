# Resolve External Dependencies

*Reference for **[technical-planning](../../SKILL.md)***

---

Orient the user:

> "All phases and tasks are written. Now I'll check for external dependencies — things this plan needs from other topics or systems."

After all phases are detailed and written, handle external dependencies — things this plan needs from other topics or systems.

Dependencies are stored in the plan's **frontmatter** as `external_dependencies`. See [dependencies.md](../dependencies.md) for the format and states.

#### If the specification has a Dependencies section

The specification's Dependencies section lists what this feature needs from outside its own scope. These must be documented in the plan so implementation knows what is blocked and what is available.

1. **Document each dependency** in the plan's `external_dependencies` frontmatter field using the format described in [dependencies.md](../dependencies.md). Initially, record each as `state: unresolved`.

2. **Resolve where possible** — For each dependency, check whether a plan already exists for that topic:
   - If a plan exists, identify the specific task(s) that satisfy the dependency. Query the output format to find relevant tasks. If ambiguous, ask the user which tasks apply. Update the dependency entry from `state: unresolved` → `state: resolved` with the `task_id`.
   - If no plan exists, leave the dependency as `state: unresolved`. It will be linked later via `/link-dependencies` or when that topic is planned.

3. **Reverse check** — Check whether any existing plans have unresolved dependencies in their `external_dependencies` frontmatter that reference *this* topic. Now that this plan exists with specific tasks:
   - Scan other plan files' `external_dependencies` for entries that mention this topic
   - For each match, identify which task(s) in the current plan satisfy that dependency
   - Update the other plan's `external_dependencies` entry with the task reference (`state: resolved`, `task_id`)

#### If the specification has no Dependencies section

Set the frontmatter field to an empty array:

```yaml
external_dependencies: []
```

This makes it clear that dependencies were considered and none exist — not that they were overlooked.

#### If no other plans exist

Skip the resolution and reverse check — there is nothing to resolve against. Document the dependencies as unresolved. They will be linked when other topics are planned, or via `/link-dependencies`.

**STOP.** Present a summary of the dependency state: what was documented, what was resolved, what remains unresolved, and any reverse resolutions made.

> · · ·
>
> **To proceed:**
> - **`y`/`yes`** — Approved. I'll proceed to plan review.
> - **Or tell me what to change.**

#### If the user provides feedback

Incorporate feedback, re-present the updated dependency state, and ask again. Repeat until approved.

#### If approved
