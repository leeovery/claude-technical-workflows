# Cross-Cutting Work Type

Status: ready for planning
Date: 2026-03-16

## Problem

Feature and bugfix work types have no access to cross-cutting specifications. Cross-cutting specs (caching strategies, rate-limiting policies, work conventions) currently live inside epic work units — tagged at spec completion but only consumed during that epic's planning phase.

This means validated architectural decisions get siloed inside the epic that authored them, invisible to standalone features and bugfixes that should follow those same patterns. The original question was whether feature and bugfix should be able to check for cross-cutting concerns during planning and implementation, same as epics do.

## Alternatives Considered

Five approaches were brainstormed before arriving at the current proposal:

1. **Project-level cross-cutting directory** — `.workflows/cross-cutting/{topic}/` as a top-level peer to work units. Simple and flat, but unclear how specs get created or managed.
2. **Promotion model** — specs start inside work units, get promoted to project level at completion. Preserves the natural authoring flow but adds lifecycle complexity and potential for stale copies.
3. **Cross-cutting as a fourth work type** — first-class work type with its own pipeline. Fits the existing mental model.
4. **Hybrid** — project-level directory with two paths in: direct creation and promotion from epics. Flexible but more moving parts.
5. **Registry file** — `.workflows/.cross-cutting-refs` listing paths to cc specs wherever they live. Minimal structural change but fragile, no lifecycle management.

**Why we chose option 3** (new work type): it gives cross-cutting concerns a proper home without introducing a special directory structure that breaks conventions. Each cc concern is a standard work unit with its own manifest, following all existing patterns. No central directory needed — the project manifest serves as the index.

## Proposal

Elevate cross-cutting concerns to a first-class work type. All cross-cutting specs live at the project level — no epic-scoped cross-cutting.

### Core Design

**New work type: `cross-cutting`**

