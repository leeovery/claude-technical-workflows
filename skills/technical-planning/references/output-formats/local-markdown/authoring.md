# Local Markdown: Authoring

## Plan Index Template

Create `docs/workflow/planning/{topic}.md` with this structure:

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

## Task Writing

Each authored task is written to `{topic}/{task-id}.md` using canonical field names:

```markdown
---
id: {topic}-{phase}-{seq}
phase: {phase-number}
status: pending
created: YYYY-MM-DD  # Use today's actual date
---

# {Task Name}

**Problem**: {Why this task exists — include rationale from specification}

**Solution**: {What we're building — the high-level approach}

**Outcome**: {What success looks like — the verifiable end state}

**Do**:
- {Specific implementation steps}
- {File locations and method names where helpful}

**Acceptance Criteria**:
- [ ] {Pass/fail criterion}
- [ ] {Pass/fail criterion}

**Tests**:
- `"{test name}"`
- `"{test name}"`

**Edge Cases**:
- {Boundary conditions for this task}

**Context**:
> {Relevant decisions and constraints from specification}

**Spec Reference**: `docs/workflow/specification/{topic}.md`
```

After writing:
1. Update the task table in the Plan Index File: set `status: authored`
2. Advance the `planning:` block in frontmatter to the next pending task (or next phase)

## Flagging

When information is missing, mark in the task table:

```markdown
| ID | Name | Edge Cases | Status |
|----|------|------------|--------|
| auth-1-3 | Configure rate limiting | [needs-info] threshold, per-user vs per-IP | pending |
```

And in the task file, add:

```markdown
**Needs Clarification**:
- What's the rate limit threshold?
- Per-user or per-IP?
```

## Cleanup (Restart)

Delete the task detail directory for this topic:

```bash
rm -rf docs/workflow/planning/{topic}/
```
