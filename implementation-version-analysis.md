# Technical Implementation Skill — Version Analysis

Analysis of three implementation versions tested against the TICK project.

## Timeline & PRs

| Version | Branch (TICK) | PR(s) | Merged | Description |
|---------|--------------|-------|--------|-------------|
| V1 | `implementation` | Pre-#73 | — | Monolithic single-session |
| V2 | `implementation-take-two` | #73 | Feb 2 | Agent-based task loop |
| V3 | `implementation-v3` | #77, #78, #79, #80 | Feb 3-5 | Refinements + polish |

---

## V1: Monolithic (Pre-PR #73)

Single Claude session doing everything — implementation, review, tracking, commits. Hit compaction limits on larger projects because the entire TDD cycle, plan reading, quality checks, and progress tracking all ran in one continuous context.

Key characteristics:
- SKILL.md was ~280 lines containing everything inline — TDD rules, hard rules, commit practices, problem handling, quality standards
- Phase-based gating (user approval between phases, not tasks)
- Direct implementation: "Act as expert senior developer who builds quality software through disciplined TDD"
- Inline plan-execution.md, progress announcements, phase completion checklists
- Commit after every green test

---

## V2: Agent-Based Task Loop (PR #73, merged Feb 2)

Introduced the executor/reviewer split with per-task orchestration.

### Architectural shift
- SKILL.md became an **orchestrator** — no longer implements code directly
- Two new agents: `implementation-task-executor.md` and `implementation-task-reviewer.md`
- New reference files: `steps/task-loop.md`, `steps/invoke-executor.md`, `steps/invoke-reviewer.md`, `task-normalisation.md`
- Deleted `plan-execution.md` (replaced by the task loop)

