# Spec Change Detection

*Reference for **[technical-planning](../SKILL.md)***

---

When resuming planning, compare the current specification hash to the stored `spec_hash` in the plan frontmatter.

**If unchanged:** Proceed to the appropriate step based on `planning:` position.

**If different:** Prompt the user:

> "The specification hash has changed since planning started.
>
> - **`continue`** — Proceed anyway (e.g., just formatting changes)
> - **`re-analyze`** — I'll re-read the spec and compare to existing phases"

#### If `continue`

Update `spec_hash` in frontmatter to the new value and proceed.

#### If `re-analyze`

1. Read the current specification fully
2. Produce a new phase proposal based on fresh analysis
3. Compare new proposal to existing phases in the plan
4. Present differences: "Phase 2 scope differs because X"
5. User decides: keep existing, take new, or discuss/merge

The plan file is the anchor — we compare new analysis against persisted phases, not against the old spec (which we don't have).

After resolving any differences, update `spec_hash` and proceed.
