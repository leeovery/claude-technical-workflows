# Workflow Updates Plan

Tracking document for systematically updating all workflow commands and skills to align with recent improvements.

## Reference Implementation

**`commands/workflow/start-specification.md`** is the reference for:
- Stricter layout and formatting
- Flattened step counts (Step 0, Step 1, Step 2... not Step 2.1, 2.2)
- Clear STOP points after user interactions
- Discovery script pattern (bash script outputs YAML, command parses it)
- Explicit routing based on state

**`scripts/specification-discovery.sh`** is the reference for:
- Centralized discovery logic in bash
- Structured YAML output
- Frontmatter extraction helpers
- Checksum computation for caching

---

## Changes to Apply

### A. Migration System (Step 0)

All workflow commands must invoke `/migrate` as Step 0.

| Command | Has Step 0 | Notes |
|---------|------------|-------|
| `workflow/start-research.md` | ✅ | Done |
| `workflow/start-discussion.md` | ✅ | Done |
| `workflow/start-specification.md` | ✅ | Done |
| `workflow/start-planning.md` | ✅ | Done |
| `workflow/start-implementation.md` | ✅ | Done |
| `workflow/start-review.md` | ✅ | Done |
| `workflow/status.md` | ✅ | Done |
| `workflow/view-plan.md` | ✅ | Done |

### B. YAML Frontmatter for Documents

Documents should use YAML frontmatter for metadata.

| Document Type | Has Frontmatter | Fields | Template Location |
|---------------|-----------------|--------|-------------------|
| Discussion | ✅ | `topic`, `status`, `date` | `skills/technical-discussion/references/template.md` |
| Specification | ✅ | `topic`, `status`, `date`, `sources`, `superseded_by` | `skills/technical-specification/references/specification-guide.md` |
| Plan | ⬜ TODO | `topic`, `status`, `date`, `format`, `specification` | `skills/technical-planning/references/` |
| Research | ✅ | `topic`, `date` | `skills/technical-research/references/template.md` |

### C. Status Values

Simplified status values across document types.

| Document Type | Status Values | Notes |
|---------------|---------------|-------|
| Discussion | `in-progress`, `concluded` | Migrated from Exploring/Deciding/Concluded |
| Specification | `active`, `superseded` | |
| Plan | TBD | Need to review current approach |
| Research | N/A | No status - exploration is ongoing |

### D. Discovery Scripts

Centralized bash scripts for state discovery.

| Phase | Script | Status | Notes |
|-------|--------|--------|-------|
| Specification | `scripts/specification-discovery.sh` | ✅ Done | Reference implementation |
| Discussion | `scripts/discussion-discovery.sh` | ✅ Done | Tests in `scripts/tests/test-discussion-discovery.sh` |
| Planning | None | ⬜ TODO | Need to assess |
| Implementation | None | ⬜ TODO | Need to assess |
| Review | None | ⬜ TODO | Need to assess |

### E. Command Formatting Alignment

Update commands to match start-specification formatting style.

| Command | Formatting Updated | Notes |
|---------|-------------------|-------|
| `workflow/start-research.md` | ✅ | Added step numbers, STOP point |
| `workflow/start-discussion.md` | ✅ | Uses discovery script, flattened steps, STOP points |
| `workflow/start-specification.md` | ✅ Reference | This is the reference implementation |
| `workflow/start-planning.md` | ⬜ TODO | Need to review |
| `workflow/start-implementation.md` | ⬜ TODO | Need to review |
| `workflow/start-review.md` | ⬜ TODO | Need to review |
| `workflow/status.md` | ⬜ TODO | Need to review |
| `workflow/view-plan.md` | ⬜ TODO | Need to review |

### F. Caching Strategy

Cache files for avoiding redundant analysis.

| Cache File | Purpose | Checksum Source |
|------------|---------|-----------------|
| `.cache/research-analysis.md` | Research topic extraction | `docs/workflow/research/*.md` |
| `.cache/discussion-consolidation-analysis.md` | Discussion groupings | `docs/workflow/discussion/*.md` |
| `.cache/migrations.log` | Migration tracking | N/A (append-only log) |

---

## Phase-by-Phase Review

### Phase 1: Research ✅

**Status: Complete**

**Decisions made:**
- Research files use minimal frontmatter: `topic` and `date`
- `topic` is `exploration` for initial file, semantic names when split
- No status field - research is ongoing exploration
- No discovery script needed (discussion phase analyzes research)

