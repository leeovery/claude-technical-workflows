# Invoke Product Assessor

*Reference for **[technical-review](../SKILL.md)***

---

This step dispatches a single `review-product-assessor` agent to evaluate the implementation holistically as a product. This is not task-by-task — the assessor evaluates robustness, gaps, and product readiness.

---

## Determine Assessment Number

Count existing files in `docs/workflow/review/product-assessment/` to determine the next number:

```bash
mkdir -p docs/workflow/review/product-assessment
ls docs/workflow/review/product-assessment/*.md 2>/dev/null | wc -l
```

The next assessment is `{count + 1}.md`.

---

## Build Implementation File List

Build the full list of implementation files across all reviewed plans (same git history approach as QA verification).

---

## Dispatch Assessor

Dispatch **one agent** via the Task tool.

- **Agent path**: `../../../agents/review-product-assessor.md`

The assessor receives:

1. **Implementation files** — all files across reviewed plans
2. **Specification path(s)** — from each plan's frontmatter
3. **Plan path(s)** — all reviewed plans
4. **Project skill paths** — from Step 2 discovery
5. **Assessment number** — sequential number for output file naming

---

## Wait for Completion

**STOP.** Do not proceed until the assessor has returned.

The assessor writes its findings to `docs/workflow/review/product-assessment/{N}.md` and returns a brief status.

---

## Expected Result

The assessor returns:

```
STATUS: findings | clean
FINDINGS_COUNT: {N}
SUMMARY: {1 sentence}
```

The full findings are in the output file at `docs/workflow/review/product-assessment/{N}.md`.
