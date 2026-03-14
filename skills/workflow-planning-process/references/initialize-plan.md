# Initialize Plan

*Reference for **[workflow-planning-process](../SKILL.md)***

---

Choose the Output Format.

Query the manifest for any existing plan format preference:

```bash
node .claude/skills/workflow-manifest/scripts/manifest.js get {work_unit}.planning format
```

#### If a phase-level format exists

Present the recommendation:

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
Existing plans use **{format}**. Use the same format for consistency?

- **`y`/`yes`** — Use {format}
- **`n`/`no`** — See all available formats
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

#### If no phase-level format exists or user declined

Read **[output-formats.md](output-formats.md)** and present each format to the user.

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
@foreach(format in output_formats)
{N}. **{format.name}** — {format.description}
   Best for: {format.best_for}
@endforeach

Select a format (enter number):
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

---

Once selected:

1. Capture the current git commit hash: `git rev-parse HEAD`
2. Create the Plan Index File at `.workflows/{work_unit}/planning/{topic}/planning.md` using the **Title** template from **[plan-index-schema.md](plan-index-schema.md)**.
3. Register planning and set metadata in the manifest:
   ```bash
   node .claude/skills/workflow-manifest/scripts/manifest.js init-phase {work_unit}.planning.{topic}
   node .claude/skills/workflow-manifest/scripts/manifest.js set {work_unit}.planning.{topic} format {chosen-format}
   node .claude/skills/workflow-manifest/scripts/manifest.js set {work_unit}.planning format {chosen-format}
   node .claude/skills/workflow-manifest/scripts/manifest.js set {work_unit}.planning.{topic} spec_commit {commit-hash}
   node .claude/skills/workflow-manifest/scripts/manifest.js set {work_unit}.planning.{topic} task_list_gate_mode gated
   node .claude/skills/workflow-manifest/scripts/manifest.js set {work_unit}.planning.{topic} author_gate_mode gated
   node .claude/skills/workflow-manifest/scripts/manifest.js set {work_unit}.planning.{topic} finding_gate_mode gated
   node .claude/skills/workflow-manifest/scripts/manifest.js set {work_unit}.planning.{topic} phase 1
   node .claude/skills/workflow-manifest/scripts/manifest.js set {work_unit}.planning.{topic} task ~
   ```

4. Commit: `planning({work_unit}): initialize plan`

→ Return to **[the skill](../SKILL.md)**.
