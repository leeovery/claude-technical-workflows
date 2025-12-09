# Plan Sources

*Reference for **[technical-implementation](../SKILL.md)***

---

Plans are always stored in `docs/specs/plans/{topic}/plan.md`. The file's frontmatter declares the format.

## Detecting Plan Format

Always read `plan.md` first and check the `format` field in frontmatter:

```yaml
---
format: local-markdown | linear | tasks-md
---
```

| Format | Meaning | How to Proceed |
|--------|---------|----------------|
| `local-markdown` | Full plan is in this file | Read content directly |
| `linear` | Plan managed in Linear | Query Linear via MCP |
| `tasks-md` | Tasks in subdirectories | Read directory structure |

## Local Markdown (`format: local-markdown`)

**Frontmatter**:
```yaml
---
format: local-markdown
---
```

**Reading**:
1. Read `plan.md` - all content is inline
2. Phases and tasks are in the document
3. Follow phase order as written
4. Tasks have micro acceptance in the file

**Structure**:
```markdown
## Phase 1: {Name}
**Tasks**:
1. **{Task Name}**
   - **Do**: What to implement
   - **Test**: `"it does expected behavior"`
```

## Linear (`format: linear`)

**Frontmatter**:
```yaml
---
format: linear
project: PROJECT_NAME
project_id: abc123-def456
team: Engineering
---
```

**Reading**:
1. Extract `project_id` and `team` from frontmatter
2. Query Linear MCP for project milestones (phases)
3. Query Linear MCP for issues within each milestone (tasks)
4. Process in milestone order

**MCP Queries**:
- Get milestones for project (phases)
- Get issues per milestone (tasks)
- Issue description contains: Goal, Implementation, Tests, Edge Cases

**Updating Progress**:
- After completing each task, update issue status in Linear via MCP
- User sees real-time progress in Linear UI

**Fallback**:
If Linear MCP is unavailable:
- Inform the user
- Cannot proceed without MCP access
- Suggest checking MCP configuration

## Tasks.md (`format: tasks-md`)

**Frontmatter**:
```yaml
---
format: tasks-md
---
```

**Reading**:
1. Read `plan.md` for overview context
2. List phase directories (numbered: `1-{name}/`, `2-{name}/`)
3. For each phase, read task files in order (`01-{task}.md`, `02-{task}.md`)

**Structure**:
```
docs/specs/plans/{topic}/
├── plan.md                   # format: tasks-md (overview)
├── 1-{phase-name}/           # Phase 1
│   ├── 01-{task}.md          # Task 1
│   └── 02-{task}.md          # Task 2
├── 2-{phase-name}/           # Phase 2
│   └── 01-{task}.md          # Task 1
└── done/                     # Completed tasks
```

**Task file contains**:
```markdown
## Goal
{What to accomplish}

## Implementation
{What to do}

## Tests
- `it does expected behavior`

## Acceptance
- [ ] Test written and failing
- [ ] Implementation complete
- [ ] Test passing
- [ ] Committed
```

**Updating Progress**:
- Check off acceptance items in task file
- Optionally move completed task files to `done/` directory

## Common Patterns

Regardless of format, you'll find:
- **Phases** with acceptance criteria
- **Tasks** with micro acceptance (test names)
- **Discussion reference** for context

Execute the same TDD workflow for all formats:
1. Derive test from micro acceptance
2. Write failing test
3. Implement to pass
4. Commit
5. Repeat
