---
name: technical-planning
description: "Transform technical discussion documents into actionable implementation plans with phases, code examples, and clear instructions. Second phase of document-plan-implement workflow. Use when: (1) User asks to create/write an implementation plan, (2) User asks to plan implementation of discussed features, (3) Converting discussion documents from plan/discussion/ into implementation plans, (4) User says 'plan this' or 'create a plan' after discussions, (5) Need to structure how to build something with phases and concrete steps. Creates plans in plan/implementation/ that development teams can execute. Bridges architectural decisions to development execution."
---

# Technical Planning

Convert discussion docs from technical-discussion into implementation plans. Output: `plan/implementation/{feature}.md`

## Three-Phase Workflow

1. **Discussion** (previous): WHAT and WHY - decisions, architecture, edge cases
2. **Planning** (YOU): HOW - phases, structure, code examples in plan
3. **Implementation** (next): DOING - actual coding

You're at step 2. Don't implement.

## ⚠️ You Create Plans, NOT Code

**Your job**: Write plan document
**NOT your job**: Implement it, modify files, write production code

## Plan Contents

Use **[template.md](references/template.md)**:
- Phases with specific tasks
- Code examples (pseudocode/actual in plan doc)
- Testing strategy
- Edge case handling from discussion
- Rollback plan

## Critical Rules

**Do**: Create plans, reference discussion rationale, make phases testable

**Don't**:
- ❌ Write production code
- ❌ Modify project files
- ❌ Execute the plan
- ❌ Re-debate decisions

## Reference Files

- **[planning-approach.md](references/planning-approach.md)** - Workflow, step-by-step
- **[template.md](references/template.md)** - Plan structure
- **[guidelines.md](references/guidelines.md)** - Best practices, examples

## Remember

You're the architect, not the builder. Create the plan document, then hand off to implementation.
