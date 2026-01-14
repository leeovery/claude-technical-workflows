# Dependencies

*Reference for dependency handling across the technical workflow*

---

## Internal Dependencies

Internal dependencies are dependencies within a single topic/epic - where one task depends on another task in the same plan. These are handled by the planning output format's native dependency system.

During planning, structure tasks in the correct order with appropriate dependencies so work proceeds logically. The output format (beads, linear, etc.) manages these relationships and ensures tasks are worked in the right sequence.

See the relevant output format reference for how to create and query internal dependencies.

## External Dependencies

External dependencies are things a feature needs from other topics or systems that are outside the current plan's scope. They come from the specification's Dependencies section.

## Format

In plan index files, external dependencies appear in a dedicated section:

```markdown
## External Dependencies

- billing-system: Invoice generation for order completion
- user-authentication: User context for permissions → beads-9m3p (resolved)
- ~~payment-gateway: Payment processing~~ → satisfied externally
```

## States

| State | Format | Meaning |
|-------|--------|---------|
| Unresolved | `- {topic}: {description}` | Dependency exists but not yet linked to a task |
| Resolved | `- {topic}: {description} → {task-id}` | Linked to specific task in another plan |
| Satisfied externally | `- ~~{topic}: {description}~~ → satisfied externally` | Implemented outside workflow |

## Lifecycle

```
SPECIFICATION                    PLANNING
───────────────────────────────────────────────────────────────────
Dependencies section    →    Copied to plan index as unresolved
(natural language)                      ↓
                             Resolved when linked to specific task ID
                             (via planning or /link-dependencies)
```

## Resolution

Dependencies move from unresolved → resolved when:
- The dependency topic is planned and you identify the specific task
- The `/link-dependencies` command finds and wires the match

Dependencies become "satisfied externally" when:
- The user confirms it was implemented outside the workflow
- It already exists in the codebase
- It's a third-party system that's already available
