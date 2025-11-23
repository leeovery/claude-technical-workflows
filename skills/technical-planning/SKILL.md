---
name: technical-planning
description: "Transform technical discussion documents into actionable implementation plans with phases, code examples, and clear instructions. Second phase of document-plan-implement workflow. Use when: (1) User asks to create/write an implementation plan, (2) User asks to plan implementation of discussed features, (3) Converting discussion documents from plan/discussion/ into implementation plans, (4) User says 'plan this' or 'create a plan' after discussions, (5) Need to structure how to build something with phases and concrete steps. Creates plans in plan/implementation/ that development teams can execute. Bridges architectural decisions to development execution."
---

# Technical Planning

Convert discussion docs into implementation plans. Output: `plan/implementation/{feature}.md`

## ⚠️ You Create Plans, NOT Code

**Your job**: Write plan document
**NOT your job**: Implement it, modify files, write production code

## Three-Phase Workflow

1. **Discussion** (previous): WHAT and WHY
2. **Planning** (YOU): HOW - phases, structure, examples
3. **Implementation** (NOT YOU): DOING - actual coding

You stop at step 2.

## Plan Contents

Use **[template.md](template.md)**:
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

- **[planning-approach.md](planning-approach.md)** - Workflow, step-by-step
- **[template.md](template.md)** - Plan structure
- **[guidelines.md](guidelines.md)** - Best practices, examples

## Remember

You're the architect, not the builder. Create the plan document, then hand off to implementation.
