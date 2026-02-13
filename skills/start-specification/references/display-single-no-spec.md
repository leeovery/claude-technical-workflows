# Display: Single Discussion — No Spec

*Reference for **[display-single.md](display-single.md)***

---

No specification exists for this discussion.

## Display

**Output the next fenced block as a code block:**

```
Specification Overview

Single concluded discussion found.

1. {Title Case Name}
   └─ Spec: none
   └─ Discussions:
      └─ {discussion-name} (ready)
```

### If in-progress discussions exist

**Output the next fenced block as a code block:**

```
Discussions not ready for specification:
These discussions are still in progress and must be concluded
before they can be included in a specification.
  · {discussion-name} (in-progress)
```

### Key/Legend

No `---` separator before this section.

**Output the next fenced block as a code block:**

```
Key:

  Discussion status:
    ready — concluded and available to be specified

  Spec status:
    none — no specification file exists yet
```

## After Display

**Output the next fenced block as a code block:**

```
Automatically proceeding with "{Title Case Name}".
```

Auto-proceed with verb **"Creating"**.

→ Load **[confirm-and-handoff.md](confirm-and-handoff.md)** and follow its instructions.
