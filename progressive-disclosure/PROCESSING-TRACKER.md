# Processing Skill Modernization Tracker

Modernize pre-modern processing skills (`technical-*`) to follow the step-based structure established by `technical-planning` and `technical-implementation`.

**Exemplars:** `technical-planning` (25 references, Steps 0–8), `technical-implementation` (12 references, Steps 1–8)

---

## What "Modern" Means

Processing skills must have:

- **Step-based structure** — `## Step 0`, `## Step 1`, etc. with `---` between steps
- **Progressive reference loading** — each step loads specific reference files on demand (not one monolithic guide)
- **Rendering instructions** — `> *Output the next fenced block as...*` before every fenced block
- **STOP gates** — `**STOP.** Wait for user response.` (bold, period, exact pattern)
- **Reference file headers** — standard `*Reference for **[skill](../SKILL.md)***` pattern
- **Step separators** — `── ── ── ── ──` output between steps (matches planning/implementation)
- **Checkpoint markers** — `**CHECKPOINT**` at natural review points

See also: CLAUDE.md — "Skill File Structure (Progressive Disclosure)" and "Structural Conventions" sections.

---

## Skills

Ordered by estimated complexity.

### Full Modernization

- [ ] **technical-research** (8.5 KB, 2 refs) — Conversational, no steps, informal STOP gates (`**STOP**` without period). Smallest scope.
- [ ] **technical-discussion** (7.6 KB, 3 refs) — Conversational, no steps. Has proper STOP gates already.
- [ ] **technical-investigation** (9.3 KB, 3 refs) — Narrative style, no steps. Has references but inline guidance sections instead of step-based backbone.
- [ ] **technical-specification** (8.8 KB, 1 ref) — Conversational, no steps. Single monolithic `specification-guide.md` needs decomposition. Most complex of the three.

### Minor Fix

- [ ] **technical-review** — Modern structure (Steps 1–5) but missing rendering instructions on fenced blocks. Quick fix.

### Already Modern (no work needed)

- [x] **technical-planning** (11 KB, 25 refs, Steps 0–8)
- [x] **technical-implementation** (13 KB, 12 refs, Steps 1–8)
