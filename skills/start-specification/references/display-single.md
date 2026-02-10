# Display: Single Discussion

*Reference for **[start-specification](../SKILL.md)***

---

Auto-proceed path — only one concluded discussion exists, so no selection menu is needed.

Convert discussion filename to title case (`auth-flow` → `Auth Flow`).

### Determine spec coverage

Check two things:
1. `has_individual_spec` — same-name spec exists (e.g., `auth-flow.md` for discussion `auth-flow`)
2. The `specifications` array — any spec that lists this discussion in its `sources`

If either matches, use the "has spec" variant below. For grouped specs, use the grouped spec's name and status.

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

## If the discussion HAS a spec (individual or grouped)

Determine extraction count: check the spec's `sources` array from discovery. Count how many have `status: incorporated` vs total.

For grouped specs, use the grouped spec's title case name as the item name (not the discussion filename).

```
Specification Overview

Single concluded discussion found with existing specification.

1. {Spec Title Case Name}
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

Use the verb rule:
- No spec → "Creating" (individual spec from discussion name)
- Spec is `in-progress` → "Continuing" (the existing spec, whether individual or grouped)
- Spec is `concluded` → "Refining" (the existing spec, whether individual or grouped)

For grouped specs, the confirm and handoff reference the grouped spec and all its sources — not just the single concluded discussion.
