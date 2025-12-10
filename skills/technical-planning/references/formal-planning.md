# Formal Planning

*Reference for **[technical-planning](../SKILL.md)** - Path B*

---

You are creating the formal implementation plan. This is either:
- Direct from source materials (discussion docs), OR
- After completing draft planning (from `draft-plan.md`)

## Before You Begin

**Confirm output format with user.** Plans can be stored as:
- **Local Markdown** → See [output-local-markdown.md](output-local-markdown.md)
- **Linear** → See [output-linear.md](output-linear.md)
- **Backlog.md** → See [output-backlog-md.md](output-backlog-md.md)

If you don't know which format, ask.

## The Planning Process

### 1. Read Source Material

From discussion docs or draft plan, extract:
- Key decisions and rationale
- Architectural choices
- Edge cases identified
- Constraints and requirements

### 2. Define Phases

Break into logical phases:
- Each independently testable
- Each has acceptance criteria
- Progression: Foundation → Core → Edge cases → Refinement

### 3. Break Phases into Tasks

Each task is one TDD cycle:
- One clear thing to build
- One test to prove it works

### 4. Write Micro Acceptance

For each task, name the test that proves completion. Implementation writes this test first.

### 5. Address Every Edge Case

Extract each edge case, create a task with micro acceptance.

### 6. Add Code Examples (if needed)

Only for novel patterns not obvious to implement.

### 7. Review Against Source

Verify:
- All decisions referenced
- All edge cases have tasks
- Each phase has acceptance criteria
- Each task has micro acceptance

## Phase Design

**Each phase should**:
- Be independently testable
- Have clear acceptance criteria (checkboxes)
- Provide incremental value

**Progression**: Foundation → Core functionality → Edge cases → Refinement

## Task Design

**Each task should**:
- Be a single TDD cycle
- Have micro acceptance (specific test name)
- Do one clear thing

**One task = One TDD cycle**: write test → implement → pass → commit

## Plan as Source of Truth

The plan IS the source of truth. Every phase, every task must contain all information needed to execute it.

- **Self-contained**: Each task executable without external context
- **No assumptions**: Spell out the context, don't assume implementer knows it

## Flagging Incomplete Tasks

When information is missing, mark it clearly with `[needs-info]`:

```markdown
### Task 3: Configure rate limiting [needs-info]

**Do**: Set up rate limiting for the API endpoint
**Test**: `it throttles requests exceeding limit`

**Needs clarification**:
- What's the rate limit threshold?
- Per-user or per-IP?
```

Planning is iterative. Create structure, flag gaps, refine.

## Quality Checklist

Before handing off to implementation:

- [ ] Clear phases with acceptance criteria
- [ ] Each phase has TDD-sized tasks
- [ ] Each task has micro acceptance (test name)
- [ ] All edge cases mapped to tasks
- [ ] Gaps flagged with `[needs-info]`

## Commit Frequently

Commit planning docs at natural breaks, after significant progress, and before any context refresh.

Context refresh = memory loss. Uncommitted work = lost work.

## Output

Load the appropriate output adapter for format-specific structure:
- [output-local-markdown.md](output-local-markdown.md) - Single plan.md file
- [output-linear.md](output-linear.md) - Linear project
- [output-backlog-md.md](output-backlog-md.md) - Backlog.md tasks
