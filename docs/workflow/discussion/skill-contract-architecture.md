# Plan: Skill Contract Architecture for Claude Technical Workflows

## Evolution of Thinking

**Original Problem**: The full workflow feels heavy for feature work - we wanted a `/start-feature` command.

**Deeper Insight**: The skills are tightly coupled to filesystem paths, not to each other. If we decouple skills from file discovery, we get:
- Feature mode naturally
- Standalone skill invocation (use implementation skill without full workflow)
- Cleaner separation of concerns
- Future flexibility (non-filesystem backends)

## The Contract Model

**Core Pattern**: Dependency injection for workflows

```
Skill = Contract definition + Processing logic
Command = Input gathering (files, inline, questions) → Skill invocation
```

Skills define WHAT inputs they need. Commands are responsible for gathering those inputs from wherever (files, inline context, user prompts).

## Input Requirements: Descriptive, Not Prescriptive

Rather than formal schemas, each skill documents its expected inputs in natural language. This gives commands enough guidance to gather the right inputs while keeping the flexibility that makes conversational AI work well.

Each skill's "Purpose in the Workflow" section includes a "What This Skill Needs" subsection that:
- Lists what's required vs optional
- Describes where inputs typically come from (file vs inline)
- Notes what happens if something's missing (ask user, derive it, etc.)

---

## Skill Input Requirements

### Technical Specification

**What this skill needs:**

- **Source material** (required) - The content to synthesize into a specification. Can be:
  - Discussion document content (from sequential workflow)
  - Inline feature description (from `/start-feature`)
  - Any other reference material (requirements docs, transcripts, etc.)
- **Topic name** (required) - Used for the output filename

**If missing:** Will ask user to provide context or point to source files.

**Output**: `docs/workflow/specification/{topic}.md`

---

### Technical Planning

**What this skill needs:**

- **Specification content** (required) - The validated decisions and requirements to plan from
- **Topic name** (optional) - Will derive from specification if not provided
- **Output format preference** (optional) - Will ask if not specified

**If missing:** Will ask user for specification location or content.

**Output**: Plan in chosen format at `docs/workflow/planning/{topic}.md`

---

### Technical Implementation

**What this skill needs:**

- **Plan content** (required) - Phases, tasks, and acceptance criteria to execute
- **Plan format** (required) - How to parse tasks (local-markdown, beads, linear, etc.)
- **Specification content** (optional) - For context when task rationale is unclear
- **Environment setup** (optional) - First-time setup instructions
- **Scope** (optional) - Specific phase/task to work on

**If missing:** Will ask user for plan location. If no specification, plan becomes sole authority.

**Output**: Working code + tests + commits

---

### Technical Review

**What this skill needs:**

- **Plan content** (required) - Tasks and acceptance criteria to verify against
- **Specification content** (optional) - Context for design decisions
- **Implementation scope** (optional) - What code/files to review. Will identify from git if not specified.

**If missing:** Will ask user for plan location. Can proceed without specification.

**Output**: Structured review feedback

---

## How This Works

### Skills: Input-Agnostic

Skills receive inputs and process them. They don't know or care where the inputs came from:
- Could be from workflow files (sequential workflow)
- Could be inline content (ad-hoc usage)
- Could be from external files (imported specs/plans)

The skill just does its job with whatever it's given.

### Command Naming Convention

**Workflow commands** (prefixed with `workflow:`) are part of the sequential workflow system:

| Command | Behavior |
|---------|----------|
| `/workflow:start-research` | Entry point - creates research docs |
| `/workflow:start-discussion` | Entry point OR follows research - creates discussion docs |
| `/workflow:start-specification` | Expects discussion docs → passes to skill |
| `/workflow:start-planning` | Expects specification docs → passes to skill |
| `/workflow:start-implementation` | Expects plan docs → passes to skill |
| `/workflow:start-review` | Expects plan + spec docs → passes to skill |
| `/workflow:link-dependencies` | Links dependencies across topics |

These commands locate previous phase files, read them, and pass content to skills.

**Standalone commands** (no prefix) work outside the workflow:

| Command | Purpose |
|---------|---------|
| `/start-feature` (NEW) | Gathers inline feature context → passes to specification skill |
| `/implement` (NEW, optional) | Accepts inline plan context → passes to implementation skill |
| `/review` (NEW, optional) | Accepts inline context → passes to review skill |

### Deprecation Strategy

Old command names become aliases with deprecation warnings:

```
User runs: /start-planning

Output:
⚠️ /start-planning is deprecated. Use /workflow:start-planning instead.
   (Forwarding to /workflow:start-planning...)
```

