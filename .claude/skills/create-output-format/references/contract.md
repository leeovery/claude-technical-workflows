# Output Format Contract

Every output format adapter is a directory of 5 files, each serving a specific concern.

## Required Files

| File | Purpose |
|------|---------|
| `about.md` | Format identity, setup, and storage layout |
| `authoring.md` | Storing tasks |
| `reading.md` | Extracting tasks |
| `updating.md` | Recording task progress |
| `dependencies.md` | Cross-topic dependency management |

## File Specifications

### about.md

Provides everything needed to evaluate and initialise the format.

Must include:

- **Format name and description** — what this format is
- **Benefits** — why choose this format
- **Setup** — installation, configuration, prerequisites
- **Output Location** — where tasks are stored

### authoring.md

Instructions for storing task content.

Must include:

- **Task Storage** — where and how to store a task (file path, API call, etc.). A task has a title and a description body — the format defines the container.
- **Flagging** — how to mark tasks as needing clarification
- **Cleanup (Restart)** — how to delete all authored tasks for a topic

### reading.md

Instructions for extracting tasks.

Must include:

- **Extracting a Task** — how to read full task detail for a specific task ID
- **Next Incomplete Task** — how to determine the next task to work on (phase ordering, status checks)

### updating.md

Instructions for recording progress.

Must include:

- **Mark Task Complete** — how to update a task's status to completed
- **Mark Task Skipped** — how to record a skipped task

### dependencies.md

Instructions for expressing and querying cross-topic dependencies.

Must include:

- **Dependency Format** — how dependencies are represented
- **Creating Dependencies** — how to wire up a blocking relationship
- **Querying Dependencies** — how to find, check, and resolve dependencies
