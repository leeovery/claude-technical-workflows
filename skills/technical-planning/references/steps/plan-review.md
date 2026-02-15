# Plan Review

*Reference for **[technical-planning](../../SKILL.md)***

---

Two-part review dispatched to sub-agents. Traceability runs first — its approved fixes are applied before the integrity review begins, so integrity evaluates the corrected plan.

---

## A. Cycle Management

Check the `review_cycle` field in the Plan Index File frontmatter.

#### If `review_cycle` is missing or not set

Add `review_cycle: 1` to the Plan Index File frontmatter.

#### If `review_cycle` is already set

Increment `review_cycle` by 1.

Record the current cycle number — passed to both review agents for tracking file naming (`c{N}`).

→ Proceed to **B. Traceability Review**.

---

## B. Traceability Review

1. Load **[invoke-review-traceability.md](invoke-review-traceability.md)** and follow its instructions to dispatch the agent.
2. **STOP.** Do not proceed until the agent has returned its result.
3. On receipt of result, load **[process-review-findings.md](process-review-findings.md)** and follow its instructions to process the findings with the user.

→ Proceed to **C. Plan Integrity Review**.

---

## C. Plan Integrity Review

1. Load **[invoke-review-integrity.md](invoke-review-integrity.md)** and follow its instructions to dispatch the agent.
2. **STOP.** Do not proceed until the agent has returned its result.
3. On receipt of result, load **[process-review-findings.md](process-review-findings.md)** and follow its instructions to process the findings with the user.

→ Proceed to **D. Re-Loop Prompt**.

---

## D. Re-Loop Prompt

#### If no findings were surfaced in this cycle

→ Proceed directly to **E. Completion**.

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

→ Return to **A. Cycle Management** to begin a fresh cycle.

#### If proceed

→ Continue to **E. Completion**.

---

## E. Completion

1. **Verify tracking files are marked complete** — All traceability and integrity tracking files across all cycles must have `status: complete`

2. **Sign-off**:

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
