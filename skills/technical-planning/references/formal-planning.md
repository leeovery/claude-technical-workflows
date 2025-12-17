# Formal Planning

*Reference for **[technical-planning](../SKILL.md)***

---

You are creating the formal implementation plan from the specification.

## Before You Begin

**Confirm output format with user.** Plans can be stored as:
- **Local Markdown** → See [output-local-markdown.md](output-local-markdown.md)
- **Linear** → See [output-linear.md](output-linear.md)
- **Backlog.md** → See [output-backlog-md.md](output-backlog-md.md)

If you don't know which format, ask.

## The Planning Process

### 1. Read Specification

From the specification (`docs/workflow/specification/{topic}.md`), extract:
- Key decisions and rationale
- Architectural choices
- Edge cases identified
- Constraints and requirements

**The specification is your sole input.** Discussion documents and other source materials have already been validated, filtered, and enriched during the specification phase. Everything you need is in the specification - do not reference other documents.

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

### 7. Review Against Specification

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
- [output-local-markdown.md](output-local-markdown.md) - Single `{topic}.md` file
- [output-linear.md](output-linear.md) - Linear project
- [output-backlog-md.md](output-backlog-md.md) - Backlog.md tasks