### What changed in the orchestrator (SKILL.md)
- Role shifted from "expert senior developer" to "orchestrate implementation by dispatching executor and reviewer agents"
- Hard rules dropped from 5 implementation rules to 2 orchestrator rules (no autonomous spec decisions, all git ops are orchestrator's)
- Phase gates replaced by per-task gates with `task_gate_mode` (gated/auto)
- Steps restructured: env setup -> read plan -> project skills discovery -> init tracking -> task loop -> mark complete
- Context refresh recovery updated to check task progress rather than reading inline state

### The executor agent
- Stateless — receives full context each invocation
- Hard rules: no code before tests, no test changes to pass, no scope expansion, no git writes, read project skills
- Returns structured: STATUS, SUMMARY, FILES_CHANGED, TESTS_WRITTEN, TEST_RESULTS, ISSUES

### The reviewer agent
- Independent from executor — no shared context
- 5 review dimensions: spec conformance, acceptance criteria, test adequacy, convention adherence, architectural quality
- Returns: VERDICT (approved/needs-changes), structured findings with file:line refs

### TDD workflow change
Removed COMMIT from the cycle (RED -> GREEN -> REFACTOR, no longer RED -> GREEN -> REFACTOR -> COMMIT). Commits now orchestrator's responsibility.

---

## V3: Refinements + Polish (PRs #77-80, merged Feb 3-5)

Four PRs in quick succession, each addressing a specific issue:

### PR #77: Fix executor re-attempts (Feb 3)

**Problem:** When the executor was re-invoked after review feedback, it wasn't getting the full task content — just the feedback.

**Fix:** Made every executor invocation (initial or re-attempt) include the complete task content. Added "You are stateless" messaging. Changed all task-loop re-invocation paths from "with the user's comments added" to "with the full task content and the user's comments."

Small but critical — without this, re-invoked executors were working blind.

### PR #78: Fix analysis + fix_gate_mode (Feb 4)

**Problem:** When the reviewer flagged issues, it just said "these are wrong" without saying how to fix them. The user always had to gate review fixes.

**Two additions:**

1. **Reviewer fix recommendations** — each issue now includes:
   - `FIX`: recommended approach
   - `ALTERNATIVE`: optional, when multiple valid approaches exist
   - `CONFIDENCE`: high/medium/low

2. **`fix_gate_mode`** — parallels `task_gate_mode` but for review fix cycles:
   - `gated`: present fix analysis to user, wait for approval
   - `auto`: automatically re-invoke executor (up to 3 attempts, then escalate)
   - `fix_attempts` counter with tripwire at 3 to prevent infinite loops

**Tracking file expanded:** added `fix_gate_mode: gated`, `fix_attempts: 0`

### PR #79: Integration context + codebase cohesion (Feb 4)

**Problem:** Each task executor started fresh with no knowledge of patterns established by previous tasks. Early tasks might create a helper; later tasks duplicate it because they don't know it exists.

**Three additions:**

1. **Integration context file** (`{topic}-context.md`) — accumulates notes from each completed task:
   - Executor's `INTEGRATION_NOTES` (3-5 bullets: patterns, helpers, conventions established)
   - Reviewer's `COHESION_NOTES` (2-4 bullets: patterns to maintain, conventions confirmed)
   - Passed to both executor and reviewer on subsequent tasks

2. **Executor codebase exploration rewrite** — changed from generic "identify patterns" to specific guidance:
   - "You are weaving into an existing canvas, not creating isolated patches"
   - Read integration context first
   - Skim the plan for task landscape awareness
   - "Search for existing helpers — reuse, don't duplicate"
   - "Read BOTH sides of an interface: consumer AND implementer"
   - "Your code should read as if the same developer wrote the entire codebase"

3. **Reviewer dimension 6: Codebase Cohesion** — new review dimension checking:
   - Duplicated logic across task boundaries
   - Helper/pattern reuse
   - Naming consistency
   - Error message conventions
   - Type concreteness
   - Type co-location

**Also added to code-quality.md:** "Convention Consistency" section — match error message casing, naming patterns, file organisation, prefer concrete types.

**Note:** This PR initially had broader Layer 1 (SKILL.md) changes and an integration smoke test, but those were reverted (`16ba683`, `e5c190b`) as redundant/wrong-layer. The final merge kept only the executor/reviewer/code-quality changes.

### PR #80: Polish agent (Feb 5)

**Problem:** Even with per-task review, nobody reviews the whole picture. Tasks 1-8 might each pass individually but the aggregate has duplicated helpers, naming drift, missed integration paths.

**Added:**
- New agent: `implementation-polish.md` (188 lines, Opus model)
- New step reference: `steps/invoke-polish.md`
- SKILL.md Step 6 -> Polish, old Step 6 -> Step 7

The polish agent is architecturally distinct — it's the only agent that dispatches other agents (executor + reviewer) and runs parallel analysis sub-agents. Its discovery-fix loop (2-5 cycles) with 3 fixed passes + optional dynamic passes is its own thing.

---

## What Specifically Changed Between V2 and V3 (Excluding Polish)

### Executor changes (cumulative from PRs 77+79)
1. **Statelessness made explicit** — "You are stateless — each invocation starts fresh"
2. **Gets the plan file** — can skim the task landscape for context
3. **Gets integration context** — accumulated notes from prior tasks
4. **Codebase exploration completely rewritten** — from 3 generic bullets to 6 specific bullets with the "weaving into existing canvas" framing
5. **New output field: INTEGRATION_NOTES** — 3-5 bullets documenting what was established

### Reviewer changes (cumulative from PRs 78+79)
1. **Fix recommendations** — FIX, ALTERNATIVE, CONFIDENCE per issue
2. **6th dimension: Codebase Cohesion** — DRY across tasks, helper reuse, naming/error conventions
3. **Gets integration context** — for checking against established patterns
4. **New output field: COHESION_NOTES** — patterns/conventions observed

### Task loop changes (cumulative from PRs 77+78+79)
1. **All re-invocations pass full task content** (PR 77)
2. **`fix_gate_mode` added** — auto/gated with 3-attempt tripwire (PR 78)
3. **`fix_attempts` reset per task** and tracked in implementation file (PR 78)
4. **Integration context appended after each task** — executor INTEGRATION_NOTES + reviewer COHESION_NOTES (PR 79)
5. **Review Changes section restructured** — conditions evaluated top-down (fix_gate_mode -> attempt count -> present) (PR 78)

### Code quality changes (PR 79)
- New "Convention Consistency" section — error message matching, naming conventions, file organisation, helper reuse, concrete types, co-location

---

## Potential Quality Divergence Observations

The V2->V3 changes are heavily weighted toward **cross-task awareness** (integration context, cohesion review, codebase exploration rewrite). This is additive — it shouldn't degrade per-task quality. But a few things to watch:

1. **Executor exploration is now more prescriptive** — "read BOTH sides of an interface", "search for existing helpers". This guides better integration but could slow down simple tasks that don't have integration concerns. The original V2 was lighter: "identify patterns, check for existing code."

2. **The fix analysis loop (PR 78) adds a layer of autonomy** — when `fix_gate_mode: auto`, the executor and reviewer can bounce back and forth 3 times without human input. If the reviewer's fix recommendations are poor, this could churn.

3. **The reviewer now has 6 dimensions instead of 5** — cohesion is the new one. More dimensions = more potential for the reviewer to flag issues that aren't really issues, especially on early tasks where there's no established pattern to deviate from.

4. **INTEGRATION_NOTES and COHESION_NOTES add context accumulation** — this is the big philosophical shift. V2 agents were truly stateless. V3 agents are still invoked statelessly, but they receive accumulated context. If that context contains bad advice from an early task, it propagates.

---

## TICK Project Results: V2 Wins Decisively

An independent analysis (stored in `/analysis/` in the TICK repo) compared all three implementations across 23 tasks in 5 phases. The analysis was performed by a separate Claude agent reading the actual code from each branch.

### Scorecard

| Phase | Tasks | V1 | V2 | V3 |
|-------|-------|-----|-----|-----|
| 1: Walking Skeleton | 7 | 3rd | **1st (6/7)** | 2nd (1/7) |
| 2: Task Lifecycle | 3 | 3rd | **1st (2.5/3)** | 2nd (0.5/3) |
| 3: Dependencies | 5 | 3rd | **1st (5/5)** | 2nd |
| 4: Output Formats | 6 | 3rd | **1st (6/6)** | 2nd |
| 5: Stats & Cache | 2 | 3rd | **1st (2/2)** | 2nd |

**V2 wins 21/23 tasks outright. V3 wins 1/23 (task 1-5: CLI framework). V1 wins 0/23.**

### V2's Winning Characteristics

- **Full spec compliance** across all 23 tasks (only version to achieve this)
- **Sub-package architecture** with compile-time layer enforcement
- **Composable SQL fragments** — `readyWhere`/`blockedWhere` reused cleanly in Phase 5 stats
- **Store-injected verbose logging** — accurate output even on failure
- **Per-operation cache isolation** — zero shared mutable state
- **Highest test LOC every phase** — 766 LOC in Phase 5 alone, 4.0:1 test-to-impl ratio
- **Cross-task refactoring** — retroactively improved earlier code (`unwrapMutationError`, `ParseTasks`)
- **Integrated `NewTask` factory** — pit-of-success API, impossible to create invalid tasks
- **Rune-aware title validation** — `utf8.RuneCountInString()` for Unicode correctness

### V3's Weaknesses (Despite Having More Guidance)

V3's problems trace to **foundational decisions made in the very first tasks** that compound:

1. **String timestamps** (task 1-1) — `string` instead of `time.Time`. Loses type safety, pushes parsing to every consumer. Cost compounds through all 5 phases.

2. **CLI-level verbose logging** (task 4-6) — `WriteVerbose()` fires from CLI before store ops execute. If `store.Rebuild()` fails, output describes actions that never happened.

3. **String-returning formatters** (task 4-1) — `FormatStats() string` breaks Go's `io.Writer` streaming pattern, requires full output buffering.

4. **`int` exit code returns** — CLI handlers return `int` instead of `error`, breaking Go's error propagation. `fmt.Fprintf(a.Stderr, "Error: %v\n", err)` duplicated 12+ times.

5. **Missing spec compliance** — no `workflow` JSON key (tasks 4-4, 5-1), merged into `by_status` instead of separate key.

6. **Bare error returns** — `queryStats` returns bare errors without wrapping. V2 wraps every error with context.

7. **Double file reads** — store reads the file twice (once for hash, once for parsing) because task 1-2 didn't expose a byte-based parser and task 1-4 didn't add one.

### V1's Profile

- **0/23 task wins**, 3rd in 20/23
- Critical dead-code defect (list/show commands never wired to CLI)
- SQL injection vulnerability (`fmt.Sprintf` for query construction)
- Lowest test quality (substring assertions, 1.5:1 test-to-impl ratio)
- Best lock helper abstraction (narrow win)
- `time.Time` timestamps (got this right where V3 didn't)

---

## Why V2 Beat V3: Diagnosis

The central paradox: V3 had *more* guidance (integration context, cohesion review, codebase exploration instructions, fix recommendations) but produced *worse* code. Several hypotheses:

### 1. The Damage Was Done Before V3's Additions Could Help

V3's critical weaknesses are all Phase 1 decisions — string timestamps, error return conventions, lack of `NewTask` factory. The integration context file (`PR #79`) only accumulates notes *after* tasks complete. By the time task 1-2's integration notes would warn "use `time.Time`", the string timestamp decision is already baked in. The context file is forward-looking but the damage is backward.

**V2 didn't need integration context because V2 made better foundational choices.** The V2 executor's simpler guidance ("identify patterns, conventions, and structures you'll need to follow or extend") didn't prevent good decisions — it just let the model make them without overthinking.

### 2. Prescriptive Exploration May Constrain Rather Than Guide

V2's executor exploration instructions were 3 generic bullets:
- Read files and tests related to the task's domain
- Identify patterns, conventions, and structures you'll need to follow or extend
- Check for existing code that the task builds on or integrates with

V3's were 6 specific bullets:
- Read integration context first
- Skim the plan for task landscape awareness
- Search for existing helpers — reuse, don't duplicate
- Read BOTH sides of an interface
- Match conventions established in the codebase
- "Your code should read as if the same developer wrote the entire codebase"

The V3 instructions tell the executor *how* to explore. The V2 instructions tell it *what* to look for and let it decide how. The V3 approach risks turning exploration into a checklist rather than genuine understanding. An executor following V3's instructions might dutifully read the integration context file but miss a pattern visible in the actual code because "read integration context first" front-loaded a secondary source over the primary one.

### 3. The Cohesion Dimension May Create Noise on Early Tasks

V3's reviewer evaluates 6 dimensions instead of 5. The 6th — codebase cohesion — checks for duplicated logic, helper reuse, naming consistency, etc. But on tasks 1-1 through 1-3, there's essentially nothing to be cohesive *with*. The reviewer is evaluating cohesion against an empty or near-empty codebase, which at best wastes attention and at worst produces meaningless feedback that the executor must process.

V2's reviewer focused on 5 dimensions — all of which are meaningful from task 1 onward. No wasted review bandwidth.

### 4. More Process Overhead May Reduce Code Quality Per Token

V3 has more machinery: fix_gate_mode, fix_attempts tracking, INTEGRATION_NOTES production, COHESION_NOTES production, integration context file management. Each piece consumes executor and reviewer attention. The executor must now produce 3-5 INTEGRATION_NOTES bullets after every task. The reviewer must produce COHESION_NOTES. This is meta-work — work about the work — that takes tokens away from actual code reasoning.

V2's agents had a clean mandate: implement (executor) or verify (reviewer). No notes to produce, no context files to maintain, no secondary outputs. More cognitive budget available for the actual code.

### 5. The Plan-Aware Executor Is a Double-Edged Sword

V3 passes the plan file to the executor and tells it to "skim the plan file to understand the task landscape." This means the executor now knows what's coming in future tasks. This could theoretically help it make forward-compatible decisions, but it could also bias it toward premature abstraction or over-engineering for future tasks that haven't been written yet.

V2's executor only knew about its current task. This forced it to make decisions based on what existed *now*, which paradoxically led to better decisions because the executor wasn't trying to be clever about a future it couldn't fully predict.

### 6. Sample Size Caveat

This is a single project comparison. The results could be influenced by:
- Model variance between runs
- The specific nature of the TICK project (Go CLI, moderate complexity)
- User interaction differences between runs (gating decisions, feedback quality)
- The fact that V2 and V3 used the same plan but were separate implementation sessions

The pattern is clear but would benefit from more data points across different project types.

---

## Key Takeaway

V3's additions (integration context, cohesion review, fix recommendations, prescriptive exploration) address real problems — cross-task awareness, review actionability, codebase coherence. But they may be solving **late-task problems at the cost of early-task quality**. The highest-leverage moment in any implementation is the first few tasks, where foundational decisions cascade. V2's simpler, less prescriptive approach left the executor more freedom to make those foundational decisions well.

The question for the skill's evolution: can V3's cross-task awareness be preserved without the overhead and prescription that may have degraded V3's early-task decision quality?

---

## Deep Analysis: Cognitive Load & Token Budget (Agent Prompt Comparison)

### Executor Instruction Load

| Metric | V2 | V3 | Change |
|--------|----|----|--------|
| Input items (initial) | 5 | 7 | +40% |
| Input items (re-attempt) | 7 | 9 | +29% |
| Explore sub-instructions | 3 | 7 | +133% |
| Output fields | 7 | 8 | +14% |
| Total distinct instructions | ~28 | ~38 | +36% |

The cognitive load increase is concentrated in step 5 (explore). This is *pre-work* — it executes before any actual implementation happens, meaning the executor carries a heavier preamble before reaching its core job.

### Meta-work vs Implementation Work

V3 executor: ~21% of actionable instructions are about workflow bookkeeping (reading context files, producing integration notes) rather than writing code. Roughly one in five instructions processes meta-concerns. The INTEGRATION_NOTES production happens *after* implementation, so it doesn't compete during TDD — but it still consumes output tokens and cognitive closure.

### Reviewer Prompt Inflation

The V3 reviewer prompt is **~68% larger** than V2's:
- Added: Codebase Cohesion dimension (6 sub-bullets — most detailed of any dimension)
- Added: Fix Recommendations framework (FIX/ALTERNATIVE/CONFIDENCE — 11 lines)
- Added: COHESION_NOTES output requirement
- Risk: format compliance competes with analytical depth. V2's reviewer could focus entirely on "is this right?" V3's reviewer must also produce structured fix advice for every issue.

### Token Budget: Integration Context File Growth

The integration context file grows linearly with tasks:

- Per task: ~190-370 tokens of notes (executor INTEGRATION_NOTES + reviewer COHESION_NOTES)
- Both executor and reviewer receive the full context file each invocation
- Task 10: ~1,900-3,700 extra input tokens x 2 agents = ~3,800-7,400 extra tokens
- Task 20: ~3,800-7,400 extra input tokens x 2 agents = ~7,600-14,800 extra tokens
- **Cumulative additional input across a 20-task plan: ~76K-148K tokens**

The concern isn't window overflow — it's attention dilution. As the file grows, each entry competes for model attention with all previous entries.

---

## Deep Analysis: V3's Integration Context File (Evidence from TICK)

The V3 TICK implementation produced a 341-line integration context file across 23 tasks. Examining its content reveals several patterns:

### What the Context File Actually Contained

**Positive patterns (valuable cross-task knowledge):**
- File paths and constructor patterns (`Store.Mutate()`, `Store.Query()`, `NewCache(path)`)
- Established conventions (error message style, test naming "it does X" format)
- Reusable SQL constants (`ReadyCondition`, `BlockedCondition`)
- CLI handler pattern (`DiscoverTickDir -> NewStore -> Query -> Formatter`)

**Problematic patterns (locked in bad decisions):**
- Task 1-1 notes: "Timestamps use `time.RFC3339` format — `DefaultTimestamps()` returns both created and updated as same value" — This *codifies* the string timestamp decision. Every subsequent executor reads this and treats it as the established convention to match.
- Task 1-1 notes: "`TrimTitle` is separate from `ValidateTitle` — call TrimTitle first, then ValidateTitle on trimmed result" — This documents a two-step coordination pattern that V2 avoided entirely via its integrated `NewTask()` factory.
- Task 1-2 notes: "Error handling: returns raw errors (acceptable for low-level storage layer)" — The reviewer's COHESION_NOTES validated bare error returns as "acceptable." This legitimised V3's weakest pattern.

### The Core Problem: Context File Reinforces Early Decisions

Once task 1-1's integration notes say "timestamps use `time.RFC3339` format" and the reviewer's cohesion notes confirm "error handling follows project convention: returns raw errors," every subsequent executor treats these as constraints. The context file doesn't just *describe* patterns — it *prescribes* them. When the V3 executor reads "returns raw errors (acceptable for low-level storage layer)" before exploring the codebase, it has been given permission to not wrap errors.

V2 had no such permission structure. Each V2 executor made its own judgment about error handling based on Go idioms and the code-quality.md file, which says "DRY" and "SOLID" but doesn't explicitly endorse bare returns. The V2 executor was free to *improve* on what came before. The V3 executor was implicitly told to *match* it.

### The Temporal Asymmetry

Integration context is most valuable in the middle and late phases (tasks 8+), where established patterns genuinely need to be discovered and matched. But its cost is highest in the early phases (tasks 1-3), where:
- The context file is empty or near-empty, providing no value
- The executor wastes time on "read integration context first" with nothing to read
- The instruction set is 36% heavier than V2's for zero additional benefit
- Early decisions get locked in by the context file and propagated forward

---

## Deep Analysis: Plan-Skimming Creates Over-Engineering Pressure

V3 passes the plan file to the executor with: "Skim the plan file to understand the task landscape — what's been built, what's coming, where your task fits. Use this for awareness, not to build ahead (YAGNI still applies)."

### Why the YAGNI Caveat Is Insufficient

Telling a model "look at future tasks but don't build for them" creates a tension that's hard to resolve. Once the executor *knows* Task 8 will need a plugin system, it's nearly impossible to implement Task 3's simple factory without pre-baking extension points. The instruction "YAGNI still applies" is a rule, but plan knowledge creates *motivation* to violate it. Rules lose to motivation in generative models.

The V3 executor explore section already contains: "When creating an interface or API boundary, read BOTH sides: the code that will consume it AND the code that will implement it." This is excellent guidance for building interfaces that fit. Adding plan-awareness on top creates redundancy: if the executor reads consumer and implementer code, it already knows what the interface needs. Plan-skimming adds *future* consumers that don't exist yet — exactly the information that tempts over-engineering.

V2 had no plan-awareness. The executor knew only its task and the codebase. This forced decisions based on what existed *now*, which paradoxically led to better decisions.

---

## Deep Analysis: "Same Developer" Pressure

V3's explore section includes: "Your code should read as if the same developer wrote the entire codebase."

### When It Helps

Naming conventions, error message style, file organization, import ordering, comment style — these should be uniform. The instruction drives the executor to *match* rather than *impose*.

### When It Hurts

If the existing codebase has suboptimal patterns (bare errors, string timestamps, `any` types), "same developer" pressure means the executor *perpetuates* those patterns rather than improving them. Code-quality.md says "Prefer concrete types over generic/any types" but "same developer" says "match the existing code." When the codebase violates code-quality.md, these instructions conflict.

The conflict resolution is implicit but the ordering is wrong: "same developer" appears in the explore section (step 5), which processes *before* TDD begins. It sets a *tone* that may override the more granular quality rules processed later.

---

## V3 Evidence: What the Context File Reveals About the Executor's Actual Behaviour

Looking at V3's integration context file task by task, a pattern emerges:

**Task 1-1** (first task, no context to read): Made the string timestamp decision. No integration context existed to prevent it. No context file to blame — this is pure model choice under V3's instruction set.

**Task 1-2** (second task, minimal context): "Relies on Task struct's `omitempty` JSON tags for optional field omission — no custom marshaling needed." The executor noted that string timestamps simplified JSON serialization. The context file is now *documenting the benefit* of the bad decision, making it harder for later tasks to question it.

**Task 1-4** (fourth task, growing context): "JSONL-first principle: SQLite failures during mutation are logged to stderr but return success (next read self-heals)." The executor adopted error-swallowing for SQLite because the context file established bare returns as the convention.

**Task 4-1** (thirteenth task, substantial context): "Formatter interface with methods: `FormatTaskList`, `FormatTaskDetail`, `FormatTransition`, `FormatDepChange`, `FormatStats`, `FormatMessage`" — all returning `string`. By this point, the "match conventions" instruction plus the accumulated context created strong pressure toward string returns, even though Go's `io.Writer` pattern is standard.

**Task 4-6** (eighteenth task): "`WriteVerbose(format, args...)` uses `verbose:` prefix — all debug output to stderr only" — CLI-level verbose logging. The executor placed verbose logging at the CLI layer because that's where the context file showed all previous output going. The context file never flagged "verbose should fire from the store layer" because no prior task had done it that way.

### The Compounding Pattern

The context file creates a **convention gravity well**. Each task's integration notes describe what was done. Each reviewer's cohesion notes confirm it as the established pattern. The next executor reads both and treats them as constraints. By task 10, the accumulated context is a 170-line document that effectively says "here is how things are done in this codebase" — even if how things were done in tasks 1-3 was suboptimal.

V2 had no such gravity well. Each executor explored the codebase fresh. If a V2 executor saw bare error returns in task 1-2's code and thought "I should wrap errors," nothing prevented that improvement. V2's executor was free to *evolve* the codebase's conventions. V3's executor was implicitly told to *conform* to them.

---

## Actionable Recommendations: What to Change

### Tier 1: High Confidence (Clear Signal from Evidence)

**1. Remove plan file access from the executor.**
The executor should know only its task and the codebase. Plan-skimming creates over-engineering pressure that the YAGNI caveat cannot counter. Remove the plan file path from executor inputs entirely.

**2. Change integration context reading order.**
From: "read it first — identify helpers, patterns, and conventions you must reuse before writing anything new"
To: "after exploring the codebase, consult the integration context file as a checklist — verify you haven't missed established patterns or duplicated existing helpers"
This eliminates framing bias while preserving the value.

**3. Add qualification to "same developer" instruction.**
Change to: "Your code should read as if the same developer wrote the entire codebase — match style, naming, and organization conventions. If existing code conflicts with the quality standards in code-quality.md or the project skills, follow the standards."
This gives code-quality.md explicit precedence over convention matching.

**4. Conditional COHESION_NOTES production.**
Only require COHESION_NOTES from the reviewer when verdict is `needs-changes` and cohesion was a factor. For `approved` verdicts, the executor's INTEGRATION_NOTES (from the person who actually wrote the code) is sufficient. This eliminates ~40% of the context file bloat.

**5. Cap integration context file growth.**
After 8 tasks, consolidate older entries into a "Consolidated Patterns" header section (5-10 bullets summarising key patterns) and keep only the most recent 8 task entries in full. This caps input inflation at a stable ceiling rather than linear growth.

### Tier 2: Moderate Confidence (Logical but Less Direct Evidence)

**6. Reduce explore sub-instructions from 7 to 5.**
Keep:
- Read files and tests related to the task's domain
- Search for existing helpers, utilities, and abstractions — reuse, don't duplicate
- When creating an interface or API boundary, read BOTH sides
- After exploring, consult integration context as a checklist (moved from first to last)
- Match conventions established in the codebase: error message style, naming patterns, file organisation

Remove:
- "skim the plan file" (covered by recommendation 1)
- "Your code should read as if the same developer wrote the entire codebase" (covered by "match conventions" bullet with the code-quality qualification)

This reduces the explore section from 7 bullets to 5 while preserving the genuinely useful guidance.

**7. Keep fix recommendations (FIX/ALTERNATIVE/CONFIDENCE) — this is the clear V3 winner.**
The structured fix framework transforms vague "needs changes" feedback into actionable guidance. This is the single highest-value V3 addition and should be preserved unchanged.

**8. Keep Codebase Cohesion as a review dimension but make it conditional.**
On tasks 1-3, there's essentially nothing to be cohesive with. Add: "Evaluate codebase cohesion from task 4 onward, or earlier if the integration context file contains at least 3 task entries." This eliminates wasted review bandwidth on early tasks while preserving the dimension's value later.

### Tier 3: Speculative (Worth Considering but Needs More Data)

**9. Consider a "foundational decisions" review for the first 2-3 tasks.**
The highest-leverage improvement would address the root cause: bad early decisions that compound. One approach: have the reviewer run a special "foundational design" pass on tasks 1-3 that specifically evaluates type choices, error handling conventions, return type patterns, and API surface decisions against language idioms. This would catch `string` vs `time.Time`, `int` vs `error`, `string` vs `io.Writer` decisions when they're still cheap to fix.

**10. Consider whether the context file should include "anti-patterns" alongside "patterns."**
Currently the context file only records what was done — not what was considered and rejected. If the reviewer saw bare error returns and flagged them (but they were accepted), that signal is lost. Recording "rejected approaches" would give later executors richer context, but adds more meta-work.

**11. Investigate whether model variance explains the gap.**
This is a single project comparison (n=1). Run V2 and V3 instructions on a different project (different language, different complexity) to see if the pattern holds. If V2 consistently produces better early decisions, the diagnosis is confirmed. If results vary, the TICK comparison may reflect model noise rather than instruction quality.
