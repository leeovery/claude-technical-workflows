# Output: Local Markdown

*Output adapter for **[technical-planning](../SKILL.md)***

---

Use this output format for **simple features** or when you want everything version-controlled in a single file.

## Output Location

```
docs/specs/plans/{topic-name}/
└── plan.md
```

The directory name should match the discussion topic name from `docs/specs/discussions/{topic-name}/`.

## File Structure

Create `plan.md` with frontmatter declaring the format:

```markdown
---
format: local-markdown
---

# Implementation Plan: {Feature/Project Name}

**Date**: YYYY-MM-DD
**Status**: Draft | Ready | In Progress | Completed
**Discussion**: `docs/specs/discussions/{topic-name}/`

... rest of plan content ...
```

Use the template from **[template.md](template.md)** for the full structure including:

- Overview (goal, done-when, key decisions)
- Architecture summary
- Phases with acceptance criteria checkboxes
- Tasks with micro acceptance (test names)
- Edge case mapping table
- Testing strategy
- Dependencies
- Change log

## Frontmatter

The `format: local-markdown` frontmatter tells implementation that the full plan content is in this file.

```yaml
---
format: local-markdown
---
```

## What to Include

Everything goes in the single `plan.md` file:

- All phases and tasks inline
- All acceptance criteria
- Edge case mapping
- Code examples for complex patterns

## When to Use

- Small to medium features
- Solo development
- Quick iterations
- When you want simple git-tracked documentation

## Resulting Structure

After planning:

```
docs/specs/
├── discussions/
│   └── {topic-name}/
│       └── discussion.md     # Source decisions
└── plans/
    └── {topic-name}/
        └── plan.md           # format: local-markdown
```

Implementation will read `plan.md`, see `format: local-markdown`, and execute directly from file content.
