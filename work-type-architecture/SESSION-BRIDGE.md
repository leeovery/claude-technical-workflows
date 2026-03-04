# Session Bridge — Audit Round 3

## What We're Doing

This PR (`feat/work-type-architecture-v2`) implements work-type architecture for the workflow system. We've been through multiple rounds of implementation and auditing. The audit process uses a living checklist at `work-type-architecture/AUDIT-CHECKLIST.md` and dispatches 5 parallel agents to verify different aspects of the codebase.

## Current State

Rounds 1 and 2 complete. All fixes committed. Tests pass:
- 159/159 discovery tests
- 80/80 manifest CLI tests
- 118/118 migration tests

### Round 2 Results

5 agents dispatched. Sections 1–4, 6–9 all **CLEAN**. Section 5 had 5 findings:

| # | Decision | Detail |
|---|----------|--------|
| 1 | **Fixed** | Missing rendering instructions in `/migrate` SKILL.md |
| 2 | **False positive** | Fenced blocks for model instructions (bash commands, file paths) are exempt from rendering instructions |
| 3 | **False positive** | Intentional split display block pattern (header + iteration + per-item template) |
| 4 | **Fixed** | H3→H4 for conditionals in `/migrate` SKILL.md |
| 5 | **Fixed differently** | Consolidated ALL Step 0s — removed duplicated conditionals from 12 entry-point skills; `/migrate` owns the branching |

### Key Decisions Made in Round 2

- **Rendering instruction scope**: Only user-facing output blocks need rendering instructions. Bash command blocks and file path references are model instructions and are exempt.
- **Step 0 consolidation**: The `/migrate` skill owns the STOP gate and conditional branching for migration output. Entry-point skills just say "Invoke the `/migrate` skill and assess its output." — no duplicated conditionals.

## What Needs to Happen Next

**Dispatch Round 3 agents** against the full checklist (`work-type-architecture/AUDIT-CHECKLIST.md`), which now includes sections 1–12. The new sections (10–12) verify Round 2 fixes:
- §10: Step 0 consolidation
- §11: Rendering instruction scope
- §12: Migrate skill convention compliance

## Key Context

- **work_units not items**: workflow-start discovery uses `epics.work_units`, `features.work_units`, `bugfixes.work_units`
- **Topicless phases**: manifest CLI allows `--phase` without `--topic` ONLY for research
- **phaseData/phaseItems**: discovery scripts must use these abstractions from `discovery-utils.js`
- **Status discovery `work_units`**: the `work_units` key in `skills/status/scripts/discovery.js` is correct — different semantic context
- **Rendering instructions**: Only for user-facing output blocks, not model instruction blocks
- **Step 0**: `/migrate` owns the branching; callers just invoke and assess

## Files to Read

- `work-type-architecture/AUDIT-CHECKLIST.md` — the living audit checklist (sections 1–12)
- `work-type-architecture/AUDIT-ROUND1-FIXES.md` — fix tracker from Round 1 (all completed)
- `work-type-architecture/ARCHITECTURE-FIX-PLAN.md` — the original 8-fix architecture plan
- `work-type-architecture/DISCOVERY-CLEANUP-PLAN.md` — the 7-fix discovery cleanup plan
- `work-type-architecture/RESEARCH-STATUS-PLAN.md` — research status support plan
- `CLAUDE.md` — project conventions (the authority for all convention checks)
