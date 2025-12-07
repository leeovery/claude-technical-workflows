# TDD Workflow

*Reference for **[technical-implementation](../SKILL.md)***

---

## The Cycle

```
RED → GREEN → REFACTOR → COMMIT
```

Repeat for each task.

## RED: Write Failing Test

1. Read task's Test field
2. Write test asserting that behavior
3. Run test - must fail
4. Verify it fails for the right reason

**Derive tests from plan**:
```markdown
Task: CacheManager.get()
- Do: Return cached value if exists
- Test: "it gets cached value when hit"
- Edge cases: Handle connection failure
```

Derived tests:
```
"it gets cached value when hit"
"it returns null on miss"
"it handles connection failure"
```

**Write test names first**: Before writing test bodies, list all test names for the task. Confirm coverage matches task acceptance criteria before implementing.

## GREEN: Minimal Implementation

Write the simplest code that passes:
- No extra features
- No "while I'm here" improvements
- No edge cases not yet tested

If you think "I should also handle X" - stop. Write a test for X first.

**One test at a time**: Write → Pass → Commit → Next

## REFACTOR: Only When Green

**Do**:
- Remove duplication
- Improve naming
- Extract methods for clarity

**Don't**:
- Touch code outside current task
- Optimize prematurely
- Add unrelated improvements

Run tests after. If they fail, undo.

## COMMIT: After Every Green

```bash
git commit -m "feat(cache): implement get() with cache hit handling

Task: Phase 2, Task 1"
```

## When Tests CAN Change

**Genuine bug in test**:
```php
// Wrong: config says 300, not 200
expect($cache->ttl)->toBe(200);
```
Fix: Correct assertion to match intended behavior.

**Tests implementation, not behavior**:
```php
// Bad: tests internal detail
$mockRedis->shouldHaveReceived('setex')->once();
```
Fix: Rewrite to test behavior.

**Missing setup**:
```php
// Fails because no user exists
$cache->getMetrics(userId: 1);
```
Fix: Add proper test setup.

## When Tests CANNOT Change

**To make broken code pass**: The test was right. Fix the code.

**To avoid difficult work**: If test requires complex implementation, that's the job.

**To skip temporarily**: Don't comment out tests. Fix or escalate.

## Red Flags

| Flag | Action |
|------|--------|
| Wrote code before test | Delete code. Write test first. |
| Multiple failing tests | Work on one at a time |
| Test passes immediately | Investigate - test may be wrong |
| Changing tests frequently | Design unclear - review plan |

## Example Cycle

**Task**: CacheManager.get() - Test: "it gets cached value when hit"

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
Run: FAIL - Class CacheManager does not exist

**GREEN**:
```php
class CacheManager
{
    public function __construct(private Redis $redis) {}

    public function get(int $userId, string $key): ?array
    {
        $cacheKey = "metrics:{$userId}:{$key}";
        $cached = $this->redis->get($cacheKey);
        return $cached ? json_decode($cached, true) : null;
    }
}
```
Run: PASS

**COMMIT**: `feat(cache): implement CacheManager::get()`

Next test: "it returns null on cache miss"
