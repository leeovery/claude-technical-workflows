# Progressive Disclosure Tracker

Split monolithic `start-*` entry-point skills into backbone + reference files pattern, matching the progressive disclosure structure already used by processing skills (`technical-planning`, `technical-implementation`).

**Conventions:** See CLAUDE.md — "Skill File Structure (Progressive Disclosure)" and "Structural Conventions" sections. These are the authoritative source.

---

## Skills

All entry-point skills have been refactored to the backbone + reference files pattern.

- [x] **start-research** (62 lines) — Simple linear flow. 2 references: gather-context, invoke-skill. *(PR #96)*
- [x] **start-specification** (backbone + 20 reference files) — Complex: discovery + conditional routing + display redesign. *(PR #97)*
- [x] **start-review** (backbone + 6 reference files) — Discovery + display/select/invoke extraction.
- [x] **start-planning** (backbone + 6 reference files) — Discovery + display/cross-cutting/invoke extraction.
- [x] **start-implementation** (backbone + 6 reference files) — Discovery + plan reading + dependency checking.
- [x] **start-discussion** (backbone + 10 reference files) — Two-mode pattern. Unified gather-context router (bridge/fresh/research/continue).
- [x] **start-investigation** (backbone + 5 reference files) — Two-mode pattern. Unified gather-context router (bridge/fresh). Topic-conflict-check merged into gather-context-fresh.
- [x] **start-feature** (backbone + 6 reference files) — Standalone entry point with research gating.
- [x] **start-bugfix** (backbone + 3 reference files) — Standalone entry point for bugfix pipeline.

### Step consolidation passes

After the initial progressive disclosure split, a second pass consolidated duplicate bridge/discovery gather-context steps:

- **start-discussion** — Merged gather-context-bridge + gather-context-discovery into unified gather-context router with source-based routing. Reduced backbone from 10 steps to 8.
- **start-investigation** — Merged gather-context-bridge + gather-context-discovery + topic-conflict-check into unified gather-context router. Reduced backbone from 9 steps to 7.

---

## start-specification Progress

### Completed

1. **Initial refactor** (PR #97) — split monolithic SKILL.md into backbone + 7 reference files
2. **Spec source regression fixes** — 5 logic gaps identified and fixed:
   - `discovery.sh`: added `discussion_status` enrichment to spec sources
   - Regressed source detection (`extracted, reopened`) across display files
   - Grouped spec coverage detection in single-discussion path
   - Verb override: concluded + pending sources → "Continuing" (not "Refining")
   - `not-found` discussion_status handling (silently skip, don't show as reopened)
   - Extraction count formulas (groupings uses union, others use spec count)
   - Not-ready sections on all display paths
   - See [spec-source-regression-analysis.md](start-specification/spec-source-regression-analysis.md)
3. **Formatting conventions aligned** with start-planning/start-implementation:
   - Dotted line separators around choice sections
   - Letter shortcuts for y/n prompts
   - H4 conditional headings (replacing bold conditionals)
   - Routing arrows (`→`) on load/proceed instructions
   - Separated numbered menu prompts
4. **display-single.md extracted** into progressive disclosure:
   - Router: `display-single.md` (24 lines, pure routing)
   - `display-single-no-spec.md` — no spec path
   - `display-single-has-spec.md` — individual spec path
   - `display-single-grouped.md` — grouped spec path
5. **display-groupings.md refined**:
   - Status determination: numbered list → H4 conditionals
   - Menu section: clear intro, assembled example, consolidated meta options
   - Routing: flattened numbered lists → plain instructions with arrows
6. **SKILL.md routing simplified**:
   - Step 2: H4 conditionals, "Otherwise" for else branch
   - Step 3: dropped redundant `concluded_count >= 2`, final condition → "Otherwise"

7. **Remaining file reviews completed**:
   - `display-specs-menu.md` — lettered phases, menu clarity, routing flattened
   - `confirm-and-handoff.md` — extracted into progressive disclosure (4 confirm files)
   - `display-analyze.md` — convention fixes applied
   - `analysis-flow.md` — lettered phases added
   - `display-blocks.md` — convention fixes applied

---

## Planning Documents

Most skills are straightforward enough to split without advance planning. `start-specification` is the exception — it has 10 output paths and a display redesign bundled with the split.

| Skill | Documents |
|-------|-----------|
| start-specification | [plan.md](start-specification/plan.md) — implementation plan |
| | [display-design.md](start-specification/display-design.md) — display format decisions, all 10 outputs |
| | [flows/](start-specification/flows/) — flow-by-flow test cases for each output path |
| | [spec-source-regression-analysis.md](start-specification/spec-source-regression-analysis.md) — regression gap analysis |
