# Confirm: Refine Specification

*Reference for **[confirm-and-handoff.md](confirm-and-handoff.md)***

---

## Confirm

```
Refining specification: {Title Case Name}

Existing: docs/workflow/specification/{kebab-case-name}.md (concluded)

All sources extracted:
  • {discussion-name}

· · · · · · · · · · · ·
Proceed?
- **`y`/`yes`**
- **`n`/`no`**
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

## If user confirms (y)

→ Load **[continue.md](handoffs/continue.md)** and follow its instructions.

## If user declines (n)

#### If single discussion (no menu to return to)

```
Understood. You can run /start-discussion to continue working on
discussions, or re-run this command when ready.
```

Command ends.

#### If groupings or specs menu

Re-display the previous menu (the display that led to this confirmation). The user can make a different choice.