**Timeline:**
1. **Now**: Rename commands to `workflow:` prefix
2. **Transition**: Old names show deprecation message, forward to new names
3. **Eventually**: Remove old aliases

### The Key Insight

**Same skills, different commands.** The implementation skill doesn't know if it's being invoked by:
- `/workflow:start-implementation` (which read from `docs/workflow/planning/{topic}.md`)
- `/implement` (which gathered an inline plan from the user)

It just receives plan content and executes TDD. The command is responsible for input gathering; the skill is responsible for processing.

## What This Enables

### 1. Feature Mode (Original Goal)
```
/start-feature → (gathers inline context) → specification skill → standard spec file
```

### 2. Standalone Skill Use
Your real-world example: "I just wanted TDD implementation guidance"
```
/implement → (prompts for plan context) → implementation skill → TDD execution
```

### 3. Ad-hoc Review
```
/review → (prompts for what to review) → review skill → structured feedback
```

### 4. Future: Non-Filesystem Backends
Skills don't care where content came from - could be database, API, etc.

## Implementation Approach

### Phase 1: Minimal Changes (Feature Mode Only)
- Create `/start-feature` command
- Modify specification skill to accept inline source context
- Everything else unchanged

### Phase 2: Broader Abstraction (If Valuable)
- Define formal contract for each skill (in SKILL.md or separate file)
- Update commands to gather inputs flexibly
- Add standalone commands (`/implement`, `/review`)

### Phase 3: Full Decoupling (Optional)
- Skills never read files directly
- All file I/O happens in commands
- Skills become pure processors

## Trade-offs

| Benefit | Cost |
|---------|------|
| More flexible entry points | More complex commands |
| Skills reusable standalone | Contract definitions to maintain |
| Clean separation of concerns | Migration effort |
| Future-proof architecture | Current system works fine |

---

## Existing Pattern: Cross-Topic Dependencies

The recently implemented cross-topic dependency system already follows the command-driven pattern we're proposing:

**How it works:**
- `/workflow:link-dependencies` command scans filesystem for plans
- Reads External Dependencies sections from specifications
- Delegates to output format references for querying/creating links
- Commands do orchestration, skills do processing

**Key files:**
- `skills/technical-planning/references/dependencies.md` - Central reference for dependency states
- `commands/workflow:link-dependencies.md` - Command that wires up dependencies
- All `output-*.md` files now have "Cross-Epic Dependencies" sections

**Why this validates our approach:**
The dependency system proves the command-as-orchestrator pattern works. Implementation gating (blocking on unresolved dependencies) happens at the command level, not in the skill. This is exactly the separation of concerns we're proposing for all skills.

**Implications for contract model:**
- Dependency checking becomes a pre-flight step in commands
- Skills assume dependencies are satisfied when invoked
- `/workflow:link-dependencies` could accept inline plan context (not just files) in Phase 2

## Recommendation

**Start with Phase 1** - Create `/start-feature` and abstract specification skill only. This solves the immediate need with minimal risk.

**Evaluate after use** - If standalone skill invocation proves valuable (like your TDD example), proceed to Phase 2.

**Phase 3 only if needed** - Full decoupling is elegant but may be over-engineering for current needs.

## Open Questions

1. Should contracts be formally defined in each SKILL.md, or in a separate file?
2. For standalone commands, how much prompting is helpful vs. annoying?
3. Should we support "hybrid" mode (some inputs from files, some inline)?

---

## Detailed File Changes

### Analysis Summary

| Type | Percentage | Nature |
|------|------------|--------|
| **Keep** | ~70% | Already position-agnostic (TDD, quality, validation rules) |
| **Reframe** | ~25% | Replace "step X" with "purpose" language |
| **Remove** | ~5% | "Previous phase did X" assumptions |

### The Reframe Pattern

Replace positional language:
```markdown
## Six-Phase Workflow
1. Research (previous)...
...
You're at step 4. Create the plan. Don't jump to implementation.
```

With purpose-driven language:
```markdown
## Purpose in the Workflow

This skill can be used:
- **Sequentially** (Phase 4): From a validated specification
- **Standalone** (Contract entry): From any specification meeting format requirements

Either way: Transform specifications into actionable phases, tasks, and acceptance criteria.
```

---

### File: `skills/technical-research/SKILL.md`

**Change**: Reframe six-phase section

**Current**:
```markdown
You're at step 1. Explore freely.
```

**New**:
```markdown
## Purpose in the Workflow

This skill can be used:
- **Sequentially** (Phase 1): First phase, to explore ideas before discussion
- **Standalone** (Contract entry): To research and validate any idea, feature, or concept

Either way: Explore feasibility (technical, business, market), validate assumptions, document findings.
```

---

