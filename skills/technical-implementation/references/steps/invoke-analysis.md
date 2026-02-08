# Invoke Analysis Agents

*Reference for **[technical-implementation](../../SKILL.md)***

---

This step dispatches the three analysis agents in parallel to evaluate the completed implementation from different perspectives: duplication, standards conformance, and architecture.

---

## Identify Scope

Build the list of implementation files using git history:

```bash
git log --oneline --name-only --pretty=format: --grep="impl({topic}):" | sort -u | grep -v '^$'
```

This captures all files touched by implementation commits for the topic.

---

## Dispatch All Three Agents

Dispatch **all three in parallel** via the Task tool. Each agent receives the same base inputs:

1. **Implementation files** — the file list from scope identification
2. **Specification path** — from the plan's frontmatter (if available)
3. **Project skill paths** — from `project_skills` in the implementation tracking file
4. **code-quality.md path** — `../code-quality.md`

### Agent 1: Duplication

- **Agent path**: `../../../../agents/implementation-analysis-duplication.md`
- **Output file**: `docs/workflow/implementation/{topic}-analysis-duplication.md`

### Agent 2: Standards

- **Agent path**: `../../../../agents/implementation-analysis-standards.md`
- **Output file**: `docs/workflow/implementation/{topic}-analysis-standards.md`

### Agent 3: Architecture

- **Agent path**: `../../../../agents/implementation-analysis-architecture.md`
- **Output file**: `docs/workflow/implementation/{topic}-analysis-architecture.md`

---

## Wait for Completion

**STOP.** Do not proceed until all three agents have returned their findings.

Write each agent's output to its respective file in `docs/workflow/implementation/`.

If any agent fails (error, timeout), record the failure and continue with the remaining agents' findings. Do not re-invoke failed agents — proceed with whatever findings are available.

---

## Expected Output

Each agent returns a structured report:

```
AGENT: {name}
FINDINGS:
- FINDING: {title}
  SEVERITY: high | medium | low
  FILES: {file:line, file:line}
  DESCRIPTION: {what's wrong}
  RECOMMENDATION: {what to do about it}
SUMMARY: {1-3 sentences}
```

Or `FINDINGS: none` if no issues were found.
