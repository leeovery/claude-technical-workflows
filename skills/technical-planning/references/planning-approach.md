# Planning Approach

*Reference for **[technical-planning](../SKILL.md)***

---

## Your Role

Bridge between discussion and implementation. Convert decisions into executable plans.

**You create**: Plans with phases, tasks, acceptance criteria
**You don't**: Implement, modify files, write production code, re-debate decisions

## Workflow

### 0. Draft Planning (Building the Specification)

Draft planning produces a **standalone specification** containing everything needed for formal planning. This is NOT conversation notes or a summary.

**The draft process**:
1. **Enrichment**: Add missing detail through collaborative discussion (not hallucination)
2. **Filtering**: Remove noise, speculation, and hallucinated content through collaborative review

**Before jumping to formal phases and tasks**:
1. Create `draft-plan.md` in the plans directory
2. Collaborate with user to build the Specification section
3. Continue until WHAT/WHY/edge cases/acceptance criteria are clear
4. Proceed to formal planning when the draft has the right level of detail for this feature

**Immediate capture rule**: After each user response, update the draft document BEFORE your next question. Distill validated information into the Specification section immediately.

See **[planning-conversations.md](planning-conversations.md)** for full draft planning workflow.

**Skip draft planning when**: Source materials already contain complete specification with all detail needed for implementation.

### 1. Read Discussion Document

From `docs/specs/discussions/{topic}/` extract:
- Key decisions and rationale
- Architectural choices
- Edge cases identified
- Constraints and requirements

### 2. Define Phases

Break into logical phases:
- Each independently testable
- Each has acceptance criteria
- Progression: Foundation → Core → Edge cases → Refinement

### 3. Break Phases into Tasks

Each task is one TDD cycle:
- One clear thing to build
- One test to prove it works
- 5-30 minutes of work

### 4. Write Micro Acceptance

For each task, name the test that proves completion.
Implementation will write this test first.

### 5. Address Every Edge Case

From discussion: extract each edge case, create a task with micro acceptance.

### 6. Add Code Examples (if needed)

Only for novel patterns not obvious to implement. Show structure, not production code.

### 7. Review Against Discussion

Verify:
- All decisions referenced
- All edge cases have tasks
- Each phase has acceptance criteria
- Each task has micro acceptance

## Output

Create `docs/specs/plans/{topic-name}/plan.md` using [template.md](template.md).

Implementation can execute via strict TDD without going back to discussion.

## Commit Frequently

Commit planning docs at:
- After each significant exchange during draft planning
- At natural breaks in discussion
- When phases/tasks become clearer
- **Before any context refresh**

Context refresh = memory loss. Uncommitted work = lost work.
