# Feature Task Design

*Context guidance for **[task-design.md](../task-design.md)** — feature additions to existing systems*

---

## Integration-Aware Ordering

In feature work, the existing codebase provides the foundation. "Foundation" means whatever the existing codebase doesn't provide yet — new model fields, new routes, service extensions — that other tasks in this phase need.

Extend existing code first, then build new behaviour on top.

**Example** ordering within a phase:

```
Task 1: Add OAuth fields to User model + migration (extends existing model)
Task 2: OAuth callback endpoint + token exchange (new route, uses existing auth middleware)
Task 3: Session creation from OAuth token (extends existing session logic)
Task 4: Handle provider errors and token validation failures (error handling)
```

The first task extends what exists. Later tasks build the new behaviour using both existing and newly-added code.

---

## Feature Vertical Slicing

Each task delivers a complete, testable increment that integrates with the existing system. Since infrastructure already exists, tasks can focus on behaviour rather than setup.

**Example** (Extending an existing system):

```
Task 1: Add search index fields to Product model (extends existing)
Task 2: Search query endpoint returning products (new endpoint, existing model)
Task 3: Filter results by category and price range (extends search)
Task 4: Handle empty results and malformed queries (edge cases)
```

---

## Follow Existing Patterns

Task implementations should match established conventions in the codebase:

- Use the same testing patterns (if the project uses factory functions, use factories; if it uses fixtures, use fixtures)
- Follow the existing file organisation and naming conventions
- Use established service/repository/controller patterns rather than introducing new ones
- Match the existing error handling approach
