# Plan: Cross-Topic Dependencies

## Summary

Implement cross-topic dependency tracking and linking across the technical workflow system. This addresses the gap where dependencies identified in specifications (external dependencies on other topics) get lost when moving to planning and implementation.

## Problem Statement

The six-phase workflow is designed for single-topic linear progression. In reality:
- Dependencies form a network, not a linear chain
- One topic's plan may depend on specific tasks in another topic's plan
- External dependencies captured in specifications don't flow into plans properly
- Implementation can start on work that depends on things that don't exist yet

## Key Concepts

### Dependency Types

| Type | Description | Where it lives |
|------|-------------|----------------|
| **Internal** | Dependencies within a topic (Task 3 depends on Task 1) | Output format only (beads, linear, etc.) |
| **External** | Dependencies on other topics (this feature needs billing system) | Plan index file → then wired into output format |

### Dependency Lifecycle

```
NATURAL LANGUAGE          →    ENRICHED REFERENCES         →    PRECISE TASK IDs
─────────────────────────────────────────────────────────────────────────────────
"Needs billing system"    →    "billing-system topic"      →    "beads-7x2k"
(spec time, no plans)          (plan exists, topic known)       (specific task identified)
```

Dependencies start vague and get more precise as knowledge accumulates.

### Beads Structure (Primary Output Format)

```
One Beads project (single database)
├── Epic: billing-system (= specification topic)
│   ├── Phase 1
│   │   ├── Task 1
│   │   └── Task 2
│   └── Phase 2
│       └── Task 3
├── Epic: authentication (= another specification topic)
│   └── ...
```

Each specification/topic = one epic. Cross-topic dependencies link tasks across epics within the same database.

## What We're Building

### 1. Update Planning Skill

**File**: `skills/technical-planning/SKILL.md` and `skills/technical-planning/references/formal-planning.md`

**Changes**:
- Add step to read Dependencies section from specification
- Copy external dependencies into plan index file
- Add "External Dependencies" section template to plan index
- During planning, check if dependencies have existing plans:
  - If yes: attempt to identify specific tasks, ask human if ambiguous
  - If no: record in natural language for later linking
- Optional prompt: "Would you like to check if any existing plans depend on this topic?" (reverse dependency check)

**External Dependencies Section Format** (in plan index):
```markdown
## External Dependencies

- billing-system: Invoice generation for order completion
- user-authentication: User context for permissions → beads-9m3p (resolved)
- ~~payment-gateway: Payment processing~~ → satisfied externally
```

Format:
- Unresolved: `- {topic}: {description}`
- Resolved: `- {topic}: {description} → {task-id}`
- Satisfied externally: `- ~~{topic}: {description}~~ → satisfied externally`

### 2. Update Output Format References

**Files**: All files in `skills/technical-planning/references/output-*.md`

**Changes for each format**:

#### output-beads.md
- Document epic = topic/specification structure
- Add section: "Querying Dependencies"
  - How to query for blocked/blocking tasks
  - How to find unresolved external dependencies
  - SQLite queries and `bd` CLI commands
- Add section: "Cross-Epic Dependencies"
  - How to create dependencies between tasks in different epics
  - `bd dep add {child-task} {parent-task}` works across epics

#### output-linear.md
- Add section: "Querying Dependencies"
  - GraphQL queries or API calls to find blocked issues
  - MCP tool usage if available
- Add section: "Cross-Project Dependencies"
  - How to link issues across projects (if supported)
  - Workarounds if not natively supported

#### output-backlog-md.md
- Add section: "Querying Dependencies"
  - How to parse frontmatter for `dependencies: []` field
  - Grep patterns for finding dependencies
- Add section: "Cross-File Dependencies"
  - Reference format: `{filename}#{task-id}`

#### output-local-markdown.md
- Add section: "Querying Dependencies"
  - How to parse the Dependencies section
  - Grep patterns
- Add section: "Cross-File Dependencies"
  - Consider adding nano IDs to task headers for unique referencing
  - Reference format: `{filename}#{nano-id}` or `{filename}#{task-header}`

### 3. Create `/link-dependencies` Command

**File**: `commands/link-dependencies.md`

**Purpose**: Scan all existing plans, find unresolved external dependencies, attempt to wire them up, update plan indexes and output formats.

**Behavior**:

1. **Discover all plans**
   - Scan `docs/workflow/planning/*.md` for plan index files
   - Identify output format for each plan

2. **Extract unresolved dependencies**
   - Read External Dependencies section from each plan index
   - Filter to unresolved (no task ID, not marked as satisfied externally)

3. **Attempt to resolve**
   - For each unresolved dependency:
     - Search other plans by topic name/keywords
     - If match found, query that plan's output format for relevant tasks
     - Present candidates to user if ambiguous
     - Wire up in output format (create blocking relationship)
     - Update plan index with task ID

4. **Bidirectional check**
   - For each plan, also check: do other plans have dependencies that THIS plan satisfies?
   - Offer to wire those up too

5. **Report**
   - List what was resolved
   - List what remains unresolved
   - List any issues encountered

**Shared Reference**: Consider creating `skills/technical-planning/references/dependency-linking.md` that both the planning skill and this command can use for consistency.

### 4. Update Implementation Skill

**File**: `skills/technical-implementation/SKILL.md` and related references

**Changes**:

