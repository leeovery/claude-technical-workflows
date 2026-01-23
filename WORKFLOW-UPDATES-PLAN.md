# Workflow Updates Plan

Tracking document for systematically updating all workflow commands and skills to align with recent improvements.

---

## Master Tracking Table

Each command analyzes documents from the PREVIOUS phase. Migrations are linked to the phase where they RUN.

| Phase | Command | Reads From | Discovery Script | Migration (runs here) | Migrates |
|-------|---------|------------|------------------|----------------------|----------|
| 1. Research | start-research.md | N/A | N/A | N/A | N/A |
| 2. Discussion | start-discussion.md | Research docs | discovery-for-discussion.sh | N/A | N/A (research has no status) |
| 3. Specification | start-specification.md | Discussion docs | discovery-for-specification.sh | 001-discussion-frontmatter.sh | Discussion docs |
| 4. Planning | start-planning.md | Specification docs | discovery-for-planning.sh | 002-specification-frontmatter.sh | Specification docs |
| 5. Implementation | start-implementation.md | Plan docs | TBD | 003-planning-frontmatter.sh (TBD) | Plan docs |
| 6. Review | start-review.md | All docs | TBD | N/A | N/A |

---

## Phase Completion Status

| Phase | Command Updated | Discovery Script | Script Tests | Template Updated | Migration | Migration Tests |
|-------|-----------------|------------------|--------------|------------------|-----------|-----------------|
| 1. Research | ✅ | N/A | N/A | ✅ | N/A | N/A |
| 2. Discussion | ✅ | ✅ | ✅ (50) | ✅ | N/A | N/A |
| 3. Specification | ✅ | ✅ | ✅ (38) | ✅ | ✅ 001 | ⬜ TODO |
| 4. Planning | ⬜ TODO | ✅ | ✅ (48) | ⬜ TODO | ✅ 002 | ⬜ TODO |
| 5. Implementation | ⬜ TODO | ⬜ TODO | ⬜ TODO | ⬜ TODO | ⬜ TODO | ⬜ TODO |
| 6. Review | ⬜ TODO | ⬜ TODO | ⬜ TODO | N/A | N/A | N/A |

---

## Status Values (Normalized)

All document types use consistent status values:

| Status | Meaning |
|--------|---------|
| `in-progress` | Work ongoing |
| `concluded` | Work complete |

| Document Type | Status Values | Notes |
|---------------|---------------|-------|
| Research | N/A | No status - exploration is ongoing |
| Discussion | `in-progress`, `concluded` | |
| Specification | `in-progress`, `concluded` | |
| Plan | `in-progress`, `concluded` | TBD - need to confirm |

---

## Reference Implementation

**`commands/workflow/start-specification.md`** is the reference for:
- Stricter layout and formatting
- Flattened step counts (Step 0, Step 1, Step 2... not Step 2.1, 2.2)
- Clear STOP points after user interactions
- Discovery script pattern (bash script outputs YAML, command parses it)
- Explicit routing based on state

**`scripts/discovery-for-specification.sh`** is the reference for:
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

### C. Caching Strategy

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
- Created `scripts/discovery-for-discussion.sh` with YAML output
- Created `scripts/tests/test-discovery-for-discussion.sh` (50 assertions)
- Updated `commands/workflow/start-discussion.md`:
  - Added `allowed-tools` header for discovery script
  - Flattened from sub-steps to Steps 0-7
  - Added discovery script integration in Step 1
  - Simplified presentation icons
  - Added explicit STOP points and navigation markers
- Reviewed skill files (no changes needed - already aligned)

**Files updated:**
- `commands/workflow/start-discussion.md`
- `scripts/discovery-for-discussion.sh` (new)
- `scripts/tests/test-discovery-for-discussion.sh` (new)

---

### Phase 3: Specification ✅

**Status: Complete**

**This phase runs migration 001** (migrates Discussion docs to frontmatter).

**Completed:**
- Command is reference implementation
- Discovery script with tests (38 assertions)
- Template uses YAML frontmatter
- Migration 001 created and tested

**Files:**
- `commands/workflow/start-specification.md`
- `scripts/discovery-for-specification.sh`
- `tests/scripts/test-discovery-for-specification.sh`
- `skills/technical-specification/references/specification-guide.md`
- `scripts/migrations/001-discussion-frontmatter.sh`

---

### Phase 4: Planning (IN PROGRESS)

**Status: Partially complete**

**This phase runs migration 002** (migrates Specification docs to frontmatter).

**Completed:**
- ✅ Discovery script: `scripts/discovery-for-planning.sh`
- ✅ Script tests: `tests/scripts/test-discovery-for-planning.sh` (48 assertions)
- ✅ Migration 002: `scripts/migrations/002-specification-frontmatter.sh`

**Remaining:**
- [ ] Update command formatting (use discovery script, flatten steps, STOP points)
- [ ] Update plan template to use YAML frontmatter
- [ ] Add migration tests for 002

**Files to update:**
- `commands/workflow/start-planning.md`
- `skills/technical-planning/references/output-local-markdown.md` (template)

---

### Phase 5: Implementation

**Status: Not started**

**This phase runs migration 003** (migrates Plan docs to frontmatter - if needed).

**Work needed:**
- [ ] Review current command formatting
- [ ] Create discovery script (reads Plan docs)
- [ ] Add script tests
- [ ] Update command to use discovery script
- [ ] Create migration 003 for Plan docs (if needed)
- [ ] Add migration tests

**Files to review:**
- `commands/workflow/start-implementation.md`
- `skills/technical-implementation/SKILL.md`
- `skills/technical-implementation/references/`

---

### Phase 6: Review

**Status: Not started**

**This phase reads ALL docs** (no migration needed - all previous phases handle their own).

**Work needed:**
- [ ] Review current command formatting
- [ ] Assess discovery script needs (may read from multiple phases)
- [ ] Update command to use discovery script(s)
- [ ] Add script tests if applicable

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
4. **Stage 4**: Create migration script + tests if needed → commit → STOP for review

Do NOT combine stages. Do NOT proceed to the next stage without explicit user approval.

## Test Organization

**Tests location:** `tests/scripts/`

### Discovery Script Tests

| Test File | Assertions | Status |
|-----------|------------|--------|
| `test-discovery-for-discussion.sh` | 50 | ✅ |
| `test-discovery-for-specification.sh` | 38 | ✅ |
| `test-discovery-for-planning.sh` | 48 | ✅ |
| `test-implementation-discovery.sh` | TBD | ⬜ TODO |
| `test-review-discovery.sh` | TBD | ⬜ TODO |

### Migration Tests

| Test File | Status | Notes |
|-----------|--------|-------|
| `test-migration-001.sh` | ⬜ TODO | Discussion frontmatter migration |
| `test-migration-002.sh` | ⬜ TODO | Specification frontmatter migration |
| `test-migration-003.sh` | ⬜ TODO | Plan frontmatter migration (if needed) |

**Migration tests should cover:**
- Various legacy document formats
- Idempotency (running migration twice)
- Edge cases (metadata in wrong location, missing fields, etc.)
