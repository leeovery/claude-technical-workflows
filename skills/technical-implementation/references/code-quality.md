# Code Quality

*Reference for **[technical-implementation](../SKILL.md)***

---

Apply standard quality principles. Defer to project-specific skills for framework conventions.

## Principles

### DRY: Don't Repeat Yourself
- Extract repeated logic after three instances (Rule of Three)
- Avoid premature abstraction for code used once or twice

### SOLID
- **Single Responsibility**: Each class/function does one thing
- **Open/Closed**: Extend behavior without modifying existing code
- **Liskov Substitution**: Subtypes must be substitutable for base types
- **Interface Segregation**: Don't force classes to implement unused methods
- **Dependency Inversion**: Depend on abstractions, not concretions

### Cyclomatic Complexity
Keep low. Fix with early returns and method extraction.

### YAGNI
Only implement what's in the plan. Ask: "Is this in the plan?"

## Testability
- Inject dependencies
- Prefer pure functions
- Avoid hidden dependencies

## Anti-Patterns to Avoid
- God classes
- Magic numbers/strings
- Deep nesting (3+)
- Long parameter lists (4+)
- Boolean parameters

## Convention Consistency

When adding to an existing codebase, match what's already there:
- **Error messages**: Match the casing, wrapping style, and prefix patterns in existing code
- **Naming**: Follow the project's conventions for files, functions, types, and variables
- **File organisation**: Follow the project's pattern for splitting concerns across files
- **Helpers**: Search for existing helpers before creating new ones. After creating one, check if existing code could use it too
- **Types**: Prefer concrete types over generic/any types when the set of possibilities is known. Use structured return types over multiple bare return values for extensibility
- **Co-location**: Keep related types near the interfaces or functions they serve

## Project Standards
Check `.claude/skills/` for project-specific patterns.
