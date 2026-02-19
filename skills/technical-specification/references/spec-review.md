# Specification Review

*Reference for **[technical-specification](../SKILL.md)***

---

Two-phase review of the specification. Phase 1 (Input Review) compares against source material. Phase 2 (Gap Analysis) reviews the specification as a standalone document.

**Why this matters**: The specification is the golden document. Plans are built from it, and those plans inform implementation. If a detail isn't in the specification, it won't make it to the plan, and therefore won't be built. Worse, the implementation agent may hallucinate to fill gaps, potentially getting it wrong. The goal is a specification robust enough that an agent or human could pick it up, create plans, break it into tasks, and write the code.

Load **[review-tracking-format.md](review-tracking-format.md)** — internalize the tracking file format for both phases.

---

## A. Cycle Management

Check the `review_cycle` field in the specification frontmatter.

#### If `review_cycle` is 0 or not set

Set `review_cycle: 1` in the specification frontmatter.

#### If `review_cycle` is already set

Increment `review_cycle` by 1.

Record the current cycle number — used for tracking file naming (`c{N}`).

Commit the updated frontmatter.

→ If `review_cycle <= 3`, proceed to **B. Phase 1 — Input Review**.

#### If `review_cycle > 3`

**Do NOT skip review autonomously.** This gate is an escape hatch for the user — not a signal to stop. The expected default is to continue running review until no issues are found. Present the choice and let the user decide.

> *Output the next fenced block as a code block:*

```
Review cycle {N}

Review has run {N-1} times so far. You can continue (recommended if issues
were still found last cycle) or skip to completion.
```

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
- **`p`/`proceed`** — Continue review *(default)*
- **`s`/`skip`** — Skip review, proceed to completion
· · · · · · · · · · · ·
```

**STOP.** Wait for user choice. You MUST NOT choose on the user's behalf.

#### If `proceed`

→ Continue to **B. Phase 1 — Input Review**.

#### If `skip`

→ Jump to **E. Completion**.

---

## B. Phase 1 — Input Review

1. Load **[review-input.md](review-input.md)** and follow its instructions (analysis + tracking file creation).
2. Load **[process-review-findings.md](process-review-findings.md)** and follow its instructions to process findings with the user.

→ Proceed to **C. Phase 2 — Gap Analysis**.

---

## C. Phase 2 — Gap Analysis

1. Load **[review-gap-analysis.md](review-gap-analysis.md)** and follow its instructions (analysis + tracking file creation).
2. Load **[process-review-findings.md](process-review-findings.md)** and follow its instructions to process findings with the user.

→ Proceed to **D. Re-Loop Prompt**.

---

## D. Re-Loop Prompt

#### If no findings were surfaced in either phase of this cycle

→ Skip the re-loop prompt and proceed directly to **E. Completion** (nothing to re-analyse).

#### If findings were surfaced

Check `finding_gate_mode` and `review_cycle` in the specification frontmatter.

#### If `finding_gate_mode: auto` and `review_cycle < 5`

> *Output the next fenced block as a code block:*

```
Review cycle {N} complete — findings applied. Running follow-up cycle.
```

→ Return to **A. Cycle Management**.

#### If `finding_gate_mode: auto` and `review_cycle >= 5`

> *Output the next fenced block as a code block:*

```
Review cycle {N}

Auto-review has not converged after 5 cycles — escalating for human review.
```

→ Present the gated re-loop prompt below.

#### If `finding_gate_mode: gated`

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
- **`r`/`reanalyse`** — Run another review cycle (Phase 1 + Phase 2)
- **`p`/`proceed`** — Proceed to completion
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

#### If reanalyse

→ Return to **A. Cycle Management** to begin a fresh cycle.

#### If proceed

→ Continue to **E. Completion**.

---

## E. Completion

1. **Verify tracking files are marked complete** — All input review and gap analysis tracking files across all cycles must have `status: complete`.

> **CHECKPOINT**: Do not confirm completion if any tracking files still show `status: in-progress`. They indicate incomplete review work.

2. **Commit** all review tracking files: `spec({topic}): complete specification review (cycle {N})`

> *Output the next fenced block as a code block:*

```
Specification review complete — {N} cycle(s), all tracking files finalised.
```

→ Return to **[technical-specification SKILL.md](../SKILL.md)** for **Step 7**.
