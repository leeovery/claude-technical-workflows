# Top-Level Conditional Routing: Bold vs H4

## The Idea

Resolve the drift between CLAUDE.md's conditional routing convention and actual usage. Either update the convention to acknowledge an unspoken sub-case, or sweep the codebase to match the stated rule.

## Context

CLAUDE.md's Structural Conventions say:

> **H4** (`####`): Conditional routing only (`#### If {condition}`, `#### Otherwise`)
> ...
> H4 for top-level conditionals, bold text for nested — never use H5/H6 for conditional nesting

In practice, `**If ...:**` bold conditionals appear at *file-prelude* positions across the codebase — routing the outcome of a trigger checklist or STOP-gate response that sits above any `## A.` section. Two patterns:

**Pattern A — H4 for all top-level conditionals:** Any conditional that routes from the file level or a section level uses `#### If ...`. Bold is reserved strictly for conditionals nested inside an H4 branch.

**Pattern B — Bold at prelude, H4 inside sections:** Conditionals in a section's prelude (before any `## A.` lettered section, or immediately after a STOP gate at file top) use `**If ...:**` bold. Once inside a lettered section, top-level conditionals use H4 and nested ones use bold.

Pattern B is what the codebase actually does. ~53 skill files use the `**If ...:**` bold pattern, many of them at prelude positions. Examples:

- `workflow-discussion-process/references/review-agent.md` — `**If all checked:**` / `**If any unchecked:**` after the trigger checklist, before `## A. Dispatch`
- `workflow-research-process/references/review-agent.md` — same pattern
- `workflow-scoping-process/SKILL.md:71` — `**If plan exists and is completed:**` after a nested check
- `workflow-review-process/SKILL.md:91,137,143` — multiple `**If ...:**` inside H2 step bodies
- `workflow-research-process/references/deep-dive-agent.md:55,61` — `**If \`no\`:**` / `**If \`yes\`:**` after a STOP gate

A strict CLAUDE.md reading says all of these should be H4. In practice, bold-at-prelude and bold-after-STOP-gate are widely used and arguably more readable than H4 (which visually competes with the lettered section headings).

## Possible Directions

- **Formalise Pattern B in CLAUDE.md.** Add a sub-case: bold `**If ...:**` is allowed for conditionals in file prelude (above any `## A.` section) and immediately after STOP gates. H4 is for conditionals inside a lettered section's body. Nested conditionals inside an H4 block stay bold. This matches existing usage with minimal churn.
- **Sweep to Pattern A.** Convert all prelude-level and STOP-gate-adjacent bold conditionals to H4. Higher churn (~53 files), but strictly matches the current CLAUDE.md rule. May visually clutter the prelude.
- **Hybrid via semantics.** Keep the CLAUDE.md rule as-is but clarify that "top-level" means "within a lettered section." Prelude and STOP-gate responses are their own category and use bold. This is basically Pattern B with a clearer definition.

## Relevant Files

- `CLAUDE.md` — Structural Conventions → Conditional Routing section
- `skills/workflow-discussion-process/references/review-agent.md`
- `skills/workflow-research-process/references/review-agent.md`
- `skills/workflow-scoping-process/SKILL.md`
- `skills/workflow-review-process/SKILL.md`
- `skills/workflow-research-process/references/deep-dive-agent.md`
- `skills/workflow-review-process/references/review-actions-loop.md` — many STOP-gate-adjacent bold conditionals
- ~53 files total match the `**If ...:**` pattern — full audit via `rg '^\*\*If [^*]+:\*\*$' skills/`
