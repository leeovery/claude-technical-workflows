# Plan Integrity Review

*Reference for **[plan-review](plan-review.md)***

---

Review the plan **as a standalone document** for structural quality, implementation readiness, and adherence to planning standards.

**Purpose**: Ensure that the plan itself is well-structured, complete, and ready for implementation. An implementer (human or AI) should be able to pick up this plan and execute it without ambiguity, without needing to make design decisions, and without referring back to the specification.

**Key distinction**: The traceability review checked *what's in the plan* against the spec. This review checks *how it's structured* — looking inward at the plan's own quality.

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

## The Review Process

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

## Presenting Integrity Findings

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

Follow the same per-item workflow as the traceability review (see [review-traceability.md](review-traceability.md#present-the-finding)): present the finding, propose the fix (showing exactly what will change in the plan), offer the Approve / Adjust / Skip choice, wait for the user's response, and apply the fix verbatim if approved.

The only difference is the finding format — use severity and category instead of type and spec reference:

> **Finding {N} of {total}: {Brief Title}**
>
> **Severity**: Critical | Important | Minor
> **Plan Reference**: [Phase/task in the plan]
> **Category**: [Which review criterion — e.g., "Task Template Compliance", "Vertical Slicing"]
>
> **Details**: [What the issue is and why it matters for implementation]

The proposed fix format, choice block, and routing (If Adjust / If Approved / If Skipped / Next Finding) are identical to the traceability review.

## What You're NOT Doing

- **Not redesigning the plan** — You're checking quality, not re-architecting
- **Not adding content from outside the spec** — If a task needs more detail, the detail must come from the specification
- **Not gold-plating** — Focus on issues that would actually impact implementation
- **Not second-guessing phase structure** — Unless it's fundamentally broken, the structure stands

## Completing Phase 2

When you've:
- Reviewed the plan for structure, quality, and implementation readiness
- Resolved all critical and important findings with the user
- Updated the tracking file with all resolutions

**Delete the Phase 2 tracking file** (`{topic}-review-integrity-tracking.md`).

Inform the user Phase 2 is complete.

→ Return to **[plan-review.md](plan-review.md)** for Completion.
