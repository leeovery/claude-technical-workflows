# Skill-Based Architecture Plan

Plan for refactoring workflow commands into the skill directory structure, leveraging conditional reference file loading to reduce context pollution and token usage.

## Background

### What Changed

Custom slash commands have been merged into skills ([docs](https://code.claude.com/docs/en/skills)). Files in `.claude/commands/` continue to work, but skills are the recommended path forward. A skill at `.claude/skills/review/SKILL.md` and a command at `.claude/commands/review.md` both create `/review` and work the same way. Skills add: a directory for supporting files, frontmatter to control invocation, and the ability for Claude to load them automatically when relevant.

### Key Skill Features We Can Leverage

1. **Multi-file directory structure**: Each skill is a directory with `SKILL.md` as the entrypoint. Supporting files (references, templates, scripts) live alongside it and are loaded on demand.

2. **Conditional reference loading**: Reference files from `SKILL.md` via markdown links. Claude loads them when needed, not all at once. This is the critical feature — it means instructions for paths not taken never enter context.

3. **Invocation control via frontmatter**:
   - `disable-model-invocation: true` — only the user can invoke (prevents accidental model-triggered invocation)
   - `user-invocable: false` — only Claude can invoke (background knowledge)
   - Default: both user and Claude can invoke

4. **Supporting files are not auto-loaded**: Only `SKILL.md` and its description enter context initially. Full content loads when invoked, and reference files load only when Claude follows the markdown link.

### Why This Matters for Complex Flows

The current `start-specification.md` command file contains all 8 steps in one file. When a user has a single concluded discussion (Outputs 3-4), Claude still has Steps 4-6 (the entire analysis flow) in context — instructions it will never use on that path.

**Problems with the monolithic approach:**
- **Context pollution**: Claude sees all steps, even irrelevant ones. Steps for paths not taken still influence the probability distribution for next-token generation.
- **Token cost**: Every invocation pays for the full file regardless of which path is taken.
- **Instruction interference**: Conditional sections ("if X, do Y; otherwise skip") require Claude to track which conditions apply. Separate files eliminate this tracking entirely — if the file isn't loaded, those instructions don't exist.

**What conditional loading gives us:**
- Each path through the command only loads the files relevant to that path
- Claude never sees instructions for steps it won't execute
- Token usage scales with path complexity, not total command complexity
- No "ignore this section" cognitive overhead

## Proposed Architecture

### Current Structure

```
commands/
  workflow/
    start-specification.md     # Monolithic: Steps 0-8, all 10 outputs
    start-planning.md          # Steps 0-7
    start-discussion.md        # Steps 0-N
    start-implementation.md    # Steps 0-N
    start-review.md            # Steps 0-N
    start-research.md          # Steps 0-N
    status.md                  # Status display
    view-plan.md               # Plan viewer

  start-feature.md             # Standalone
  link-dependencies.md         # Standalone
  migrate.md                   # Standalone

skills/
  technical-specification/     # Skill (processes inputs)
  technical-planning/          # Skill (processes inputs)
  technical-discussion/        # Skill (processes inputs)
  technical-implementation/    # Skill (processes inputs)
  technical-review/            # Skill (processes inputs)
  technical-research/          # Skill (processes inputs)
```

### Proposed Structure

```
skills/
  # Workflow commands → skills with conditional references
  start-specification/
    SKILL.md                     # Steps 0-3: discovery, prerequisites, routing
    references/
      display-blocks.md          # Outputs 1-2 (no concluded discussions)
      display-single.md          # Outputs 3-4 (single discussion, auto-proceed)
      display-analyze.md         # Outputs 5/7 (no cache, proceed to analysis)
      display-groupings.md       # Outputs 6/9 (valid cache, show groupings)
      display-specs-menu.md      # Outputs 8/10 (specs exist, offer menu)
      analysis-flow.md           # Steps 4-6 (context, analyze, show results)
      confirm-and-handoff.md     # Steps 7-8 (confirm selection, invoke skill)

  start-planning/
    SKILL.md                     # Steps 0-3: discovery, routing, display
    references/
      output-selection.md        # Step 4: choose output format
      context-and-handoff.md     # Steps 5-7: context, cross-cutting, invoke

  start-discussion/
    SKILL.md
    references/
      ...                        # TBD based on command analysis

  start-implementation/
    SKILL.md
    references/
      ...                        # TBD based on command analysis

  start-review/
    SKILL.md
    references/
      ...                        # TBD based on command analysis

  start-research/
    SKILL.md
    references/
      ...                        # TBD based on command analysis

  status/
    SKILL.md                     # Likely stays monolithic (no conditional paths)

  view-plan/
    SKILL.md                     # Likely stays monolithic

  # Standalone commands → skills
  start-feature/
    SKILL.md
    references/
      ...                        # TBD

  link-dependencies/
    SKILL.md

  migrate/
    SKILL.md

  # Processing skills (unchanged, already skill-structured)
  technical-specification/
    SKILL.md
    references/
      ...

  technical-planning/
    SKILL.md
    references/
      ...

  technical-discussion/
    SKILL.md
    references/
      ...

  technical-implementation/
    SKILL.md
    references/
      ...

  technical-review/
    SKILL.md
    references/
      ...

  technical-research/
    SKILL.md
    references/
      ...
```

### Frontmatter Strategy

**Workflow commands (user-triggered, sequential):**
```yaml
---
name: start-specification
description: Start a specification session from concluded discussions
disable-model-invocation: true
allowed-tools: Bash(.claude/scripts/discovery-for-specification.sh)
---
```

`disable-model-invocation: true` prevents Claude from auto-triggering workflow commands based on keywords. These are explicit user actions.

**Processing skills (invoked by commands, not directly by users):**
```yaml
---
name: technical-specification
description: Build and refine specifications from source discussions
user-invocable: false
---
```

`user-invocable: false` keeps these out of the `/` menu since users invoke them indirectly via workflow commands.

**Note:** The current processing skills don't use `user-invocable: false`. This is a design decision to evaluate — there may be cases where direct invocation is useful.

## Deep Dive: start-specification Refactor

This is the primary candidate since we've already mapped all 10 outputs and 8 flow paths in detail.

### File Breakdown

#### `SKILL.md` — Always Loaded (~100-150 lines)

Contains:
- Frontmatter (name, description, disable-model-invocation, allowed-tools)
- Workflow context table (phase position)
- Critical instructions (STOP after interactions, don't skip steps)
- Step 0: Run migrations
- Step 1: Run discovery script
- Step 2: Check prerequisites (routes to `display-blocks.md` if blocked)
- Step 3: Routing logic — determines which display reference to load based on discovery output
- Navigation links to all reference files so Claude knows what's available

Does NOT contain: any display output format, analysis flow, confirm format, or handoff text.

#### `references/display-blocks.md` — Loaded for Outputs 1-2 (~20 lines)

Contains:
- Output 1: "No discussions found" block message
- Output 2: "No concluded discussions" block message with in-progress list
- STOP instruction

Loaded when: `concluded_count: 0`. Flow ends here.

#### `references/display-single.md` — Loaded for Outputs 3-4 (~40 lines)

Contains:
- Single discussion display format (nested tree with key)
- Auto-proceed text ("Automatically proceeding with...")
- Verb rule for single discussions (no spec → "Creating", in-progress → "Continuing", concluded → "Refining")
- Link to `confirm-and-handoff.md` for next step

Loaded when: `concluded_count: 1`. After display, proceeds to confirm.

#### `references/display-analyze.md` — Loaded for Outputs 5/7 (~40 lines)

Contains:
- Discussion list format (concluded + not-ready sections)
- Stale cache messaging (Output 7 variant)
- Analysis prompt text ("These discussions will be analyzed...")
- Confirm y/n format
- Decline path (graceful exit)
- Link to `analysis-flow.md` for next step

Loaded when: `concluded_count >= 2`, `spec_count: 0`, cache is none or stale.

#### `references/display-groupings.md` — Loaded for Outputs 6/9 and Step 6 (~80 lines)

Contains:
- Full groupings display format (nested tree)
- Key/legend
- "Not ready" section
- Tip about re-analyze
- Numbered menu format with inline explanations (Unify, Re-analyze)
- Menu option behaviour (which links to load based on user choice)
- Link to `confirm-and-handoff.md` for spec picks
- Link to `analysis-flow.md` for re-analyze
- Unified specification flow (update cache, proceed to confirm with supersede info)

Loaded when: valid cache exists (from Step 3 routing or after Step 6 analysis).

#### `references/display-specs-menu.md` — Loaded for Outputs 8/10 (~60 lines)

Contains:
- Existing specs display format (nested tree from frontmatter data)
- Unassigned discussions list
- "Not ready" section
- Key/legend
- Stale cache messaging (Output 10 variant)
- Numbered menu with inline explanations (Analyze, Continue existing)
- Menu option behaviour
- Link to `analysis-flow.md` for analyze choice
- Link to `confirm-and-handoff.md` for continue choice

Loaded when: `concluded_count >= 2`, `spec_count >= 1`, cache is none or stale.

#### `references/analysis-flow.md` — Loaded on demand (~50 lines)

Contains:
- Step 4: Gather analysis context (prompt, STOP)
- Step 5: Analyze discussions + save cache (anchored names, grouping logic)
- Step 6: After analysis, load `display-groupings.md` to show results
- Cache management instructions (delete stale, create new)

Loaded when: user chooses "Analyze for groupings" or "Re-analyze", or auto-proceeds to analysis (Outputs 5/7).

#### `references/confirm-and-handoff.md` — Loaded on demand (~80 lines)

Contains:
- Step 7: Confirm selection formats (all variants)
  - Creating new spec
  - Continuing spec with pending sources
  - Refining concluded spec
  - Creating grouped spec that supersedes
  - Unified spec with supersede list
- Verb rule (Creating/Continuing/Refining)
- Decline path (graceful exit)
- Step 8: Invoke skill handoff format
- Link to technical-specification skill

Loaded when: user has made a selection (from any display reference).

### Path Analysis — What Gets Loaded

| Path | Files Loaded | Estimated Tokens |
|------|-------------|-----------------|
| Output 1-2 (blocks) | SKILL.md + display-blocks.md | ~200 lines |
| Output 3-4 (single) | SKILL.md + display-single.md + confirm-and-handoff.md | ~270 lines |
| Output 6/9 (valid cache) | SKILL.md + display-groupings.md + confirm-and-handoff.md | ~310 lines |
| Output 8/10 (specs, continue) | SKILL.md + display-specs-menu.md + confirm-and-handoff.md | ~290 lines |
| Output 5/7 (analyze) | SKILL.md + display-analyze.md + analysis-flow.md + display-groupings.md + confirm-and-handoff.md | ~400 lines |
| Output 8/10 (specs, analyze) | SKILL.md + display-specs-menu.md + analysis-flow.md + display-groupings.md + confirm-and-handoff.md | ~410 lines |

**Current monolithic file**: All paths load everything (~500+ lines).

**Savings**: Block paths load ~40% of current. Single-discussion paths load ~55%. Even the most complex analysis path loads ~80% (and that content is all relevant). The biggest win is for the common case — valid cache with groupings — which loads ~60%.

### Shared Content Considerations

Some content appears across multiple display references:
- **Key/legend**: Appears in groupings, specs-menu, single, and analyze displays. Options: (a) duplicate in each file (it's small, ~15 lines), (b) create a `key-legend.md` reference loaded by display files. Duplication is probably fine given the size.
- **"Not ready" section**: Appears in groupings, specs-menu, and analyze displays. Same consideration — small enough to duplicate.
- **Graceful exit message**: Used in single-discussion decline and analysis decline. One line, just duplicate.

Recommendation: duplicate small shared content rather than adding another layer of reference indirection. Keep the file structure flat and simple.

## Migration Strategy

### Phase 1: start-specification (Primary)

This is the most complex command and the one we've fully designed flows for. Refactor this first as a proof of concept.

1. Create `skills/start-specification/` directory structure
2. Write SKILL.md with routing logic (Steps 0-3)
3. Extract each reference file from the flow documents and tracking file
4. Verify each path loads only the files it needs
5. Test all 10 outputs
6. Remove `commands/workflow/start-specification.md`

### Phase 2: Other Workflow Commands

Analyze each remaining workflow command for conditional paths and refactor where beneficial:

- **start-planning**: Has conditional paths (no specs, single spec, multiple specs, output format selection). Good candidate.
- **start-discussion**: Needs analysis of step structure.
- **start-implementation**: Needs analysis.
- **start-review**: Needs analysis.
- **start-research**: Needs analysis.
- **status/view-plan**: Likely stay monolithic — no complex conditional paths.

### Phase 3: Standalone Commands

- **start-feature**: May benefit from reference splitting if complex.
- **link-dependencies**: Likely stays monolithic.
- **migrate**: Likely stays monolithic (orchestrator only).

### Phase 4: Processing Skills

Evaluate whether existing processing skills (technical-specification, etc.) should adopt `user-invocable: false`. These are currently invokable by both users and Claude — determine if direct user invocation is a valid use case.

## Composer Package Considerations

This project is distributed via Composer as `leeovery/claude-technical-workflows`. The current structure installs into `.claude/` with commands and skills. The refactor needs to maintain Composer compatibility:

- Skills install to `.claude/skills/` (already the case for processing skills)
- Commands currently install to `.claude/commands/` — these move to `.claude/skills/`
- Scripts stay in `.claude/scripts/`
- The `allowed-tools` frontmatter references script paths relative to `.claude/`
- Composer's `extra.claude` config may need updating for new paths

## Open Questions

1. **Reference loading depth**: Can a reference file link to another reference file? (e.g., `analysis-flow.md` links to `display-groupings.md`). The docs suggest this works since Claude follows markdown links, but needs verification.

2. **Allowed-tools inheritance**: When a reference file is loaded, does it inherit the `allowed-tools` from the skill's frontmatter? The docs suggest tools are scoped to the skill, not individual files, so this should work.

3. **Context budget**: Skill descriptions are loaded into a context budget (default 15,000 chars). With more skills (commands becoming skills), we need to check we don't exceed this. The `SLASH_COMMAND_TOOL_CHAR_BUDGET` env var can increase it if needed.

4. **Migration path for existing users**: Users upgrading the Composer package will have both old commands and new skills temporarily. Since skills take precedence over commands with the same name, this should be seamless — but needs testing.

5. **Processing skill invocation**: Should processing skills use `user-invocable: false`? Current workflow has commands invoking skills, but some users might want to invoke a processing skill directly (e.g., "run the technical-specification skill on this file"). Need to decide.

## Dependencies

- Completion of the specification display redesign (current work)
- Flow documents finalized and reviewed
- Understanding of any skill system limitations through testing

## Related Files

- `SPEC-DISPLAY-REDESIGN.md` — current design tracking (display formats, step structure, flow paths)
- `SPEC-FLOWS/*.md` — detailed flow scenarios for all 10 outputs
- `commands/workflow/start-specification.md` — current monolithic command
- `scripts/discovery-for-specification.sh` — discovery script (unchanged by this refactor)
