# Design: Unified Entry Point & Work Type Flow

## Context

PR #133 (`feat/context-aware-planning`) adds context-aware phase and task design to the planning phase. Instead of always mandating a walking skeleton (greenfield approach), it extracts greenfield content to a dedicated context file and adds `feature` and `bugfix` alternatives. The right context is dispatched via a `work_type` field in the plan frontmatter.

The PR works — context files exist, dispatch mechanism works, agents read the right guidance, all tests pass. But during review, a design question emerged about *where* `work_type` should originate.

---

## The Problem

Currently, `begin-planning` (a bridge skill, not user-invocable) hardcodes `Work type: feature` in its handoff to `technical-planning`. This is the only place `work_type` gets set in the pipeline.

Issues with this:

1. **Too deep in the process** — `begin-planning` is called by `continue-feature`, which is called after `start-feature`. The intent is known at the very top (`start-feature`), but the value isn't set until several layers in.

2. **Bridge skills should relay, not decide** — `begin-planning` is a handoff skill. It shouldn't be the one determining work type; it should receive it from upstream and pass it through.

3. **Hardcoded `feature` is wrong for other paths** — if someone uses the pipeline for a greenfield project or a bugfix (which is possible), they'd incorrectly get feature guidance.

4. **Standalone `start-planning` passes nothing** — falls back to universal principles, which works but means standalone users never get context-specific guidance unless they also happen to set `work_type` manually.

---

## The Discussion

### Where should work_type originate?

Work type is a *user intent* — "I'm building a new product", "I'm adding a feature", "I'm fixing a bug". It should be declared at the very start of the workflow and carried through every phase, not injected midway by a bridge skill.

`start-feature` already knows it's a feature from the moment it's invoked. The work_type should be set there and threaded through: `start-feature` → `continue-feature` → `begin-planning` → `technical-planning`. The bridge relays, doesn't decide.

### This leads to a bigger question: too many entry points?

Current user-invocable entry points:
- `/start-feature` — full pipeline (discussion → spec → plan → impl → review)
- `/continue-feature` — continue through pipeline phases
- `/start-research`, `/start-discussion`, `/start-specification`, `/start-planning`, `/start-implementation`, `/start-review` — standalone phase entry points
- `/status` — show workflow status
- `/link-dependencies` — link dependencies across topics
- `/view-plan` — view plan tasks

The idea: rather than separate commands for each work type (`start-feature`, `start-bugfix`, future `start-greenfield`), consider a **unified entry point** that:

1. Discovers the current project state
2. Asks the user what they want to do (build the product, add a feature, fix a bug)
3. Sets `work_type` based on their answer
4. Routes them to the right place

### Possible command structure (brainstorming, names TBD)

Option A — one command, always asks:
- `/workflow` → "What would you like to do?" → routes accordingly

Option B — family of commands:
- `/workflow` → asks what to do (generic entry point)
- `/workflow feature` → starts/continues a feature (replaces start-feature + continue-feature)
- `/workflow bugfix` → starts/continues a bugfix
- `/workflow build` (or similar, name TBD for greenfield) → starts/continues product build

Either way, the unified entry point would:
- Discover project state (what phase are things in, what's actionable)
- Offer contextual options based on that state
- Set `work_type` upfront and carry it through the pipeline
- Potentially consolidate `start-*` and `continue-*` into a single flow per work type

### What about knowing when "building the product" is done?

We don't need to solve this precisely right now. Just ask the user every time. Later, we could track whether the initial product build is complete and stop offering it as an option. Once the product is built, it's always feature or bugfix (or security scan, or other future work types).

### The key engineering challenge

A robust way to store the `work_type` declaration so it flows through the entire process. Options:
- Pipeline context (already exists in session state for compaction recovery)
- Frontmatter in workflow artifacts (plan already has `work_type`)
- Could extend to discussion and specification frontmatter too

---

## What the Current PR Delivers (Consumption Side)

All of this is needed regardless of how the entry point evolves:

- 6 context files: `phase-design/{greenfield,feature,bugfix}.md`, `task-design/{greenfield,feature,bugfix}.md`
- Refactored `phase-design.md` and `task-design.md` with universal principles and dispatch sections
- `work_type` field in plan-index-schema frontmatter
- Dispatch plumbing in `define-phases.md` and `define-tasks.md`
- Agent updates in `planning-phase-designer.md` and `planning-task-designer.md`
- `begin-planning` hardcodes `Work type: feature` (placeholder — will be replaced when entry point redesign lands)

---

## Future Consideration: Implementation-Level Work Type Awareness

Currently, `work_type` is used during planning (phase design, task design) but not during implementation. The executor agent has generic codebase guidance that works across all work types.

**Current state:**
- Plan Index File stores `work_type`
- `technical-implementation` and executor agent don't read or use it
- Executor guidance is generic: "find similar implementations, understand inputs/outputs, note testing patterns"

**Question for later:** Does implementation need work-type-specific guidance?

- **Bugfix** implementation could emphasize extra caution about minimal changes, understanding side effects
- **Feature** implementation could emphasize integration testing, pattern consistency
- **Greenfield** implementation might not need codebase analysis at all in early phases

**Current thinking:** The implementation guidance is probably generic enough. Work-type-specific concerns are addressed during planning — the tasks themselves carry that context forward. The executor just needs to "follow existing patterns" regardless of type.

This can be revisited after seeing how the current approach works in practice. If implementation struggles in work-type-specific ways, we can add context dispatch at that level too.

---

## Next Steps

1. **Merge PR #133** — the consumption mechanism is correct and all tests pass
2. **Design the unified entry point** — decide on command naming, routing logic, and how work_type flows from top to bottom
3. **Thread work_type through the pipeline** — `start-feature` (or unified command) sets it, carried through `continue-feature` → bridge skills → processing skills
4. **Consider consolidating start/continue** — may not need separate commands if the unified entry point handles both
5. **Future: `start-bugfix`** — or its equivalent in the unified command family
6. **Evaluate implementation-level work type awareness** — after observing the current approach in practice
