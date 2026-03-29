---
name: workflow-scoping-process
user-invocable: false
allowed-tools: Bash(node .claude/skills/workflow-manifest/scripts/manifest.cjs)
---

# Scoping Process

Act as **expert technical analyst** performing rapid scoping of a mechanical change. Assess scope, write a lightweight specification, and produce 1-2 task files — all in a single pass.

## Purpose in the Workflow

Scope a mechanical change — gather context, write a specification, and produce a plan with 1-2 task files ready for implementation.

## What This Skill Needs

- **Work unit description** (required) - From the manifest, summarising the mechanical change
- **Topic name** (required) - Same as work_unit for quick-fix
- **Output format preference** (optional) - Will ask if not specified

---

## Resuming After Context Refresh

Context refresh (compaction) summarizes the conversation, losing procedural detail. When you detect a context refresh has occurred — the conversation feels abruptly shorter, you lack memory of recent steps, or a summary precedes this message — follow this recovery protocol:

1. **Re-read this skill file completely.** Do not rely on your summary of it. The full process, steps, and rules must be reloaded.
2. **Check what artifacts exist on disk** — spec file, plan file, task files. Their presence reveals which steps completed.
3. **Check git state.** Run `git status` and `git log --oneline -10` to see recent commits.
4. **Announce your position** to the user before continuing: what step you believe you're at, what's been completed, and what comes next. Wait for confirmation.

Do not guess at progress or continue from memory. The files on disk and git history are authoritative — your recollection is not.

---

## Hard Rules

1. **Maximum 2 tasks** — if the change needs more, it's not a quick-fix. Promote it.
2. **No acceptance criteria** — mechanical changes are verified by test baselines and completeness checks, not by acceptance criteria.
3. **No agents** — scoping writes specs and tasks directly, without invoking planning agents or review cycles.

## Output Formatting

When announcing a new step, output `── ── ── ── ──` on its own line before the step heading.

---

## Step 0: Resume Detection

Check if a specification already exists:

```bash
ls .workflows/{work_unit}/specification/{topic}/specification.md 2>/dev/null && echo "exists" || echo "none"
```

#### If specification exists

Check if a plan also exists:

```bash
node .claude/skills/workflow-manifest/scripts/manifest.cjs exists {work_unit}.planning.{topic}
```

**If plan exists and is completed:**

> *Output the next fenced block as a code block:*

```
Scoping already completed for "{topic:(titlecase)}". Spec and plan are in place.
```

Mark scoping as completed if not already, then invoke the bridge:

```bash
node .claude/skills/workflow-manifest/scripts/manifest.cjs exists {work_unit}.scoping.{topic}
```

If scoping doesn't exist, init and complete it:

```bash
node .claude/skills/workflow-manifest/scripts/manifest.cjs init-phase {work_unit}.scoping.{topic}
node .claude/skills/workflow-manifest/scripts/manifest.cjs set {work_unit}.scoping.{topic} status completed
```

→ Proceed to **Step 6**.

**Otherwise:**

→ Proceed to **Step 1** (spec exists but plan is incomplete — resume from format selection).

#### If specification does not exist

→ Proceed to **Step 1**.

---

## Step 1: Gather Context

Load **[gather-context.md](references/gather-context.md)** and follow its instructions as written.

→ Proceed to **Step 2**.

---

## Step 2: Complexity Check

Load **[complexity-check.md](references/complexity-check.md)** and follow its instructions as written.

→ Proceed to **Step 3**.

---

## Step 3: Write Specification

Load **[write-specification.md](references/write-specification.md)** and follow its instructions as written.

→ Proceed to **Step 4**.

---

## Step 4: Select Output Format

Load **[select-format.md](references/select-format.md)** and follow its instructions as written.

→ Proceed to **Step 5**.

---

## Step 5: Write Tasks

Load **[write-tasks.md](references/write-tasks.md)** and follow its instructions as written.

→ Proceed to **Step 6**.

---

## Step 6: Conclude Scoping

Load **[conclude-scoping.md](references/conclude-scoping.md)** and follow its instructions as written.
