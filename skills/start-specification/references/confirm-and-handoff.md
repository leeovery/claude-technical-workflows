# Confirm and Handoff

*Reference for **[start-specification](../SKILL.md)***

---

## Step 1: Confirm Selection

Present the confirmation based on what was selected.

### Verb Rule

- No spec exists → **"Creating"**
- Spec is `in-progress` → **"Continuing"**
- Spec is `concluded` with pending sources → **"Continuing"**
- Spec is `concluded` with all sources extracted → **"Refining"**

### Creating a New Spec (no existing spec)

```
Creating specification: {Title Case Name}

Sources:
  • {discussion-name}
  • {discussion-name}

Output: docs/workflow/specification/{kebab-case-name}.md

· · · · · · · · · · · ·
Proceed?
- **`y`/`yes`**
- **`n`/`no`**
· · · · · · · · · · · ·
```

### Creating a New Spec That Supersedes Individual Specs

If any source discussion has an individual spec (`has_individual_spec: true`), note the supersession:

```
Creating specification: {Title Case Name}

Sources:
  • {discussion-name} (has individual spec — will be incorporated)
  • {discussion-name}

Output: docs/workflow/specification/{kebab-case-name}.md

After completion:
  specification/{discussion-name}.md → marked as superseded

· · · · · · · · · · · ·
Proceed?
- **`y`/`yes`**
- **`n`/`no`**
· · · · · · · · · · · ·
```

### Continuing a Spec With Pending Sources

```
Continuing specification: {Title Case Name}

Existing: docs/workflow/specification/{kebab-case-name}.md (in-progress)

Sources to extract:
  • {discussion-name} (pending)

Previously extracted (for reference):
  • {discussion-name}

· · · · · · · · · · · ·
Proceed?
- **`y`/`yes`**
- **`n`/`no`**
· · · · · · · · · · · ·
```

### Continuing a Spec With All Sources Extracted

```
Continuing specification: {Title Case Name}

Existing: docs/workflow/specification/{kebab-case-name}.md (in-progress)

All sources extracted:
  • {discussion-name}
  • {discussion-name}

· · · · · · · · · · · ·
Proceed?
- **`y`/`yes`**
- **`n`/`no`**
· · · · · · · · · · · ·
```

### Continuing a Concluded Spec With New Sources

```
Continuing specification: {Title Case Name}

Existing: docs/workflow/specification/{kebab-case-name}.md (concluded)

New sources to extract:
  • {discussion-name} (pending)

Previously extracted (for reference):
  • {discussion-name}

· · · · · · · · · · · ·
Proceed?
- **`y`/`yes`**
- **`n`/`no`**
· · · · · · · · · · · ·
```

### Refining a Concluded Spec

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

### Unify All (with existing specs to supersede)

```
Creating specification: Unified

Sources:
  • {discussion-name}
  • {discussion-name}
  ...

Existing specifications to incorporate:
  • {spec-name}.md → will be superseded
  • {spec-name}.md → will be superseded

Output: docs/workflow/specification/unified.md

· · · · · · · · · · · ·
Proceed?
- **`y`/`yes`**
- **`n`/`no`**
· · · · · · · · · · · ·
```

### Unify All (no existing specs)

```
Creating specification: Unified

Sources:
  • {discussion-name}
  • {discussion-name}
  ...

Output: docs/workflow/specification/unified.md

· · · · · · · · · · · ·
Proceed?
- **`y`/`yes`**
- **`n`/`no`**
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

## If user confirms (y)

Proceed to **Step 2: Invoke Skill**.

## If user declines (n)

**For single discussion (no menu to return to):**
```
Understood. You can run /start-discussion to continue working on
discussions, or re-run this command when ready.
```
Command ends.

**For groupings/specs menu (return to previous display):**
Re-display the previous menu (the display that led to this confirmation). The user can make a different choice.

---

## Step 2: Invoke Skill

This skill's purpose is now fulfilled. Invoke the [technical-specification](../../technical-specification/SKILL.md) skill for your next instructions. Do not act on the gathered information until the skill is loaded — it contains the instructions for how to proceed.

### Handoff: Creating a New Spec

```
Specification session for: {Title Case Name}

Sources:
- docs/workflow/discussion/{discussion-name}.md
- docs/workflow/discussion/{discussion-name}.md

Output: docs/workflow/specification/{kebab-case-name}.md

---
Invoke the technical-specification skill.
```

### Handoff: Creating With Specs to Incorporate

```
Specification session for: {Title Case Name}

Source discussions:
- docs/workflow/discussion/{discussion-name}.md
- docs/workflow/discussion/{discussion-name}.md

Existing specifications to incorporate:
- docs/workflow/specification/{spec-name}.md (covers: {discussion-name} discussion)

Output: docs/workflow/specification/{kebab-case-name}.md

Context: This consolidates multiple sources. The existing {spec-name}.md specification should be incorporated - extract and adapt its content alongside the discussion material. The result should be a unified specification, not a simple merge.

After the {kebab-case-name} specification is complete, mark the incorporated specs as superseded by updating their frontmatter:

    status: superseded
    superseded_by: {kebab-case-name}

---
Invoke the technical-specification skill.
```

### Handoff: Continuing an Existing Spec

```
Specification session for: {Title Case Name}

Continuing existing: docs/workflow/specification/{kebab-case-name}.md

Sources for reference:
- docs/workflow/discussion/{discussion-name}.md
- docs/workflow/discussion/{discussion-name}.md

Context: This specification already exists. Review and refine it based on the source discussions.

---
Invoke the technical-specification skill.
```

### Handoff: Continuing a Concluded Spec With New Sources

```
Specification session for: {Title Case Name}

Continuing existing: docs/workflow/specification/{kebab-case-name}.md (concluded)

New sources to extract:
- docs/workflow/discussion/{new-discussion-name}.md

Previously extracted (for reference):
- docs/workflow/discussion/{existing-discussion-name}.md

Context: This specification was previously concluded. New source discussions have been identified. Extract and incorporate their content while maintaining consistency with the existing specification.

---
Invoke the technical-specification skill.
```

### Handoff: Unify All (With Specs to Incorporate)

```
Specification session for: Unified

Source discussions:
- docs/workflow/discussion/{discussion-name}.md
- docs/workflow/discussion/{discussion-name}.md
...

Existing specifications to incorporate:
- docs/workflow/specification/{spec-name}.md
- docs/workflow/specification/{spec-name}.md

Output: docs/workflow/specification/unified.md

Context: This consolidates all discussions into a single unified specification. The existing specifications should be incorporated - extract and adapt their content alongside the discussion material.

After the unified specification is complete, mark the incorporated specs as superseded by updating their frontmatter:

    status: superseded
    superseded_by: unified

---
Invoke the technical-specification skill.
```

### Handoff: Unify All (No Existing Specs)

```
Specification session for: Unified

Sources:
- docs/workflow/discussion/{discussion-name}.md
- docs/workflow/discussion/{discussion-name}.md
...

Output: docs/workflow/specification/unified.md

---
Invoke the technical-specification skill.
```
