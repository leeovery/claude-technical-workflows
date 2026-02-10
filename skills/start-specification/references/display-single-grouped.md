# Display: Single Discussion — Grouped Spec

*Reference for **[display-single.md](display-single.md)***

---

This discussion is covered by a grouped specification — a spec with a different name that lists this discussion as a source.

Use the grouped spec for display. Show the grouped spec name as the title. Show ALL the grouped spec's sources (not just this discussion) with their statuses:
- `incorporated` + `discussion_status: concluded` or `not-found` → `(extracted)`
- `incorporated` + `discussion_status: other` (e.g. `in-progress`) → `(extracted, reopened)`
- `pending` → `(pending)`

Extraction count: X = sources with `status: incorporated`, Y = total source count from the spec's `sources` array.

## Display

```
Specification Overview

Single concluded discussion found with existing grouped specification.

1. {Grouped Spec Title Case Name}
   └─ Spec: {spec_status} ({X} of {Y} sources extracted)
   └─ Discussions:
      ├─ {source-name} (extracted)
      └─ {source-name} (extracted, reopened)
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

## After Display

```
---
Automatically proceeding with "{Grouped Spec Title Case Name}".
```

Auto-proceed uses the grouped spec name. Verb rule:
- Spec is `in-progress` → **"Continuing"**
- Spec is `concluded` with pending sources → **"Continuing"**
- Spec is `concluded` with all sources extracted → **"Refining"**

Load **[confirm-and-handoff.md](confirm-and-handoff.md)** and follow its instructions.
