# Planning Guidelines

*Reference for **[technical-planning](../SKILL.md)***

---

## Core Principles

- **One task = One TDD cycle**: write test → implement → pass → commit
- **Exact paths**: Specify exact file paths, not "update the controller"
- **Reference, don't re-debate**: "Using Redis (per discussion doc)" not re-debating
- **Test name required**: Every task needs a micro acceptance that becomes a test

## Phase Design

**Each phase should**:
- Be independently testable
- Have clear acceptance criteria (checkboxes)
- Provide incremental value

**Good progression**: Foundation → Core functionality → Edge cases → Refinement

## Task Design

**Each task should**:
- Be a single TDD cycle
- Have micro acceptance (specific test name)
- Take 5-30 minutes
- Do one clear thing

**Bad tasks**: "Implement caching layer" (too big), "Handle errors" (too vague)

## Micro Acceptance

The test name that proves task completion. Implementation will:
1. Read your micro acceptance
2. Write that test (failing)
3. Implement to pass
4. Commit

**Your micro acceptance quality determines test quality.**

## Edge Case Handling

Extract each edge case from discussion. For each:
- Create a task with micro acceptance
- Assign to specific phase

## Quality Checklist

**Structure**:
- [ ] Clear phases with acceptance criteria
- [ ] Each phase has TDD-sized tasks
- [ ] Each task has micro acceptance (test name)

**Content**:
- [ ] All edge cases from discussion mapped to tasks
- [ ] No "TBD" or "figure out later"
- [ ] Implementation can start without questions