**Changes made:**
- Created `skills/technical-research/references/template.md`
- Updated `skills/technical-research/SKILL.md` to reference template
- Updated `commands/workflow/start-research.md` formatting (step numbers, STOP point)

**Files updated:**
- `commands/workflow/start-research.md`
- `skills/technical-research/SKILL.md`
- `skills/technical-research/references/template.md` (new)

---

### Phase 2: Discussion ✅

**Status: Complete**

**Decisions made:**
- Discovery script outputs structured YAML (research, discussions, cache, state sections)
- Cache status uses `"valid" | "stale" | "none"` pattern matching spec-discovery
- Scenario-based routing: `"fresh"`, `"research_only"`, `"discussions_only"`, `"research_and_discussions"`
- Simplified icons: `·` (undiscussed), `✓` (discussed), `-` (discussions list)
- No special cache invalidation handling needed (loose coupling to research)

**Changes made:**
- Created `scripts/discussion-discovery.sh` with YAML output
- Created `scripts/tests/test-discussion-discovery.sh` (50 assertions)
- Updated `commands/workflow/start-discussion.md`:
  - Added `allowed-tools` header for discovery script
  - Flattened from sub-steps to Steps 0-7
  - Added discovery script integration in Step 1
  - Simplified presentation icons
  - Added explicit STOP points and navigation markers
- Reviewed skill files (no changes needed - already aligned)

**Files updated:**
- `commands/workflow/start-discussion.md`
- `scripts/discussion-discovery.sh` (new)
- `scripts/tests/test-discussion-discovery.sh` (new)

---

### Phase 3: Specification

**Current state:**
- ✅ Reference implementation - fully updated
- ✅ Discovery script pattern
- ✅ YAML frontmatter
- ✅ Caching with checksums
- ✅ Strict formatting

**Work needed:**
- None - this is the reference

**Files (for reference):**
- `commands/workflow/start-specification.md`
- `scripts/specification-discovery.sh`
- `skills/technical-specification/SKILL.md`
- `skills/technical-specification/references/specification-guide.md`

---

### Phase 4: Planning

**Current state:**
- ⬜ Need to review current command structure
- ⬜ Need to review plan document format
- ⬜ Need to assess if discovery script needed

**Work needed:**
- [ ] Review current command formatting
- [ ] Assess plan document frontmatter needs
- [ ] Determine if discovery script pattern applies
- [ ] Update command formatting

**Files to review:**
- `commands/workflow/start-planning.md`
- `skills/technical-planning/SKILL.md`
- `skills/technical-planning/references/`

---

### Phase 5: Implementation

**Current state:**
- ⬜ Need to review current command structure

**Work needed:**
- [ ] Review current command formatting
- [ ] Assess discovery needs
- [ ] Update command formatting

**Files to review:**
- `commands/workflow/start-implementation.md`
- `skills/technical-implementation/SKILL.md`
- `skills/technical-implementation/references/`

---

### Phase 6: Review

**Current state:**
- ⬜ Need to review current command structure

**Work needed:**
- [ ] Review current command formatting
- [ ] Assess discovery needs
- [ ] Update command formatting

**Files to review:**
- `commands/workflow/start-review.md`
- `skills/technical-review/SKILL.md`
- `skills/technical-review/references/`

---

### Utility Commands

**status.md:**
- [ ] Review formatting alignment
- [ ] Assess if it should use discovery scripts

**view-plan.md:**
- [ ] Review formatting alignment

---

## Progress Log

| Date | Phase | Change | Commit |
|------|-------|--------|--------|
| 2026-01-21 | Setup | Created this planning document | fad6191 |
| 2026-01-21 | Research | Added template, updated skill and command | 244824a |
| 2026-01-22 | Discussion | Created discovery script and tests | da4b534 |
| 2026-01-22 | Discussion | Updated command intro, Steps 0-1 | 84a51bd |
| 2026-01-22 | Discussion | Flattened step structure to Steps 0-7 | bf25750 |

---

## Notes

- Work through phases sequentially (1 → 6)
- Commit after each significant change
- Update this document as work progresses
- Reference start-specification.md for formatting decisions

## Working Process (IMPORTANT)

**Break each phase into discrete stages and STOP for user approval between stages.**

For phases with discovery scripts:
1. **Stage 1**: Create discovery script + tests → commit → STOP for review
2. **Stage 2**: Update command to use script → commit → STOP for review
3. **Stage 3**: Update templates/frontmatter if needed → commit → STOP for review
4. **Stage 4**: Create migration script if needed → commit → STOP for review

Do NOT combine stages. Do NOT proceed to the next stage without explicit user approval.
