# Progressive Disclosure Tracker

Split monolithic `start-*` entry-point skills into backbone + reference files pattern, matching the progressive disclosure structure already used by processing skills (`technical-planning`, `technical-implementation`).

**Conventions:** [conventions.md](conventions.md)

---

## Skills

Ordered by complexity. Work through in order — simpler skills establish patterns for harder ones.

- [x] **start-research** (62 lines) — Simple linear flow. 2 references: gather-context, invoke-skill. *(PR #96)*
- [ ] **start-review** (173 lines) — Linear with discovery script
- [ ] **start-planning** (290 lines) — Linear with discovery script + format selection
- [ ] **start-implementation** (338 lines) — Linear with discovery script + plan reading + format loading
- [ ] **start-discussion** (391 lines) — Linear with discovery script + topic creation/resume
- [ ] **start-specification** (851 lines) — Complex: discovery + 10 output paths + conditional routing + display redesign. Planning docs: [start-specification/](start-specification/)
- [ ] **start-feature** (82 lines) — Standalone entry point (no prior phase). May not need splitting at this size.

---

## Planning Documents

Most skills are straightforward enough to split without advance planning. `start-specification` is the exception — it has 10 output paths and a display redesign bundled with the split.

| Skill | Documents |
|-------|-----------|
| start-specification | [plan.md](start-specification/plan.md) — implementation plan |
| | [display-design.md](start-specification/display-design.md) — display format decisions, all 10 outputs |
| | [flows/](start-specification/flows/) — flow-by-flow test cases for each output path |
