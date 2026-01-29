# Define Phases

*Reference for **[technical-planning](../../SKILL.md)***

---

This step uses the `planning-phase-designer` agent (`.claude/agents/planning-phase-designer.md`) to design phases. You invoke the agent, present its output, and handle the approval gate.

---

## Check for Existing Phases

Read the Plan Index File. Check if phases already exist in the body.

**If phases exist with `status: approved`:**
- Present them to the user for review (deterministic replay)
- User can approve (`y`), amend, or navigate (`skip to {X}`)
- If amended, re-invoke the agent with the existing phases + user feedback
- Once approved (or skipped), proceed to Step 5

**If phases exist with `status: draft`:**
- Present the draft for review/approval
- Continue the approval flow below

**If no phases exist:**
- Continue with fresh phase design below

---

## Fresh Phase Design

Orient the user:

> "I'm going to delegate phase design to a specialist agent. It will read the full specification and propose a phase structure — how we break this into independently testable stages. Once we agree on the phases, we'll take each one and break it into tasks."

### Invoke the Agent

Invoke `planning-phase-designer` with these file paths:

1. **read-specification.md**: `.claude/skills/technical-planning/references/read-specification.md`
2. **Specification**: path from the Plan Index File's `specification:` field
3. **Cross-cutting specs**: paths from the Plan Index File's `cross_cutting_specs:` field (if any)
4. **phase-design.md**: `.claude/skills/technical-planning/references/phase-design.md`
5. **task-design.md**: `.claude/skills/technical-planning/references/task-design.md`

### Present the Output

The agent returns a complete phase structure. Write it directly to the Plan Index File body.

Update the frontmatter `planning:` block:
```yaml
planning:
  phase: 1
  task: ~
```

Commit: `planning({topic}): draft phase structure`

Present the phase structure to the user.

**STOP.** Ask:

> **To proceed:**
> - **`y`/`yes`** — Approved. I'll proceed to task breakdown.
> - **Or tell me what to change** — reorder, split, merge, add, edit, or remove phases.

#### If the user provides feedback

Re-invoke `planning-phase-designer` with all original inputs PLUS:
- **Previous output**: the current phase structure
- **User feedback**: what the user wants changed

Update the Plan Index File with the revised output, re-present, and ask again. Repeat until approved.

#### If approved

1. Update each phase in the Plan Index File: set `status: approved` and `approved_at: YYYY-MM-DD` (use today's actual date)
2. Update `planning:` block in frontmatter to note current position
3. Commit: `planning({topic}): approve phase structure`

→ Proceed to **Step 5**.
