# Technical Planning Guidelines

*Part of **[technical-planning](../SKILL.md)** | See also: **[planning-approach.md](planning-approach.md)** · **[template.md](template.md)***

---

Best practices for creating actionable implementation plans. For PLANNING only - not implementation.

## Core Principles

**Actionable over theoretical**: "Phase 1: Set up Redis cache with user-key partitioning" not "Consider implementing caching strategies"

**Specific over vague**: "Create CacheManager class with get/set/invalidate methods" not "Add caching layer"

**Testable over aspirational**: Each phase ends with clear verification steps that prove it works

**Referenced over re-decided**: "Using Redis (per discussion doc: users accept 5min staleness)" not re-debating cache choice

## Planning Mindset

**You're translating decisions → execution strategy**

- Discussion decided WHAT and WHY
- Planning defines HOW and WHEN (phases)
- Implementation executes the plan

**CRITICAL**: You create the execution strategy document. You do NOT execute it. Your output is a plan in `plan/implementation/`, not code changes.

**Bridge the gap**: Discussion says "use caching." Plan says "Phase 1: Install Redis, Phase 2: Implement CacheManager with these methods, Phase 3: Update controllers to use cache" - then you STOP. Implementation phase does the actual work.

## Phase Design

**Each phase should**:
- Be independently testable
- Provide incremental value
- Have clear completion criteria
- Be deployable (if applicable)

**Good phase progression**:
1. Foundation (DB schema, base classes, infrastructure)
2. Core functionality (main features without edge cases)
3. Edge cases and error handling
4. Performance optimization and monitoring
5. Documentation and deployment

**Anti-pattern**: "Phase 1: Build entire feature, Phase 2: Test it"

## Code Examples & Pseudocode

**When to include code**:
- Novel patterns not obvious to implement
- Complex algorithms or logic
- Integration points with specific requirements
- Data structures or class hierarchies

**When to use pseudocode vs actual code**:

**Pseudocode**: When approach matters more than language specifics
```pseudocode
function getCachedMetric(userId, metricKey):
    cacheKey = buildKey(userId, metricKey)

    if cache.exists(cacheKey) and !cache.isExpired(cacheKey):
        return cache.get(cacheKey)

    data = database.query(userId, metricKey)
    cache.set(cacheKey, data, TTL=300)
    return data
```

**Actual code**: When specific implementation is clear from discussion
```python
class MetricsCacheManager:
    def __init__(self, redis_client: Redis, db: Database):
        self.redis = redis_client
        self.db = db
        self.ttl = 300  # 5 minutes per discussion

    def get_metric(self, user_id: int, metric_key: str) -> dict:
        cache_key = f"metrics:{user_id}:{metric_key}"

        cached = self.redis.get(cache_key)
        if cached:
            return json.loads(cached)

        data = self.db.query_metric(user_id, metric_key)
        self.redis.setex(cache_key, self.ttl, json.dumps(data))
        return data
```

**Code example checklist**:
- [ ] Shows structure clearly
- [ ] Includes error handling approach
- [ ] Addresses edge cases from discussion
- [ ] Includes comments for non-obvious parts
- [ ] Realistic and implementable

## Specificity Levels

**Too vague**: "Add caching"
**Better**: "Implement Redis caching with 5-minute TTL"
**Best**: "Phase 2: Implement CacheManager with get(user_id, key), set(user_id, key, value), invalidate(user_id, key) methods. Use Redis with 5min TTL per discussion."

**Too vague**: "Handle errors"
**Better**: "Add error handling for cache failures"
**Best**: "On Redis connection failure, log error and fall back to direct DB query. Alert if cache unavailable >5min."

**Too vague**: "Update the API"
**Better**: "Add cache status to API response"
**Best**: "Add 'cache_status' field to /api/v1/metrics response: {cached: boolean, expires_at: timestamp}. See API contract section."

## Edge Case Handling

**Extract from discussion document**:
- Read discussion doc edge cases section
- For each edge case, specify HOW to handle it
- Assign to specific phase
- Add verification test

**Example transformation**:

*Discussion doc*: "Edge case: What if user has no metrics yet?"

*Implementation plan*:
```markdown
### Edge Case: New User with No Metrics

**From Discussion**: Identified in discussion doc section 3.2
**Solution**: Return empty array with proper structure
**Phase**: Phase 2 (core functionality)
**Implementation**:
- Check if database query returns empty
- Return: {data: [], cached: false, message: "No metrics found"}
**Test**:
- [ ] Create new user
- [ ] Call GET /api/v1/metrics/{key}
- [ ] Verify empty array response with 200 status
```

## Testing Strategy

**Three levels**:

1. **Unit**: Individual components in isolation
2. **Integration**: Components working together
3. **System**: End-to-end user flows

