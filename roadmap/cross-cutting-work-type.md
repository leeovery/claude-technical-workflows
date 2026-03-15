# Cross-Cutting Work Type

Status: brainstorming
Date: 2026-03-15

## Problem

Cross-cutting specifications (caching strategies, rate-limiting policies, work conventions) currently live inside epic work units. They're tagged at spec completion but only consumed during that epic's planning phase. Feature and bugfix work types have no access to cross-cutting specs — they can't discover or reference them.

This means validated architectural decisions get siloed inside the epic that authored them, invisible to standalone features and bugfixes that should follow those same patterns.

## Proposal

Elevate cross-cutting concerns to a first-class work type. All cross-cutting specs live at the project level — no epic-scoped cross-cutting.

### Core Design

**New work type: `cross-cutting`**

- Lives in `.workflows/{work-unit}/` like any other work unit — no special central directory
- Standard manifest, standard directory structure
- Pipeline: Research (optional) → Discussion → Specification (terminal — no planning, implementation, or review)
- Created via `/workflow-start` alongside epic, feature, bugfix
- Bridge knows to stop after specification phase completes

**Project-level manifest**

- `.workflows/manifest.json` (or `project.json`) at the top level
- Tracks work unit name and work type only — stable, rarely-changing data
- Mutable state (status, phase progress, topics) stays in work unit manifests where it belongs — no dual-update sync risk
- Discovery reads project manifest to know what exists and what type each is, then selectively opens only the work unit manifests it needs (e.g., only cross-cutting work units when looking for cc specs during planning)
- Future use: project-level metadata, conventions, team info, default plan format

**Epic promotion**

At epic spec completion, the existing assessment determines whether the spec is a feature or cross-cutting concern. Claude assesses, user confirms or disagrees (same flow as today). If confirmed as cross-cutting, it gets auto-promoted — no second question, no scope choice.

Promotion mechanics:

1. Creates new cross-cutting work unit (`.workflows/{topic}/`)
2. **Moves** (not copies) the specification and all discussion files that fed it (tracked via the spec's `sources` field)
3. Research stays with the epic — it belongs to the epic's exploratory phase, not any single spec. Provenance pointer provides the trail back
4. New manifest records provenance: `{ source_work_unit: "payments-overhaul", source_topic: "idempotency-strategy" }`
5. Discussion and spec arrive pre-completed (already done in the epic)
6. Original epic manifest marks that topic as `promoted` (new status)
7. Epic planning naturally skips promoted topics — they no longer exist as specs in the epic

**Direct creation**

`/start-cross-cutting` or selecting `cross-cutting` at `/workflow-start`. Pipeline: Research (optional) → Discussion → Specification. Same as epic/feature — reuses existing research, discussion, and specification skills. Only difference is the bridge stops after specification completes.

### Why No Epic-Scoped Cross-Cutting

We considered allowing cross-cutting specs to stay inside an epic (epic-scoped vs project-scoped). Decided against it:

- Once an epic ships, its code is part of the system. Patterns that applied within the epic almost always apply to future work touching the same code — meaning the concern was project-scoped all along
- Having two homes (epic-scoped and project-scoped) introduces management complexity: promote, recall, scope assessment, type field on specs, not-ready display logic in planning
- Planning already filters cross-cutting specs by relevance — a project-level spec that's irrelevant to a given plan just gets filtered out. No harm in it existing
- Keeps the model simple: if it's cross-cutting, it lives at the project level. One home, one concept
- Could add epic-scoped cross-cutting later if a real need emerges, but the benefits of simplicity outweigh any hypothetical scenarios

### Simplifications from This Decision

- `type` field on specs removed entirely — all specs inside an epic are feature specs, all plannable
- Not-ready display logic for cross-cutting specs in epics eliminated
- Assessment at spec completion is a single step: "feature or cross-cutting?" → if cross-cutting, auto-promote
- Topic-level management (see [topic-level-management.md](topic-level-management.md)) becomes simpler: reclassify + recall for mistakes, no scope management

### Planning Integration

Planning entry for ALL work types (epic, feature, bugfix):

1. Read project manifest → find cross-cutting work units → read their manifests for status → filter to completed specs
2. Assess relevance to the feature being planned
3. Present relevant specs to user for confirmation
4. Pass confirmed specs to planning process as cross-cutting context
5. Planning process incorporates them (existing logic — phase design, task design, cross-cutting references section)

No changes needed to planning process itself — it already knows how to handle cross-cutting specs when provided.

### Spec Change Detection (Self-Resolving)

Current mechanism: planning stores `spec_commit` (git hash) at plan creation. On resume, diffs the specification against that hash. If changes detected, user chooses `continue` (walk through plan, amend) or `restart` (wipe and re-plan). The hash then updates to current HEAD.

This applies equally to cross-cutting specs referenced by plans:

| Plan status | Cross-cutting spec edited | What happens |
|---|---|---|
| **Completed** | After completion | Nothing — plan is frozen, implementation follows the plan as authored |
| **In-progress** | While planning | Next `continue-planning` detects the diff via `spec_commit`, user decides |
| **Not yet created** | Before planning | Plan authored from latest spec, no issue |

Edge case of "edit only intended for future plans" self-resolves: completed plans don't re-enter planning, and in-progress plans should incorporate the change (if the edit wasn't needed for in-progress work, it could have waited). Fundamental scope changes warrant a new spec, not an edit.

