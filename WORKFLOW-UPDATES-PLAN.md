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
| Research | ⬜ DISCUSS | TBD - may stay freeform | `skills/technical-research/references/` |

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
| Discussion | None | ⬜ TODO | Currently inline in command |
| Planning | None | ⬜ TODO | Need to assess |
| Implementation | None | ⬜ TODO | Need to assess |
| Review | None | ⬜ TODO | Need to assess |

### E. Command Formatting Alignment

Update commands to match start-specification formatting style.

| Command | Formatting Updated | Notes |
|---------|-------------------|-------|
| `workflow/start-research.md` | ⬜ TODO | Simple command, may need minimal changes |
| `workflow/start-discussion.md` | ⬜ TODO | Complex - has discovery, caching, routing |
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

### Phase 1: Research

**Current state:**
- No frontmatter on research files
- No status concept (exploration is ongoing)
- No discovery script needed (discussion does the analysis)
- Freeform file structure (`exploration.md` → semantic files)

**Questions to resolve:**
- [ ] Should research files have minimal frontmatter (`date` only)?
- [ ] Should there be a research template?
- [ ] Any changes to the skill needed?

**Files to review:**
- `commands/workflow/start-research.md`
- `skills/technical-research/SKILL.md`
- `skills/technical-research/references/interview.md`

---

### Phase 2: Discussion

**Current state:**
- ✅ YAML frontmatter (`topic`, `status`, `date`)
- ✅ Status values: `in-progress`, `concluded`
- ✅ Migration exists for legacy format
- ⬜ Discovery logic is inline in command (not a script)
- ⬜ Command formatting needs alignment with spec command

**Work needed:**
- [ ] Extract discovery logic to `scripts/discussion-discovery.sh`
- [ ] Update command formatting to match start-specification
- [ ] Flatten step numbers (remove 2.1, 2.2, 2.3 pattern)
- [ ] Review skill for any needed updates

**Files to update:**
- `commands/workflow/start-discussion.md`
- `skills/technical-discussion/SKILL.md` (review)
- `skills/technical-discussion/references/template.md` (review)
- `skills/technical-discussion/references/guidelines.md` (review)
- New: `scripts/discussion-discovery.sh`

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
| 2026-01-21 | Setup | Created this planning document | |

---

## Notes

- Work through phases sequentially (1 → 6)
- Commit after each significant change
- Update this document as work progresses
- Reference start-specification.md for formatting decisions
