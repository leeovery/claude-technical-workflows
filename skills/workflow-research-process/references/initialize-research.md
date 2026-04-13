# Initialize Research

*Reference for **[workflow-research-process](../SKILL.md)***

---

#### If source is `import`

1. Read each file listed in the handoff's Import files verbatim
2. Create the research file at the Output path using this structure:
   ```markdown
   # Research: {Title}

   Imported from existing research files.

   ## Starting Point

   Imported from:
   - {path_1}
   - {path_2}

   ---

   {Full verbatim content of first file}

   ---

   {Full verbatim content of second file, if multiple}
   ```
   **CRITICAL**: No summarization, no restructuring. Content is copied exactly as-is. If multiple files, separate with `---`.
3. Register in manifest:
   ```bash
   node .claude/skills/workflow-manifest/scripts/manifest.cjs init-phase {work_unit}.research.{topic}
   ```
4. Commit: `research({work_unit}): import {topic} research from existing files`

→ Return to caller.

#### Otherwise

1. Load **[template.md](template.md)** — use it to create the research file at the Output path from the handoff (e.g., `.workflows/{work_unit}/research/{resolved_filename}`)
2. Populate the Starting Point section with context from the handoff. If restarting (no Context in handoff), create with a minimal Starting Point — the session will gather context naturally
3. Register in manifest:
   ```bash
   node .claude/skills/workflow-manifest/scripts/manifest.cjs init-phase {work_unit}.research.{topic}
   ```
4. Commit the initial file

→ Return to caller.
