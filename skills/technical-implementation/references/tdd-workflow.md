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
- Micro acceptance: "it gets cached value when hit"
```

Derived tests:
```
"it gets cached value when hit"
"it returns null when cache miss"
"it fetches from database on miss"
"it handles connection failure gracefully"
```

### Test Naming

Follow the naming conventions for the language or framework being used. Check project-specific skills or existing tests for the established pattern.

### Write Test Names First

Before writing test bodies, list all test names:
```php
test('it gets cached value when hit');
test('it fetches from db on miss');
test('it caches db result after fetch');
test('it handles redis connection error');
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
```php
// Bug: should expect 300, not 200
test('it uses config value for ttl', function () {
    expect($cache->ttl)->toBe(200); // Config says 300
});
```

Fix: Correct the assertion to match intended behavior.

### Poor Test Design

Test is brittle, unclear, or tests implementation instead of behavior:
```php
// Bad: Tests internal implementation detail
test('it uses redis setex', function () {
    $cache->set('key', 'value');
    $mockRedis->shouldHaveReceived('setex')->once();
});
```

Fix: Rewrite to test behavior, not implementation.

### Missing Setup

Test fails due to missing fixture or setup:
```php
// Missing: needs database seeding
test('it returns user metrics', function () {
    $result = $cache->getMetrics(userId: 1);
    expect($result['count'])->toBe(5); // No user exists
});
```

Fix: Add proper test setup.

## When Tests CANNOT Be Changed

### To Make Broken Code Pass

**Never do this:**
```php
// Code returns wrong value
public function get($key)
{
    return null; // Bug: should return cached value
}

// BAD: Changing test to match broken code
test('it returns cached value', function () {
    expect($cache->get('key'))->toBeNull(); // Was: ->toBe('value')
});
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

**Task**: Implement `CacheManager::get()` - gets cached value when hit

**RED**:
```php
test('it gets cached value when hit', function () {
    $redis = Mockery::mock(Redis::class);
    $redis->shouldReceive('get')
        ->with('metrics:1:views')
        ->andReturn('{"count": 42}');

    $cache = new CacheManager($redis);

    $result = $cache->get(userId: 1, key: 'views');

    expect($result)->toBe(['count' => 42]);
});
```

Run: `FAIL - Class CacheManager does not exist`

**GREEN**:
```php
class CacheManager
{
    public function __construct(
        private Redis $redis
    ) {}

    public function get(int $userId, string $key): ?array
    {
        $cacheKey = "metrics:{$userId}:{$key}";
        $cached = $this->redis->get($cacheKey);

        if ($cached) {
            return json_decode($cached, true);
        }

        return null;
    }
}
```

Run: `PASS`

**REFACTOR**: (none needed for now)

**COMMIT**:
```bash
git commit -m "feat(cache): implement CacheManager::get() for cache hits

Task: Phase 2, Task 1"
```

Next test: `it 'returns null on cache miss'`
