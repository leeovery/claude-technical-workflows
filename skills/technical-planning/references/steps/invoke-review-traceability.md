# Invoke Traceability Review

*Reference for **[plan-review](plan-review.md)***

---

This step invokes the `planning-review-traceability` agent (`../../../../agents/planning-review-traceability.md`) to analyze plan traceability against the specification.

---

## Invoke the Agent

Invoke `planning-review-traceability` with:

1. **Review criteria path**: `review-traceability.md` (in this directory)
2. **Specification path**: from the plan's `specification` frontmatter field (resolved relative to the plan directory)
3. **Plan path**: `docs/workflow/planning/{topic}/plan.md`
4. **Format reading.md path**: load **[output-formats.md](../output-formats.md)**, find the entry matching the plan's `format:` field, and pass the format's `reading.md` path
5. **Cycle number**: current `review_cycle` from the Plan Index File frontmatter
6. **Topic name**: from the plan's `topic` frontmatter field

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
  type: {Missing from plan | Hallucinated content | Incomplete coverage}
  spec_ref: {section/decision in specification}
  plan_ref: {phase/task in plan, or "N/A"}
  details: {what's wrong}
  proposed_fix_type: {update | add | remove | add-task | remove-task | add-phase | remove-phase}
  proposed_fix: {description of proposed change}
```

- `clean`: plan is a faithful, complete translation of the specification. No findings to process.
- `findings`: FINDINGS contains items to present to the user for approval.
