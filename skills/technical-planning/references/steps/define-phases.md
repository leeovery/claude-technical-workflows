# Define Phases

*Reference for **[technical-planning](../../SKILL.md)***

---

This step uses the `planning-phase-designer` agent (`.claude/agents/planning-phase-designer.md`) to define or review the phase structure. Whether phases are being designed for the first time or reviewed from a previous session, the process converges on the same approval gate.

---

## Determine Phase State

Read the Plan Index File. Check if phases already exist in the body.

#### If phases exist

Orient the user:

> "Phase structure already exists. I'll present it for your review."

Continue to **Review and Approve** below.

#### If no phases exist

Orient the user:

> "I'll delegate phase design to a specialist agent. It will read the full specification and propose a phase structure — how we break this into independently testable stages."

### Invoke the Agent

Invoke `planning-phase-designer` with these file paths:

1. **read-specification.md**: `.claude/skills/technical-planning/references/read-specification.md`
2. **Specification**: path from the Plan Index File's `specification:` field
3. **Cross-cutting specs**: paths from the Plan Index File's `cross_cutting_specs:` field (if any)
4. **phase-design.md**: `.claude/skills/technical-planning/references/phase-design.md`
5. **task-design.md**: `.claude/skills/technical-planning/references/task-design.md`

The agent returns a complete phase structure. Write it directly to the Plan Index File body.

Update the frontmatter `planning:` block:
```yaml
planning:
  phase: 1
  task: ~
```

Commit: `planning({topic}): draft phase structure`

Continue to **Review and Approve** below.

---

## Review and Approve

Present the phase structure to the user.

**STOP.** Ask:

> **Phase Structure**
>
> · · ·
>
> **To proceed:**
> - **`y`/`yes`** — Approved. I'll proceed to task breakdown.
> - **Or tell me what to change** — reorder, split, merge, add, edit, or remove phases.
> - **Or navigate** — a different phase or task, or the leading edge.

#### If the user provides feedback

Re-invoke `planning-phase-designer` with all original inputs PLUS:
- **Previous output**: the current phase structure
- **User feedback**: what the user wants changed

Update the Plan Index File with the revised output, re-present, and ask again. Repeat until approved.

#### If approved

**If the phase structure is new or was amended:**

1. Update each phase in the Plan Index File: set `status: approved` and `approved_at: YYYY-MM-DD` (use today's actual date)
2. Commit: `planning({topic}): approve phase structure`

**If the phase structure was already approved and unchanged:** No updates needed.
