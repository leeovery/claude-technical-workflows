# Spec Source Regression Analysis

Analysis of logic gaps in start-specification when spec source discussions change status after spec creation. Covers display accuracy, routing correctness, and verb/status consistency.

## The Core Problem

The start-specification skill assumes discussions move forward: in-progress → concluded → specified. But discussions can regress (concluded → in-progress), and new discussions can appear after specs are created. The current display and routing logic doesn't account for either scenario, leading to invisible sources, contradictory status displays, and missed spec coverage.

## Terminology

- **Regression**: A concluded discussion returning to in-progress after being incorporated into a spec
- **Spec source**: A discussion listed in a spec's `sources` frontmatter array
- **Grouped spec**: A spec covering multiple discussions (name differs from any single discussion)
- **Extraction count**: "X of Y sources extracted" shown in displays — currently X = incorporated sources in the grouping, Y = total discussions in the grouping

## Gaps Identified

### Gap 1: Regressed Sources Become Invisible After Re-Analysis

**Affects:** display-groupings (after analysis-flow completes)

**How it happens:**
1. Spec "Authentication System" has sources: auth-flow (incorporated), user-sessions (incorporated)
2. user-sessions regresses to in-progress
3. Cache goes stale → user triggers re-analysis
4. analysis-flow reads only concluded discussions — user-sessions is excluded
5. Grouping for "Authentication System" now contains only auth-flow
6. display-groupings shows the grouping with 1 discussion
7. Extraction count: "1 of 1 sources extracted" (Y = grouping size, not spec source count)
8. user-sessions is nowhere — not in the grouping, not in "not ready" section (which only shows non-concluded discussions not in any spec)

**Result:** The spec appears to have 1 source when it actually has 2. The user has no indication that user-sessions was part of this spec and has regressed.

**Expected:** The display should show user-sessions as a regressed source. Something like:

```
1. Authentication System
   └─ Spec: in-progress (1 of 2 sources extracted)
   └─ Discussions:
      ├─ auth-flow (extracted)
      └─ user-sessions (extracted, discussion reopened)
```

Or at minimum, a note that the spec has sources not shown in the grouping.

### Gap 2: display-single Doesn't Detect Grouped Spec Coverage

**Affects:** display-single (routing case: concluded_count == 1)

**How it happens:**
1. Spec "Authentication System" covers auth-flow + user-sessions
2. user-sessions AND all other discussions regress — only auth-flow remains concluded
3. concluded_count == 1 → routes to display-single
4. display-single checks `has_individual_spec` (same-name spec) → false
5. Shows "Spec: none", offers to create `auth-flow.md`

**Result:** User creates a duplicate spec. `authentication-system.md` already covers auth-flow but display-single doesn't know.

**Expected:** display-single should detect that auth-flow is in authentication-system's sources and show the grouped spec.

### Gap 3: display-single Missing "Not Ready" Section

**Affects:** display-single (all cases with in-progress discussions)

**How it happens:** display-single never shows in-progress discussions. Every other display includes a "not ready" section. This appears to be an omission — the flow docs for Output 3/4 don't include it, but every other output does.

**Expected:** Consistent with other displays — show the "not ready" section.

### Gap 4: Concluded Spec With New Pending Sources — Contradictory Status and Verb

**Affects:** display-groupings, confirm-and-handoff

**How it happens:**
1. Spec "Authentication System" is concluded with sources: auth-flow (incorporated), user-sessions (incorporated)
2. New discussion oauth-integration is created and concluded
3. Re-analysis groups oauth-integration with authentication-system
4. display-groupings shows: `Spec: concluded (2 of 3 sources extracted)`
5. Menu verb: "Refine" (because spec status is concluded)

**Result:** "Concluded" and "2 of 3 extracted" contradict each other. "Refine" implies reviewing something complete, but there's new material to extract. The confirm template for "Refining" assumes all sources are extracted.

