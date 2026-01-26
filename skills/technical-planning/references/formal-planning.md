# Formal Planning

*Reference for **[technical-planning](../SKILL.md)***

---

You are creating the formal implementation plan from the specification.

## Before You Begin

**Confirm output format with user.** Ask which format they want, then load the appropriate output adapter from the main skill file. If you don't know which format, ask.

## Planning is a Gated Process

Planning translates the specification into actionable structure. This translation requires judgment, and the process is designed to ensure that judgment is exercised carefully and collaboratively — not rushed.

### Process Expectations

**This is a step-by-step process with mandatory stop points.** You must work through each step sequentially. Steps end with **STOP** — you must present your work, wait for explicit user confirmation, and only then proceed to the next step.

**Never one-shot the plan.** Do not write the entire plan document in a single operation. The plan is built incrementally — one phase at a time, with the user confirming the structure at each stage. A one-shot plan that misses requirements, hallucinates content, or structures tasks poorly wastes more time than a careful, step-by-step process. Go slow to go fast.

**Stop and ask when judgment is needed.** Planning is collaborative — not in the sense that every line needs approval, but in the sense that the user guides structural decisions and resolves ambiguity. You must stop and ask when:

- The specification is ambiguous about implementation approach
- Multiple valid ways to structure phases or tasks exist
- You're uncertain whether a task is appropriately scoped
- Edge cases aren't fully addressed in the specification
- You need to make any decision the specification doesn't cover
- Something doesn't add up or feels like a gap

**Never invent to fill gaps.** If the specification doesn't address something, flag it with `[needs-info]` and ask the user. The specification is the golden document — everything in the plan must trace back to it. Assuming or guessing — even when it seems reasonable — is not acceptable. Surface the problem immediately rather than continuing and hoping to address it later.

---

## Step 1: Read Specification and Define Phases

Read the specification (`docs/workflow/specification/{topic}.md`) **in full**. Do not summarize it — work from the complete document throughout the planning process. The specification has already been validated and signed off. Your job is to translate it into an actionable plan, not to review or reinterpret it.

From the specification, extract:
- Key decisions and rationale
- Architectural choices
- Edge cases identified
- Constraints and requirements
- **External dependencies** (from the Dependencies section)

**The specification is your sole input.** Prior source materials have already been validated, filtered, and enriched into the specification. Everything you need is in the specification — do not reference other documents.

#### Extract External Dependencies

The specification's Dependencies section lists things this feature needs from other topics/systems. These are **external dependencies** — things outside this plan's scope that must exist for implementation to proceed.

Copy these into the plan index file (see "External Dependencies Section" below). During planning:

1. **Check for existing plans**: For each dependency, search `docs/workflow/planning/` for a matching topic
2. **If plan exists**: Try to identify specific tasks that satisfy the dependency. Query the output format to find relevant tasks. If ambiguous, ask the user which tasks apply.
3. **If no plan exists**: Record the dependency in natural language — it will be linked later via `/link-dependencies` or when that topic is planned.

**Optional reverse check**: Ask the user: "Would you like me to check if any existing plans depend on this topic?"

If yes:
1. Scan other plan indexes for External Dependencies that reference this topic
2. For each match, identify which task(s) in the current plan satisfy that dependency
3. Update the other plan's dependency entry with the task ID (unresolved → resolved)

Alternatively, the user can run `/link-dependencies` later to resolve dependencies across all plans in bulk.

#### Define Phases

Break the specification into logical phases:
- Each independently testable
- Each has acceptance criteria
- Progression: Foundation → Core → Edge cases → Refinement

Present the proposed phase structure. For each phase, show:
- Phase name and goal
- What it accomplishes and why it comes in this order
- High-level acceptance criteria

**STOP.** Present your proposed phase structure and wait for user confirmation before breaking phases into tasks. Do not proceed.

---

## Step 2: Detail Each Phase

Work through phases **one at a time**, in order. For each phase:

