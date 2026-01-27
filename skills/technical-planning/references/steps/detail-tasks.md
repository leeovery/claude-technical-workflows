# Detail, Approve, and Log Each Task

*Reference for **[technical-planning](../../SKILL.md)***

---

Orient the user:

> "Task list for Phase {N} is agreed. I'll work through each task one at a time — presenting the full detail, discussing if needed, and logging it to the plan once approved."

Work through the agreed task list **one task at a time**.

#### Present

Write the complete task using the required template (Problem, Solution, Outcome, Do, Acceptance Criteria, Tests, Context) — see [Task Design](#task-design) for the required structure and field requirements.

Present it to the user **in the format it will be written to the plan**. The output format adapter determines the exact format. What the user sees is what gets logged — no changes between approval and writing.

After presenting, ask:

> **Task {M} of {total}: {Task Name}**
>
> **To proceed, choose one:**
> - **"Approve"** — Task is confirmed. I'll log it to the plan verbatim.
> - **"Adjust"** — Tell me what to change.

**STOP.** Wait for the user's response.

#### If adjust

The user may:
- Request changes to the task content
- Ask questions about scope, granularity, or approach
- Flag that something doesn't match the specification
- Identify missing edge cases or acceptance criteria

Incorporate feedback and re-present the updated task **in full**. Then ask the same choice again. Repeat until approved.

#### If approved

Log the task to the plan — verbatim, as presented. Do not modify content between approval and writing. The output format adapter determines how tasks are written (appending markdown, creating issues, etc.).

After logging, confirm:

> "Task {M} of {total}: {Task Name} — logged."

#### Next task or phase complete

**If tasks remain in this phase:** → Return to the top of **Step 5** with the next task. Present it, ask, wait.

**If all tasks in this phase are logged:**

```
Phase {N}: {Phase Name} — complete ({M} tasks logged).
```

→ Return to **Step 4** for the next phase.

**If all phases are complete:** → Proceed to **Step 6**.

---

## Cross-Cutting References

Cross-cutting specifications (e.g., caching strategy, error handling conventions, rate limiting policy) are not things to build — they are architectural decisions that influence how features are built. They inform technical choices within the plan without adding scope.

If cross-cutting specifications were provided alongside the specification:

1. **Apply their decisions** when designing tasks (e.g., if caching strategy says "cache API responses for 5 minutes", reflect that in relevant task detail)
2. **Note where patterns apply** — when a task implements a cross-cutting pattern, reference it
3. **Include a "Cross-Cutting References" section** in the plan linking to these specifications

Cross-cutting references are context, not scope. They shape how tasks are written, not what tasks exist.

---

## Task Design

**One task = One TDD cycle**: write test → implement → pass → commit

### Task Structure

Every task should follow this structure:

```markdown
### Task N: [Clear action statement]

**Problem**: Why this task exists - what issue or gap it addresses.

**Solution**: What we're building - the high-level approach.

**Outcome**: What success looks like - the verifiable end state.

**Do**:
- Specific implementation steps
- File locations and method names where helpful
- Concrete guidance, not vague directions

**Acceptance Criteria**:
- [ ] First verifiable criterion
- [ ] Second verifiable criterion
- [ ] Edge case handling criterion

**Tests**:
- `"it does the primary expected behavior"`
- `"it handles edge case correctly"`
- `"it fails appropriately for invalid input"`

**Context**: (when relevant)
> Relevant details from specification: code examples, architectural decisions,
> data models, or constraints that inform implementation.
```

### Field Requirements

| Field | Required | Notes |
|-------|----------|-------|
| Problem | Yes | One sentence minimum - why this task exists |
| Solution | Yes | One sentence minimum - what we're building |
| Outcome | Yes | One sentence minimum - what success looks like |
| Do | Yes | At least one concrete action |
| Acceptance Criteria | Yes | At least one pass/fail criterion |
| Tests | Yes | At least one test name; include edge cases, not just happy path |
| Context | When relevant | Only include when spec has details worth pulling forward |

### The Template as Quality Gate

If you struggle to articulate a clear Problem for a task, this signals the task may be:

- **Too granular**: Merge with a related task
- **Mechanical housekeeping**: Include as a step within another task
- **Poorly understood**: Revisit the specification

Every standalone task should have a reason to exist that can be stated simply. The template enforces this - difficulty completing it is diagnostic information, not a problem to work around.

### Vertical Slicing

Prefer **vertical slices** that deliver complete, testable functionality over horizontal slices that separate by technical layer.

**Horizontal (avoid)**:
```
Task 1: Create all database models
Task 2: Create all service classes
Task 3: Wire up integrations
Task 4: Add error handling
```

Nothing works until Task 4. No task is independently verifiable.

**Vertical (prefer)**:
```
Task 1: Fetch and store events from provider (happy path)
Task 2: Handle pagination for large result sets
Task 3: Handle authentication token refresh
Task 4: Handle rate limiting
```

Each task delivers a complete slice of functionality that can be tested in isolation.

Within a bounded feature, vertical slicing means each task completes a coherent unit of that feature's functionality - not that it must touch UI/API/database layers. The test is: *can this task be verified independently?*

TDD naturally encourages vertical slicing - when you think "what test can I write?", you frame work as complete, verifiable behavior rather than technical layers
