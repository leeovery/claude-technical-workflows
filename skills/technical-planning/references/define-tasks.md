# Define Tasks

*Reference for **[technical-planning](../SKILL.md)***

---

This step uses the `planning-task-designer` agent (`../../../agents/planning-task-designer.md`) to design a task list for a single phase. You invoke the agent, present its output, and handle the approval gate.

---

## Design the Task List

> *Output the next fenced block as a code block:*

```
Taking Phase {N}: {Phase Name} and breaking it into tasks. I'll delegate
this to a specialist agent that will read the full specification and
propose a task list.
```

### Invoke the Agent

Read `work_type` from the Plan Index File frontmatter.

Invoke `planning-task-designer` with these file paths:

1. **read-specification.md**: `read-specification.md`
2. **Specification**: path from the Plan Index File's `specification:` field
3. **Cross-cutting specs**: paths from the Plan Index File's `cross_cutting_specs:` field (if any)
4. **task-design.md**: `task-design.md`
5. **Context guidance**: If `work_type` is set, include `task-design/{work_type}.md`
6. **All approved phases**: the complete phase structure from the Plan Index File body
7. **Target phase number**: the phase being broken into tasks
8. **plan-index-schema.md**: `plan-index-schema.md`

### Present the Output

The agent returns a task overview and task table. Write the task table directly to the Plan Index File under the phase.

Update the frontmatter `planning:` block:
```yaml
planning:
  phase: {N}
  task: ~
```

Commit: `planning({topic}): draft Phase {N} task list`

Present the task overview to the user:

> *Output the next fenced block as markdown (not a code block):*

```
{task overview from planning-task-designer agent}
```

Then check the gate mode.

### Check Gate Mode

Check `task_list_gate_mode` in the Plan Index File frontmatter.

#### If `task_list_gate_mode: auto`

> *Output the next fenced block as a code block:*

```
Phase {N}: {Phase Name} — task list approved. Proceeding to authoring.
```

→ Skip to **If approved** below.

#### If `task_list_gate_mode: gated`

**STOP.** Ask:

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
**To proceed:**
- **`y`/`yes`** — Approved.
- **`a`/`auto`** — Approve this and all remaining task list gates automatically
- **Or tell me what to change** — reorder, split, merge, add, edit, or remove tasks.
- **Or navigate** — a different phase or task, or the leading edge.
· · · · · · · · · · · ·
```

#### If the user provides feedback

Re-invoke `planning-task-designer` with all original inputs (including context guidance if `work_type` is set) PLUS:
- **Previous output**: the current task list
- **User feedback**: what the user wants changed

Update the Plan Index File with the revised task table, re-present, and ask again. Repeat until approved.

#### If `auto`

Note that `task_list_gate_mode` should be updated to `auto` during the commit step below.

→ Proceed to **If approved** below.

#### If approved (`y`/`yes` or `auto`)

**If the task list is new or was amended:**

1. Advance the `planning:` block to the first task in this phase
2. If user chose `auto` at this gate: update `task_list_gate_mode: auto` in the Plan Index File frontmatter
3. Commit: `planning({topic}): approve Phase {N} task list`

**If the task list was already approved and unchanged:** No updates needed.

→ Return to **Plan Construction**.
