# Planning Scratch File Schema

*Reference for **[workflow-planning-process](../SKILL.md)***

---

This file defines the structure for planning scratch files used during phase and task design. Scratch files are temporary — they live at `.workflows/.cache/{work_unit}/planning/{topic}/` and are discarded after content is written to the output format.

All metadata (format, status, gate modes, progress tracking, `task_map`) is stored in the manifest via the manifest CLI.

---

## Phase Scratch File

Path: `.workflows/.cache/{work_unit}/planning/{topic}/phases.md`

```markdown
## Phases

### Phase {N}: {Phase Name}

**Goal**: {What this phase accomplishes}

**Why this order**: {Why this comes at this position}

**Acceptance**:
- [ ] {First verifiable criterion}
- [ ] {Second verifiable criterion}
```

After approval, phases are created in the output format immediately, their external IDs are recorded in `task_map`, and the scratch file is deleted.

---

## Task List Scratch File

Path: `.workflows/.cache/{work_unit}/planning/{topic}/phase-{N}-tasks.md`

```markdown
#### Tasks
| Internal ID | Name | Edge Cases |
|-------------|------|------------|
| {topic}-{phase_id}-{task_id} | {Task Name} | {comma-separated list, or "none"} |
```

| Field | Set when |
|-------|----------|
| `Internal ID` | Task design -- format: `{topic}-{phase_id}-{task_id}` (full topic name, never abbreviated) |
| `Name` | Task design -- descriptive task name |
| `Edge Cases` | Task design -- curated list scoping which edge cases this task handles |

Authored status is derived from `task_map` presence in the manifest — if an internal ID exists in `task_map`, it has been authored.

---

## Manifest Fields

All metadata is managed via the manifest CLI (`node .claude/skills/workflow-manifest/scripts/manifest.js`). The following fields are set during planning:

| Field (via `planning.{topic}`) | Set when |
|------------|----------|
| `status` | Plan creation -> `in-progress`; completion -> `completed` |
| `format` | Plan creation -- user-chosen output format |
| `spec_commit` | Plan creation -- `git rev-parse HEAD`; updated on continue if spec changed |
| `external_id` | First task authored -- external identifier for the plan |
| `task_map` | Task/phase authoring -- maps internal IDs to external IDs (object: `{ "topic-1-1": "ext-abc", ... }`) |
| `external_dependencies` | Dependency resolution (Step 7) |
| `task_list_gate_mode` | Plan creation -> `gated`; user opts in -> `auto` |
| `author_gate_mode` | Plan creation -> `gated`; user opts in -> `auto` |
| `finding_gate_mode` | Plan creation -> `gated`; user opts in -> `auto` |
| `phase` | Tracks current phase position |
| `task` | Tracks current task position (`~` when between tasks) |
| `review_cycle` | Added by plan-review when review cycle begins |
