# Implementation Plan Template

*Part of **[technical-planning](SKILL.md)** | See also: **[planning-approach.md](planning-approach.md)** · **[guidelines.md](guidelines.md)***

---

Standard structure for `plan/implementation/` documents. PLAN only - no actual code changes.

## Template

```markdown
# Implementation Plan: {Feature/Project Name}

**Date**: YYYY-MM-DD
**Status**: Draft | Ready | In Progress | Completed
**Discussion Source**: Link to `plan/discussion/{filename}.md`
**Estimated Complexity**: Low | Medium | High | Very High

## Overview

**Goal**: One sentence describing what we're building and why

**Success Criteria**: What "done" looks like
- Measurable outcome 1
- Measurable outcome 2

**Source Context**: Brief summary from discussion doc - key decisions, constraints, rationale

## Architecture Overview

High-level architecture diagram or description:
- Major components
- Data flow
- Integration points
- Technology choices (from discussion)

**Key Architectural Decisions**:
1. Decision: Rationale from discussion
2. Decision: Rationale from discussion

## Implementation Phases

Break work into logical, testable phases. Each phase should:
- Be independently deployable/testable
- Provide incremental value
- Have clear completion criteria

### Phase 1: {Foundation/Core Setup}

**Goal**: What this phase accomplishes

**Duration Estimate**: Small | Medium | Large | Very Large

**Prerequisites**:
- What must exist before starting

**Tasks**:
1. **{Task Name}**
   - Description: What needs to be done
   - Details: Specific requirements
   - Acceptance: How to verify completion

2. **{Task Name}**
   - Description
   - Details
   - Acceptance

**Deliverables**:
- Specific outputs
- Test results
- Documentation

**Verification**:
- [ ] Test case 1
- [ ] Test case 2
- [ ] Integration check

---

### Phase 2: {Next Logical Step}

(Repeat structure from Phase 1)

---

### Phase 3: {Subsequent Phase}

(Repeat structure)

## Code Examples & Patterns

Provide concrete code examples or pseudocode for complex/novel implementations:

### Example: {Component/Pattern Name}

**Purpose**: What this solves

**Approach**: High-level strategy

```pseudocode
// Pseudocode showing structure
class CacheManager {
    function get(key, userId) {
        cacheKey = buildKey(key, userId)

        if (cache.has(cacheKey) && !isExpired(cacheKey)) {
            return cache.get(cacheKey)
        }

        data = fetchFromDatabase(key, userId)
        cache.set(cacheKey, data, TTL)
        return data
    }
}
```

**Or actual code** (when specific implementation is clear):

```python
class CacheManager:
    def __init__(self, redis_client, ttl=300):
        self.redis = redis_client
        self.ttl = ttl

    def get(self, key: str, user_id: int) -> dict:
        cache_key = f"metrics:{user_id}:{key}"

        cached = self.redis.get(cache_key)
        if cached:
            return json.loads(cached)

        data = self._fetch_from_db(key, user_id)
        self.redis.setex(cache_key, self.ttl, json.dumps(data))
        return data
