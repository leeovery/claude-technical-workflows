# PR 14: Manifest CLI — Dot-Path Syntax

## Summary

Replace `--phase`/`--topic` flags with a simplified dot-path convention. Phase names are recognised as the first segment and routed through the same domain-aware resolution — callers never see `phases`, `items`, or internal structure.

## Background

This was originally documented as Option 2 in [PR13](PR13-MANIFEST-WILDCARD-TOPIC.md) but deferred in favour of the minimal `--topic "*"` change. Now that PR 13 is complete and wildcard support is proven, this PR delivers the full syntax simplification.

## Problem

The current `--phase`/`--topic` flag syntax is verbose and redundant:

```bash
$MANIFEST get my-epic --phase discussion --topic auth-flow status
$MANIFEST set my-epic --phase discussion --topic auth-flow status completed
$MANIFEST init-phase my-epic --phase discussion --topic auth-flow
$MANIFEST get my-epic --phase discussion --topic "*" status
```

Every call requires both flags even though phase and topic form a natural hierarchy. The dot-path is more concise and makes wildcards feel native.

## Design

### New Syntax

```bash
# Phase + topic + field
$MANIFEST get my-epic discussion.auth-flow.status
$MANIFEST set my-epic discussion.auth-flow.status completed

# Wildcard (all topics in a phase)
$MANIFEST get my-epic discussion.*.status

# Phase-level init
$MANIFEST init-phase my-epic discussion.auth-flow

# Push to array
$MANIFEST push my-epic implementation.auth-flow.completed_tasks "auth-1-1"

# Work-unit-level (unchanged)
$MANIFEST get my-epic work_type
$MANIFEST set my-epic status completed
$MANIFEST delete my-epic phases.research.analysis_cache
$MANIFEST exists my-epic
$MANIFEST list
```

### Resolution Rules

The CLI recognises known phase names (`research`, `discussion`, `investigation`, `specification`, `planning`, `implementation`, `review`) as the first dot-path segment. When detected:

- `{phase}.{topic}.{field}` → routes through `resolvePhaseSegments` (same abstraction as current flags)
- `{phase}.*.{field}` → wildcard collection (same as current `--topic "*"`)
- `{phase}.{topic}` (no field) → used by `init-phase`, returns full topic object for `get`

Paths that don't start with a known phase name are treated as work-unit-level dot paths (existing behaviour).

### Migration

- Flag syntax (`--phase`, `--topic`) continues to work during transition (deprecated, not removed)
- All skill files updated to dot-path syntax
- CLAUDE.md grammar examples updated
- Deprecation warning emitted when flags are used (optional)

## Touch Points

- `skills/workflow-manifest/scripts/manifest.js` — dot-path parsing, phase detection, flag deprecation
- `skills/workflow-manifest/SKILL.md` — full API docs update
- All skill files using `--phase`/`--topic` — syntax migration
- All agent files using manifest CLI — syntax migration
- `tests/scripts/test-workflow-manifest.sh` — dot-path tests, flag backwards-compat tests
- `CLAUDE.md` — update CLI grammar section
- Migration script — update any manifest calls in migration files (or leave as-is since migrations are point-in-time snapshots)
