# Display: Single Discussion

*Reference for **[start-specification](../SKILL.md)***

---

Auto-proceed path — only one concluded discussion exists, so no selection menu is needed.

Convert discussion filename to title case (`auth-flow` → `Auth Flow`).

## Determine Spec Coverage

Check for spec coverage in this order:

1. **Individual spec**: does `docs/workflow/specification/{discussion-name}.md` exist? (Check `has_individual_spec` from discovery.) If yes → use **"Has a spec"** section below.
2. **Grouped spec**: does any spec in the `specifications` array list this discussion in its `sources`? If yes → use **"Covered by a GROUPED spec"** section below.
3. **No coverage** → use **"No spec"** section below.

## If the discussion has NO spec

```
Specification Overview

Single concluded discussion found.

1. {Title Case Name}
   └─ Spec: none
   └─ Discussions:
      └─ {discussion-name} (ready)
```

### If in-progress discussions exist

```
---
Discussions not ready for specification:
These discussions are still in progress and must be concluded
before they can be included in a specification.
  · {discussion-name} (in-progress)
```

### Key/Legend

```
---
Key:

  Discussion status:
    ready — concluded and available to be specified

  Spec status:
    none — no specification file exists yet
```

```
---
Automatically proceeding with "{Title Case Name}".
```

## If the discussion is covered by a GROUPED spec

Use the grouped spec for display. Show the grouped spec name as the title. Show ALL the grouped spec's sources (not just this discussion) with their statuses:
- `incorporated` + `discussion_status: concluded` or `not-found` → `(extracted)`
- `incorporated` + `discussion_status: other` (e.g. `in-progress`) → `(extracted, reopened)`
- `pending` → `(pending)`

Extraction count: X = sources with `status: incorporated`, Y = total source count from the spec's `sources` array.

```
Specification Overview

Single concluded discussion found with existing grouped specification.

1. {Grouped Spec Title Case Name}
   └─ Spec: {spec_status} ({X} of {Y} sources extracted)
   └─ Discussions:
      ├─ {source-name} (extracted)
      └─ {source-name} (extracted, reopened)
```

Auto-proceed uses the grouped spec name. Verb rule for the grouped spec:
- Spec is `in-progress` → "Continuing"
- Spec is `concluded` with pending sources → "Continuing"
- Spec is `concluded` with all sources extracted → "Refining"

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
    reopened  — was extracted but discussion has regressed to in-progress

  Spec status:
    in-progress — specification work is ongoing
    concluded   — specification is complete
```

```
---
Automatically proceeding with "{Grouped Spec Title Case Name}".
```

## If the discussion HAS a spec

Determine extraction count: check the spec's `sources` array from discovery. Count how many have `status: incorporated` vs total.

```
Specification Overview

Single concluded discussion found with existing specification.

1. {Title Case Name}
   └─ Spec: {spec_status} ({X} of {Y} sources extracted)
   └─ Discussions:
      └─ {discussion-name} (extracted)
```

### If in-progress discussions exist

```
---
Discussions not ready for specification:
These discussions are still in progress and must be concluded
before they can be included in a specification.
  · {discussion-name} (in-progress)
```

### Key/Legend

```
---
Key:

  Discussion status:
    extracted — content has been incorporated into the specification

  Spec status:
    {spec_status} — {in-progress: "specification work is ongoing" | concluded: "specification is complete"}
```

```
---
Automatically proceeding with "{Title Case Name}".
```

## After Display

Auto-proceed — no prompt needed. Load **[confirm-and-handoff.md](confirm-and-handoff.md)** and follow its instructions.

The selected item is the single discussion (or grouped spec if covered). Use the verb rule:
- No spec → "Creating"
- Spec is `in-progress` → "Continuing"
- Spec is `concluded` with pending sources → "Continuing"
- Spec is `concluded` with all sources extracted → "Refining"
