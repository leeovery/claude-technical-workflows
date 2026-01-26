# Specification Command Redesign — Handoff

This document is the entry point for implementing the start-specification command redesign. It ties together three sets of planning documents that were produced during the design phase.

## What's Being Built

The start-specification command is being rebuilt as a skill with conditional reference file loading. Instead of one 810-line command file where Claude sees all steps regardless of path, the new structure splits the flow into separate files loaded only when relevant to the user's path.

## Planning Documents

### 1. Design Decisions & Display Formats — `SPEC-DISPLAY-REDESIGN.md`

The primary design reference. Contains:

- **Agreed display format** — nested tree with `└─` / `├─` hierarchy
- **11 design decisions** — groupings shown immediately, title case, status vocabulary, extraction counts, anchored names, inline menu explanations, etc.
- **10 pathway outputs** — every possible entry condition (no discussions, single discussion, multiple with/without specs, cache valid/stale/none) with exact display text
- **Reorganized step structure** — old Steps 0-11 mapped to new Steps 0-8, with rationale for each removal/merge
- **Confirm selection formats** — all variants (creating, continuing, refining, superseding)
- **Discovery script improvements** — proposed `current_state` section with explicit counts
- **6 resolved questions** — pick individually removed, unified option added, verb logic, etc.

Start here to understand *what* to build.

### 2. Flow Scenarios — `SPEC-FLOWS/`

Eight documents showing every path through the command with exact prompts, user responses, and handoff text:

| File | Covers | Outputs |
|------|--------|---------|
| `01-blocks.md` | No discussions / none concluded | 1-2 |
| `02-single-discussion.md` | Single concluded discussion (±spec) | 3-4 |
| `03-multiple-no-specs-no-cache.md` | Multiple discussions, no specs, no cache | 5 |
| `04-multiple-no-specs-valid-cache.md` | Multiple discussions, no specs, valid cache | 6 |
| `05-multiple-no-specs-stale-cache.md` | Multiple discussions, no specs, stale cache | 7 |
| `06-multiple-with-specs-no-cache.md` | Multiple discussions, with specs, no cache | 8 |
| `07-multiple-with-specs-valid-cache.md` | Multiple discussions, with specs, valid cache | 9 |
| `08-multiple-with-specs-stale-cache.md` | Multiple discussions, with specs, stale cache | 10 |

Each document walks through complete scenarios step by step, including the discovery YAML output, display text, user interactions, and skill invocation handoff. Use these to verify the implementation handles every path correctly.

### 3. Architecture & Implementation — `SKILL-ARCHITECTURE-PLAN.md`

The technical plan for *how* to build it. Contains:

- **Proposed skill directory structure** — SKILL.md + 7 reference files
- **What each file contains** — content breakdown for every reference file
- **Path analysis** — which files load for each output, with estimated token savings
- **Implementation notes** — current command state (810 lines, old Steps 0-11), instruction to go straight to skill structure (skip monolithic rewrite), discovery script improvements timing
- **Anchored names mechanism** — full explanation of how spec names are preserved during analysis
- **Frontmatter strategy** — `disable-model-invocation: true` for workflow commands
- **Migration strategy** — 4 phases, start-specification first as proof of concept
- **Open questions** — reference loading depth, allowed-tools inheritance, context budget, migration path

## Reading Order

1. `SKILL-ARCHITECTURE-PLAN.md` — Implementation Notes section first (understand the starting point)
2. `SPEC-DISPLAY-REDESIGN.md` — design decisions and step structure (understand the target)
3. `SPEC-FLOWS/` — reference as needed during implementation (verify specific paths)

## Pending Work (Not Part of This Handoff)

These items are logged but should be addressed separately:

- **Planning command superseded display** — `discovery-for-planning.sh` doesn't extract `superseded_by`. Logged in `SPEC-DISPLAY-REDESIGN.md` under "Still To Decide."
- **Cleanup** — remove `SPEC-DISPLAY-REDESIGN.md`, `SPEC-FLOWS/`, `SKILL-ARCHITECTURE-PLAN.md`, and this file once implementation is complete.