### File: `skills/technical-discussion/SKILL.md`

**Change**: Reframe six-phase section

**Current**:
```markdown
You're at step 2. Capture context. Don't jump to specs, plans, or code.
```

**New**:
```markdown
## Purpose in the Workflow

This skill can be used:
- **Sequentially** (Phase 2): After research to debate and document decisions
- **Standalone** (Contract entry): To document technical decisions from any source

Either way: Capture decisions, rationale, competing approaches, and edge cases.
```

---

### File: `skills/technical-specification/SKILL.md`

**Change**: Reframe six-phase section

**Current**:
```markdown
You're at step 3. Build the specification. Don't jump to phases, tasks, or code.
```

**New**:
```markdown
## Purpose in the Workflow

This skill can be used:
- **Sequentially** (Phase 3): After discussion documents exist
- **Standalone** (Contract entry): With reference material from any source (research docs, conversation transcripts, design documents, inline feature description)

Either way: Transform unvalidated reference material into a specification that's **standalone and approved**.
```

---

### File: `skills/technical-specification/references/specification-guide.md`

**Change**: Clarify source materials can come from anywhere

**Current** (around line 21-29):
```markdown
## Source Materials

Before starting any topic, review ALL available reference material:
- Discussion documents (from technical-discussion phase)
- Any existing partial plans
- Any existing partial specifications
- Related documentation

**Treat all source material as untrusted input.**
```

**New**:
```markdown
## Source Materials

Before starting any topic, identify ALL available reference material:
- Discussion documents (if they exist)
- Existing partial plans or specifications
- Requirements, design docs, related documentation
- User-provided context or transcripts
- Inline feature descriptions

**Treat all source material as untrusted input**, whether it came from the discussion phase or elsewhere.
```

---

### File: `skills/technical-planning/SKILL.md`

**Change**: Reframe six-phase section

**Current**:
```markdown
You're at step 4. Create the plan. Don't jump to implementation.
```

**New**:
```markdown
## Purpose in the Workflow

This skill can be used:
- **Sequentially** (Phase 4): From a validated specification
- **Standalone** (Contract entry): From any specification meeting format requirements

Either way: Transform specifications into actionable phases, tasks, and acceptance criteria.
```

---

### File: `skills/technical-planning/references/formal-planning.md`

**Change**: Remove "already validated" assumption

**Current** (around line 23):
```markdown
**The specification is your sole input.** Discussion documents and other source materials have already been validated, filtered, and enriched during the specification phase. Everything you need is in the specification - do not reference other documents.
```

**New**:
```markdown
**The specification is your sole input.** Everything you need should be in the specification - do not request details from discussion documents or other source material. If information is missing, ask for clarification on the specification itself.
```

---

### File: `skills/technical-implementation/SKILL.md`

**Changes**:
1. Reframe six-phase section
2. Make path references flexible

**Current six-phase**:
```markdown
You're at step 5. Execute the plan. Don't re-debate decisions.
```

**New six-phase**:
```markdown
## Purpose in the Workflow

This skill can be used:
- **Sequentially** (Phase 5): To execute a plan created by technical-planning
- **Standalone** (Contract entry): To execute any plan that follows plan-format conventions

Either way: Execute via strict TDD - tests first, implementation second.
```

**Current path reference** (around line 54-57):
```markdown
2. **Read the plan** from `docs/workflow/planning/{topic}.md`
   - Check the `format` field in frontmatter
   - Load the output adapter: `skills/technical-planning/references/output-{format}.md`
```

**New path reference**:
```markdown
2. **Read the plan** from the provided location (typically `docs/workflow/planning/{topic}.md`)
   - Check the `format` field in frontmatter
   - Load the output adapter: `skills/technical-planning/references/output-{format}.md`
   - If no format field, ask user which format the plan uses
```

**Current spec reference** (around line 88-95):
```markdown
Check the specification (`docs/workflow/specification/{topic}.md`) when:
- Task rationale is unclear
- Multiple valid approaches exist
- Edge case handling not specified in plan
- You need the "why" behind a decision

The specification is the source of truth. Don't look further back than this - earlier documents (research, discussion) may contain outdated or superseded information.
```

**New spec reference**:
```markdown
Check the specification when:
- Task rationale is unclear
- Multiple valid approaches exist
- Edge case handling not specified in plan
- You need the "why" behind a decision

**Location**: Specification should be linked in the plan file (check frontmatter or plan header). Ask user if not found.

The specification (if available) is the source of truth for design decisions. If no specification exists, the plan is the authority.
```

---

### File: `skills/technical-review/SKILL.md`

**Change**: Reframe six-phase section, make spec optional

