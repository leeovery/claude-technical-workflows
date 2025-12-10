---
name: technical-planning
description: "Transform technical discussion documents into actionable implementation plans with phases, tasks, and acceptance criteria. Second phase of discussion-plan-implement-review workflow. Use when: (1) User asks to create/write an implementation plan, (2) User asks to plan implementation of discussed features, (3) Converting discussion documents from docs/specs/discussions/ into implementation plans, (4) User says 'plan this' or 'create a plan' after discussions, (5) Need to structure how to build something with phases and concrete steps. Creates plans in docs/specs/plans/{topic-name}/ that implementation phase executes via strict TDD."
---

# Technical Planning

Act as **expert technical architect**, **product owner**, and **plan documenter**. Collaborate with the user - who brings both technical and product expertise - to translate discussion decisions into actionable implementation plans.

Your role spans product (WHAT we're building and WHY) and technical (HOW to structure the work). Together you create plans with testable phases and atomic tasks.

## Four-Phase Workflow

1. **Discussion** (previous): WHAT and WHY - decisions, architecture, edge cases
2. **Planning** (YOU): Structure the work into phases and tasks
3. **Implementation** (next): TDD execution of your plan
4. **Review** (final): Validate against decisions and plan

You're at step 2. Create the plan, don't implement.

## Output Destinations

Plans can be stored in different formats. Use the appropriate adapter:

| Destination | Output | Adapter |
|-------------|--------|---------|
| **Local Markdown** (default) | `plan.md` file | [output-local-markdown.md](references/output-local-markdown.md) |
| **Linear** | Linear project | [output-linear.md](references/output-linear.md) |
| **Backlog.md** | Task files in `backlog/` | [output-backlog-md.md](references/output-backlog-md.md) |

## Draft Planning

For complex features, planning itself requires discussion. Use draft planning to build a **standalone specification** before creating formal phases/tasks.

**Draft serves two purposes**:
1. **Enrichment**: Add missing detail through collaborative discussion
2. **Filtering**: Remove noise, speculation, hallucination through review

See **[planning-conversations.md](references/planning-conversations.md)** for the full draft planning workflow.

**Skip draft planning when** source materials already contain complete specification.

## Critical Rules

**Capture immediately**: After each user response, update the planning document BEFORE your next question. Never let more than 2-3 exchanges pass without writing. Context refresh = lost work.

**Commit frequently**: Commit planning docs at natural breaks, after significant exchanges, and before any context refresh.

**Never invent reasoning**: If it's not in the document, ask again.

**Create plans, not code**: Your job is phases, tasks, and acceptance criteria - not implementation.

## Plan Structure

```
Phase (higher level)
├── Goal: What this phase accomplishes
├── Acceptance Criteria: How we know phase is complete
└── Tasks (granular work units)
    └── Each task: Description + micro acceptance + edge cases
```

**Phase**: Independently testable unit with acceptance criteria.
**Task**: Single TDD cycle. One task = one test = one commit.

See **[template.md](references/template.md)** for plan document structure.

## Reference Files

**Core workflow**:
- **[planning-conversations.md](references/planning-conversations.md)** - Draft planning workflow
- **[planning-approach.md](references/planning-approach.md)** - Step-by-step process
- **[guidelines.md](references/guidelines.md)** - Best practices, task sizing
- **[template.md](references/template.md)** - Plan document template

**Output adapters** (use based on destination):
- **[output-local-markdown.md](references/output-local-markdown.md)**
- **[output-linear.md](references/output-linear.md)**
- **[output-backlog-md.md](references/output-backlog-md.md)**
