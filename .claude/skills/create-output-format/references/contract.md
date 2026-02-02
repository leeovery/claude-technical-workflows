# Output Format Contract

Every output format adapter is a directory of 5 files, each serving a specific concern.

## Required Files

| File | Purpose |
|------|---------|
| `about.md` | Format identity, setup, and storage layout |
| `authoring.md` | Creating tasks and setting their properties |
| `reading.md` | Extracting tasks and determining work order |
| `updating.md` | Modifying tasks — status, content, properties |
| `dependencies.md` | Blocking relationships within and across plans |

## File Specifications

### about.md

Provides everything needed to evaluate and initialise the format.

Must include:

- **Format name and description** — what this format is
- **Benefits** — why choose this format
- **Setup** — installation, configuration, prerequisites
- **Output Location** — where tasks are stored
- **Structure Mapping** — how workflow concepts (topic, phase, task) map to the format's entities

### authoring.md

Instructions for creating tasks and setting their properties.

Must include:

- **Task Storage** — how to create a task (file path, API call, etc.) with a complete example showing the full task template
- **Task Properties** — what properties this format supports and how to set each one during creation. Common properties include:
  - **Status** — available values and their meanings
  - **Priority** — levels available and how to assign them
  - **Phase grouping** — how tasks are grouped into phases
  - **Labels/tags** — categorisation available beyond phases
- **Flagging** — how to mark tasks as needing clarification
- **Cleanup (Restart)** — how to delete all authored tasks for a topic

### reading.md

Instructions for extracting tasks and determining work order.

Must include:

- **Extracting a Task** — how to read full task detail including all properties
- **Next Available Task** — how to determine the next task to work on. Document how the format uses status, priority, dependencies, and phase ordering to determine sequence.

### updating.md

Instructions for modifying tasks.

Must include:

- **Status Transitions** — how to change task status. Document all supported statuses (e.g., complete, skipped, cancelled) and how to set each one.
- **Updating Task Content** — how to modify a task's title, description, priority, or other properties after creation.

### dependencies.md

Instructions for expressing and querying blocking relationships.

Must include:

- **Adding a Dependency** — how to declare that one task depends on another. Must support multiple dependencies per task.
- **Removing a Dependency** — how to remove a dependency
- **Cross-Topic Dependencies** — whether the same mechanism works across plans, or if there are differences
- **Querying Dependencies** — how to find tasks with dependencies, check if a dependency is resolved, and find unblocked work
