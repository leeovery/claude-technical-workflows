# Progressive Disclosure Tracker

Split monolithic `start-*` entry-point skills into backbone + reference files pattern, matching the progressive disclosure structure already used by processing skills (`technical-planning`, `technical-implementation`).

**Conventions:** [conventions.md](conventions.md)

---

## Skills

Ordered by complexity. Work through in order — simpler skills establish patterns for harder ones.

- [x] **start-research** (62 lines) — Simple linear flow. 2 references: gather-context, invoke-skill. *(PR #96)*
- [x] **start-specification** (851 lines → backbone + 14 reference files) — Complex: discovery + conditional routing + display redesign. *(PR #97)*
- [x] **start-review** (243 lines → backbone + 3 reference files) — Linear discovery + display/select/invoke extraction. *(PR #106)*
- [x] **start-planning** (310 lines → backbone + 3 reference files) — Linear discovery + display/cross-cutting/invoke extraction.
- [x] **start-implementation** (338 lines → backbone + 5 reference files) — Linear with discovery script + plan reading. References: validate-plan, check-dependencies, environment-check, display-plans, invoke-skill.
- [x] **start-discussion** (391 lines → backbone + 8 reference files) — Discovery inline, 3-path gather-context router. *(PR #99)*
- [x] **start-investigation** (backbone + 6 reference files) — Two-mode pattern (discovery vs bridge). References: validate-investigation, route-scenario, gather-context-discovery, gather-context-bridge, topic-conflict-check, invoke-skill.
- [ ] **start-feature** (82 lines) — Standalone entry point (no prior phase). May not need splitting at this size.

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
   - See [conventions.md](conventions.md) — Interactive Formatting section
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
