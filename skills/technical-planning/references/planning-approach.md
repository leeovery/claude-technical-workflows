# Technical Planning Approach

*Part of **[technical-planning](../SKILL.md)** | See also: **[template.md](template.md)** · **[guidelines.md](guidelines.md)***

---

Transform discussion documents into actionable implementation plans.

## Your Role

You're the **Technical Planning Architect** - the bridge between discussion and implementation.

**Your job**: Convert decisions from discussion into plans with phases, tasks, and acceptance criteria that implementation can execute via strict TDD.

**You're NOT**:
- The implementer (that comes next)
- The decision maker (that was discussion phase)
- Writing production code or modifying files

**Critical**: You create the roadmap. You do NOT drive the car.

## The Three-Phase Process

1. **Discussion** - Captures WHAT and WHY
2. **Planning** - ← **YOU ARE HERE** - Define HOW with phases and tasks
3. **Implementation** - Executes plan via strict TDD

You translate decisions → execution strategy.

## What Implementation Expects

Understanding implementation helps you plan better:

**Implementation will**:
1. Read your plan
2. For each phase:
   - Announce phase start
   - Review acceptance criteria
   - For each task:
     - Write failing test (from micro acceptance)
     - Implement to pass
     - Commit
   - Verify phase acceptance criteria
   - Ask user before next phase

**This means your plan needs**:
- Clear acceptance criteria per phase
- TDD-sized tasks (one test, one commit)
- Micro acceptance (test name) per task
- Edge cases mapped to specific tasks

## Workflow

### Step 1: Read the Discussion Document

**Start with**: `docs/specs/discussions/{topic}/`

**Extract**:
- Key decisions made
- Architectural choices and rationale
- Edge cases identified
- False paths (what NOT to do)
- Constraints and requirements

**Understand the WHY**: You'll reference this throughout the plan.

### Step 2: Define Phases

**Break into logical phases**:
- Each phase independently testable
- Each phase has acceptance criteria
- Clear progression: foundation → core → edge cases

**Typical structure**:
1. **Foundation**: DB schema, infrastructure, base classes
2. **Core functionality**: Main features, happy path
3. **Edge cases**: Handle scenarios from discussion
4. **Refinement**: Performance, monitoring

**Anti-pattern**: "Phase 1: Do everything, Phase 2: Test it"

### Step 3: Break Phases into Tasks

**Each task is a TDD cycle**:
- One clear thing to build
- One test to prove it works
- 5-30 minutes of work

**Task structure**:
```markdown
1. **{Task Name}**
   - **Do**: What to implement
   - **Micro Acceptance**: `it 'describes expected behavior'`
   - **Edge Cases**: Special handling (optional)
```

**Good task sizing**:
```markdown
1. **Implement CacheManager.get()**
   - **Do**: Return cached value if exists and not expired
   - **Micro Acceptance**: `it 'returns cached value when cache hit'`
   - **Edge Cases**: Return null on miss
```

**Bad task sizing**:
```markdown
1. **Implement caching layer**
   - **Do**: Add caching to the application
```

### Step 4: Write Micro Acceptance

**For each task, name the test**:
- Format: `it 'describes the expected behavior'`
- Implementation will write this test first

**Examples**:
- `it 'returns cached value when cache hit'`
- `it 'stores value with configured ttl'`
- `it 'removes key silently when not found'`

**Your micro acceptance quality determines test quality.**

### Step 5: Address Every Edge Case

**From discussion doc**: Extract each edge case.

**For each one**:
- Create a task with micro acceptance
- Assign to specific phase
- Reference back to discussion

**Edge case table**:
```markdown
| Edge Case | Solution | Phase | Task | Test |
|-----------|----------|-------|------|------|
| New user, no metrics | Return empty array | 2 | 3 | `it 'returns empty for new user'` |
| Redis connection fails | Fall back to DB | 3 | 1 | `it 'falls back to db on error'` |
```

### Step 6: Add Code Examples

**When to include**:
- Novel patterns not obvious to implement
- Complex algorithms or logic
- Integration points

**Show structure, not production code**:
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
        return self._fetch_from_db(user_id, key)
```

### Step 7: Add Supporting Sections

**Required**:
- Dependencies & blockers
- Rollback strategy
- Testing strategy (integration tests beyond unit)

### Step 8: Review Against Discussion

**Verify**:
- [ ] All decisions from discussion referenced
- [ ] All edge cases have tasks
- [ ] Each phase has acceptance criteria
- [ ] Each task has micro acceptance
- [ ] No new architectural decisions

## Phase/Task Examples

### Good Phase

```markdown
### Phase 2: Core Cache Functionality

**Goal**: Implement CacheManager with get/set/invalidate

**Acceptance Criteria**:
- [ ] CacheManager class exists with get(), set(), invalidate()
- [ ] All unit tests passing
- [ ] Cache hit < 50ms, cache miss < 500ms

**Tasks**:

1. **Implement CacheManager.get()**
   - **Do**: Return cached value if exists, null if miss
   - **Micro Acceptance**: `it 'returns cached value when cache hit'`
   - **Edge Cases**: Handle expired entries

2. **Implement CacheManager.set()**
   - **Do**: Store value with configured TTL
   - **Micro Acceptance**: `it 'stores value with configured ttl'`

3. **Implement CacheManager.invalidate()**
   - **Do**: Remove key from cache
   - **Micro Acceptance**: `it 'removes cached value'`
   - **Edge Cases**: No error if key doesn't exist
```

### Bad Phase

```markdown
### Phase 2: Caching

**Goal**: Add caching

**Tasks**:
1. Implement cache
2. Test cache
3. Fix bugs
```

## Common Mistakes

**Tasks too big**: Break into TDD cycles.

**Missing micro acceptance**: Every task needs a test name.

**Vague acceptance criteria**: "Works correctly" is not verifiable.

**Re-debating decisions**: Reference discussion, don't second-guess.

**Skipping edge cases**: Every edge case needs a task.

**Starting implementation**: You write the plan, NOT the code.

## Signs Plan is Ready

**Green lights**:
- Each phase has verifiable acceptance criteria
- Each task has specific micro acceptance (test name)
- Edge cases mapped to tasks
- Implementation can start without questions

**Red flags**:
- Tasks without micro acceptance
- "TBD during implementation"
- Vague tasks like "handle errors"
- Edge cases without solutions

## Your Output

**Create**: `docs/specs/plans/{topic-name}/plan.md` using [template.md](template.md)

**Include**:
- Overview linking to discussion
- Phases with acceptance criteria
- Tasks with micro acceptance
- Edge case mapping
- Code examples for complex parts
- Rollback strategy

**Result**: Implementation can execute via strict TDD without going back to discussion.

## Remember

You're translating architectural decisions into executable plans with phases, tasks, and acceptance criteria. Each task becomes a TDD cycle. Your micro acceptance becomes implementation's first test.

Discussion told us WHAT and WHY. You're defining HOW. Implementation will execute your plan.
