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

## Step 1: Read Specification

Read the specification **in full**. Not a scan, not a summary — read every section, every decision, every edge case. The specification must be fully digested before any structural decisions are made.

The specification contains validated decisions. Your job is to translate it into an actionable plan, not to review or reinterpret it.

**The specification is your sole input.** Everything you need is in the specification — do not reference other documents or prior source materials.

From the specification, absorb:
- Key decisions and rationale
- Architectural choices
- Edge cases identified
- Constraints and requirements
- Whether a Dependencies section exists (you will handle these in Step 5)

Do not present or summarize the specification back to the user — it has already been signed off. Proceed directly to Step 2.

---

## Step 2: Define Phases

With the full specification understood, break it into logical phases:
- Each independently testable
- Each has acceptance criteria
- Progression: Foundation → Core → Edge cases → Refinement

Understanding what tasks belong in each phase is necessary to determine the right ordering. Consider the natural dependencies between areas of functionality — what must exist before something else can be built. This informs both phase boundaries and phase sequence.

Present the proposed phase structure using this format:

```
Phase {N}: {Phase Name}
  Goal: {What this phase accomplishes}
  Why this order: {Why this phase comes at this position in the sequence}
  Acceptance criteria:
    - [ ] {First verifiable criterion}
    - [ ] {Second verifiable criterion}
```

**Example:**

```
Phase 1: Foundation — Event Model and Storage
  Goal: Establish the core data model and persistence layer for calendar events
  Why this order: All subsequent phases depend on events being storable and retrievable
  Acceptance criteria:
    - [ ] Events can be created with required fields (title, start, end)
    - [ ] Events persist to the database and can be retrieved by ID
    - [ ] Validation rejects events with missing required fields

Phase 2: Core — Recurring Events
  Goal: Support recurring event patterns (daily, weekly, monthly)
  Why this order: Recurrence extends the event model from Phase 1
  Acceptance criteria:
    - [ ] Events can be created with a recurrence rule
    - [ ] Recurring instances are generated correctly for a given date range
    - [ ] Editing a single instance does not affect other instances
```

**STOP.** Present your proposed phase structure and wait for user confirmation before proceeding. Do not proceed.

---

## Step 3: Present Phase Task Overview

Take the first (or next) phase and break it into tasks. Present a high-level overview so the user can see the shape of the phase before committing to the detail of each task.

Present the task overview using this format:

```
Phase {N}: {Phase Name}

  1. {Task Name} — {One-line summary}
     Edge cases: {comma-separated list, or "none"}

  2. {Task Name} — {One-line summary}
     Edge cases: {comma-separated list, or "none"}
```

**Example:**

```
Phase 1: Foundation — Event Model and Storage

  1. Create Event model and migration — Define the events table and Eloquent model with required fields
     Edge cases: none

  2. Implement event creation endpoint — POST /api/events with validation and persistence
     Edge cases: overlapping time ranges, past dates

  3. Implement event retrieval — GET /api/events/{id} and GET /api/events with date filtering
     Edge cases: empty result sets, invalid date ranges
```

This overview establishes the scope and ordering. The user should be able to see whether the phase is well-structured, whether tasks are in the right order, and whether anything is missing or unnecessary — before investing time in writing out full task detail.

**STOP.** Present the phase task overview and wait for user confirmation. Do not proceed to task detail until the task list is agreed.

---

## Step 4: Detail, Approve, and Log Each Task

Work through the agreed task list **one task at a time**. For each task:

#### 1. Present the Full Task

Write the complete task using the required template (Problem, Solution, Outcome, Do, Acceptance Criteria, Tests, Context) — see [Task Design](#task-design) for the required structure and field requirements.

Present it to the user **in the format it will be written to the plan**. The output format adapter determines the exact format. What the user sees is what gets logged — no changes between approval and writing.

#### 2. Discuss If Needed

The user may:
- Request adjustments to the task content
- Ask questions about scope, granularity, or approach
- Flag that something doesn't match the specification
- Identify missing edge cases or acceptance criteria

Incorporate feedback and re-present the updated task. Repeat until the user is satisfied.

#### 3. Approve

Wait for explicit approval before logging. The user confirms the task is ready to be written.

#### 4. Log

Write the approved task to the plan — verbatim, as presented. Do not modify content between approval and writing. The output format adapter determines how tasks are written (appending markdown, creating issues, etc.).

#### 5. Next Task

Move to the next task in the phase. Present it, discuss, approve, log. Continue until all tasks in the phase are logged.

#### Phase Complete

After all tasks in the current phase are logged:

```
Phase {N}: {Phase Name} — complete ({M} tasks logged).
```

Then return to **Step 3** for the next phase.

**Repeat Steps 3–4 for each phase** until all phases are complete.

---

## Step 5: Resolve External Dependencies

After all phases are detailed and written, handle external dependencies — things this plan needs from other topics or systems.

#### If the specification has a Dependencies section

The specification's Dependencies section lists what this feature needs from outside its own scope. These must be documented in the plan so implementation knows what is blocked and what is available.

1. **Document each dependency** in the plan's External Dependencies section using the format described in [dependencies.md](dependencies.md). Initially, record each as unresolved.

2. **Resolve where possible** — For each dependency, check whether a plan already exists for that topic:
   - If a plan exists, identify the specific task(s) that satisfy the dependency. Query the output format to find relevant tasks. If ambiguous, ask the user which tasks apply. Update the dependency entry from unresolved → resolved with the task reference.
   - If no plan exists, leave the dependency as unresolved. It will be linked later via `/link-dependencies` or when that topic is planned.

3. **Reverse check** — Check whether any existing plans have unresolved dependencies that reference *this* topic. Now that this plan exists with specific tasks:
   - Scan other plan files for External Dependencies entries that mention this topic
   - For each match, identify which task(s) in the current plan satisfy that dependency
   - Update the other plan's dependency entry with the task reference (unresolved → resolved)

#### If the specification has no Dependencies section

Document this explicitly in the plan:

```markdown
## External Dependencies

No external dependencies.
```

This makes it clear that dependencies were considered and none exist — not that they were overlooked.

#### If no other plans exist

Skip the resolution and reverse check — there is nothing to resolve against. Document the dependencies as unresolved. They will be linked when other topics are planned, or via `/link-dependencies`.

**STOP.** Present a summary of the dependency state: what was documented, what was resolved, what remains unresolved, and any reverse resolutions made. Wait for user confirmation before proceeding.

---

## Step 6: Plan Review

After all phases are detailed, confirmed, and dependencies are documented, perform the comprehensive two-phase review. This is the most important quality gate in the planning process — it ensures the plan faithfully represents the specification and is structurally ready for implementation.

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

**Location**: Store tracking files alongside the plan file:
- `{topic}-review-traceability-tracking.md` — Phase 1 findings
- `{topic}-review-integrity-tracking.md` — Phase 2 findings

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

## Commit Frequently

Commit planning docs at natural breaks, after significant progress, and before any context refresh.

Context refresh = memory loss. Uncommitted work = lost work.

## Output

Load the appropriate output adapter (linked from the main skill file) for format-specific structure and templates.
