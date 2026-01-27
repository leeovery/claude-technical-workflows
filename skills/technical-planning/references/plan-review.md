# Plan Review

*Reference for **[formal-planning](formal-planning.md)***

---

After completing the plan, perform a comprehensive two-phase review before handing off to implementation.

**Why this matters**: The plan is what gets built. If content was hallucinated into the plan, it will be implemented — building something that was never discussed or validated. If specification content was missed, it won't be built. The entire purpose of this workflow is that artifacts carry validated decisions through to implementation. The plan is the final gate before code is written.

**This review is not optional.** It is the most important quality gate in the planning process.

## Review Tracking Files

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

## Phase 1: Traceability Review

Compare the plan against the specification **in both directions** to ensure complete, faithful translation.

### Direction 1: Specification → Plan (completeness)

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

### Direction 2: Plan → Specification (fidelity)

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

### Presenting Traceability Findings

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

### What You're NOT Doing in Phase 1

- **Not adding new requirements** — If something isn't in the spec, the fix is to remove it from the plan or flag it with `[needs-info]`, not to justify its inclusion
- **Not expanding scope** — Missing spec content should be added as tasks; it shouldn't trigger re-architecture of the plan
- **Not being lenient with hallucinated content** — If it can't be traced to the specification, it must be removed or the user must explicitly approve it as an intentional addition
- **Not re-litigating spec decisions** — The specification reflects validated decisions; you're checking the plan's fidelity to them

### Completing Phase 1

When you've:
- Verified every specification element has plan coverage
- Verified every plan element traces to the specification
- Resolved all findings with the user
- Updated the tracking file with all resolutions

**Delete the Phase 1 tracking file** (`{topic}-review-traceability-tracking.md`) — it has served its purpose.

Inform the user Phase 1 is complete and proceed to Phase 2: Plan Integrity Review.

---

## Phase 2: Plan Integrity Review

Review the plan **as a standalone document** for structural quality, implementation readiness, and adherence to planning standards.

**Purpose**: Ensure that the plan itself is well-structured, complete, and ready for implementation. An implementer (human or AI) should be able to pick up this plan and execute it without ambiguity, without needing to make design decisions, and without referring back to the specification.

**Key distinction**: Phase 1 checked *what's in the plan* against the spec. Phase 2 checks *how it's structured* — looking inward at the plan's own quality.

### What to Look For

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

### The Review Process

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

### Presenting Integrity Findings

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

### What You're NOT Doing in Phase 2

- **Not redesigning the plan** — You're checking quality, not re-architecting
- **Not adding content from outside the spec** — If a task needs more detail, the detail must come from the specification
- **Not gold-plating** — Focus on issues that would actually impact implementation
- **Not second-guessing phase structure** — Unless it's fundamentally broken, the structure stands

### Completing Phase 2

When you've:
- Reviewed the plan for structure, quality, and implementation readiness
- Resolved all critical and important findings with the user
- Updated the tracking file with all resolutions

**Delete the Phase 2 tracking file** (`{topic}-review-integrity-tracking.md`).

Both review phases are now complete. Proceed to Completion.

---

## Completion

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
