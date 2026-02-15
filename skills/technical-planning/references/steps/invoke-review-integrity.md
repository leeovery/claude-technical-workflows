# Invoke Integrity Review

*Reference for **[plan-review](plan-review.md)***

---

This step invokes the `planning-review-integrity` agent (`../../../../agents/planning-review-integrity.md`) to review plan structural quality and implementation readiness.

---

## Invoke the Agent

Invoke `planning-review-integrity` with:

1. **Review criteria path**: `review-integrity.md` (in this directory)
2. **Plan path**: `docs/workflow/planning/{topic}/plan.md`
3. **Format reading.md path**: load **[output-formats.md](../output-formats.md)**, find the entry matching the plan's `format:` field, and pass the format's `reading.md` path
4. **Cycle number**: current `review_cycle` from the Plan Index File frontmatter
5. **Topic name**: from the plan's `topic` frontmatter field

---

## Expected Result

The agent returns a structured result:

```
STATUS: findings | clean
CYCLE: {N}
TRACKING_FILE: {path to tracking file}
FINDING_COUNT: {N}
FINDINGS:
- finding: {N}
  title: {brief title}
  severity: {Critical | Important | Minor}
  plan_ref: {phase/task in plan}
  category: {review criterion}
  details: {what the issue is}
  proposed_fix_type: {update | add | remove | add-task | remove-task | add-phase | remove-phase}
  proposed_fix: {description of proposed change}
```

- `clean`: plan meets structural quality standards. No findings to process.
- `findings`: FINDINGS contains items to present to the user for approval.
