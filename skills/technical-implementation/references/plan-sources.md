# Plan Sources

*Reference for **[technical-implementation](../SKILL.md)***

---

Plans are always stored in `docs/workflow/planning/{topic}.md`. The file's frontmatter declares the format.

## Reading Plans

1. Read the plan file and check the `format` field in frontmatter
2. Load the corresponding output adapter from the planning skill:
   ```
   skills/technical-planning/references/output-{format}.md
   ```
3. Follow the **Implementation** section in that adapter for how to read tasks and update progress

## Execution Workflow

Regardless of format, execute the same TDD workflow:
1. Derive test from micro acceptance
2. Write failing test
3. Implement to pass
4. Commit
5. Update progress
6. Repeat
