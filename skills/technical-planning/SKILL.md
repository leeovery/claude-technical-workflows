---
name: technical-planning
description: "Transform technical discussion documents into actionable implementation plans with phases, code examples, and clear instructions. Second phase of document-plan-implement workflow. Use when: (1) User asks to create/write an implementation plan, (2) User asks to plan implementation of discussed features, (3) Converting discussion documents from plan/discussion/ into implementation plans, (4) User says 'plan this' or 'create a plan' after discussions, (5) Need to structure how to build something with phases and concrete steps. Creates plans in plan/implementation/ that development teams can execute. Bridges architectural decisions to development execution."
---

# Technical Planning

Transform discussion documents into actionable implementation plans with phases and clear instructions.

## ⚠️ Critical: Your Role Ends at Planning

**You create the plan. You do NOT implement it.**

Output is a document in `plan/implementation/` that tells developers HOW to build. The actual coding, file changes, and implementation are handled by a separate implementation phase.

**Your responsibility**: Create detailed, actionable plans
**NOT your responsibility**: Write production code, modify files, or implement features

## Core Principle

**Planning ≠ Discussion ≠ Implementation**

- **Discussion** (previous phase): WHAT and WHY - decisions, architecture, edge cases
- **Planning** (your role): HOW - phases, structure, code examples in plan document
- **Implementation** (NOT your job): DOING - actual coding, file changes

Convert decisions → execution strategy. Then STOP.

## What to Deliver

- **Structured phases**: Foundation → Core → Edge cases → Polish
- **Code examples**: Pseudocode/actual code showing patterns (in plan doc)
- **Specific tasks**: Actionable items per phase
- **Testing strategy**: How to verify each phase
- **Traceability**: Link decisions to discussion rationale
- **Completeness**: Edge cases, rollback, monitoring, dependencies

**Goal**: Implementation team starts coding immediately without questions.

See **[planning-approach.md](planning-approach.md)** for detailed workflow and methodology.

## Structure

Use **[template.md](template.md)** for implementation plans in `plan/implementation/`:

- Overview linking to discussion
- Architecture from discussion decisions
- Phases with specific tasks
- Code examples for complex parts
- Testing strategy
- Edge case handling
- Rollback plan
- Dependencies

## Do / Don't

**Do**: Create plans, reference discussion rationale, make phases testable, include code examples (in plan), address edge cases, define verification

**Don't - CRITICAL**:
- ❌ **Write production code or modify project files**
- ❌ **Execute the plan (you ONLY create it)**
- ❌ Re-debate decisions (reference discussion)
- ❌ Skip edge cases or use vague tasks

See **[guidelines.md](guidelines.md)** for best practices, code example patterns, and anti-patterns.

## Commit Plans

**Commit often** to `plan/implementation/`:
- Initial plan complete
- After review/approval
- Significant updates
- Phase completions

**Why**: Keeps plan current, provides history, enables collaboration.

## Quick Reference

- **Approach**: **[planning-approach.md](planning-approach.md)** - Your role, workflow, step-by-step process
- **Template**: **[template.md](template.md)** - Plan structure and format
- **Guidelines**: **[guidelines.md](guidelines.md)** - Best practices, specificity levels, examples

## Remember

**You're the architect, not the builder.**

Discussion decided WHAT and WHY. You define HOW and structure. Implementation executes your plan.

**Your deliverable**: A document in `plan/implementation/` that guides developers
**Your job ends**: When the plan is complete and committed
**Not your job**: Writing production code or executing implementation

Be specific. Be concrete. Be thorough. Then hand it off to implementation.
