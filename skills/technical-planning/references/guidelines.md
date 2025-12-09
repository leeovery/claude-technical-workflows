# Planning Guidelines

*Reference for **[technical-planning](../SKILL.md)***

---

## Core Principles

### Plan as Source of Truth

The plan (whether Linear issues, Backlog.md tasks, or local markdown) IS the source of truth. Every phase, every task must contain all information needed to execute it.

- **Self-contained**: Each task should be executable without external context
- **Reference, don't depend**: OK to link discussion docs, but if they vanish the task should still make sense
- **No assumptions**: Don't assume implementer knows context - spell it out

### No Hallucinations

If you don't know something, don't guess. If the discussion is missing information:

1. **Flag it explicitly** - use `needs-info` label or note in task description
2. **Don't block on it** - create the task anyway, mark what's missing
3. **Circle back later** - iterate over plans multiple times, adding detail progressively

Planning is iterative. You don't need complete information on pass one. Create structure, flag gaps, refine.

### Task Design

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

**Self-Contained**:
- [ ] Each task executable without reading discussion doc
- [ ] No assumed context - everything spelled out
- [ ] Links to discussion for "why", but task has the "what" and "how"

**Content**:
- [ ] All edge cases from discussion mapped to tasks
- [ ] No hallucinations - unknown info flagged with `needs-info`
- [ ] Gaps identified explicitly, not glossed over

**Iteration**:
- [ ] OK if first pass incomplete - flag and refine
- [ ] Can circle back multiple times before implementation