```

**Key Considerations**:
- Edge case handling
- Error scenarios
- Performance implications

(Repeat for other complex patterns)

## Data Models & Schemas

### Database Changes

**New Tables**:
```sql
CREATE TABLE user_metrics (
    id BIGINT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    metric_key VARCHAR(255),
    value JSON,
    created_at TIMESTAMP,
    INDEX idx_user_metrics (user_id, metric_key)
);
```

**Modified Tables**:
- Table: users
  - Add column: `last_metrics_sync TIMESTAMP`

**Migrations**:
- Migration order and dependencies
- Data backfill requirements
- Rollback strategy

### API Contracts

**New Endpoints**:

```
GET /api/v1/metrics/{metric_key}
Request: { user_id, date_range: { start, end }, filters }
Response: { data: [...], cached: boolean, expires_at: timestamp }
```

**Modified Endpoints**:
- Endpoint: /api/v1/dashboard
  - Added field: cache_status

## Integration Points

### External Dependencies

1. **Service/Library**: Redis
   - Purpose: Caching layer
   - Configuration: Connection string, TTL settings
   - Error Handling: Fallback to direct DB queries

2. **Service/Library**: {Name}
   - Purpose
   - Configuration
   - Error Handling

### Internal Dependencies

- Component X must be updated before Y
- Service Z needs new permissions

## Edge Cases & Error Handling

List edge cases from discussion document and how plan addresses them:

### Edge Case: {Description}

**From Discussion**: How it was identified
**Solution**: Specific handling in implementation
**Phase**: Where it's addressed
**Test**: How to verify

(Repeat for each edge case)

## Testing Strategy

### Unit Tests
- Component: Tests needed
- Coverage requirements

### Integration Tests
- System flow: Test scenarios
- Data validation

### Performance Tests
- Load testing requirements
- Metrics to monitor

### Manual Testing Checklist
- [ ] Test scenario 1
- [ ] Test scenario 2
- [ ] Edge case verification

## Security Considerations

- Authentication/authorization changes
- Data access controls
- Input validation
- Security edge cases

## Monitoring & Observability

**Metrics to Track**:
- Performance metric 1 (target: X)
- Error rate (target: <Y%)
- Usage metric

**Alerts**:
- Condition → Action

**Logging**:
- What to log at each phase
- Debug information needed

## Rollback Strategy

**Rollback Triggers**:
- Error rate > X%
- Performance degradation > Y%
- Critical bug discovered

**Rollback Steps**:
1. Step 1
2. Step 2

**Data Handling**:
- How to handle data created during failed deployment

## Dependencies & Blockers

**Must Have Before Starting**:
- Dependency 1: Status, owner
- Dependency 2: Status, owner

**Known Risks**:
- Risk: Mitigation plan
- Risk: Mitigation plan

**Assumptions**:
- Assumption 1: Validation needed
- Assumption 2: Validation needed

## Documentation Requirements

**Code Documentation**:
- API documentation
- Inline comments for complex logic
- README updates

**User Documentation**:
- Feature guide
- API docs for consumers

**Team Documentation**:
- Architecture decision records
- Runbook updates

## Post-Implementation

**Verification Period**: X days/weeks

**Success Metrics Review**:
- Metric 1: Target vs actual
- Metric 2: Target vs actual

**Follow-up Items**:
- [ ] Optimization opportunity 1
- [ ] Tech debt to address
- [ ] Documentation updates

**Retrospective Topics**:
- What went well
- What to improve
- Lessons learned

## Evolution Log

Track how plan evolves:

### YYYY-MM-DD - Initial Plan
Created from discussion document

### YYYY-MM-DD - {Change}
Updated phase 2 based on {reason}
```

## Usage Notes

**When creating**:
1. Start with discussion document from `plan/discussion/`
2. Create: `plan/implementation/{feature-name}.md`
3. Extract key decisions and constraints from discussion
4. Break into logical phases
5. Add code examples for complex parts

**During planning**:
- Reference discussion document frequently
- Ensure all edge cases from discussion are addressed
- Verify phases are independently testable
- Add code examples where approach isn't obvious
- Keep it actionable for implementation team

**What to include**:
- Clear phases with specific tasks
- Code examples/pseudocode for novel patterns
- Data models and API contracts
- Testing strategy
- Rollback plans

**What to avoid**:
- ❌ Don't start implementing (that's next phase)
- ❌ Don't re-debate decisions (reference discussion)
- ❌ Don't make new architectural decisions without discussion
- ❌ Don't skip edge cases from discussion

**Ready for implementation when**:
- [ ] All phases defined with clear tasks
- [ ] Success criteria measurable
- [ ] Edge cases addressed
- [ ] Testing strategy clear
- [ ] Code examples for complex parts
- [ ] Dependencies identified
- [ ] Team reviewed and approved