1. **Break the phase into tasks** — each task is one TDD cycle (one thing to build, one test to prove it)
2. **Write the full task template** for each task (Problem, Solution, Outcome, Do, Acceptance Criteria, Tests, Context) — see [Task Design](#task-design) for the required structure and field requirements
3. **Address edge cases** relevant to this phase — each gets its own task or is explicitly handled within a task
4. **Add code examples** only for novel patterns not obvious to implement
5. **Flag anything unclear** with `[needs-info]` — do not guess or invent

Present the phase's tasks to the user. For each task, show the full template. Highlight:
- How tasks are ordered and any dependencies between them
- Edge cases covered
- Any `[needs-info]` flags that need resolution

**STOP.** Present the phase's tasks and wait for user confirmation before proceeding to the next phase. Do not proceed.

**Write the confirmed phase to the plan file before starting the next phase.** The plan grows incrementally — phase by phase, not all at once. Repeat this step for each phase.

---

## Step 3: Plan Review

After all phases are detailed and confirmed, perform the comprehensive two-phase review. This is the most important quality gate in the planning process — it ensures the plan faithfully represents the specification and is structurally ready for implementation.

**This review is not optional.** See [Plan Review](#plan-review) below for the full process.

---

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

Within a bounded feature, vertical slicing means each task completes a coherent unit of that feature's functionality - not that it must touch UI/API/database layers. The test is: *can this task be verified independently?*

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

## Plan Review

After completing the plan, perform a comprehensive two-phase review before handing off to implementation.

**Why this matters**: The plan is what gets built. If content was hallucinated into the plan, it will be implemented — building something that was never discussed or validated. If specification content was missed, it won't be built. The entire purpose of this workflow is that artifacts carry validated decisions through to implementation. The plan is the final gate before code is written.

**This review is not optional.** It is the most important quality gate in the planning process.

### Review Tracking Files

To ensure analysis isn't lost during context refresh, create tracking files that capture findings. These files persist analysis so work can continue across sessions.

**Location**: Store tracking files alongside the plan:
- `docs/workflow/planning/{topic}-review-traceability-tracking.md` — Phase 1 findings
- `docs/workflow/planning/{topic}-review-integrity-tracking.md` — Phase 2 findings

**Format**:
```markdown
---
status: in-progress | complete
created: YYYY-MM-DD
phase: Traceability Review | Plan Integrity Review
topic: [Topic Name]
---

# Review Tracking: [Topic Name] - [Phase]

## Findings

### 1. [Brief Title]

**Type**: Missing from plan | Hallucinated content | Incomplete coverage | Structural issue | Weak criteria | ...
**Spec Reference**: [Section/decision in specification, or "N/A" for integrity findings]
**Plan Reference**: [Phase/task in plan, or "N/A" for missing content]

**Details**:
[What was found and why it matters]

**Proposed Fix**:
[What should change in the plan — leave blank until discussed]

**Resolution**: Pending | Fixed | Adjusted | Skipped
**Notes**: [Discussion notes or adjustments]

---

### 2. [Next Finding]
...
```

**Workflow with Tracking Files**:
1. Complete your analysis and create the tracking file with all findings
2. Present the summary to the user (from the tracking file)
3. Work through items one at a time:
   - Present the finding
   - Discuss and agree on the fix
   - Apply the fix to the plan
   - Update the tracking file: mark resolution, add notes
4. After all items resolved, delete the tracking file
5. Proceed to the next phase (or completion)

**Why tracking files**: If context refreshes mid-review, you can read the tracking file and continue where you left off. The tracking file shows which items are resolved and which remain.

---

### Phase 1: Traceability Review

Compare the plan against the specification **in both directions** to ensure complete, faithful translation.

#### Direction 1: Specification → Plan (completeness)

Is everything from the specification represented in the plan?

1. **Re-read the entire specification** — Don't rely on memory. Read it as if seeing it for the first time.

2. **For each specification element, verify plan coverage**:
   - Every decision → has a task that implements it
   - Every requirement → has a task with matching acceptance criteria
   - Every edge case → has a task or is explicitly handled within a task
   - Every constraint → is reflected in the relevant tasks
   - Every data model or schema → appears in the relevant tasks
   - Every integration point → has a task that addresses it
   - Every validation rule → has a task with test coverage

3. **Check depth of coverage** — It's not enough that a spec topic is *mentioned* in a task. The task must contain enough detail that an implementer wouldn't need to go back to the specification. Summarizing and rewording is fine, but the essence and instruction must be preserved.

#### Direction 2: Plan → Specification (fidelity)

Is everything in the plan actually from the specification? This is the anti-hallucination check.

1. **For each task, trace its content back to the specification**:
   - The Problem statement → ties to a spec requirement or decision
   - The Solution approach → matches the spec's architectural choices
   - The implementation details → come from the spec, not invention
   - The acceptance criteria → verify spec requirements, not made-up ones
   - The tests → cover spec behaviors, not imagined scenarios
   - The edge cases → are from the spec, not invented

2. **Flag anything that cannot be traced**:
   - Content that has no corresponding specification section
   - Technical approaches not discussed in the specification
   - Requirements or behaviors not mentioned anywhere in the spec
   - Edge cases the specification never identified
   - Acceptance criteria testing things the specification doesn't require

3. **The standard for hallucination**: If you cannot point to a specific part of the specification that justifies a piece of plan content, it is hallucinated. It doesn't matter how reasonable it seems — if it wasn't discussed and validated, it doesn't belong in the plan.

#### Presenting Traceability Findings

After completing your review:

1. **Create the tracking file** — Write all findings to `{topic}-review-traceability-tracking.md`
2. **Commit the tracking file** — Ensures it survives context refresh
3. **Present findings** in two stages:

**Stage 1: Summary**

> "I've completed the traceability review comparing the plan against the specification. I found [N] items:
>
> 1. **[Brief title]** (Missing from plan | Hallucinated | Incomplete)
>    [2-4 line explanation: what's wrong, where in the spec/plan, why it matters]
>
> 2. **[Brief title]** (Missing from plan | Hallucinated | Incomplete)
>    [2-4 line explanation]
>
> Let's work through these one at a time, starting with #1."

**Stage 2: Process One Item at a Time**

For each item:

1. **Present** the finding in detail — what's wrong, the spec reference, the plan reference
2. **Discuss** the appropriate fix with the user
3. **Apply the fix** to the plan
4. **Update tracking file** — Mark resolution, add notes
5. **Move to next item**: "Moving to #2: [Brief title]..."

> **CHECKPOINT**: Each finding requires discussion and resolution before moving on. Do not batch fixes. Do not proceed to the next item until the current one is resolved (fixed, adjusted, or explicitly skipped by the user).

#### What You're NOT Doing in Phase 1

- **Not adding new requirements** — If something isn't in the spec, the fix is to remove it from the plan or flag it with `[needs-info]`, not to justify its inclusion
- **Not expanding scope** — Missing spec content should be added as tasks; it shouldn't trigger re-architecture of the plan
- **Not being lenient with hallucinated content** — If it can't be traced to the specification, it must be removed or the user must explicitly approve it as an intentional addition
- **Not re-litigating spec decisions** — The specification reflects validated decisions; you're checking the plan's fidelity to them

#### Completing Phase 1

When you've:
- Verified every specification element has plan coverage
- Verified every plan element traces to the specification
- Resolved all findings with the user
- Updated the tracking file with all resolutions

**Delete the Phase 1 tracking file** (`{topic}-review-traceability-tracking.md`) — it has served its purpose.

Inform the user Phase 1 is complete and proceed to Phase 2: Plan Integrity Review.

---

### Phase 2: Plan Integrity Review

Review the plan **as a standalone document** for structural quality, implementation readiness, and adherence to planning standards.

**Purpose**: Ensure that the plan itself is well-structured, complete, and ready for implementation. An implementer (human or AI) should be able to pick up this plan and execute it without ambiguity, without needing to make design decisions, and without referring back to the specification.

**Key distinction**: Phase 1 checked *what's in the plan* against the spec. Phase 2 checks *how it's structured* — looking inward at the plan's own quality.

#### What to Look For

1. **Task Template Compliance**
   - Every task has all required fields: Problem, Solution, Outcome, Do, Acceptance Criteria, Tests
   - Problem statements clearly explain WHY the task exists
   - Solution statements describe WHAT we're building
   - Outcome statements define what success looks like
   - Acceptance criteria are concrete and verifiable (not vague)
   - Tests include edge cases, not just happy paths

2. **Vertical Slicing**
   - Tasks deliver complete, testable functionality
   - No horizontal slicing (all models, then all services, then all wiring)
   - Each task can be verified independently
   - Each task is a single TDD cycle

3. **Phase Structure**
   - Phases follow logical progression (Foundation → Core → Edge cases → Refinement)
   - Each phase has clear acceptance criteria
   - Each phase is independently testable
   - Phase boundaries make sense (not arbitrary groupings)

4. **Dependencies and Ordering**
   - Phase ordering reflects actual dependencies
   - Tasks within phases are ordered logically
   - Cross-phase dependencies are explicit where they exist
   - No circular dependencies
   - An implementer can infer execution order from the plan structure

5. **Task Self-Containment**
   - Each task contains all context needed for execution
   - No task requires reading other tasks to understand what to do
   - Relevant specification decisions are pulled into task context
   - An implementer could pick up any single task and execute it

6. **Scope and Granularity**
   - Each task is one TDD cycle (not too large, not too small)
   - No task requires multiple unrelated implementation steps
   - No task is so granular it's just mechanical boilerplate

7. **Acceptance Criteria Quality**
   - Criteria are pass/fail, not subjective
   - Criteria cover the actual requirement, not just "code exists"
   - Edge case criteria are specific about boundary values and behaviors
   - No criteria that an implementer would have to interpret

8. **External Dependencies**
   - All external dependencies from the specification are documented in the plan
   - Dependencies are in the correct state (resolved/unresolved)
   - No external dependencies were missed or invented

#### The Review Process

1. **Read the plan end-to-end** — Carefully, as if you were about to implement it
2. **For each phase**: Check structure, acceptance criteria, logical progression
3. **For each task**: Check template compliance, self-containment, granularity
4. **For the plan overall**: Check dependencies, ordering, external dependencies
5. **Collect findings** and categorize by severity:
   - **Critical**: Would block implementation or cause incorrect behavior
   - **Important**: Would force implementer to guess or make design decisions
   - **Minor**: Polish or improvement that strengthens the plan
6. **Create the tracking file** — Write findings to `{topic}-review-integrity-tracking.md`
7. **Commit the tracking file**

#### Presenting Integrity Findings

Follow the same two-stage pattern:

**Stage 1: Summary**

> "I've completed the plan integrity review. I found [N] items:
>
> 1. **[Brief title]** (Critical/Important/Minor)
>    [2-4 line explanation: what the issue is, why it matters for implementation]
>
> 2. **[Brief title]** (Critical/Important/Minor)
>    [2-4 line explanation]
>
> Let's work through these one at a time, starting with #1."

**Stage 2: Process One Item at a Time**

Same workflow as Phase 1: present → discuss → fix → update tracking → next.

> **CHECKPOINT**: Each finding requires discussion and resolution. Do not batch fixes.

#### What You're NOT Doing in Phase 2

- **Not redesigning the plan** — You're checking quality, not re-architecting
- **Not adding content from outside the spec** — If a task needs more detail, the detail must come from the specification
- **Not gold-plating** — Focus on issues that would actually impact implementation
- **Not second-guessing phase structure** — Unless it's fundamentally broken, the structure stands

#### Completing Phase 2

When you've:
- Reviewed the plan for structure, quality, and implementation readiness
- Resolved all critical and important findings with the user
- Updated the tracking file with all resolutions

**Delete the Phase 2 tracking file** (`{topic}-review-integrity-tracking.md`).

Both review phases are now complete. Proceed to Completion.

---

### Completion

After both review phases:

1. **Verify tracking files are deleted** — Both traceability and integrity tracking files must be gone

2. **Final quality confirmation**:
   - All specification content has plan coverage (Phase 1)
   - No hallucinated content remains (Phase 1)
   - All tasks follow the required template (Phase 2)
   - Dependencies are documented and ordered (Phase 2)
   - External dependencies match specification (Phase 2)

3. **Ask for sign-off**:

> "The plan has passed both review phases:
> - **Traceability**: All specification content is covered; no hallucinated content
> - **Integrity**: Plan structure, tasks, and dependencies are implementation-ready
>
> Ready to mark the plan as complete?"

4. **Update plan status** — After user confirms, update the plan frontmatter to `status: concluded`

5. **Final commit** — Commit the concluded plan

> **CHECKPOINT**: Do not proceed to sign-off if tracking files still exist. They indicate incomplete review work.

## External Dependencies Section

The plan index file must include an External Dependencies section. See **[dependencies.md](dependencies.md)** for the format, states, and how they affect implementation.

## Commit Frequently

Commit planning docs at natural breaks, after significant progress, and before any context refresh.

Context refresh = memory loss. Uncommitted work = lost work.

## Output

Load the appropriate output adapter (linked from the main skill file) for format-specific structure and templates.
