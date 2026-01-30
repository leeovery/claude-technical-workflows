# Plan Review

*Reference for **[technical-planning](../../SKILL.md)***

---

After completing the plan, perform a comprehensive two-part review before handing off to implementation.

**Why this matters**: The plan is what gets built. If content was hallucinated into the plan, it will be implemented — building something that was never discussed or validated. If specification content was missed, it won't be built. The entire purpose of this workflow is that artifacts carry validated decisions through to implementation. The plan is the final gate before code is written.

## Review Tracking Files

To ensure analysis isn't lost during context refresh, create tracking files that capture findings. These files persist analysis so work can continue across sessions.

**Location**: Store tracking files alongside the Plan Index File:
- `{topic}-review-traceability-tracking.md` — Traceability findings
- `{topic}-review-integrity-tracking.md` — Integrity findings

**Format**:
```markdown
---
status: in-progress | complete
created: YYYY-MM-DD  # Use today's actual date
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

**Why tracking files**: If context refreshes mid-review, you can read the tracking file and continue where you left off. The tracking file shows which items are resolved and which remain.

---

## Traceability Review

Compare the plan against the specification in both directions — checking that everything from the spec is in the plan, and everything in the plan traces back to the spec.

Load **[review-traceability.md](review-traceability.md)** and follow its instructions as written.

---

## Plan Integrity Review

Review the plan as a standalone document for structural quality, implementation readiness, and adherence to planning standards.

Load **[review-integrity.md](review-integrity.md)** and follow its instructions as written.

---

## Completion

After both reviews:

1. **Verify tracking files are deleted** — Both traceability and integrity tracking files must be gone

2. **Final quality confirmation**:
   - All specification content has plan coverage (Traceability)
   - No hallucinated content remains (Traceability)
   - All tasks follow the required template (Integrity)
   - Dependencies are documented and ordered (Integrity)
   - External dependencies match specification (Integrity)

3. **Confirm with the user**:

> "The plan has passed both reviews:
> - **Traceability**: All specification content is covered; no hallucinated content
> - **Integrity**: Plan structure, tasks, and dependencies are implementation-ready
>
> Review is complete."

> **CHECKPOINT**: Do not confirm completion if tracking files still exist. They indicate incomplete review work.
