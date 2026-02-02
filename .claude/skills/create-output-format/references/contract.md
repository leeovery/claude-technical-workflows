# Output Format Contract

Every output format adapter is a directory of 6 files, each serving a specific concern. Consumers load only the files they need — they never need to read the entire adapter.

## Required Files

| File | Purpose | Loaded by |
|------|---------|-----------|
| `about.md` | Format identity and setup | Planning (format selection) |
| `authoring.md` | Writing plans and tasks | Planning (task writing), restart/cleanup |
| `reading.md` | Reading plans and tasks | Implementation, view-plan, review |
| `updating.md` | Updating task progress | Implementation (progress tracking) |
| `dependencies.md` | Cross-topic dependencies | Link-dependencies, planning |
| `frontmatter.md` | Metadata schemas | Authoring, reading, updating |

## File Specifications

### about.md

Provides everything needed to evaluate and initialise the format.

Must include:

- **Format name and description** — what this format is
- **Benefits** — why choose this format (bullet list)
- **Setup** — installation, configuration, prerequisites
- **Output Location** — where plans and tasks are stored (path patterns or external locations)
- **Resulting Structure** — directory/entity layout after planning is complete

### authoring.md

Instructions for creating plans and writing task detail during planning.

Must include:

- **Plan Index Template** — full template for `docs/workflow/planning/{topic}.md` including frontmatter and body structure
- **Task Writing** — how to create individual tasks using canonical field names (see [canonical-task.md](canonical-task.md))
- **Flagging** — how to mark tasks as `[needs-info]` when information is missing
- **Cleanup (Restart)** — how to delete all authored tasks for a topic (used during plan restart)

### reading.md

Instructions for reading plans and extracting tasks during implementation.

Must include:

- **Reading the Plan Index** — how to read the plan overview, phases, and task tables
- **Extracting a Task** — how to read full task detail for a specific task ID
- **Next Incomplete Task** — how to determine the next task to implement (phase ordering, status checks)

### updating.md

Instructions for recording progress during implementation.

Must include:

- **Mark Task Complete** — how to update a task's status to completed
- **Mark Task Skipped** — how to record a skipped task
- **Update Plan Index** — how to update the task table and phase status in the Plan Index File
- **Advance Progress** — how to update the `planning:` frontmatter block to reflect current position

### dependencies.md

Instructions for expressing and querying cross-topic dependencies.

Must include:

- **Dependency Format** — how dependencies are represented in this format
- **Creating Dependencies** — how to wire up a blocking relationship
- **Querying Dependencies** — commands/instructions to find, check, and resolve dependencies

### frontmatter.md

Schema definitions for all YAML frontmatter used by this format.

Must include:

- **Plan Index Frontmatter** — all fields with types, required/optional, descriptions
- **Task Frontmatter** — all fields with types, required/optional, descriptions (if tasks have frontmatter)
- **Format-Specific Fields** — any fields unique to this format (e.g., `project_id` for Linear)

## Canonical Task Fields

All formats must use the standardised task field names defined in [canonical-task.md](canonical-task.md). The authoring.md file maps these fields to the format's storage mechanism (markdown sections, issue fields, API attributes, etc.).
