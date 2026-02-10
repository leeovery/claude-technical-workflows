# Display: Groupings

*Reference for **[start-specification](../SKILL.md)***

---

Shows when cache is valid (directly from routing) or after analysis completes. This is the most content-rich display.

## Load Groupings

Load groupings from `docs/workflow/.cache/discussion-consolidation-analysis.md`. Parse the `### {Name}` headings and their discussion lists.

## Determine Discussion Status

For each grouping, check if a grouped specification exists:
1. Convert the grouping name to kebab-case (lowercase, spaces to hyphens)
2. Check if `docs/workflow/specification/{kebab-name}.md` exists in the discovery `specifications` array
3. If it exists, get its `sources` array

**If a grouped spec exists:**
- For each discussion in the grouping:
  - Look up in the spec's `sources` array (by `name` field)
  - If found → use the source's `status` (`incorporated` → `extracted`, `pending` → `pending`)
  - If NOT found → status is `pending` (new source not yet in spec)
- Spec status: show actual status with extraction count `({X} of {Y} sources extracted)`

**If NO grouped spec exists:**
- For each discussion: status is `ready`
- Spec status: `none`

## Display Format

All items are first-class — every grouping (including single-discussion entries) is a numbered item.

```
Specification Overview

Recommended breakdown for specifications with their source discussions.

1. {Grouping Name}
   └─ Spec: {status} {(X of Y sources extracted) if applicable}
   └─ Discussions:
      ├─ {discussion-name} ({status})
      └─ {discussion-name} ({status})

2. {Grouping Name}
   └─ Spec: none
   └─ Discussions:
      └─ {discussion-name} (ready)
```

Use `├─` for all but the last discussion, `└─` for the last.

### If in-progress discussions exist

```
---
Discussions not ready for specification:
These discussions are still in progress and must be concluded
before they can be included in a specification.
  · {discussion-name} (in-progress)
```

### Key/Legend

Show only the statuses that appear in the current display.

```
---
Key:

  Discussion status:
    extracted — content has been incorporated into the specification
    pending   — listed as source but content not yet extracted
    ready     — concluded and available to be specified

  Spec status:
    none        — no specification file exists yet
    in-progress — specification work is ongoing
    concluded   — specification is complete
```

### Tip (show when 2+ groupings)

```
---
Tip: To restructure groupings or pull a discussion into its own
specification, choose "Re-analyze" and provide guidance.
```

## Menu

Numbered menu with verb logic per grouping:
- No spec exists → **Start** "{Name}" — {N} ready discussions
- Spec is `in-progress` with pending sources → **Continue** "{Name}" — {N} source(s) pending extraction
- Spec is `in-progress` with all extracted → **Continue** "{Name}" — all sources extracted
- Spec is `concluded` → **Refine** "{Name}" — concluded spec

After the per-grouping items, add meta options:

**Unify** (only when 2+ groupings exist):
```
{N+1}. Unify all into single specification
   All discussions are combined into one specification{if specs exist: ". Existing
   specifications are incorporated and superseded"} instead
   of following the recommended groupings.
```

**Re-analyze** (always):
```
{N+2}. Re-analyze groupings
   Current groupings are discarded and rebuilt.{if specs exist: " Existing
   specification names are preserved."} You can provide guidance
   in the next step.
```

```
Enter choice (1-{max}):
```

**STOP.** Wait for user response.

## Menu Routing

**If user picks a grouping** → Load **[confirm-and-handoff.md](confirm-and-handoff.md)** and follow its instructions.

**If user picks "Unify all":**
1. Update the cache: rewrite `docs/workflow/.cache/discussion-consolidation-analysis.md` with a single "Unified" grouping containing all concluded discussions. Keep the same checksum, update the generated timestamp. Add note: `Custom groupings confirmed by user (unified).`
2. Load **[confirm-and-handoff.md](confirm-and-handoff.md)** with spec name "Unified" and all concluded discussions as sources.

**If user picks "Re-analyze":**
1. Delete the cache:
```bash
rm docs/workflow/.cache/discussion-consolidation-analysis.md
```
2. Load **[analysis-flow.md](analysis-flow.md)** and follow its instructions.