**Expected:** When a concluded spec gains pending sources, it should display differently — either:
- Override the display status to something like "needs update" (the spec file status stays concluded, but the displayed status reflects reality)
- Change the verb to "Continue" (there's new work, not just refinement)

### Gap 5: Extraction Count Based on Grouping, Not Spec Sources

**Affects:** display-groupings

**Current logic:** For each discussion in the **grouping**, look up in spec sources. X = incorporated found, Y = total in grouping.

**Problem:** Y should reflect the spec's actual source count, not just what's in the current grouping. When a source regresses and drops out of the grouping, Y shrinks, hiding the gap.

**Expected:** Y should be the union of grouping members and spec sources. Or at minimum, spec sources should be the baseline, with grouping additions treated as new pending sources.

## Scenario Walkthroughs

### Scenario 1: Source Discussion Regresses (concluded_count >= 2)

**Setup:** 3 concluded discussions, spec covers 2 of them. One regresses.

| Step | State | What happens |
|------|-------|-------------|
| Start | auth-flow (concluded), user-sessions (concluded), api-design (concluded). Spec: authentication-system [auth-flow ✓, user-sessions ✓] | Everything healthy |
| user-sessions → in-progress | concluded_count: 2, spec_count: 1, cache: stale | Cache stale because discussions changed |
| Route | concluded_count >= 2, spec_count >= 1, cache stale | → display-specs-menu |
| Display | Shows authentication-system tree. Sources from frontmatter: auth-flow (extracted), user-sessions (extracted) | **Gap:** user-sessions shown as "extracted" but discussion is in-progress |
| User picks "Analyze" | Analysis reads auth-flow + api-design (concluded only) | user-sessions excluded |
| After analysis | Grouping: "Authentication System" → [auth-flow]. "API Design" → [api-design] | user-sessions gone from grouping |
| display-groupings | Auth System: Spec in-progress (1 of 1 extracted). auth-flow (extracted) | **Gap 1 + 5:** user-sessions invisible. Count misleading |

### Scenario 2: Source Discussion Regresses (concluded_count drops to 1)

**Setup:** 2 concluded discussions, spec covers both. One regresses.

| Step | State | What happens |
|------|-------|-------------|
| Start | auth-flow (concluded), user-sessions (concluded). Spec: authentication-system [auth-flow ✓, user-sessions ✓] | Everything healthy |
| user-sessions → in-progress | concluded_count: 1, spec_count: 1 | |
| Route | concluded_count == 1 | → display-single |
| Display | Checks has_individual_spec for auth-flow → false | **Gap 2:** Doesn't see authentication-system |
| Result | Shows "Spec: none", offers to create auth-flow.md | Duplicate spec created |

### Scenario 3: New Discussion Joins Concluded Spec

**Setup:** Spec is concluded. New discussion gets analyzed into its grouping.

| Step | State | What happens |
|------|-------|-------------|
| Start | auth-flow (concluded), user-sessions (concluded). Spec: authentication-system (concluded) [auth-flow ✓, user-sessions ✓] | Spec complete |
| oauth-integration created + concluded | concluded_count: 3, cache: stale | |
| User triggers analysis | Analysis groups oauth-integration with auth system | Anchored name preserved |
| display-groupings | Auth System: concluded (2 of 3 extracted). oauth-integration (pending) | **Gap 4:** "concluded" contradicts "2 of 3" |
| Menu | "Refine Authentication System" | **Gap 4:** Should be "Continue" — new material to extract |
| Confirm | Uses "Refining" template which assumes all extracted | **Gap 4:** Wrong template — should show pending sources |

### Scenario 4: display-single With In-Progress Discussions

**Setup:** 1 concluded, 2 in-progress, no specs.

| Step | State | What happens |
|------|-------|-------------|
| Route | concluded_count == 1 | → display-single |
| Display | Shows auth-flow tree, auto-proceeds | **Gap 3:** In-progress discussions not shown |
| Expected | Should show "not ready" section with the 2 in-progress discussions | Awareness of what else exists |

## Proposed Fixes

### Fix 1: Show Regressed Sources in Groupings Display

In display-groupings, after building the tree from the grouping, also check the spec's actual sources. Any source that is in the spec but NOT in the grouping should be shown with a "regressed" or "reopened" status:

```
1. Authentication System
   └─ Spec: in-progress (1 of 2 sources extracted)
   └─ Discussions:
      ├─ auth-flow (extracted)
      └─ user-sessions (extracted, reopened)
```

The extraction count Y should be based on the **spec's source count** (or union of spec sources + grouping members), not just grouping size.

The "not ready" section should note regressed spec sources separately from ordinary in-progress discussions, since they have different implications.

### Fix 2: Detect Grouped Spec Coverage in display-single

Add instruction to check the `specifications` array for any spec listing this discussion as a source. If found, use the grouped spec's info (name, status, sources) for display and handoff.

This keeps display-single simple — it doesn't need to handle the full groupings display. It just needs to know: is this discussion covered by an existing spec? If yes, show that spec and continue/refine it.

### Fix 3: Add "Not Ready" Section to display-single

Add the standard "not ready" section showing in-progress discussions. Same format as every other display.

### Fix 4: Handle Concluded Spec With Pending Sources

When a spec is `concluded` but has pending sources (from re-analysis grouping a new discussion into it):

**Display status:** Show as `concluded` but with the extraction count making the situation clear: `concluded (2 of 3 sources extracted)`. This is accurate — the spec IS concluded, AND there are new sources. Alternative: show `needs update` but this introduces a new status term.

**Verb logic:** Override to "Continue" when a concluded spec has pending sources. There's new material to extract — that's continuation, not refinement.

**Confirm template:** Use the "Continuing a Spec With Pending Sources" template (which already exists and shows pending vs previously extracted).

### Fix 5: Base Extraction Count on Spec Sources

Change the extraction count calculation in display-groupings:
- Y = number of unique discussions in (spec sources ∪ grouping members)
- X = number of those with `incorporated` status in spec sources

This ensures regressed sources still count toward Y, making the gap visible.

## Files Affected

| File | Fixes | Changes |
|------|-------|---------|
| display-groupings.md | 1, 4, 5 | Add regressed source detection, override verb for concluded+pending, change extraction count base |
| display-single.md | 2, 3 | Check specifications array for grouped coverage, add not-ready section |
| display-specs-menu.md | 1 | Same regressed source visibility issue when showing existing specs |
| confirm-and-handoff.md | 4 | Verb override rule for concluded specs with pending sources |
| analysis-flow.md | — | No changes — correctly reads only concluded discussions |

## Open Questions

1. **Should regressed sources block the spec?** The user mentioned "maybe that specification should be blocked." If a source regresses, should we warn but allow continuing, or should we prevent spec work until the source re-concludes?

2. **Status term for regression:** "reopened", "regressed", "in-progress" — which term is clearest? "reopened" feels most natural for display.

3. **Concluded + pending verb:** This analysis proposes overriding to "Continue." Alternative: introduce a new verb like "Update" to distinguish from continuing in-progress work.

4. **display-specs-menu regressed sources:** When showing existing specs from frontmatter (not cache), should we also cross-reference source discussion statuses? This would require checking each spec's sources against the discussions array.
