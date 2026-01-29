# Spec Change Detection

*Reference for **[technical-planning](../SKILL.md)***

---

When resuming planning, check whether the specification or cross-cutting specifications have changed since planning started.

The Plan Index File stores `spec_commit` — the git commit hash captured when planning began. This allows diffing any input file against that point in time.

## Detection

Run a git diff against the stored commit for all input files:

```bash
git diff {spec_commit} -- {specification-path} {cross-cutting-spec-paths...}
```

Also check for new cross-cutting specification files that didn't exist at that commit.

#### If no changes detected

No action needed. Proceed with the normal step sequence.

#### If changes detected

Summarise the extent of changes for the user:

- **What files changed** (specification, cross-cutting specs, or both)
- **Whether any cross-cutting specs are new** (didn't exist at the stored commit)
- **Nature of changes** — formatting/cosmetic, minor additions/removals, or substantial restructuring

Present the summary and options:

> "{Summary of changes detected}
>
> - **`continue`** — Proceed with the existing plan as-is
> - **`restart`** — Delete the plan and start fresh from the updated specification"

**STOP.** Wait for user response.

#### If `continue`

Update `spec_commit` in the Plan Index File frontmatter to the current commit hash and proceed.

The user accepts the plan as-is. They can still amend individual phases or tasks through the normal review flow if they spot something that needs updating.

#### If `restart`

Return to Step 0's restart flow — delete the Plan Index File and any Authored Tasks, then begin fresh.

---

## Why Not Incremental Merge

Even small specification changes can cascade into phase reordering, task restructuring, and invalidation of authored tasks. Attempting to incrementally propagate spec changes through a half-built plan risks producing a worse result than starting fresh.

The planning process (phase design, task design, authoring) is a heavyweight analysis with detailed instructions at each stage. A reliable merge would require re-running that full analysis and reconciling the results — which is effectively a restart with extra complexity.
