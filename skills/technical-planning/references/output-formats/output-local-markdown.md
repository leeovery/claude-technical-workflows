# Output: Local Markdown

*Output adapter for **[technical-planning](../../SKILL.md)***

---

Use this format for simple features or when you want everything in a single version-controlled file with detailed task files.

## Benefits

- No external tools or dependencies required
- Plan Index File provides overview; task files provide detail
- Human-readable and easy to edit
- Works offline with any text editor
- Simplest setup - just create markdown files

## Setup

No external tools required. This format uses plain markdown files stored in the repository.

## Output Location

```
docs/workflow/planning/
├── {topic}.md                    # Plan Index File
└── {topic}/
    └── {task-id}.md              # Task detail files
```

The Plan Index File contains phases and task tables. Each authored task gets its own file in the `{topic}/` directory. Task filename = task ID for easy lookup.

## Plan Index Template

Create `{topic}.md` with this structure:

```markdown
---
topic: {feature-name}
status: planning
format: local-markdown
specification: ../specification/{topic}.md
cross_cutting_specs:              # Omit if none
  - ../specification/{spec}.md
spec_commit: {git-commit-hash}
created: YYYY-MM-DD  # Use today's actual date
updated: YYYY-MM-DD  # Use today's actual date
planning:
  phase: 1
  task: ~
---

# Plan: {Feature/Project Name}

## Overview

**Goal**: What we're building and why (one sentence)

**Done when**:
- Measurable outcome 1
- Measurable outcome 2

**Key Decisions** (from specification):
- Decision 1: Rationale
- Decision 2: Rationale

## Cross-Cutting References

Architectural decisions from cross-cutting specifications that inform this plan:

| Specification | Key Decisions | Applies To |
|---------------|---------------|------------|
| [Caching Strategy](../../specification/caching-strategy.md) | Cache API responses for 5 min; use Redis | Tasks involving API calls |
| [Rate Limiting](../../specification/rate-limiting.md) | 100 req/min per user; sliding window | User-facing endpoints |

*Remove this section if no cross-cutting specifications apply.*

## Phases

### Phase 1: {Name}
status: draft

**Goal**: What this phase accomplishes
**Why this order**: Why this comes at this position

**Acceptance**:
- [ ] Criterion 1
- [ ] Criterion 2

#### Tasks
| ID | Name | Edge Cases | Status |
|----|------|------------|--------|
| {topic}-1-1 | {Task Name} | {list} | pending |
| {topic}-1-2 | {Task Name} | {list} | pending |

---

### Phase 2: {Name}
status: draft

**Goal**: What this phase accomplishes
**Why this order**: Why this comes at this position

**Acceptance**:
- [ ] Criterion 1
- [ ] Criterion 2

#### Tasks
| ID | Name | Edge Cases | Status |
|----|------|------------|--------|

(Continue pattern for remaining phases)

---

## External Dependencies

[Dependencies on other topics - copy from specification's Dependencies section]

- {topic}: {description}
- {topic}: {description} → {task-reference} (resolved)
- ~~{topic}: {description}~~ → satisfied externally

## Log

| Date | Change |
|------|--------|
| YYYY-MM-DD *(use today's actual date)* | Created from specification |
```

## Task File Template

Each authored task is written to `{topic}/{task-id}.md`:

```markdown
---
id: {topic}-{phase}-{seq}
phase: {phase-number}
status: pending
created: YYYY-MM-DD  # Use today's actual date
---

# {Task Name}

## Goal

{What this task accomplishes and why — include rationale from specification}

## Implementation

{The "Do" — specific files, methods, approach}

## Tests

- `it does expected behavior`
- `it handles edge case`

## Edge Cases

{Specific edge cases for this task}

## Acceptance Criteria

- [ ] Test written and failing
- [ ] Implementation complete
- [ ] Tests passing
- [ ] Committed

## Context

{Relevant decisions and constraints from specification}

Specification reference: `docs/workflow/specification/{topic}.md` (for ambiguity resolution)
```

## Cross-Topic Dependencies

Cross-topic dependencies link tasks between different plan files. This is how you express "this feature depends on the billing system being implemented."

### In the External Dependencies Section

Use the format `{topic}: {description} → {task-id}` where task-id points to a specific task:

```markdown
## External Dependencies

- billing-system: Invoice generation → billing-1-2 (resolved)
- authentication: User context → auth-2-1 (resolved)
- payment-gateway: Payment processing (unresolved - not yet planned)
```

### Task References

For local markdown plans, reference tasks using the task ID (e.g., `billing-1-2`). The task file is at `{topic}/{task-id}.md`.

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

## Frontmatter

Plan Index Files use YAML frontmatter for metadata:

```yaml
---
topic: {feature-name}                    # Matches filename (without .md)
status: planning | concluded             # Planning status
format: local-markdown                   # Output format used
specification: ../specification/{topic}.md
cross_cutting_specs:                     # Omit if none
  - ../specification/{spec}.md
spec_commit: {git-commit-hash}        # Git commit when planning started
created: YYYY-MM-DD  # Use today's actual date
updated: YYYY-MM-DD  # Use today's actual date
planning:                                # Removed when concluded
  phase: 2
  task: 3
---
```

The `planning:` block tracks current progress position. It's removed when the plan is concluded.

## Flagging Incomplete Tasks

When information is missing, mark in the task table:

```markdown
| ID | Name | Edge Cases | Status |
|----|------|------------|--------|
| auth-1-3 | Configure rate limiting | [needs-info] threshold, per-user vs per-IP | pending |
```

And in the task file, add a "Needs Clarification" section:

```markdown
## Needs Clarification

- What's the rate limit threshold?
- Per-user or per-IP?
```

## Resulting Structure

After planning:

```
docs/workflow/
├── discussion/{topic}.md           # Discussion output
├── specification/{topic}.md        # Specification output
└── planning/
    ├── {topic}.md                  # Plan Index File (format: local-markdown)
    └── {topic}/
        ├── {topic}-1-1.md          # Task detail files
        ├── {topic}-1-2.md
        └── {topic}-2-1.md
```

## Implementation

### Reading Plans

1. Read the Plan Index File to get overview and task tables
2. For each task to implement, read `{topic}/{task-id}.md`
3. Follow phase order as written in the index
4. Check task status in the index table

### Updating Progress

- Update task file frontmatter `status: completed` when done
- Update the task table in the Plan Index File
- Check off phase acceptance criteria when all phase tasks complete

### Authoring Tasks (During Planning)

When a task is approved:
1. Create `{topic}/{task-id}.md` with the task content
2. Update the task table: set `status: authored`
3. Update the `planning:` block in frontmatter

### Cleanup (Restart)

Delete the task detail directory for this topic:

```bash
rm -rf docs/workflow/planning/{topic}/
```
