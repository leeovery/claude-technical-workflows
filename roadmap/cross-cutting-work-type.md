# Cross-Cutting Work Type

Status: brainstorming
Date: 2026-03-15

## Problem

Cross-cutting specifications (caching strategies, rate-limiting policies, work conventions) currently live inside epic work units. They're tagged at spec completion but only consumed during that epic's planning phase. Feature and bugfix work types have no access to cross-cutting specs — they can't discover or reference them.

This means validated architectural decisions get siloed inside the epic that authored them, invisible to standalone features and bugfixes that should follow those same patterns.

## Proposal

Elevate cross-cutting concerns to a first-class work type.

### Core Design

**New work type: `cross-cutting`**

- Lives in `.workflows/{work-unit}/` like any other work unit — no special central directory
- Standard manifest, standard directory structure
- Pipeline: Discussion → Specification (no planning, implementation, or review — nothing to build)
- Created via `/workflow-start` alongside epic, feature, bugfix

**Project-level manifest**

- `.workflows/manifest.json` (or `project.json`) at the top level
- Tracks all work units: name, work type, status
- Serves as an index — no directory scanning needed for discovery
- Planning entry for any work type reads this manifest to find cross-cutting work units, loads their completed specs, filters for relevance
- Future use: project-level metadata, conventions, team info

**Epic promotion (provenance tracking)**

When an epic spec is tagged cross-cutting at completion, offer to promote it:

1. Creates new cross-cutting work unit (`.workflows/{topic}/`)
2. Copies discussion + specification (preserving the reasoning chain)
3. New manifest records provenance: `{ source_work_unit, source_topic }`
4. Original epic manifest marks that topic as `promoted`
5. Epic's own planning can still reference the spec internally

**Direct creation**

`/start-cross-cutting` or selecting `cross-cutting` at `/workflow-start`. Starts fresh with Discussion → Specification. No research phase (authoring intentionally, not discovering from broader exploration). Research could be optional if the user wants to explore patterns first.

### Planning Integration

Planning entry for ALL work types (epic, feature, bugfix):

1. Read project manifest → find cross-cutting work units with completed specs
2. Assess relevance to the feature being planned
3. Present relevant specs to user for confirmation
4. Pass confirmed specs to planning process as cross-cutting context
5. Planning process incorporates them (existing logic — phase design, task design, cross-cutting references section)

No changes needed to planning process itself — it already knows how to handle cross-cutting specs when provided.

## Open Questions

### 1. Remove spec-type tagging?

If cross-cutting is its own work type, does tagging specs as `feature` vs `cross-cutting` at completion still make sense?

Options:
- **Remove tagging entirely** — a cross-cutting concern is a work type, not a spec attribute. Features are features, cross-cutting is cross-cutting.
- **Keep tagging for epic only** — epics might still have internal cross-cutting specs that don't warrant promotion (e.g., patterns specific to that epic's scope)
- **Replace tagging with promotion prompt** — instead of "is this feature or cross-cutting?", ask "should this be promoted to a project-level cross-cutting work unit?"

### 2. Versioning / evolution

Cross-cutting specs may need to evolve over time. Options:
- Reopen the cross-cutting work unit, revise the spec
- New work unit that supersedes the old (provenance chain: `supersedes: "old-caching-strategy"`)
- Version field within the spec

### 3. Project manifest scope

If we're adding a project manifest, should ALL work unit creation/completion register there? This would make it the authoritative index for everything — simplifying discovery scripts across the board, not just for cross-cutting.

### 4. Research phase for direct creation

Should directly-created cross-cutting work units support an optional research phase? Scenario: "I want a caching strategy" → research existing patterns → discuss tradeoffs → specify. Could be useful but adds pipeline complexity.
