# Audit Checklist

Living document. Each round of audit agents checks everything below. When findings are fixed, new checks are appended. Agents re-run against the full list each round.

**Scope exclusion**: Ignore `workflow-explorer.html` — it will be updated separately once all other fixes are stable.

---

## Round 1 Checks

Source: ARCHITECTURE-FIX-PLAN.md, DISCOVERY-CLEANUP-PLAN.md, RESEARCH-STATUS-PLAN.md, CLAUDE.md conventions.

### 1. Path & Structure Consistency

Verify the uniform path pattern from ARCHITECTURE-FIX-PLAN is applied everywhere (skills, agents, entry-points, references, tests, hooks, docs).

**Flat file phases** (file IS the topic, no subdirectory):
- `.workflows/{work_unit}/discussion/{topic}.md`
- `.workflows/{work_unit}/investigation/{topic}.md`
- `.workflows/{work_unit}/research/*.md` (exempt — freeform, no topic)

**Topic subdir phases** (metafiles alongside primary artifact):
- `.workflows/{work_unit}/specification/{topic}/specification.md`
- `.workflows/{work_unit}/planning/{topic}/planning.md` (+ `tasks/`)
- `.workflows/{work_unit}/implementation/{topic}/implementation.md`
- `.workflows/{work_unit}/review/{topic}/r{N}/review.md`

**State & cache**:
- Per-work-unit state: `.workflows/{work_unit}/.state/` (research-analysis.md, discussion-consolidation-analysis.md)
- Global state: `.workflows/.state/` (migrations, environment-setup.md only)
- Cache: `.workflows/.cache/sessions/`, `.workflows/.cache/planning/{work_unit}/{topic}/`

**What to flag**:
- Old phase-first paths (`.workflows/discussion/{topic}/...` without work_unit prefix)
- Dropped `{topic}` (`.workflows/{work_unit}/implementation/` missing `{topic}/`)
- State files at global `.workflows/.state/` that should be per-work-unit
- Any path that doesn't match the patterns above

### 2. Manifest CLI & Domain-Aware Usage

All manifest interactions must use the domain-aware flag syntax.

**Phase-level operations** (reading/writing per-topic state):
```
$MANIFEST get {work_unit} --phase discussion --topic {topic} status
$MANIFEST set {work_unit} --phase discussion --topic {topic} status concluded
$MANIFEST add-item {work_unit} --phase discussion --topic {topic}
```

**Work-unit-level operations** (no `--phase`/`--topic` flags, dot-path positional args):
```
$MANIFEST get {work_unit} work_type
$MANIFEST set {work_unit} phases.research.analysis_cache '{"checksum":"..."}'
```

**What to flag**:
- Old dot-path syntax: `{name}.phases.discussion.status` (the dot-delimited name prefix)
- `--raw` flag anywhere
- Phase-level metadata (like `analysis_cache`) accessed via `--phase --topic` instead of work-unit-level dot-path
- Missing `--topic` on phase operations that should have it

### 3. Work Type Architecture Correctness

Three work types: Epic, Feature, Bugfix. A work unit is an instance of a work type.

**Epic**: Multiple topics per phase. Manifest uses `phases.{phase}.items.{topic}` internally. Topics are distinct from work_unit name.

**Feature/Bugfix**: Single topic per phase. Topic name equals work_unit name. Manifest uses `phases.{phase}` flat structure internally.

**Key**: Skills never know the internal structure — the CLI abstracts it via `--phase --topic` flags.

**workflow-start naming**: `epics: { items: [...] }`, `features: { items: [...] }`, `bugfixes: { items: [...] }` — all plural, all use `items`.

**What to flag**:
- `work_units` or `topics` keys (old naming, replaced by `items`)
- `epic` singular key (should be `epics`)
- `greenfield` work type (replaced by `epic`)
- Skills that hardcode manifest internal structure (flat vs items) instead of using CLI flags
- Incorrect assumptions about topic=work_unit for epic

### 4. Old System Remnants

Things that should no longer exist anywhere in the codebase.

**Bash discovery scripts**: All discovery scripts should be Node.js (`.js`). No `.sh` discovery scripts should remain in `skills/start-*/scripts/` or `skills/workflow-*/scripts/`.

**Frontmatter in discovery**: No `readFrontmatterField` function or imports. No frontmatter parsing in discovery scripts. Cache files are pure markdown — metadata lives in the manifest.

**Dead code from DISCOVERY-CLEANUP-PLAN**:
- `--raw` flag (removed from manifest CLI)
- `dependency_resolution` top-level array (flattened into plan entries as `deps_satisfied`/`deps_blocking`)
- Dead state counts: `plans_concluded_count`, `plans_with_unresolved_deps`, `plans_ready_count`, `plans_in_progress_count`, `plans_completed_count`
- `cache.status` / `cache.reason` at top level (normalized to always `cache: { entries: [...] }`)
- `work_units` / `topics` keys in workflow-start (replaced by `items`)

**Research status**: No "never concludes" language. Research supports `in-progress` / `concluded` status via manifest. Migration 016 detects concluded research via `> **Discussion-ready**:` marker.

### 5. CLAUDE.md Convention Adherence

Check all skill files (SKILL.md, references/*.md) against CLAUDE.md conventions.

**Display conventions**:
- Every fenced block preceded by a rendering instruction (`> *Output the next fenced block as a code block:*` or `> *Output the next fenced block as markdown (not a code block):*`)
- Titles use `{Phase} Overview` pattern
- Tree structures use `└─` branches with blank lines between numbered items
- Status terms always parenthetical: `(in-progress)`, `(concluded)`
- Menus framed with `· · · · · · · · · · · ·` dot separators
- Bullet character is `•` for all bulleted lists

**Structural conventions**:
- `**STOP.**` (bold, period) — only pattern for interaction boundaries
- H1 for file title only, H2 for steps, H3 for subsections, H4 for conditional routing only
- H4 conditionals: `#### If {condition}` / `#### Otherwise` — no else-if chains
- Nested conditionals use bold text, not H4 (never double-nest H4)
- Navigation: only `→ Proceed to` (forward) and `→ Return to` (backward) — no `→ Go to`, `→ Skip to`, etc.
- Load directives: no `→` before Load line, bold the markdown link
- Reference file headers: `# Title` + `*Reference for **[parent-skill](../SKILL.md)***` + `---`
- Zero Output Rule blockquote present in entry-point skills that invoke processing skills

---

## How to Use This Document

1. Dispatch audit agents — each agent gets this full checklist plus the relevant source plans
2. Agents report findings per section number (e.g., "Section 2: found old dot-path in agents/foo.md line 42")
3. Fix findings
4. Append new checks below as a new "Round N" section
5. Re-dispatch agents against the full expanded checklist
6. Repeat until clean
