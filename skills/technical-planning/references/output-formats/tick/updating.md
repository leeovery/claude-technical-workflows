# Tick: Updating

## Status Transitions

Tick uses dedicated commands for each status transition:

| Transition | Command |
|------------|---------|
| Start | `tick start <task-id>` (open → in_progress) |
| Complete | `tick done <task-id>` (in_progress → done) |
| Cancelled | `tick cancel <task-id>` (any → cancelled) |
| Reopen | `tick reopen <task-id>` (done/cancelled → open) |
| Skipped | `tick cancel <task-id>` (no separate skipped status — use cancel) |

`done` and `cancel` set a closed timestamp. `reopen` clears it.

## Updating Task Content

To update a task's properties:

- **Title**: `tick update <task-id> --title "New title"`
- **Description**: `tick update <task-id> --description "New description"`
- **Priority**: `tick update <task-id> --priority 1`
- **Parent**: `tick update <task-id> --parent <new-parent-id>` (pass empty string to clear)
- **Dependencies**: See [graph.md](graph.md)