**For each phase, specify**:
- What to test
- How to verify
- Success criteria

**Example**:
```markdown
### Phase 2 Testing

**Unit Tests**:
- CacheManager.get() returns cached data
- CacheManager.get() fetches from DB on cache miss
- CacheManager.set() stores with correct TTL

**Integration Tests**:
- API endpoint uses CacheManager correctly
- Cache miss triggers DB query
- Subsequent request hits cache

**Manual Verification**:
- [ ] First request: cached=false in response
- [ ] Second request: cached=true in response
- [ ] After 5min: cached=false (cache expired)
```

## Architecture Decisions

**Reference discussion doc**: Don't re-debate decisions made in discussion phase

**Good**: "Using PostgreSQL with JSONB for metrics storage (per discussion: need JSON queries + ACID)"

**Bad**: "We should probably use PostgreSQL because it has good JSON support and ACID compliance..."

**If new decision needed**: Stop, create new discussion doc, then return to planning

## Dependencies & Sequencing

**Identify dependencies early**:
- What must exist before Phase 1?
- What must complete in Phase N before Phase N+1?
- External service dependencies?
- Infrastructure requirements?

**Make dependencies explicit**:
```markdown
## Dependencies

**Before Phase 1**:
- Redis server deployed and accessible
- Database migration environment set up
- API versioning strategy decided

**Phase Dependencies**:
- Phase 2 requires Phase 1 complete (needs DB schema)
- Phase 3 requires Phase 2 complete (needs CacheManager)

**External**:
- Redis cluster (Infrastructure team, ETA: 2024-01-15)
- API Gateway rate limit increase (Platform team, ticket: PLAT-123)
```

## Rollback Strategy

**Every plan needs rollback**:
- What triggers rollback?
- How to roll back safely?
- What about data created during deployment?

**Example**:
```markdown
## Rollback Strategy

**Triggers**:
- Error rate > 5% for 10 minutes
- P95 latency > 2s (regression from current)
- Cache poisoning detected

**Steps**:
1. Revert application deployment
2. Clear Redis cache entirely (to remove any poisoned entries)
3. Database migration rollback (if Phase 1 deployed)
4. Restore previous API version

**Data Handling**:
- New metrics stored during deployment retained (backward compatible)
- Cache invalidation affects all users (acceptable per discussion)
```

## Common Pitfalls

**❌ CRITICAL: Starting implementation**: Planning defines HOW to build, not the actual building. DO NOT write production code or modify project files. You create the plan document ONLY.

**Re-debating decisions**: Reference discussion doc, don't second-guess architectural choices

**Skipping edge cases**: Every edge case from discussion must have handling in plan

**Vague phases**: "Make it work" is not a phase. "Implement CacheManager with get/set/invalidate methods" is.

**Missing verification**: Each phase needs "how do we know it works?" answered

**Ignoring rollback**: Every deployment can fail. Plan for it.

**No code examples**: Novel patterns need concrete examples in the plan (as documentation examples, not production code)

**Confusing your role**: You're the architect drawing blueprints, not the construction crew building the house

## Quality Checklist

Before marking plan complete:

**Structure**:
- [ ] Clear phases with logical progression
- [ ] Each phase independently testable
- [ ] Tasks within phases specific and actionable
- [ ] Success criteria defined

**Content**:
- [ ] Code examples for complex/novel patterns
- [ ] All edge cases from discussion addressed
- [ ] Data models and schemas defined
- [ ] API contracts specified
- [ ] Testing strategy comprehensive

**Traceability**:
- [ ] References discussion document
- [ ] Architectural decisions traced to discussion rationale
- [ ] Edge cases mapped to solutions
- [ ] Assumptions called out

**Completeness**:
- [ ] Dependencies identified
- [ ] Rollback strategy defined
- [ ] Monitoring specified
- [ ] Security considered
- [ ] Documentation requirements listed

**Readiness**:
- [ ] Implementation team can start without questions
- [ ] Verification steps clear
- [ ] No ambiguous tasks
- [ ] Ready for code review

## When Plan is Ready

**Signs of readiness**:
- Developer can start Phase 1 immediately
- All "how do I..." questions answered
- Edge cases have clear handling
- Testing approach defined
- Team reviewed and approved

**Not ready if**:
- "We'll figure it out during implementation"
- Missing code examples for complex parts
- Edge cases marked "TBD"
- Vague tasks like "handle errors"
- Dependencies unclear

## Iteration

**Plans evolve during implementation**:
- New edge cases discovered → Update plan
- Dependency delay → Reorder phases
- Simpler approach found → Document in Evolution Log

**Keep plan current**: Update as implementation progresses, don't let it become stale

**Document changes**: Evolution Log shows what changed and why
