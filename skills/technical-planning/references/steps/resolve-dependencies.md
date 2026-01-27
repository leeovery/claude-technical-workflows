# Resolve External Dependencies

*Reference for **[technical-planning](../../SKILL.md)***

---

Orient the user:

> "All phases and tasks are written. Now I'll check for external dependencies — things this plan needs from other topics or systems."

After all phases are detailed and written, handle external dependencies — things this plan needs from other topics or systems.

#### If the specification has a Dependencies section

The specification's Dependencies section lists what this feature needs from outside its own scope. These must be documented in the plan so implementation knows what is blocked and what is available.

1. **Document each dependency** in the plan's External Dependencies section using the format described in [dependencies.md](../dependencies.md). Initially, record each as unresolved.

2. **Resolve where possible** — For each dependency, check whether a plan already exists for that topic:
   - If a plan exists, identify the specific task(s) that satisfy the dependency. Query the output format to find relevant tasks. If ambiguous, ask the user which tasks apply. Update the dependency entry from unresolved → resolved with the task reference.
   - If no plan exists, leave the dependency as unresolved. It will be linked later via `/link-dependencies` or when that topic is planned.

3. **Reverse check** — Check whether any existing plans have unresolved dependencies that reference *this* topic. Now that this plan exists with specific tasks:
   - Scan other plan files for External Dependencies entries that mention this topic
   - For each match, identify which task(s) in the current plan satisfy that dependency
   - Update the other plan's dependency entry with the task reference (unresolved → resolved)

#### If the specification has no Dependencies section

Document this explicitly in the plan:

```markdown
## External Dependencies

No external dependencies.
```

This makes it clear that dependencies were considered and none exist — not that they were overlooked.

#### If no other plans exist

Skip the resolution and reverse check — there is nothing to resolve against. Document the dependencies as unresolved. They will be linked when other topics are planned, or via `/link-dependencies`.

**STOP.** Present a summary of the dependency state: what was documented, what was resolved, what remains unresolved, and any reverse resolutions made.

> **To proceed, choose one:**
> - **"Approve"** — Dependency state is confirmed. Proceed to plan review.
> - **"Adjust"** — Tell me what to change.

#### If Adjust

Incorporate feedback, re-present the updated dependency state, and ask again. Repeat until approved.

#### If Approved

→ Proceed to **Step 8**.
