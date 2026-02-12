# Display: Single Discussion — Has Spec

*Reference for **[display-single.md](display-single.md)***

---

An individual specification exists for this discussion.

Determine extraction count: check the spec's `sources` array from discovery. Count how many have `status: incorporated` vs total.

## Display

```
Specification Overview

Single concluded discussion found with existing specification.

1. {Title Case Name}
   └─ Spec: {spec_status} ({X} of {Y} sources extracted)
   └─ Discussions:
      └─ {discussion-name} (extracted)
```

**Formatting is exact**: Output the tree structure exactly as shown above — preserve all indentation spaces and `├─`/`└─` characters. Do not flatten or compress the spacing.

### If in-progress discussions exist

```
Discussions not ready for specification:
These discussions are still in progress and must be concluded
before they can be included in a specification.
  · {discussion-name} (in-progress)
```

### Key/Legend

No `---` separator before this section.

```
Key:

  Discussion status:
    extracted — content has been incorporated into the specification

  Spec status:
    {spec_status} — {in-progress: "specification work is ongoing" | concluded: "specification is complete"}
```

## After Display

```
Automatically proceeding with "{Title Case Name}".
```

Auto-proceed. Verb rule:
- Spec is `in-progress` → **"Continuing"**
- Spec is `concluded` with pending sources → **"Continuing"**
- Spec is `concluded` with all sources extracted → **"Refining"**

→ Load **[confirm-and-handoff.md](confirm-and-handoff.md)** and follow its instructions.