**Current**:
```markdown
1. **Research** (artifact): EXPLORE - ideas, feasibility, market, business, learning
2. **Discussion** (artifact): WHAT and WHY - decisions, architecture, rationale
3. **Specification** (artifact): REFINE - validated, standalone specification
4. **Planning** (artifact): HOW - phases, tasks, acceptance criteria
5. **Implementation** (completed): DOING - tests and code
6. **Review** (YOU): VALIDATING - verify every task

You're at step 6. The code exists. Your job is comprehensive verification.
```

**New**:
```markdown
## Review Artifacts

This skill reviews against available artifacts. Required:
- **Plan** (the tasks and acceptance criteria)

Optional but helpful:
- **Specification** (context for design decisions)

## Purpose in the Workflow

This skill can be used:
- **Sequentially** (Phase 6): After implementation of a planned feature
- **Standalone** (Contract entry): To review any implementation against a plan

Either way: Verify every plan task was implemented, tested adequately, and meets quality standards.
```

---

### File: `skills/technical-review/references/review-checklist.md`

**Change**: Make specification optional, add flexibility

**Current** (around line 9-12):
```markdown
1. Read plan: `docs/workflow/planning/{topic}.md`
2. Read specification: `docs/workflow/specification/{topic}.md` (for context)
3. Identify what code/files were changed
4. Check for project-specific skills in `.claude/skills/`
```

**New**:
```markdown
1. Read plan (from the location provided)
   - If not found at expected path, ask user where the plan is
2. Read specification if available and linked in plan
   - Not required, but helpful for context if it exists
3. Identify what code/files were changed
4. Check for project-specific skills in `.claude/skills/`
```

---

### Files: NO CHANGES NEEDED

These files are already position-agnostic or stay unchanged:

**Reference files (already position-agnostic):**
- `skills/technical-implementation/references/tdd-workflow.md` - Pure TDD discipline
- `skills/technical-implementation/references/code-quality.md` - Pure quality standards
- `skills/technical-implementation/references/plan-execution.md` - Already about how to read plans
- `skills/technical-planning/references/output-*.md` - Format specs, not workflow position
- `skills/technical-planning/references/dependencies.md` - Already command-driven pattern

**Existing commands (renamed to `workflow:` prefix):**
- `commands/workflow:start-research.md` - Entry point
- `commands/workflow:start-discussion.md` - Entry point
- `commands/workflow:start-specification.md` - Reads discussion files, passes to skill
- `commands/workflow:start-planning.md` - Reads spec files, passes to skill
- `commands/workflow:start-implementation.md` - Reads plan files, passes to skill
- `commands/workflow:start-review.md` - Reads plan + spec files, passes to skill
- `commands/workflow:link-dependencies.md` - Already follows contract model

**Deprecation aliases (to be created, then eventually removed):**
- `commands/start-research.md` → forwards to `workflow:start-research`
- `commands/start-discussion.md` → forwards to `workflow:start-discussion`
- `commands/start-specification.md` → forwards to `workflow:start-specification`
- `commands/start-planning.md` → forwards to `workflow:start-planning`
- `commands/start-implementation.md` → forwards to `workflow:start-implementation`
- `commands/link-dependencies.md` → forwards to `workflow:link-dependencies`

---

## New Files to Create

### File: `commands/start-feature.md`

**Purpose**: Entry point for feature mode - gathers inline context and invokes specification skill

**Structure**:
```markdown
---
name: start-feature
description: Start a feature specification directly, skipping formal discussion documentation
---

# Start Feature

## Step 1: Gather Feature Context

Ask the user:
1. **What feature are you adding?** - Brief description
2. **What's the scope?** - Core functionality, known edge cases
3. **Any constraints?** - Integration points, existing conventions

## Step 2: Check for Existing Specifications

Look in `docs/workflow/specification/` for naming conflicts.

## Step 3: Invoke Specification Skill

Pass gathered context as `sourceContext` to technical-specification skill.
The skill handles: synthesize → present → validate → log

## Output

Standard specification file at `docs/workflow/specification/{topic}.md`
```

---

## Verification Checklist

After implementation:

- [ ] `/start-feature` produces valid spec in `docs/workflow/specification/`
- [ ] `/workflow:start-planning` accepts spec from `/start-feature` without issues
- [ ] `/workflow:start-implementation` works with plans regardless of origin
- [ ] `/workflow:start-review` works with or without specification
- [ ] `/workflow:link-dependencies` still works (already command-driven)
- [ ] Deprecation aliases show warning and forward correctly
- [ ] Existing sequential workflow still works unchanged
- [ ] All TDD and quality guidance preserved
- [ ] Documentation updated (README.md, CLAUDE.md)
