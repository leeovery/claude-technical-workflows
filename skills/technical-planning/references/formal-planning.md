# Formal Planning

*Reference for **[technical-planning](../SKILL.md)***

---

You are creating the formal implementation plan from the specification.

## Before You Begin

**Confirm output format with user.** Ask which format they want, then load the appropriate output adapter from the main skill file. If you don't know which format, ask.

## The Planning Process

### 1. Read Specification

From the specification (`docs/workflow/specification/{topic}.md`), extract:
- Key decisions and rationale
- Architectural choices
- Edge cases identified
- Constraints and requirements
- **External dependencies** (from the Dependencies section)

**The specification is your sole input.** Discussion documents and other source materials have already been validated, filtered, and enriched during the specification phase. Everything you need is in the specification - do not reference other documents.

#### Extract External Dependencies

The specification's Dependencies section lists things this feature needs from other topics/systems. These are **external dependencies** - things outside this plan's scope that must exist for implementation to proceed.

Copy these into the plan index file (see "External Dependencies Section" below). During planning:

1. **Check for existing plans**: For each dependency, search `docs/workflow/planning/` for a matching topic
2. **If plan exists**: Try to identify specific tasks that satisfy the dependency. Query the output format to find relevant tasks. If ambiguous, ask the user which tasks apply.
3. **If no plan exists**: Record the dependency in natural language - it will be linked later via `/link-dependencies` or when that topic is planned.

**Optional reverse check**: Ask the user: "Would you like me to check if any existing plans depend on this topic?" If yes, scan other plan indexes for dependencies that reference this topic and offer to wire them up.

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
- [ ] External dependencies documented in plan index

## External Dependencies Section

The plan index file must include an External Dependencies section. This tracks dependencies on other topics that must be satisfied before implementation can proceed.

### Format

```markdown
## External Dependencies

- billing-system: Invoice generation for order completion
- user-authentication: User context for permissions → beads-9m3p (resolved)
- ~~payment-gateway: Payment processing~~ → satisfied externally
```

### States

| State | Format | Meaning |
|-------|--------|---------|
| Unresolved | `- {topic}: {description}` | Dependency exists but not yet linked to a task |
| Resolved | `- {topic}: {description} → {task-id}` | Linked to specific task in another plan |
| Satisfied externally | `- ~~{topic}: {description}~~ → satisfied externally` | Implemented outside workflow |

### Resolution

Dependencies move from unresolved → resolved when:
- The dependency topic is planned and you identify the specific task
- The `/link-dependencies` command finds and wires the match

Dependencies become "satisfied externally" when:
- The user confirms it was implemented outside the workflow
- It already exists in the codebase
- It's a third-party system that's already available

### Why This Matters

The `start-implementation` command checks this section before allowing implementation to proceed. Unresolved or incomplete dependencies **block implementation** - like trying to put a roof on a house before the walls are built.

## Commit Frequently

Commit planning docs at natural breaks, after significant progress, and before any context refresh.

Context refresh = memory loss. Uncommitted work = lost work.

## Output

Load the appropriate output adapter (linked from the main skill file) for format-specific structure and templates.
