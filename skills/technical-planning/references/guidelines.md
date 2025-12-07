# Technical Planning Guidelines

*Part of **[technical-planning](../SKILL.md)** | See also: **[planning-approach.md](planning-approach.md)** · **[template.md](template.md)***

---

Best practices for creating actionable implementation plans. For PLANNING only - not implementation.

## Core Principles

**Phase > Task hierarchy**: Phases are milestones with acceptance criteria. Tasks are TDD-sized work units.

**One task = One TDD cycle**: Each task should be: write test → implement → pass → commit.

**Micro acceptance required**: Every task needs a test name that proves completion.

**Exact paths**: Specify exact file paths, not vague locations like "update the controller".

**Referenced over re-decided**: "Using Redis (per discussion doc)" not re-debating cache choice.

**DRY and YAGNI**: Don't repeat yourself. You aren't gonna need it.

## Phase Design

**Each phase should**:
- Be independently testable
- Have clear acceptance criteria (checkboxes)
- Contain 3-7 tasks
- Provide incremental value

**Good phase progression**:
1. Foundation (DB schema, base classes, infrastructure)
2. Core functionality (main features, happy path)
3. Edge cases and error handling
4. Refinement (performance, monitoring)

**Anti-pattern**: "Phase 1: Build entire feature, Phase 2: Test it"

## Task Design

**Each task should**:
- Be a single TDD cycle
- Have micro acceptance (specific test name)
- Take 5-30 minutes
- Do one clear thing

**Task structure**:
```markdown
1. **{Task Name}**
   - **Do**: What to implement
   - **Micro Acceptance**: `"it does expected behavior"`
   - **Edge Cases**: Special handling (optional)
   - **Notes**: Implementation guidance (optional)
```

**Good task**:
```markdown
1. **Implement CacheManager.get()**
   - **Do**: Return cached value if exists and not expired
   - **Micro Acceptance**: `"it gets cached value when hit"`
   - **Edge Cases**: Return null on miss, handle connection failures
```

**Bad tasks**:
- "Implement caching layer" (too big)
- "Handle errors" (too vague)
- "Update the code" (meaningless)

## Micro Acceptance Criteria

**Purpose**: Name the test that proves task completion.

**Format**: `"it does the expected behavior"`

**Examples**:
- `"it gets cached value when hit"`
- `"it stores value with configured ttl"`
- `"it removes key silently when not found"`

**Implementation will**:
1. Read your micro acceptance
2. Write that test (failing)
3. Implement to pass
4. Commit

**Your micro acceptance quality determines test quality.**

## How Implementation Uses Plans

Understanding this helps you write better plans:

1. **Phase start**: Implementation announces phase, reviews acceptance criteria
2. **Task loop**: For each task:
   - Derive test from micro acceptance
   - Write failing test
   - Implement minimal code to pass
   - Commit
3. **Phase end**: Verify all acceptance criteria met
4. **User checkpoint**: Implementation asks before next phase

**Implications for planning**:
- Acceptance criteria must be verifiable
- Tasks must be TDD-sized
- Micro acceptance must be specific enough to write a test

## Specificity Levels

**Too vague**: "Add caching"
**Better**: "Implement Redis caching with 5-minute TTL"
**Best**: Task with micro acceptance:
```markdown
1. **Implement CacheManager.get()**
   - **Do**: Return cached value if exists, fetch from DB if miss
   - **Micro Acceptance**: `"it gets cached value when hit"`
```

**Too vague**: "Handle errors"
**Better**: "Add error handling for cache failures"
**Best**:
```markdown
1. **Handle Redis connection failures**
   - **Do**: On connection failure, log warning, fall back to DB
   - **Micro Acceptance**: `"it falls back to db on redis error"`
```

## Edge Case Handling

**From discussion doc**: Extract each edge case identified.

**For each one**:
- Create a task with micro acceptance
- Assign to specific phase
- Reference back to discussion

**Edge case table**:
```markdown
| Edge Case | Solution | Phase | Task | Test |
|-----------|----------|-------|------|------|
| User has no metrics | Return empty array | 2 | 3 | `"it returns empty array for new user"` |
| Cache connection fails | Fall back to DB | 3 | 1 | `"it falls back to db on connection error"` |
```

## Code Examples

**When to include**:
- Novel patterns not obvious to implement
- Complex algorithms or logic
- Integration points with specific requirements

**In plan, not production**: Examples show structure, not deployable code.

```python
# GOOD: Shows structure, error handling, approach
class CacheManager:
    def get(self, user_id: int, key: str) -> Optional[dict]:
        cache_key = f"metrics:{user_id}:{key}"
        try:
            cached = self.redis.get(cache_key)
            if cached:
                return json.loads(cached)
        except RedisError as e:
            logger.error(f"Cache error: {e}")
        return self._fetch_from_db(user_id, key)
```

```python
# BAD: Too vague
# Add a cache manager class with methods for getting and setting values
```

## Testing Strategy

**Three levels**:
1. **Unit**: Individual components (covered by task micro acceptance)
2. **Integration**: Components working together
3. **System**: End-to-end user flows

**For each phase, specify**:
- What to test (already in tasks)
- Integration tests needed
- Manual verification steps

## Dependencies & Sequencing

**Make explicit**:
```markdown
**Before Phase 1**:
- Redis server accessible
- Database migrations ready

**Phase Dependencies**:
- Phase 2 requires Phase 1 (needs DB schema)
- Phase 3 requires Phase 2 (needs CacheManager)
```

## Rollback Strategy

**Every plan needs rollback**:
- What triggers rollback?
- Steps to roll back
- Data handling

## Common Pitfalls

**Starting implementation**: You create the plan, NOT the code.

**Tasks too big**: If task can't be done in one TDD cycle, break it down.

**Missing micro acceptance**: Every task needs a test name.

**Vague acceptance criteria**: "Works correctly" is not acceptance criteria.

**Re-debating decisions**: Reference discussion doc, don't second-guess.

**Skipping edge cases**: Every edge case from discussion needs a task.

## Quality Checklist

Before marking plan complete:

**Structure**:
- [ ] Clear phases with acceptance criteria
- [ ] Each phase has 3-7 TDD-sized tasks
- [ ] Each task has micro acceptance (test name)
- [ ] Logical progression: foundation → core → edge cases

**Content**:
- [ ] All edge cases from discussion mapped to tasks
- [ ] Code examples for complex patterns
- [ ] Data models defined
- [ ] API contracts specified

**Readiness**:
- [ ] Implementation can start Phase 1 immediately
- [ ] No "TBD" or "figure out later"
- [ ] Dependencies identified
- [ ] Rollback strategy defined

## When Plan is Ready

**Signs of readiness**:
- Each phase has verifiable acceptance criteria
- Each task has specific micro acceptance
- Edge cases have tasks
- Implementation can start without questions

**Not ready if**:
- Tasks like "implement the feature"
- Missing micro acceptance
- Edge cases marked "TBD"
- Vague acceptance criteria