## Resolved Questions

### 1. Spec-type tagging → removed, replaced by auto-promotion

Cross-cutting is a work type, not a spec attribute. The `type: feature | cross-cutting` field on specs is removed entirely:

- **Feature/bugfix**: Always a feature-type spec by definition — no assessment needed
- **Epic**: Assessment at spec completion asks "feature or cross-cutting?" (Claude assesses, user confirms or disagrees — same flow as today). If cross-cutting, auto-promoted to its own work unit. All remaining specs in the epic are feature specs, all plannable
- Not-ready display logic for cross-cutting specs in epics eliminated — they don't exist in epics after promotion

### 2. Versioning → reopen and revise

- Cross-cutting work units are lightweight (discussion + spec). Reopen, update discussion with new context, revise spec — natural and preserves history in one place
- Superseding creates lineage complexity (which version is current?)
- Manifest `status` already supports: `completed` → `in-progress` → `completed`
- Git history captures evolution naturally
- If scope fundamentally changes, that's a new work unit, not a version

### 3. Project manifest → yes, all work units register

- ALL work unit creation registers in the project manifest, not just cross-cutting
- Stores name and work type only — stable index, not a state mirror
- Mutable state (status, phases, topics) stays in work unit manifests — avoids dual-update sync bugs
- Discovery reads one file to know what exists and what type, then selectively opens only the work unit manifests needed
- Simplifies discovery scripts across the board — no more scanning every directory

### 4. Research phase → optional, same as epic/feature

- Include research as optional for directly-created cross-cutting work units
- Scenario: "I want a caching strategy" → research existing patterns → discuss tradeoffs → specify
- Reuses existing research, discussion, specification skills — nothing new needed
- Bridge just needs to know to stop at end of specification
- Keeps pipeline shapes more consistent across work types

### 5. No epic-scoped cross-cutting

- All cross-cutting specs live at project level — see "Why No Epic-Scoped Cross-Cutting" above
- Could revisit if a real need emerges, but simplicity wins for now

## Open Questions

### 1. Project manifest structure

What fields beyond work unit registry? Candidates:
- Default plan format (currently in environment setup)
- Project-level metadata
- Cross-cutting spec index (or just filter work units by type?)

### 2. Promotion UX details

- Prompt wording at spec completion (how the assessment is presented)
- What if user declines (says it's a feature) but later realises it should be cross-cutting? See [topic-level-management.md](topic-level-management.md) for after-the-fact reclassification

### 3. Discovery script impact

Project manifest replaces directory scanning. How much of the existing discovery infrastructure changes? Likely simplifies significantly but needs audit.

## Related

- [Topic-Level Management](topic-level-management.md) — reclassify and recall for after-the-fact changes (not required for initial build)
