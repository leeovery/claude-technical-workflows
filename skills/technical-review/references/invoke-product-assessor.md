# Invoke Product Assessor

*Reference for **[technical-review](../SKILL.md)***

---

This step dispatches a single `review-product-assessor` agent to evaluate the implementation holistically as a product. This is not task-by-task — the assessor evaluates robustness, gaps, and product readiness.

---

## Identify Scope

Determine the review scope indicator to pass to the assessor:

- **single-plan** — one plan selected
- **multi-plan** — multiple plans selected
- **full-product** — all implemented plans

Build the full list of implementation files across all plans in scope (same git history approach as QA verification).

---

## Dispatch Assessor

Dispatch **one agent** via the Task tool.

- **Agent path**: `../../../agents/review-product-assessor.md`

The assessor receives:

1. **Implementation files** — all files in scope (the full list, not summarized)
2. **Specification path(s)** — from each plan's frontmatter
3. **Plan path(s)** — all plans in scope
4. **Project skill paths** — from Step 2 discovery
5. **Review scope** — one of: `single-plan`, `multi-plan`, `full-product`

---

## Wait for Completion

**STOP.** Do not proceed until the assessor has returned.

The assessor writes its findings to `docs/workflow/review/{topic-or-scope}/product-assessment.md` and returns a brief status. If the agent fails (error, timeout), record the failure and continue to the review production step with QA findings only.

---

## Expected Result

The assessor returns:

```
STATUS: findings | clean
FINDINGS_COUNT: {N}
SUMMARY: {1 sentence}
```

The full findings are in the output file. Read `docs/workflow/review/{topic-or-scope}/product-assessment.md` to incorporate into the review document.
