---
name: begin-implementation
description: "Bridge skill for the feature pipeline. Runs pre-flight checks for implementation and invokes the technical-implementation skill. Called by continue-feature — not directly by users."
user-invocable: false
allowed-tools: Bash(.claude/skills/start-implementation/scripts/discovery.sh)
---

Invoke the **technical-implementation** skill for this conversation with pre-flight context.

<!-- TODO: Steps 2 and 3 (external dependencies, environment setup) duplicate content
     from start-implementation Steps 4 and 5. When start-implementation is refactored
     to use progressive disclosure (reference files), de-duplicate by referencing
     start-implementation's reference files directly — same pattern as begin-planning
     referencing start-planning's cross-cutting-context.md. -->

> **⚠️ ZERO OUTPUT RULE**: Do not narrate your processing. Produce no output until a step or reference file explicitly specifies display content. No "proceeding with...", no discovery summaries, no routing decisions, no transition text. Your first output must be content explicitly called for by the instructions.

## Instructions

Follow these steps EXACTLY as written. Do not skip steps or combine them.

This skill is a **bridge** — it runs pre-flight checks for implementation and hands off to the processing skill. The topic has already been selected by the caller.

**CRITICAL**: This guidance is mandatory.

- After each user interaction, STOP and wait for their response before proceeding
- Never assume or anticipate user choices
- Complete each step fully before moving to the next

---

## Step 1: Run Discovery

Execute the start-implementation discovery script to gather current state:

```bash
.claude/skills/start-implementation/scripts/discovery.sh
```

Parse the output to find the plan matching the provided topic. Extract:

- **Plan details**: status, format, plan_id, specification, specification_exists
- **External dependencies**: external_deps, has_unresolved_deps
- **Dependency resolution**: deps_satisfied, deps_blocking
- **Implementation tracking**: from `implementation.files` matching the topic
- **Environment**: setup_file_exists, requires_setup

If the plan is missing or not concluded, this is an error — report it and stop.

→ Proceed to **Step 2**.

---

## Step 2: Check External Dependencies

Check the plan's `external_deps` and `dependency_resolution` from the discovery output.

#### If all deps satisfied (or no deps)

> *Output the next fenced block as a code block:*

```
External dependencies satisfied.
```

→ Proceed to **Step 3**.

#### If any deps are blocking

> *Output the next fenced block as a code block:*

```
Missing Dependencies

Unresolved (not yet planned):
  • {topic}: {description}
    No plan exists. Create with /start-planning or mark as
    satisfied externally.

Incomplete (planned but not implemented):
  • {topic}: {plan}:{task-id} not yet completed
    This task must be completed first.
```

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
- **`i`/`implement`** — Implement the blocking dependencies first
- **`s`/`satisfied`** — Mark a dependency as satisfied externally
- **`c`/`continue`** — Continue anyway (at your own risk)
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

If the user chooses `implement`, end here — suggest running `/start-implementation` for the blocking topic. If `satisfied`, update the plan frontmatter (`state: satisfied_externally`) and continue. If `continue`, proceed.

→ Proceed to **Step 3**.

---

## Step 3: Check Environment Setup

Use the `environment` section from the discovery output:

**If `setup_file_exists: true` and `requires_setup: false`:**

> *Output the next fenced block as a code block:*

```
Environment: No special setup required.
```

→ Proceed to **Step 4**.

**If `setup_file_exists: true` and `requires_setup: true`:**

> *Output the next fenced block as a code block:*

```
Environment setup file found: docs/workflow/environment-setup.md
```

→ Proceed to **Step 4**.

**If `setup_file_exists: false` or `requires_setup: unknown`:**

> *Output the next fenced block as a code block:*

```
Are there any environment setup instructions I should follow before implementation?
(Or "none" if no special setup is needed)
```

**STOP.** Wait for user response.

- If the user provides instructions, save them to `docs/workflow/environment-setup.md`, commit
- If the user says no/none, create `docs/workflow/environment-setup.md` with "No special setup required." and commit

→ Proceed to **Step 4**.

---

## Step 4: Invoke the Skill

Determine the implementation tracking state:
- If a tracking file exists for this topic → use its status
- If no tracking file → status is "not-started"

Construct the handoff and invoke the [technical-implementation](../technical-implementation/SKILL.md) skill:

```
Implementation session for: {topic}
Plan: docs/workflow/planning/{topic}/plan.md
Format: {format}
Plan ID: {plan_id} (if applicable)
Specification: docs/workflow/specification/{topic}/specification.md (exists: {true|false})
Implementation tracking: {exists | new} (status: {status})
Dependencies: {All satisfied | notes}
Environment: {Setup required | No special setup required}

Invoke the technical-implementation skill.
```
