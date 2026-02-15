# Plan Review

*Reference for **[technical-planning](../../SKILL.md)***

---

After completing the plan, perform a comprehensive two-part review before handing off to implementation. Each review is dispatched to a sub-agent for analysis, and findings are processed interactively with the user before the next review begins.

**Why sub-agents**: The main planning context has accumulated significant state from phase design, task authoring, and dependency graphing. Dispatching reviews to fresh agents ensures analysis starts from a clean context with only the inputs needed — the specification, plan, and tasks.

**Why sequential**: Traceability runs first and its approved fixes are applied to the plan before integrity begins. This means the integrity review evaluates the *corrected* plan — it won't waste time flagging structural issues in content that traceability has already removed or rewritten.

**Why this matters**: The plan is what gets built. If content was hallucinated into the plan, it will be implemented — building something that was never discussed or validated. If specification content was missed, it won't be built. The entire purpose of this workflow is that artifacts carry validated decisions through to implementation. The plan is the final gate before code is written.

---

## A. Cycle Management

Check the `review_cycle` field in the Plan Index File frontmatter.

#### If `review_cycle` is missing or not set

Add `review_cycle: 1` to the Plan Index File frontmatter.

#### If `review_cycle` is already set

This is a re-loop. Increment `review_cycle` by 1.

Record the current cycle number — it is passed to both review agents for tracking file naming (`c{N}`).

→ Proceed to **B. Traceability Review**.

---

## B. Traceability Review

Compare the plan against the specification in both directions — checking that everything from the spec is in the plan, and everything in the plan traces back to the spec.

1. Load **[invoke-review-traceability.md](invoke-review-traceability.md)** and follow its instructions to dispatch the agent.
2. **STOP.** Do not proceed until the agent has returned its result.
3. On receipt of result, load **[process-review-findings.md](process-review-findings.md)** and follow its instructions to process the findings with the user.

→ Proceed to **C. Plan Integrity Review**.

---

## C. Plan Integrity Review

Review the plan as a standalone document for structural quality, implementation readiness, and adherence to planning standards. The integrity agent reviews the plan *after* traceability fixes have been applied.

1. Load **[invoke-review-integrity.md](invoke-review-integrity.md)** and follow its instructions to dispatch the agent.
2. **STOP.** Do not proceed until the agent has returned its result.
3. On receipt of result, load **[process-review-findings.md](process-review-findings.md)** and follow its instructions to process the findings with the user.

→ Proceed to **D. Re-Loop Prompt**.

---

## D. Re-Loop Prompt

After both reviews complete, check whether either review surfaced findings in this cycle.

#### If no findings were surfaced in this cycle

→ Skip the re-loop prompt and proceed directly to **E. Completion**.

#### If findings were surfaced

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
- **`r`/`reanalyse`** — Run another round of review (traceability + integrity)
- **`p`/`proceed`** — Proceed to conclusion
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

#### If reanalyse

Keep existing tracking files — they are cycle-numbered and persist as review history.

→ Return to **A. Cycle Management** to begin a fresh cycle.

#### If proceed

→ Continue to **E. Completion**.

---

## E. Completion

After reviews are complete:

1. **Verify tracking files are marked complete** — All traceability and integrity tracking files across all cycles must have `status: complete`

2. **Final quality confirmation**:
   - All specification content has plan coverage (Traceability)
   - No hallucinated content remains (Traceability)
   - All tasks follow the required template (Integrity)
   - Dependencies are documented and ordered (Integrity)
   - External dependencies match specification (Integrity)

3. **Sign-off**:

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
- **`y`/`yes`** — Conclude plan and mark as concluded
- **Comment** — Add context before concluding
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

#### If comment

Discuss the user's context, apply any changes, then re-present the sign-off prompt above.

#### If yes

→ Return to **[technical-planning SKILL.md](../../SKILL.md)** Step 8 for conclusion.

> **CHECKPOINT**: Do not confirm completion if any tracking files still show `status: in-progress`. They indicate incomplete review work.
