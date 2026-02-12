# Plan Integrity Review

*Reference for **[plan-review](plan-review.md)***

---

Review the plan **as a standalone document** for structural quality, implementation readiness, and adherence to planning standards.

**Purpose**: Ensure that the plan itself is well-structured, complete, and ready for implementation. An implementer (human or AI) should be able to pick up this plan and execute it without ambiguity, without needing to make design decisions, and without referring back to the specification.

**Key distinction**: The traceability review checked *what's in the plan* against the spec. This review checks *how it's structured* — looking inward at the plan's own quality.

Read the plan end-to-end — carefully, as if you were about to implement it. For each phase, each task, and the plan overall, check against the following criteria:

## What You're NOT Doing

- **Not redesigning the plan** — You're checking quality, not re-architecting
- **Not adding content from outside the spec** — If a task needs more detail, the detail must come from the specification
- **Not gold-plating** — Focus on issues that would actually impact implementation
- **Not second-guessing phase structure** — Unless it's fundamentally broken, the structure stands

---

## What to Look For

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
   - Task dependencies are explicit and correct — each dependency reflects a genuine data or capability requirement
   - No circular dependencies exist in the task graph
   - Priority assignments reflect graph position — foundation tasks and tasks that unblock others are prioritised appropriately
   - An implementer can determine execution order from the dependency graph and priorities alone

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

## Presenting Integrity Findings

After completing your review, categorize each finding by severity:

- **Critical**: Would block implementation or cause incorrect behavior
- **Important**: Would force implementer to guess or make design decisions
- **Minor**: Polish or improvement that strengthens the plan

Then:

1. **Create the tracking file** — Write all findings to `{topic}-review-integrity-tracking.md`
2. **Commit the tracking file** — Ensures it survives context refresh
3. **Present findings** in two stages:

**Stage 1: Summary**

"I've completed the plan integrity review. I found [N] items:

1. **[Brief title]** (Critical/Important/Minor)
   [2-4 line explanation: what the issue is, why it matters for implementation]

2. **[Brief title]** (Critical/Important/Minor)
   [2-4 line explanation]

Let's work through these one at a time, starting with #1."

**Stage 2: Process One Item at a Time**

Work through each finding **one at a time**. For each finding: present it, propose the fix, wait for approval, then apply it verbatim.

### Present the Finding

Show the finding with full detail:

**Finding {N} of {total}: {Brief Title}**

**Severity**: Critical | Important | Minor

**Plan Reference**: [Phase/task in the plan]

**Category**: [Which review criterion — e.g., "Task Template Compliance", "Vertical Slicing"]

**Details**: [What the issue is and why it matters for implementation]

### Propose the Fix

Present the proposed fix **in the format it will be written to the plan**, rendered as markdown (not in a code block). What the user sees is what gets applied — no changes between approval and writing.

State the action type explicitly so the user knows what's changing structurally:

**Update a task** — change content within an existing task:

**Proposed fix — update Phase {N}, Task {M}:**

**Current:**
[The existing content as it appears in the plan]

**Proposed:**
[The replacement content]

**Add content to a task** — insert into an existing task (e.g., missing acceptance criteria, edge case):

**Proposed fix — add to Phase {N}, Task {M}, {section}:**

[The exact content to be added, in plan format]

**Remove content from a task** — strip content that shouldn't be there:

**Proposed fix — remove from Phase {N}, Task {M}, {section}:**

[The exact content to be removed]

**Add a new task** — a spec section has no plan coverage and needs its own task:

**Proposed fix — add new task to Phase {N}:**

[The complete task in plan format, using the task template]

**Remove a task** — an entire task is hallucinated with no spec backing:

**Proposed fix — remove Phase {N}, Task {M}: {Task Name}**

**Reason**: [Why this task has no specification basis]

**Add a new phase** — a significant area of the specification has no plan coverage:

**Proposed fix — add new Phase {N}: {Phase Name}**

[Phase goal, acceptance criteria, and task overview]

**Remove a phase** — an entire phase is not backed by the specification:

**Proposed fix — remove Phase {N}: {Phase Name}**

**Reason**: [Why this phase has no specification basis]

After presenting the finding and proposed fix, ask:

**Finding {N} of {total}: {Brief Title}**

· · · · · · · · · · · ·
**To proceed:**
- **`y`/`yes`** — Approved. I'll apply it to the plan verbatim.
- **`s`/`skip`** — Leave this as-is and move to the next finding.
- **Or tell me what to change.**
· · · · · · · · · · · ·

**Do not wrap the above in a code block** — output as raw markdown so bold styling renders.

**STOP.** Wait for the user's response.

### If the user provides feedback

The user may:
- Request changes to the proposed fix
- Ask questions about why this was flagged
- Suggest a different approach to resolving the finding

Incorporate feedback and re-present the proposed fix **in full** using the same format above. Then ask the same choice again. Repeat until approved or skipped.

### If Approved

Apply the fix to the plan — as presented, using the output format adapter to determine how it's written. Do not modify content between approval and writing. Then update the tracking file: mark resolution as "Fixed", add any discussion notes.

Confirm:

"Finding {N} of {total}: {Brief Title} — fixed."

### If Skipped

Update the tracking file: mark resolution as "Skipped", note the reason.

"Finding {N} of {total}: {Brief Title} — skipped."

### Next Finding

Commit the tracking file (and any plan changes) before moving on. This ensures progress survives context refresh or session interruption.

**If findings remain:** → Present the next finding. Follow the same present → propose → ask → apply sequence.

**If all findings are processed:**

**Delete the integrity tracking file** (`{topic}-review-integrity-tracking.md`) — it has served its purpose.

Inform the user the integrity review is complete.

→ Return to **[plan-review.md](plan-review.md)** for completion.
