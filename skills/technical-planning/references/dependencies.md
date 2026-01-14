# Dependencies

*Reference for dependency handling across the technical workflow*

---

## External Dependencies

External dependencies are things a feature needs from other topics or systems that are outside the current plan's scope. They come from the specification's Dependencies section and must be satisfied before implementation can proceed.

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
SPECIFICATION                    PLANNING                         IMPLEMENTATION
─────────────────────────────────────────────────────────────────────────────────
Dependencies section    →    Copied to plan index         →    Gate checks status
(natural language)           (unresolved initially)            (blocks if not satisfied)
                                    ↓
                             Resolved when linked
                             to specific task ID
```

## Resolution

Dependencies move from unresolved → resolved when:
- The dependency topic is planned and you identify the specific task
- The `/link-dependencies` command finds and wires the match

Dependencies become "satisfied externally" when:
- The user confirms it was implemented outside the workflow
- It already exists in the codebase
- It's a third-party system that's already available

## Implementation Blocking

The `start-implementation` command checks external dependencies before allowing implementation to proceed:

- **Unresolved**: Blocks - no plan exists for this dependency
- **Resolved but incomplete**: Blocks - the linked task isn't finished yet
- **Resolved and complete**: Proceeds
- **Satisfied externally**: Proceeds

Unresolved or incomplete dependencies block implementation - like trying to put a roof on a house before the walls are built.
