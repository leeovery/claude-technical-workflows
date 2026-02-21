# Invoke Traceability Review

*Reference for **[plan-review](plan-review.md)***

---

This step invokes the `planning-review-traceability` agent (`../../../agents/planning-review-traceability.md`) to analyze plan traceability against the specification.

---

## Invoke the Agent

Invoke `planning-review-traceability` with:

1. **Review criteria path**: `review-traceability.md` (in this directory)
2. **Specification path**: from the plan's `specification` frontmatter field (resolved relative to the plan directory)
3. **Plan path**: `.workflows/planning/{topic}/plan.md`
4. **Format reading.md path**: load **[output-formats.md](output-formats.md)**, find the entry matching the plan's `format:` field, and pass the format's `reading.md` path
5. **Cycle number**: current `review_cycle` from the Plan Index File frontmatter
6. **Topic name**: from the plan's `topic` frontmatter field
7. **Task design path**: `task-design.md`

---

## Expected Result

The agent returns a brief status:

```
STATUS: findings | clean
CYCLE: {N}
TRACKING_FILE: {path to tracking file}
FINDING_COUNT: {N}
```

- `clean`: plan is a faithful, complete translation of the specification. No findings to process.
- `findings`: tracking file contains findings with full fix content for the orchestrator to present to the user.
