# Tick: Authoring

## Sandbox Mode and Large Descriptions

Bash heredocs (`$(cat <<'EOF'...EOF)`) create temp files that sandbox mode blocks, resulting in empty descriptions being set silently. Do **not** use `dangerouslyDisableSandbox` — it forces user approval on every call.

Instead, use the **Write tool + cat pattern**:

1. Use the **Write tool** to save the description to `$TMPDIR/tick-desc.txt` — this bypasses sandbox because it uses Claude Code's file writing, not bash
2. Run the tick command with `--description "$(cat $TMPDIR/tick-desc.txt)"` in normal sandbox mode — `cat` just reads, no temp files needed

This works for both `tick create --description` and `tick update --description`.

## Task Storage

Tasks are created using the `tick create` command. Before creating individual tasks, establish the topic and phase parent tasks.

**1. Create the topic task:**

```bash
tick create "{Topic Name}"
```

This returns the topic task ID (e.g., `tick-a1b2`).

**2. Create phase tasks as children of the topic:**

```bash
tick create "Phase 1: {Phase Name}" --parent tick-a1b2
tick create "Phase 2: {Phase Name}" --parent tick-a1b2
```

**3. Create tasks as children of their phase:**

```bash
tick create "{Task Title}" --parent tick-c3d4 \
  --description "{Task description content.

Acceptance criteria, edge cases, and implementation
details go here. Supports multi-line text.}"
```

Complete example — creating a task under a phase:

```bash
tick create "Implement authentication middleware" \
  --parent tick-c3d4 \
  --description "Create Express middleware that validates JWT tokens on protected routes.

Acceptance criteria:
- Validates token signature and expiry
- Extracts user ID from token payload
- Returns 401 for missing or invalid tokens
- Passes user context to downstream handlers"
```

## Task Properties

### Status

Tasks are created with `open` status by default.

| Status | Meaning |
|--------|---------|
| `open` | Task has been authored but not started |
| `in_progress` | Task is currently being worked on |
| `done` | Task is complete |
| `cancelled` | Task is no longer needed |

### Phase Grouping

Phases are represented as parent tasks. Each task belongs to a phase by being a child of that phase's task. Use `--parent <phase-id>` during creation.

To list tasks within a phase:

```bash
tick list --parent <phase-id>
```

### Labels / Tags

Tick does not have a native label or tag system. Categorisation is handled through the parent/child hierarchy.

## Flagging

When information is missing, prefix the task title with `[NEEDS INFO]` and include questions in the description:

```bash
tick create "[NEEDS INFO] Rate limiting strategy" \
  --parent tick-c3d4 \
  --description "Needs clarification:
- What is the rate limit threshold?
- Per-user or per-IP?
- What response code on limit exceeded?"
```

## Cleanup (Restart)

Cancel the topic task and all its descendants. First, list the tasks to collect their IDs:

```bash
tick list --parent <topic-id>
```

Then cancel each task (leaf tasks first, then phases, then the topic):

```bash
tick cancel <task-id>
```

Cancelled tasks remain in the JSONL history but are excluded from `tick ready` and active listings.

**Full reset** (removes all tasks across all topics):

```bash
rm -rf .tick && tick init
```
