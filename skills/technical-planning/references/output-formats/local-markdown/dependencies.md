# Local Markdown: Dependencies

## Dependency Format

Cross-topic dependencies link tasks between different plan files. This is how you express "this feature depends on the billing system being implemented."

In the External Dependencies section of the Plan Index File, use the format `{topic}: {description} → {task-id}`:

```markdown
## External Dependencies

- billing-system: Invoice generation → billing-1-2 (resolved)
- authentication: User context → auth-2-1 (resolved)
- payment-gateway: Payment processing (unresolved - not yet planned)
```

## Creating Dependencies

For local markdown plans, reference tasks using the task ID (e.g., `billing-1-2`). The task file is at `docs/workflow/planning/{topic}/{task-id}.md`.

To wire up a dependency:
1. Update the External Dependencies section with the task reference and `(resolved)` marker
2. No format-level blocking mechanism — dependencies are tracked via the External Dependencies section

## Querying Dependencies

Use these queries to understand the dependency graph for implementation blocking and `/link-dependencies`.

### Find Plans With External Dependencies

```bash
# Find all plans with external dependencies
grep -l "## External Dependencies" docs/workflow/planning/*.md

# Find unresolved dependencies (no arrow →)
grep -A 10 "## External Dependencies" docs/workflow/planning/*.md | grep "^- " | grep -v "→"
```

### Find Dependencies on a Specific Topic

```bash
# Find plans that depend on billing-system
grep -l "billing-system:" docs/workflow/planning/*.md
```

### Check if a Task Exists

```bash
# Check if task file exists
ls docs/workflow/planning/billing-system/billing-1-2.md
```

### Check if a Task is Complete

Read the task file and check the status in frontmatter:

```bash
# Check task status
grep "status:" docs/workflow/planning/billing-system/billing-1-2.md
```
