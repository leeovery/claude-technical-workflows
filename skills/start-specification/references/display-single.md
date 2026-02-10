# Display: Single Discussion

*Reference for **[start-specification](../SKILL.md)***

---

Auto-proceed path — only one concluded discussion exists, so no selection menu is needed.

Convert discussion filename to title case (`auth-flow` → `Auth Flow`).

## If the discussion has NO spec

```
Specification Overview

Single concluded discussion found.

1. {Title Case Name}
   └─ Spec: none
   └─ Discussions:
      └─ {discussion-name} (ready)

---
Key:

  Discussion status:
    ready — concluded and available to be specified

  Spec status:
    none — no specification file exists yet

---
Automatically proceeding with "{Title Case Name}".
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

---
Key:

  Discussion status:
    extracted — content has been incorporated into the specification

  Spec status:
    {spec_status} — {in-progress: "specification work is ongoing" | concluded: "specification is complete"}

---
Automatically proceeding with "{Title Case Name}".
```

## After Display

Auto-proceed — no prompt needed. Load **[confirm-and-handoff.md](confirm-and-handoff.md)** and follow its instructions.

The selected item is the single discussion. Use the verb rule:
- No spec → "Creating"
- Spec is `in-progress` → "Continuing"
- Spec is `concluded` → "Refining"