#### Pre-Implementation Dependency Check

Before starting implementation on any plan:

1. Read plan index's External Dependencies section
2. For each dependency:
   - If unresolved (natural language, no task ID): **BLOCK** - "Cannot proceed. Unresolved dependency: {description}. This must be planned first or marked as satisfied externally."
   - If resolved (has task ID): Check if that task is complete in the output format
     - If complete: proceed
     - If not complete: **BLOCK** - "Cannot proceed. Dependency not complete: {task-id} in {topic}. This must be implemented first."
   - If marked "satisfied externally": proceed (escape hatch used)

3. Present blocking message clearly:
   ```
   Implementation blocked. Missing dependencies:

   UNRESOLVED (not yet planned):
   - billing-system: Invoice generation for order completion

   INCOMPLETE (planned but not implemented):
   - beads-7x2k (authentication): User context retrieval - Status: in_progress

   These must be completed before this plan can be implemented.
   ```

#### Escape Hatch: Marking Dependencies Satisfied Externally

Add ability for user to mark a dependency as satisfied outside the workflow:

- User says: "The billing system dependency has been implemented outside this workflow"
- Agent updates plan index: `- ~~billing-system: Invoice generation~~ → satisfied externally`
- Implementation can proceed

This handles:
- Dependencies implemented by human directly
- Dependencies handled by another Claude instance
- Third-party systems that already exist
- Features already in the codebase

### 5. Update Start Implementation Command

**File**: `commands/start-implementation.md`

**Changes**:

Add step between "discover plans" and "start implementation":

```markdown
## Step X: Check Dependencies

Before starting implementation:

1. Read the plan index's External Dependencies section
2. Check each dependency:
   - Unresolved? → Block and explain
   - Resolved but incomplete? → Block and explain
   - Resolved and complete? → OK
   - Satisfied externally? → OK
3. If any blocking dependencies, present clear message and stop
4. Offer escape hatch: "If any of these have been implemented outside this workflow, let me know and I can mark them as satisfied."
```

## Implementation Order

### Phase 1: Foundation
1. Update `formal-planning.md` with external dependencies handling
2. Update plan index template with External Dependencies section
3. Update `output-beads.md` with dependency querying section

### Phase 2: Other Output Formats
4. Update `output-linear.md` with dependency querying
5. Update `output-backlog-md.md` with dependency querying
6. Update `output-local-markdown.md` with dependency querying

### Phase 3: Link Dependencies Command
7. Create `commands/link-dependencies.md`
8. Optionally create shared `references/dependency-linking.md`

### Phase 4: Implementation Blocking
9. Update implementation skill with dependency checking
10. Update `start-implementation.md` with dependency gate

## Edge Cases

### Circular Dependencies
If Plan A depends on Plan B which depends on Plan A:
- Link-dependencies command should detect and warn
- Implementation will naturally block (neither can start)
- Human must resolve by restructuring plans

### Partial Requirements
Specifications can have "Partial Requirement" dependencies (minimum scope needed):
- Should be handled by proper task breakdown in the dependency plan
- Link to the specific task that represents minimum scope
- If breakdown isn't granular enough, flag during linking

### Ambiguous Matches
When searching for dependency matches:
- Multiple tasks might satisfy a dependency
- Present options to user: "Found 3 tasks that might satisfy 'user authentication'. Which applies?"
- Allow selecting multiple if dependency needs multiple tasks

### Plan Doesn't Exist Yet
Dependency on a topic that hasn't been planned:
- Stays as natural language in plan index
- Blocks implementation
- Link-dependencies command reports as unresolved

## Testing Considerations

After implementation, verify:
- [ ] Planning skill copies external dependencies from spec to plan index
- [ ] Planning skill attempts to resolve against existing plans
- [ ] Planning skill asks human when matches are ambiguous
- [ ] Each output format documents how to query dependencies
- [ ] `/link-dependencies` finds unresolved dependencies across plans
- [ ] `/link-dependencies` wires up matches in output format
- [ ] `/link-dependencies` updates plan index with task IDs
- [ ] Implementation blocks on unresolved dependencies
- [ ] Implementation blocks on incomplete dependencies
- [ ] Implementation proceeds when dependencies complete
- [ ] "Satisfied externally" escape hatch works

## Files to Create/Modify

### Create
- `commands/link-dependencies.md`
- Optionally: `skills/technical-planning/references/dependency-linking.md`

### Modify
- `skills/technical-planning/SKILL.md` - add dependency handling mention
- `skills/technical-planning/references/formal-planning.md` - add dependency extraction step
- `skills/technical-planning/references/output-beads.md` - add querying section
- `skills/technical-planning/references/output-linear.md` - add querying section
- `skills/technical-planning/references/output-backlog-md.md` - add querying section
- `skills/technical-planning/references/output-local-markdown.md` - add querying section
- `skills/technical-implementation/SKILL.md` - add dependency checking
- `commands/start-implementation.md` - add dependency gate step

## Open Questions (Resolved)

All questions from discussion have been resolved:

1. **Dependency met = complete** - Task must be complete, not just planned
2. **Beads structure** - One project, epics per topic, cross-epic dependencies supported
3. **Command name** - `/link-dependencies`
4. **Partial requirements** - Handled by proper task breakdown
5. **Unresolvable dependencies** - "Satisfied externally" escape hatch
