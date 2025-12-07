# TDD Workflow

*Part of **[technical-implementation](../SKILL.md)** | See also: **[code-quality.md](code-quality.md)** · **[plan-execution.md](plan-execution.md)***

---

Strict test-driven development process for implementation.

## The Cycle

```
RED → GREEN → REFACTOR → COMMIT
```

1. **RED**: Write a failing test
2. **GREEN**: Write minimal code to pass
3. **REFACTOR**: Clean up (only when green)
4. **COMMIT**: Save progress

Repeat for each task.

## RED: Write Failing Test

### Before Writing Any Code

- Read the task's acceptance criteria
- Identify what behavior to test
- Write the test that asserts that behavior
- Run the test - it MUST fail
- Verify it fails for the RIGHT reason

### Deriving Tests from Plan Tasks

Plan task example:
```markdown
**Task: Implement CacheManager.get()**
- Returns cached value if exists and not expired
- Edge case: Handle cache connection failure gracefully
- Micro acceptance: test_get_returns_cached_value passes
```

Derived tests:
```
test_get_returns_cached_value_when_cache_hit()
test_get_returns_none_when_cache_miss()
test_get_fetches_from_database_on_miss()
test_get_handles_connection_failure_gracefully()
```

### Test Naming

Use descriptive names that explain the scenario:
- `test_{method}_{scenario}_{expected_result}`
- `test_get_returns_cached_value_when_key_exists`
- `test_set_stores_value_with_configured_ttl`
- `test_invalidate_removes_key_silently_when_not_found`

### Write Test Names First

Before writing test bodies, list all test names:
```python
def test_get_returns_cached_value_when_hit(): pass
def test_get_fetches_from_db_on_miss(): pass
def test_get_caches_db_result_after_fetch(): pass
def test_get_handles_redis_connection_error(): pass
```

Confirm coverage matches task acceptance criteria before implementing.

## GREEN: Minimal Implementation

### Only Enough to Pass

Write the simplest code that makes the test pass:

- No extra features
- No "while I'm here" improvements
- No edge cases not yet tested
- No optimization

If you think "I should also handle X" - stop. Write a test for X first.

### One Test at a Time

- Write one test
- Make it pass
- Commit
- Next test

Don't write multiple failing tests then implement all at once.

## REFACTOR: Clean When Green

### Only When Tests Pass

Refactoring happens AFTER green, never during red.

### What to Refactor

- Remove duplication (DRY)
- Improve naming
- Extract methods for clarity
- Simplify complex logic

### What NOT to Refactor

- Code outside current task scope
- "Improvements" unrelated to current work
- Optimization (unless tests require performance)

### Tests Still Pass?

Run tests after refactoring. If they fail, you broke something. Undo and try again.

## COMMIT: Save Progress

### After Every Green

```bash
git add .
git commit -m "feat(cache): implement get() with cache hit handling"
```

### Commit Message Format

```
type(scope): brief description

- Detail 1
- Detail 2

Task: Phase X, Task Y
```

Types: `feat`, `fix`, `refactor`, `test`

### Why Frequent Commits?

- Easy to bisect if something breaks
- Clear history of implementation steps
- Safe rollback points
- Can squash before PR if desired

## When Tests CAN Be Changed

### Genuine Bugs in Test

Test has wrong assertion:
```python
# Bug: should expect 300, not 200
def test_ttl_uses_config_value():
    assert cache.ttl == 200  # Config says 300
```

Fix: Correct the assertion to match intended behavior.

### Poor Test Design

Test is brittle, unclear, or tests implementation instead of behavior:
```python
# Bad: Tests internal implementation detail
def test_uses_redis_setex():
    cache.set("key", "value")
    mock_redis.setex.assert_called_once()
```

Fix: Rewrite to test behavior, not implementation.

### Missing Setup

Test fails due to missing fixture or setup:
```python
# Missing: needs database seeding
def test_get_returns_user_metrics():
    result = cache.get_metrics(user_id=1)
    assert result["count"] == 5  # No user exists
```

Fix: Add proper test setup.

## When Tests CANNOT Be Changed

### To Make Broken Code Pass

**Never do this:**
```python
# Code returns wrong value
def get(self, key):
    return None  # Bug: should return cached value

# BAD: Changing test to match broken code
def test_get_returns_cached_value():
    assert cache.get("key") is None  # Was: == "value"
```

The test was right. The code is wrong. Fix the code.

### To Avoid Difficult Implementation

If the test requires complex implementation, that's the job. Don't simplify the test to avoid the work.

### To "Temporarily" Skip

Don't comment out or skip tests to proceed. Fix the issue or escalate.

## Red Flags

### Writing Code Before Tests

Stop. Delete the code. Write the test first.

### Multiple Failing Tests

Work on one test at a time. Comment out others if needed (uncomment before committing).

### Test Passes Immediately

Either:
- Test is wrong (doesn't test what you think)
- Code already exists (check for duplication)
- Test is trivial (might still be valid)

Investigate before proceeding.

### Changing Tests Frequently

If you keep modifying tests, the design may be unclear. Stop and review the plan or discussion.

## Example TDD Cycle

**Task**: Implement `CacheManager.get()` - returns cached value on hit

**RED**:
```python
def test_get_returns_cached_value_when_hit():
    cache = CacheManager(redis_client)
    redis_client.set("metrics:1:views", '{"count": 42}')

    result = cache.get(user_id=1, key="views")

    assert result == {"count": 42}
```

Run: `FAIL - CacheManager has no get method`

**GREEN**:
```python
class CacheManager:
    def __init__(self, redis):
        self.redis = redis

    def get(self, user_id: int, key: str) -> dict | None:
        cache_key = f"metrics:{user_id}:{key}"
        cached = self.redis.get(cache_key)
        if cached:
            return json.loads(cached)
        return None
```

Run: `PASS`

**REFACTOR**: (none needed for now)

**COMMIT**:
```bash
git commit -m "feat(cache): implement CacheManager.get() for cache hits

Task: Phase 2, Task 1"
```

Next test: `test_get_returns_none_on_cache_miss`
