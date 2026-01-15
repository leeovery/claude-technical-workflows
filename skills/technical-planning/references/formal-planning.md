# Formal Planning

*Reference for **[technical-planning](../SKILL.md)***

---

You are creating the formal implementation plan from the specification.

## Before You Begin

**Confirm output format with user.** Ask which format they want, then load the appropriate output adapter from the main skill file. If you don't know which format, ask.

## Planning is Collaborative

Planning is an iterative process between you and the user. The research, discussion, and specification phases have done the heavy lifting - planning translates that work into actionable structure. But translation still requires judgment, and the user should guide that judgment.

**Stop, reflect, and ask** when:
- The specification is ambiguous about implementation approach
- Multiple valid ways to structure phases or tasks exist
- You're uncertain whether a task is appropriately scoped
- Edge cases aren't fully addressed in the specification

**Never invent to fill gaps.** If the specification doesn't address something, use `[needs-info]` and ask the user. The specification is the golden document - everything in the plan must trace back to it.

**The user expects collaboration.** Planning doesn't have to be done by the agent alone. It's normal and encouraged to pause for guidance rather than guess.

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

**Optional reverse check**: Ask the user: "Would you like me to check if any existing plans depend on this topic?"

If yes:
1. Scan other plan indexes for External Dependencies that reference this topic
2. For each match, identify which task(s) in the current plan satisfy that dependency
3. Update the other plan's dependency entry with the task ID (unresolved → resolved)

Alternatively, the user can run `/link-dependencies` later to resolve dependencies across all plans in bulk.

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

**One task = One TDD cycle**: write test → implement → pass → commit

### Task Structure

Every task should follow this structure:

```markdown
### Task N: [Clear action statement]

**Problem**: Why this task exists - what issue or gap it addresses.

**Solution**: What we're building - the high-level approach.

**Outcome**: What success looks like - the verifiable end state.

**Do**:
- Specific implementation steps
- File locations and method names where helpful
- Concrete guidance, not vague directions

**Acceptance Criteria**:
- [ ] First verifiable criterion
- [ ] Second verifiable criterion
- [ ] Edge case handling criterion

**Tests**:
- `"it does the primary expected behavior"`
- `"it handles edge case correctly"`
- `"it fails appropriately for invalid input"`

**Context**: (when relevant)
> Relevant details from specification: code examples, architectural decisions,
> data models, or constraints that inform implementation.
```

### Field Requirements

| Field | Required | Notes |
|-------|----------|-------|
| Problem | Yes | One sentence minimum - why this task exists |
| Solution | Yes | One sentence minimum - what we're building |
| Outcome | Yes | One sentence minimum - what success looks like |
| Do | Yes | At least one concrete action |
| Acceptance Criteria | Yes | At least one pass/fail criterion |
| Tests | Yes | At least one test name; include edge cases, not just happy path |
| Context | When relevant | Only include when spec has details worth pulling forward |

### The Template as Quality Gate

If you struggle to articulate a clear Problem for a task, this signals the task may be:

- **Too granular**: Merge with a related task
- **Mechanical housekeeping**: Include as a step within another task
- **Poorly understood**: Revisit the specification

Every standalone task should have a reason to exist that can be stated simply. The template enforces this - difficulty completing it is diagnostic information, not a problem to work around.

### Vertical Slicing

Prefer **vertical slices** that deliver complete, testable functionality over horizontal slices that separate by technical layer.

**Horizontal (avoid)**:
```
Task 1: Create all database models
Task 2: Create all service classes
Task 3: Wire up integrations
Task 4: Add error handling
```

Nothing works until Task 4. No task is independently verifiable.

**Vertical (prefer)**:
```
Task 1: Fetch and store events from provider (happy path)
Task 2: Handle pagination for large result sets
Task 3: Handle authentication token refresh
Task 4: Handle rate limiting
```

Each task delivers a complete slice of functionality that can be tested in isolation.

Within a bounded feature (e.g., "sync engine"), vertical slicing means each task completes a coherent unit of that feature's functionality - not that it must touch UI/API/database layers. The test is: *can this task be verified independently?*

TDD naturally encourages vertical slicing - when you think "what test can I write?", you frame work as complete, verifiable behavior rather than technical layers

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

The plan index file must include an External Dependencies section. See **[dependencies.md](dependencies.md)** for the format, states, and how they affect implementation.

## Commit Frequently

Commit planning docs at natural breaks, after significant progress, and before any context refresh.

Context refresh = memory loss. Uncommitted work = lost work.

## Output

Load the appropriate output adapter (linked from the main skill file) for format-specific structure and templates.
