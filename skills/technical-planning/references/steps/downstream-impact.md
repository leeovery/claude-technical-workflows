# Downstream Impact Handling

*Reference for **[technical-planning](../../SKILL.md)***

---

When the user amends an earlier phase or task, downstream content may be affected.

After applying the amendment, check if later phases or tasks depend on what was changed.

**If downstream impact exists:**

> "You've changed Phase {N}. This may affect:
> - Phase {N+1}: {name} — depends on Phase {N} outcome
> - Phase {N+2}: {name} — builds on Phase {N} work
>
> Review these phases next? (y/skip)"

**If user says `y`:** Present each flagged phase/task for review, allowing approve or amend.

**If user says `skip`:** Proceed without reviewing downstream items. The user takes responsibility for any inconsistencies.

---

## What Counts as Downstream Impact

- **Phase changes**: Later phases that build on the changed phase's outcome
- **Task changes**: Later tasks in the same phase that depend on the changed task
- **Cross-phase task changes**: Tasks in later phases that reference the changed task

Use judgment — not every change affects downstream content. Flag only when the change is substantive enough to potentially invalidate later work.