- Lives in `.workflows/{work-unit}/` like any other work unit — no special central directory (a central location would be against current conventions)
- Standard manifest, standard directory structure
- Pipeline: Research (optional) → Discussion → Specification (terminal — no planning, implementation, or review — there's nothing to build)
- Created via `/workflow-start` alongside epic, feature, bugfix
- Bridge is the pipeline authority — it delegates to the discovery script to determine that for cross-cutting work types, the pipeline is done after specification completes
- Separate `start-cross-cutting` and `continue-cross-cutting` skills, matching existing conventions (one start/continue pair per work type)

**Project-level manifest**

- `.workflows/manifest.json` — matches the naming convention of work unit manifests
- Tracks work unit name and work type only — stable, rarely-changing data
- Mutable state (status, phase progress, topics) stays in work unit manifests where it belongs — anything that changes at the work unit level should stay at that level. No dual-update sync risk
- Discovery reads project manifest to know what exists and what type each is, then selectively opens only the work unit manifests it needs (e.g., only cross-cutting work units when looking for cc specs during planning)
- Future use: project-level metadata, conventions, team info. Default plan format could move here, though plan format currently lives at topic and phase level in planning — topic-level overrides may still make sense for individual topics

**Epic promotion**

At epic spec completion, the existing assessment determines whether the spec is a feature or cross-cutting concern. Claude assesses, user confirms or disagrees (same flow as today). If confirmed as cross-cutting, it gets auto-promoted — no second question, no scope choice.

In the current system, discussions are analyzed at the specification phase and grouped. A specification is made up of one or more discussion documents (epic only — feature/bugfix have a single topic). When promoting, the entire group moves: the spec and all discussions that fed it.

Promotion mechanics:

1. Creates new cross-cutting work unit (`.workflows/{topic}/`)
2. **Moves** (not copies) the specification and all discussion files that fed it (tracked via the spec's `sources` field) — the content should live in its proper home, not be duplicated. As discussed: "move the content out of that epic into its own cross-cutting work unit"
3. Research stays with the epic — it belongs to the epic's exploratory phase, not any single spec. Research files feed all discussions collectively, not one spec. The provenance pointer provides the trail back to the original research if needed
4. New manifest records provenance: `{ source_work_unit: "payments-overhaul", source_topic: "idempotency-strategy" }` — useful for tracking where the concern originated and the original research and discussion that fed the spec
5. Discussion and spec arrive pre-completed (already done in the epic)
6. New cross-cutting work unit registered in project manifest
7. Original epic manifest marks that topic as `promoted` (new status)
8. Epic planning naturally skips promoted topics — they no longer exist as specs in the epic, so they naturally won't be plannable. No further effort required

**Direct creation**

`/start-cross-cutting` or selecting `cross-cutting` at `/workflow-start`. Pipeline: Research (optional) → Discussion → Specification. Reuses existing research, discussion, and specification skills — nothing new needs to happen other than the bridge knowing to stop at end of spec. Keeps pipeline shapes more consistent across work types.

### Why No Epic-Scoped Cross-Cutting

We initially considered a two-step assessment: (1) feature or cross-cutting? (2) if cross-cutting, epic-scoped or project-scoped? This would have allowed cross-cutting specs to stay inside an epic when they only applied to that epic's scope.

We challenged that thinking and decided against it:

- Once an epic ships, its code is part of the system. Patterns that applied within the epic almost always apply to future work touching the same code — meaning the concern was project-scoped all along. As discussed: "once you implement that epic, the code becomes part of the whole system. Does that cross-cutting concern still matter? If it does, it should be at the project level"
- Having two homes (epic-scoped and project-scoped) introduces management complexity: promote, recall, scope assessment, type field on specs, not-ready display logic in planning. As discussed: "having them in two places has caused us to introduce management, now we need to be able to manage moving them back and forth"
- Planning already filters cross-cutting specs by relevance — a project-level spec that's irrelevant to a given plan just gets filtered out. No harm in it existing
- Keeps the model simple: if it's cross-cutting, it lives at the project level. One home, one concept
- As discussed: "the benefits of keeping it simple outweigh anything I can think of in terms of loss" and "I think I'm finding myself creating scenarios that probably aren't realistic to justify doing it. It's overcomplicating the architecture for no real gain"
- Could add epic-scoped cross-cutting later if a real need emerges — "it is something we could add later if I find that we need it"

### Simplifications from This Decision

- `type` field on specs removed entirely — all specs inside an epic are feature specs, all plannable
- Not-ready display logic for cross-cutting specs in epics eliminated
- Assessment at spec completion is a single step: "feature or cross-cutting?" → if cross-cutting, auto-promote
- Topic-level management (see [topic-level-management.md](topic-level-management.md)) becomes simpler: reclassify + recall for mistakes, no scope management

### Planning Integration

Planning entry for ALL work types (epic, feature, bugfix):

1. Read `.workflows/manifest.json` → find cross-cutting work units → read their work unit manifests for status → filter to completed specs
2. Assess relevance to the feature being planned
3. Present relevant specs to user for confirmation
4. Pass confirmed specs to planning process as cross-cutting context
5. Planning process incorporates them (existing logic — phase design, task design, cross-cutting references section)

No changes needed to planning process itself — it already knows how to handle cross-cutting specs when provided.

Feature and bugfix won't assess "feature vs cross-cutting" at spec completion (they're always features), but they WILL take into account project-level cross-cutting concerns when they reach planning. This was the original motivation for the entire proposal.

### Spec Change Detection (Self-Resolving)

Current mechanism: planning stores `spec_commit` (git hash) at plan creation. On resume, it diffs the specification (and any cross-cutting spec paths) against that hash. If changes detected, user chooses `continue` (walk through plan, amend) or `restart` (wipe and re-plan). The hash then updates to current HEAD.

This concern was raised because if a cross-cutting spec is edited after being referenced by a plan, it could interfere with existing plans. Investigation confirmed the existing mechanism handles this:

| Plan status | Cross-cutting spec edited | What happens |
|---|---|---|
| **Completed** | After completion | Nothing — plan is frozen, implementation follows the plan as authored |
| **In-progress** | While planning | Next `continue-planning` detects the diff via `spec_commit`, user decides |
| **Not yet created** | Before planning | Plan authored from latest spec, no issue |

Edge case of "edit only intended for future plans" self-resolves: completed plans don't re-enter planning. In-progress plans should incorporate the change — as discussed: "if a plan is in progress, perhaps it should use the edits, otherwise those edits wouldn't be needed to be made." And: "if the topic of the change is big enough, then it would be a new spec, not an edit anyway."

### Migration

Two migrations needed, run via the existing migration system (idempotent scripts in `skills/workflow-migrate/scripts/migrations/`):

**Migration A: Build project manifest**

Scan existing `.workflows/*/manifest.json` files, build `.workflows/manifest.json` with name and work type for each work unit. This is a standard migration — no different to the others we've done.

**Migration B: Promote existing cross-cutting specs**

For epic work units with specs tagged `type: cross-cutting`:
- Auto-promote each to its own cross-cutting work unit (same mechanics as runtime promotion: create work unit, move discussion group + spec, record provenance, mark `promoted` in epic, register in project manifest)
- This must be done properly — the result should be exactly the same as if promotion had happened at runtime after this feature was released. Seamless, no exceptions

For feature/bugfix work units with specs tagged `type: cross-cutting`:
- Strip the `type` field. This was always a bug — a feature/bugfix tagged as cross-cutting would break the pipeline (can't proceed to planning). The field is removed; the work unit continues as-is

For all specs: remove the `type` field from manifests (it no longer exists in the schema).

## Resolved Questions

### 1. Spec-type tagging → removed, replaced by auto-promotion

Cross-cutting is a work type, not a spec attribute. The `type: feature | cross-cutting` field on specs is removed entirely:

- **Feature/bugfix**: Always a feature-type spec by definition — no assessment at spec completion. However, project-level cross-cutting concerns are checked during planning
- **Cross-cutting work type**: No assessment — already known to be cross-cutting
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
- `.workflows/manifest.json` — matches naming convention
- Stores name and work type only — stable index, not a state mirror
- Mutable state (status, phases, topics) stays in work unit manifests — avoids dual-update sync bugs
- Discovery reads one file to know what exists and what type, then selectively opens only the work unit manifests needed
- Simplifies discovery scripts across the board — no more scanning every directory

### 4. Research phase → optional, same as epic/feature

- Include research as optional for directly-created cross-cutting work units
- As discussed: "I want to define caching ideas but need to bounce ideas around first. I know its cc but dont have all the details"
- Reuses existing research, discussion, specification skills — nothing new needed
- Bridge just needs to know to stop at end of specification
- Keeps pipeline shapes more consistent across work types — "keeps more things the same too"

### 5. No epic-scoped cross-cutting

- All cross-cutting specs live at project level — see "Why No Epic-Scoped Cross-Cutting" above
- Could revisit if a real need emerges, but simplicity wins for now

### 6. Migration → auto-promote existing cc specs

- Existing cc-tagged specs in epics are auto-promoted via migration script (same mechanics as runtime promotion)
- Existing cc-tagged specs in feature/bugfix have the type field stripped (it was a bug — would have broken the pipeline)
- Project manifest built from existing work units
- Result should be seamless — identical to what would happen at runtime after this feature ships

### 7. Bridge as pipeline authority

- Spec-completion should always invoke the bridge; bridge handles terminal conditions per work type
- Bridge delegates to discovery script to know that for cross-cutting, pipeline is done after specification
- Single pipeline state machine, not split across individual phase skills

### 8. Separate start/continue skills

- `start-cross-cutting` and `continue-cross-cutting` as separate skills, matching existing conventions (one pair per work type)

## Open Questions

### 1. Project manifest structure

What fields beyond work unit registry? Candidates:
- Default plan format (currently in environment setup — could move here, but topic-level overrides may still be needed)
- Project-level metadata
- To be determined during implementation — start minimal (name + type), extend as needs emerge

### 2. Promotion UX details

- Prompt wording at spec completion (how the assessment is presented)
- What if user declines (says it's a feature) but later realises it should be cross-cutting? See [topic-level-management.md](topic-level-management.md) for after-the-fact reclassification

### 3. Discovery script impact

Project manifest replaces directory scanning. How much of the existing discovery infrastructure changes? Likely simplifies significantly but needs audit during implementation.

### 4. Work unit name collision on promotion

When promoting a topic from an epic, the topic name becomes the work unit name. If a work unit with that name already exists, collision handling is needed. Approach TBD.

## Implementation Readiness

### Infrastructure Touch Points

These are identified from codebase analysis — the files that need changes:

| Area | File(s) | Change |
|------|---------|--------|
| Manifest CLI | `manifest.js` | Add `cross-cutting` to `VALID_WORK_TYPES`; add `promoted` to valid spec statuses |
| Pipeline state machine | `discovery-utils.js` `computeNextPhase()` | Add cc terminal condition (spec completed → done) |
| Bridge | `workflow-bridge/SKILL.md` | Add cc branch (terminal after spec, delegating to discovery script) |
| Work unit creation | `workflow-start/` | Add cc as 4th option |
| Continue skill | New `continue-cross-cutting/` | New skill, pipeline: research → discussion → spec |
| Start skill | New `start-cross-cutting/` | New entry-point skill |
| Spec completion | `spec-completion.md` | Epic-only assessment; if cc → auto-promote. Skip for feature/bugfix/cc work types |
| Spec format | `specification-format.md` | Remove `type` field from schema |
| Planning entry | `cross-cutting-context.md` | Rewrite: read project manifest, find cc work units, load completed specs |
| Planning entry | `validate-spec.md` | Remove cc identification from epic specs |
| Project manifest | `.workflows/manifest.json` | New file, created on first work unit creation |
| All creation flows | Various | Register in project manifest on creation |
| Discovery scripts | `workflow-start/discovery.js`, `continue-*/discovery.js` | Add cc to type filtering |
| Epic displays | `continue-epic` | Show promoted topics as `(promoted)`, don't offer for continuation |
| Migrations | New scripts | (A) build project manifest, (B) promote existing cc specs + strip type field |

### Edge Cases

1. **Work unit name collision on promotion** — topic name may already exist as a work unit. Need collision handling (open question)
2. **Promoted topic in epic displays** — `continue-epic` must show promoted topics as `(promoted)` and not offer them for continuation
3. **Discussion shared between specs** — if a discussion was grouped into two specs (unlikely but not prevented by the system) and one gets promoted, the discussion moves with it, leaving the other spec with a broken source reference. The grouping flow produces disjoint groups in practice, so this is unlikely

## Related

- [Topic-Level Management](topic-level-management.md) — reclassify and recall for after-the-fact changes (not required for initial build)
