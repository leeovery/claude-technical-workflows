# Plan Index Schema

*Reference for **[technical-planning](../SKILL.md)** and its agents*

---

This file defines the canonical structure for Plan Index Files (`docs/workflow/planning/{topic}/plan.md`). All agents and references that create or update plan index content **must** follow these templates.

---

## Frontmatter

```yaml
---
topic: {topic-name}
status: {status}
format: {chosen-format}
work_type:
ext_id:
specification: ../specification/{topic}/specification.md
cross_cutting_specs:
  - ../specification/{spec}/specification.md
spec_commit: {commit-hash}
created: YYYY-MM-DD
updated: YYYY-MM-DD
external_dependencies: []
task_list_gate_mode: gated
author_gate_mode: gated
finding_gate_mode: gated
planning:
  phase: 1
  task: ~
---
```

| Field | Set when |
|-------|----------|
| `topic` | Plan creation (Step 1) |
| `status` | Plan creation → `planning`; conclusion → `concluded` |
| `format` | Plan creation — user-chosen output format |
| `work_type` | Plan creation — set by caller if known. Values: `greenfield`, `feature`, `bugfix`. Defaults to `greenfield` when empty. |
| `ext_id` | First task authored — external identifier for the plan |
| `specification` | Plan creation — relative path to source specification |
| `cross_cutting_specs` | Plan creation — relative paths to cross-cutting specs (omit key if none) |
| `spec_commit` | Plan creation — `git rev-parse HEAD`; updated on continue if spec changed |
| `created` | Plan creation — today's date |
| `updated` | Plan creation — today's date; update on each commit |
| `external_dependencies` | Dependency resolution (Step 6) |
| `task_list_gate_mode` | Plan creation → `gated`; user opts in → `auto` |
| `author_gate_mode` | Plan creation → `gated`; user opts in → `auto` |
| `finding_gate_mode` | Plan creation → `gated`; user opts in → `auto` |
| `planning.phase` | Tracks current phase position |
| `planning.task` | Tracks current task position (`~` when between tasks) |
| `review_cycle` | Added by plan-review when review cycle begins |

---

## Title

```markdown
# Plan: {Topic Name}
```

---

## Phase Entry

```markdown
### Phase {N}: {Phase Name}
status: {status}
ext_id:
approved_at: {YYYY-MM-DD}

**Goal**: {What this phase accomplishes}

**Why this order**: {Why this comes at this position}

**Acceptance**:
- [ ] {First verifiable criterion}
- [ ] {Second verifiable criterion}
```

| Field | Set when |
|-------|----------|
| `status` | Phase design → `draft`; approval → `approved` |
| `ext_id` | First task in phase authored — external identifier for the phase |
| `approved_at` | Phase approval — today's date. Omit while `draft`. |

---

## Task Table

```markdown
#### Tasks
| ID | Name | Edge Cases | Status | Ext ID |
|----|------|------------|--------|--------|
| {topic}-{phase}-{seq} | {Task Name} | {comma-separated list, or "none"} | {status} | |
```

| Field | Set when |
|-------|----------|
| `ID` | Task design — format: `{topic}-{phase}-{seq}` |
| `Name` | Task design — descriptive task name |
| `Edge Cases` | Task design — curated list scoping which edge cases this task handles |
| `Status` | Task design → `pending`; authoring → `authored` |
| `Ext ID` | Task authored — external identifier for the task |
