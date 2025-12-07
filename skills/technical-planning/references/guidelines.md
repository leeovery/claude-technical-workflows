# Planning Guidelines

*Reference for **[technical-planning](../SKILL.md)***

---

## Core Principles

- **One task = One TDD cycle**: write test → implement → pass → commit
- **Exact paths**: Specify exact file paths, not "update the controller"
- **Reference, don't re-debate**: "Using Redis (per discussion doc)" not re-debating the choice
- **Test name required**: Every task needs a test name that proves completion

## Phase Sizing

**Target**: 3-7 tasks per phase

**Good progression**:
1. Foundation - DB schema, base classes, infrastructure
2. Core - Main features, happy path
3. Edge cases - Error handling, special scenarios
4. Refinement - Performance, monitoring (if needed)

**Anti-pattern**: "Phase 1: Build everything, Phase 2: Test it"

## Task Sizing

**Target**: One TDD cycle, 5-30 minutes

**Required fields**:
- **Do**: What to implement
- **Test**: `"it does expected behavior"` - the test name
- **Edge cases**: Special handling (if any)

**Good**:
```markdown
1. **CacheManager.get()**
   - **Do**: Return cached value if exists and not expired
   - **Test**: `"it gets cached value when hit"`
   - **Edge cases**: Return null on miss
```

**Bad**:
```markdown
1. **Implement caching layer**
   - **Do**: Add caching to the application
```

## Specificity Levels

**Too vague**: "Add caching"
**Better**: "Implement Redis caching with 5-minute TTL"
**Best**: Task with test name:
```markdown
1. **CacheManager.get()**
   - **Do**: Return cached value if exists, fetch from DB if miss
   - **Test**: `"it gets cached value when hit"`
```

## Edge Case Mapping

Extract every edge case from discussion. Each one becomes a task with a test.

**Table format**:
```markdown
| Edge Case | Solution | Phase.Task | Test |
|-----------|----------|------------|------|
| New user, no data | Return empty array | 2.3 | `"it returns empty for new user"` |
| Redis timeout | Fall back to DB | 3.1 | `"it falls back on timeout"` |
```

## Code Examples

**Include when**: Pattern is non-obvious, complex algorithm, specific integration

**Show structure, not production code**:
```python
class CacheManager:
    def get(self, user_id: int, key: str) -> Optional[dict]:
        cache_key = f"metrics:{user_id}:{key}"
        try:
            cached = self.redis.get(cache_key)
            if cached:
                return json.loads(cached)
        except RedisError:
            logger.warning("Cache error, falling back")
        return self._fetch_from_db(user_id, key)
```

## Acceptance Criteria

**Phase level** - checkboxes that verify the phase works:
```markdown
**Acceptance**:
- [ ] CacheManager exists with get(), set(), invalidate()
- [ ] All unit tests passing
- [ ] Cache operations < 50ms
```

**Task level** - the test name:
```markdown
- **Test**: `"it stores value with configured ttl"`
```

## Plan Ready Indicators

**Ready**:
- Each phase has acceptance checkboxes
- Each task has a test name
- All edge cases mapped to tasks
- No "TBD" items

**Not ready**:
- Tasks like "implement the feature"
- Missing test names
- Edge cases without tasks
- Vague acceptance criteria

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Task too big for one TDD cycle | Break into smaller tasks |
| Missing test name | Add `**Test**: "it does X"` |
| Re-debating discussion decisions | Reference discussion, don't change |
| Skipped edge cases | Map every edge case to a task |
| Started writing code | Stop. Write plan only |
