# Output Format Contract

Every output format adapter is a directory of 6 files, each serving a specific concern.

## Required Files

| File | Purpose |
|------|---------|
| `about.md` | Format identity, setup, and storage layout |
| `authoring.md` | Creating plans and storing tasks |
| `reading.md` | Reading plans and extracting tasks |
| `updating.md` | Recording task progress |
| `dependencies.md` | Cross-topic dependency management |
| `frontmatter.md` | Metadata schemas |

## File Specifications

### about.md

Provides everything needed to evaluate and initialise the format.

Must include:

- **Format name and description** — what this format is
- **Benefits** — why choose this format
- **Setup** — installation, configuration, prerequisites
- **Output Location** — where plans and tasks are stored
- **Resulting Structure** — directory/entity layout after planning

### authoring.md

Instructions for creating plans and storing task content.

Must include:

- **Plan Index Template** — full template for the plan index file including frontmatter and body structure
- **Task Storage** — where and how to store a task (file path, API call, etc.). A task has a title and a description body — the format defines the container.
- **Flagging** — how to mark tasks as `[needs-info]` when information is missing
- **Cleanup (Restart)** — how to delete all authored tasks for a topic

### reading.md

Instructions for reading plans and extracting tasks.

Must include:

- **Reading the Plan Index** — how to read the plan overview, phases, and task tables
- **Extracting a Task** — how to read full task detail for a specific task ID
- **Next Incomplete Task** — how to determine the next task to work on (phase ordering, status checks)

### updating.md

Instructions for recording progress.

Must include:

- **Mark Task Complete** — how to update a task's status to completed
- **Mark Task Skipped** — how to record a skipped task
- **Update Plan Index** — how to update the task table and phase status
- **Advance Progress** — how to update the progress tracking frontmatter

### dependencies.md

Instructions for expressing and querying cross-topic dependencies.

Must include:

- **Dependency Format** — how dependencies are represented
- **Creating Dependencies** — how to wire up a blocking relationship
- **Querying Dependencies** — how to find, check, and resolve dependencies

### frontmatter.md

Schema definitions for all YAML frontmatter used by this format.

Must include:

- **Plan Index Frontmatter** — all fields with types, required/optional, descriptions
- **Task Frontmatter** — all fields with types, required/optional, descriptions (if tasks have frontmatter)
- **Format-Specific Fields** — any fields unique to this format
