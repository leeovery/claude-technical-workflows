# Local Markdown

*Output format adapter for **[technical-planning](../../../SKILL.md)***

---

Use this format for simple features or when you want everything in version-controlled markdown files.

## Benefits

- No external tools or dependencies required
- Human-readable and easy to edit
- Works offline with any text editor
- Simplest setup — just create markdown files

## Setup

No external tools required. This format uses plain markdown files stored in the repository.

## Output Location

Tasks are stored as individual markdown files in a `{topic}/` subdirectory under the planning directory:

```
docs/workflow/planning/{topic}/
├── {topic}-1-1.md              # Task files
├── {topic}-1-2.md
└── {topic}-2-1.md
```

Task filename = task ID for easy lookup.
