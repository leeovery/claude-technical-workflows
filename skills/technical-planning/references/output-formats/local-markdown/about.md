# Local Markdown

*Output format adapter for **[technical-planning](../../../SKILL.md)***

---

Use this format for simple features or when you want everything in version-controlled markdown files with detailed task files.

## Benefits

- No external tools or dependencies required
- Plan Index File provides overview; task files provide detail
- Human-readable and easy to edit
- Works offline with any text editor
- Simplest setup - just create markdown files

## Setup

No external tools required. This format uses plain markdown files stored in the repository.

## Output Location

```
docs/workflow/planning/
├── {topic}.md                    # Plan Index File
└── {topic}/
    └── {task-id}.md              # Task detail files
```

The Plan Index File contains phases and task tables. Each authored task gets its own file in the `{topic}/` directory. Task filename = task ID for easy lookup.

## Resulting Structure

After planning:

```
docs/workflow/
├── discussion/{topic}.md           # Discussion output
├── specification/{topic}.md        # Specification output
└── planning/
    ├── {topic}.md                  # Plan Index File (format: local-markdown)
    └── {topic}/
        ├── {topic}-1-1.md          # Task detail files
        ├── {topic}-1-2.md
        └── {topic}-2-1.md
```
