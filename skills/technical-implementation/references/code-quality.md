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

## Project Standards
Check `.claude/skills/` for project-specific patterns.
