---
name: technical-planning
description: "Transform technical discussion documents into actionable implementation plans with phases, code examples, and clear instructions. Second phase of document-plan-implement workflow. Use when: (1) User asks to create/write an implementation plan, (2) User asks to plan implementation of discussed features, (3) Converting discussion documents from plan/discussion/ into implementation plans, (4) User says 'plan this' or 'create a plan' after discussions, (5) Need to structure how to build something with phases and concrete steps. Creates plans in plan/implementation/ that development teams can execute. Bridges architectural decisions to development execution."
---

# Technical Planning

Transform discussion documents into actionable implementation plans. Bridge between architectural decisions and code execution.

## ⚠️ Critical: Your Role Ends at Planning

**You create the plan. You do NOT implement it.**

Your output is a document in `plan/implementation/` that tells developers HOW to build. You stop there. The actual coding, file changes, and implementation are handled by a separate implementation phase.

**Your responsibility**: Create detailed, actionable plans
**NOT your responsibility**: Write production code, modify files, or implement features

## Core Principle

**Planning ≠ Discussion ≠ Implementation**

- **Discussion** (previous phase): WHAT and WHY - decisions, architecture, edge cases
- **Planning** (YOUR ROLE): HOW - phases, structure, code examples, testable steps
- **Implementation** (NOT YOUR JOB): DOING - actual coding, file changes, execution

Convert decisions → execution strategy. Then STOP.

## What Planning Provides

- **Structured phases**: Foundation → Core → Edge cases → Polish
- **Code examples**: Pseudocode and actual code for complex patterns
- **Clear tasks**: Specific, actionable items per phase
- **Testing strategy**: How to verify each phase works
- **Traceability**: Every decision linked to discussion rationale
- **Completeness**: Edge cases, rollback, monitoring, security

**Goal**: Implementation team starts coding immediately without questions.

## Workflow

1. **Read discussion document**: `plan/discussion/{topic}.md`
2. **Extract decisions**: Architectural choices, edge cases, constraints
3. **Structure phases**: Logical, testable, incremental
4. **Add code examples**: Show complex patterns concretely
5. **Address edge cases**: Every one from discussion
6. **Define testing**: Unit, integration, system tests
7. **Add support sections**: Dependencies, rollback, monitoring
8. **Create plan**: `plan/implementation/{feature}.md`

See **[planning-approach.md](planning-approach.md)** for detailed workflow.

## Structure Your Plan

Use **[template.md](template.md)** for implementation plans:

- **Overview**: Goal, success criteria, source discussion
- **Architecture**: High-level design, key decisions
- **Phases**: Logical progression with specific tasks
- **Code Examples**: Pseudocode or actual code for complex parts
- **Testing Strategy**: How to verify each phase
- **Edge Cases**: Solutions from discussion
- **Rollback**: Deployment failure handling
- **Dependencies**: What's needed before starting

## Phase Design Principles

**Each phase should**:
- Be independently testable
- Provide incremental value
- Have clear completion criteria
- Build on previous phases

**Good progression**:
1. Foundation: Infrastructure, DB schema, base classes
2. Core: Main functionality, happy path
3. Edge cases: Handle scenarios from discussion
4. Refinement: Performance, monitoring, error handling
5. Documentation: Code docs, runbooks, user guides

**Anti-pattern**: "Phase 1: Build it all, Phase 2: Test"

## Code Examples

**When to include**:
- Novel patterns not obvious to implement
- Complex integrations or algorithms
- Specific data structures
- Non-trivial error handling

**Pseudocode vs actual code**:

**Pseudocode** - Structure matters more than syntax:
```pseudocode
function getCachedData(userId, key):
    if cache.has(key) and !cache.expired(key):
        return cache.get(key)

    data = database.query(userId, key)
    cache.set(key, data, TTL)
    return data
```

**Actual code** - Specific implementation clear:
```python
class CacheManager:
    def get(self, user_id: int, key: str) -> Optional[dict]:
        cache_key = f"metrics:{user_id}:{key}"

        try:
            cached = self.redis.get(cache_key)
            if cached:
                return json.loads(cached)
        except RedisError as e:
            logger.error(f"Cache error: {e}")
            # Fall back to DB

        return self._fetch_from_db(user_id, key)
```

## Do / Don't

**Do**:
- Create comprehensive plans in `plan/implementation/`
- Reference discussion decisions with rationale
- Make phases testable and specific
- Include code examples for complex parts (as examples in the plan)
- Address every edge case from discussion
- Define clear verification steps
- Plan for rollback

**Don't - CRITICAL BOUNDARIES**:
- ❌ **Write production code or modify actual project files**
- ❌ **Start implementing features (that's the NEXT phase)**
- ❌ **Execute the plan you create (you ONLY create the plan)**
- ❌ Re-debate architectural decisions
- ❌ Skip edge cases
- ❌ Use vague tasks like "handle errors"
- ❌ Forget rollback strategy
- ❌ Leave dependencies unclear

See **[guidelines.md](guidelines.md)** for best practices.

## Edge Case Handling

**Extract from discussion**: Every edge case identified

**For each one**:
- Specify handling approach
- Assign to phase
- Add verification test
- Reference discussion source

**Example**:
```markdown
### Edge Case: New User with No Metrics

**From Discussion**: Section 3.2
**Solution**: Return empty array with proper structure
**Phase**: Phase 2
**Code**: Return {data: [], cached: false, message: "No metrics"}
**Test**: Verify new user gets empty array, not error
```

## Commit Plans

**Commit often** to `plan/implementation/`:
- Initial plan complete
- After review/approval
- Significant updates during implementation
- Phase completions

**Why**: Keeps plan current, provides history, enables collaboration.

## Quality Checklist

Before marking plan complete:

- [ ] Clear phases with logical progression
- [ ] Specific, actionable tasks (not "TBD")
- [ ] Code examples for complex patterns
- [ ] All edge cases from discussion addressed
- [ ] Testing strategy defined
- [ ] Rollback plan included
- [ ] Dependencies identified
- [ ] References discussion document
- [ ] Implementation team can start immediately

## Signs of Readiness

**Ready when**:
- Developer can start Phase 1 without questions
- All "how do I..." answered
- Edge cases have specific solutions
- Testing approach clear
- Code examples for novel patterns

**Not ready if**:
- "Figure it out during implementation"
- Missing code examples
- Edge cases without solutions
- Vague tasks
- Unclear dependencies

## Quick Reference

- **Approach**: **[planning-approach.md](planning-approach.md)** - Your role, workflow, mindset
- **Template**: **[template.md](template.md)** - Plan structure
- **Guidelines**: **[guidelines.md](guidelines.md)** - Best practices, code examples, anti-patterns

## Remember

**You're the architect, not the builder.**

- Discussion phase decided WHAT and WHY
- You define HOW and structure
- Implementation phase executes your plan

**Your deliverable**: A document in `plan/implementation/` that guides developers

**Your job ends**: When the plan is complete and committed

**Not your job**: Writing production code, modifying project files, or executing the implementation

Be specific. Be concrete. Be thorough. Show the path from current state to goal, one testable phase at a time. Then hand it off to implementation.
