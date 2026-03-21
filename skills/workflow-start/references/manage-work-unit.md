# Manage Work Unit

*Reference for **[workflow-start](../SKILL.md)***

---

Manage an in-progress work unit's lifecycle. Self-contained four-step flow.

## A. Select

> *Output the next fenced block as a code block:*

```
Manage

@if(feature_count > 0)
Features:
@foreach(unit in features.work_units)
  {N}. {unit.name:(titlecase)}
@endforeach
@endif

@if(bugfix_count > 0)
Bugfixes:
@foreach(unit in bugfixes.work_units)
  {N}. {unit.name:(titlecase)}
@endforeach
@endif

@if(cross_cutting_count > 0)
Cross-Cutting:
@foreach(unit in cross_cutting.work_units)
  {N}. {unit.name:(titlecase)}
@endforeach
@endif

@if(epic_count > 0)
Epics:
@foreach(unit in epics.work_units)
  {N}. {unit.name:(titlecase)}
@endforeach
@endif
```

Build from discovery output. Only show sections that have work units. Numbering is continuous across sections — same numbers as the overview.

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
Select a work unit (enter number, or **`b`/`back`** to return):
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

#### If user chose `b`/`back`

→ Return to caller.

#### If user chose a number

Store the selected work unit.

→ Proceed to **B. Pre-Checks**.

## B. Pre-Checks

Default `implementation_completed` = false, `has_plan` = false.

Check whether the planning phase exists:

```bash
node .claude/skills/workflow-manifest/scripts/manifest.cjs exists {selected.name}.planning
```

If the result is `true`, set `has_plan` = true.

Check whether the implementation phase exists:

```bash
node .claude/skills/workflow-manifest/scripts/manifest.cjs exists {selected.name}.implementation
```

#### If the result is `false`

→ Proceed to **D. Action Menu**.

#### If the result is `true`

→ Proceed to **C. Completion Check**.

## C. Completion Check

```bash
node .claude/skills/workflow-manifest/scripts/manifest.cjs get '{selected.name}.implementation.*' status
```

This returns all topic statuses in the implementation phase.

#### If any result has `"value": "completed"`

Set `implementation_completed` = true.

→ Proceed to **D. Action Menu**.

#### Otherwise

→ Proceed to **D. Action Menu**.

## D. Action Menu

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
**{selected.name:(titlecase)}** ({selected.work_type})

@if(implementation_completed)
- **`d`/`done`** — Mark as completed
@endif
@if(selected.work_type == 'feature')
- **`p`/`pivot`** — Convert to epic (enables multiple topics)
@endif
@if(has_plan)
- **`v`/`view-plan`** — View the implementation plan
@endif
- **`c`/`cancel`** — Mark as cancelled
- **`b`/`back`** — Return
- **Ask** — Ask a question about this work unit
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

#### If user chose `d`/`done`

```bash
node .claude/skills/workflow-manifest/scripts/manifest.cjs set {selected.name} status completed
```

Commit: `workflow({selected.name}): mark as completed`

> *Output the next fenced block as a code block:*

```
"{selected.name:(titlecase)}" marked as completed.
```

→ Return to caller.

#### If user chose `p`/`pivot`

```bash
node .claude/skills/workflow-manifest/scripts/manifest.cjs set {selected.name} work_type epic
```

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
**{selected.name:(titlecase)}** converted from feature to epic.

- **`c`/`continue`** — Continue {selected.name:(titlecase)} as epic
- **`b`/`back`** — Return to previous view
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

**If user chose `c`/`continue`:**

Invoke the `/continue-epic` skill. This is terminal — do not return to the caller.

**If user chose `b`/`back`:**

→ Return to caller.

#### If user chose `v`/`view-plan`

→ Load **[view-plan.md](view-plan.md)** and follow its instructions as written.

→ Return to **D. Action Menu**.

#### If user chose `c`/`cancel`

```bash
node .claude/skills/workflow-manifest/scripts/manifest.cjs set {selected.name} status cancelled
```

Commit: `workflow({selected.name}): mark as cancelled`

> *Output the next fenced block as a code block:*

```
"{selected.name:(titlecase)}" marked as cancelled.
```

→ Return to caller.

#### If user chose `b`/`back`

→ Return to caller.

#### If user asked a question

Answer the question.

→ Return to **D. Action Menu**.
