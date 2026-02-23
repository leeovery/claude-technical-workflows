---
name: technical-investigation
description: "Investigate bugs by combining symptom gathering and code analysis. Captures reproduction steps, traces code paths, identifies root cause, and assesses blast radius. Creates documentation in .workflows/investigation/{topic}/investigation.md that flows to specification and planning."
user-invocable: false
---

# Technical Investigation

Act as **expert debugger** tracing through code AND **documentation assistant** capturing findings. These are equally important — the investigation drives understanding, the documentation preserves it. Dig deep: trace code paths, challenge assumptions, explore related areas. Then capture what you found.

## Purpose in the Workflow

This skill is the first phase of the **bugfix pipeline**:
Investigation → Specification → Planning → Implementation → Review

Investigation combines:
- **Symptom gathering**: What's broken, how it manifests, reproduction steps
- **Code analysis**: Tracing paths, finding root cause, understanding blast radius

The output becomes source material for a specification focused on the fix approach.

### What This Skill Needs

- **Topic** (required) - Bug identifier or short description
- **Bug context** (optional) - Initial symptoms, error messages, reproduction steps
- **Work type** - Always "bugfix" for investigation

**Before proceeding**, confirm the required input is clear. If anything is missing or unclear, **STOP** and resolve with the user.

#### If no topic provided

> *Output the next fenced block as a code block:*

```
What bug would you like to investigate? Provide:
- A short identifier or name for tracking
- What's broken (expected vs actual behavior)
- Any error messages or symptoms observed
```

**STOP.** Wait for user response.

---

## Resuming After Context Refresh

Context refresh (compaction) summarizes the conversation, losing procedural detail. When you detect a context refresh has occurred — the conversation feels abruptly shorter, you lack memory of recent steps, or a summary precedes this message — follow this recovery protocol:

1. **Re-read this skill file completely.** Do not rely on your summary of it. The full process, steps, and rules must be reloaded.
2. **Read the investigation file** at `.workflows/investigation/{topic}/investigation.md` — this is your source of truth for what's been discovered.
3. **Check git state.** Run `git status` and `git log --oneline -10` to see recent commits. Commit messages follow a conventional pattern that reveals what was completed.
4. **Announce your position** to the user before continuing: what you've found so far, what's still to investigate, and what comes next. Wait for confirmation.

Do not guess at progress or continue from memory. The files on disk and git history are authoritative — your recollection is not.

---

## Investigation Process

### Phase 1: Symptom Gathering

Start by understanding the bug from the user's perspective:

1. **Problem description**: What's the expected vs actual behavior?
2. **Manifestation**: How is it surfacing? (errors, UI issues, data corruption)
3. **Reproduction steps**: Can it be reproduced? What triggers it?
4. **Environment**: Where does it occur? (production, staging, specific browsers)
5. **Links**: Error tracking (Sentry), logs, support tickets
6. **Impact**: How severe? How many users affected?
7. **Initial hypotheses**: What does the user suspect?

Document symptoms in the investigation file as you gather them.

### Phase 2: Code Analysis

With symptoms understood, trace through the code:

1. **Reproduce the issue**: If possible, confirm the bug exists
2. **Identify entry points**: Where does the problematic flow start?
3. **Trace code paths**: Follow the execution through the codebase
4. **Isolate root cause**: What specific code/condition causes the bug?
5. **Assess blast radius**: What else might be affected by a fix?
6. **Identify related code**: Are there similar patterns elsewhere?

Document findings in the investigation file as you analyze.

### Phase 3: Root Cause Analysis

Synthesize findings into a clear root cause:

1. **Root cause statement**: Clear, precise description of the bug's cause
2. **Contributing factors**: What conditions enable the bug?
3. **Why it wasn't caught**: Testing gaps, edge cases, etc.
4. **Fix direction**: High-level approach (detailed in specification)

---

## What to Capture

- **Symptom details**: Error messages, screenshots, logs
- **Reproduction steps**: Precise steps to trigger the bug
- **Code traces**: Which files/functions are involved
- **Root cause**: The specific issue and why it occurs
- **Blast radius**: What else might be affected
- **Initial fix ideas**: Rough approaches to consider in specification

**On length**: Investigations can vary widely. Capture what's needed to fully understand the bug. Don't summarize prematurely — document the trail.

## Structure

**Output**: `.workflows/investigation/{topic}/investigation.md`

Use **[template.md](references/template.md)** for structure:

```markdown
---
topic: {topic}
status: in-progress
work_type: bugfix
date: {YYYY-MM-DD}
---

# Investigation: {Topic}

## Symptoms

### Problem Description
{Expected vs actual behavior}

### Manifestation
{How the bug surfaces - errors, UI issues, etc.}

### Reproduction Steps
1. {Step}
2. {Step}
...

### Environment
{Where it occurs, conditions}

### Impact
{Severity, affected users}

## Analysis

### Code Trace
{Entry points, code paths followed}

### Root Cause
{Clear statement of what causes the bug}

### Contributing Factors
{Conditions that enable the bug}

### Blast Radius
{What else might be affected}

## Fix Direction

### Proposed Approach
{High-level fix direction for specification}

### Alternatives Considered
{Other approaches, why not chosen}

### Testing Gaps
{What testing should be added}
```

## Write to Disk and Commit Frequently

The investigation file is your memory. Context compaction is lossy — what's not on disk is lost.

**Write to the file at natural moments:**

- Symptoms are gathered
- A code path is traced
- Root cause is identified
- Each significant finding

**After writing, git commit.** Commits let you track and recover after compaction. Don't batch — commit each time you write.

**Create the file early.** After understanding the initial symptoms, create the investigation file with frontmatter and symptoms section.

## Concluding an Investigation

When the root cause is identified and documented:

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
Root cause identified. Ready to conclude?

- **`y`/`yes`** — Conclude investigation and proceed to specification
- **`m`/`more`** — Continue investigating (more analysis needed)
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

#### If more

Continue investigation. Ask what aspects need more analysis.

#### If yes

1. Update frontmatter `status: concluded`
2. Final commit
3. Display conclusion:

> *Output the next fenced block as a code block:*

```
Investigation concluded: {topic}

Root cause: {brief summary}
Fix direction: {proposed approach}

The investigation is ready for specification. The specification will
detail the exact fix approach, acceptance criteria, and testing plan.
```

4. Check the investigation frontmatter for `work_type`

**If work_type is set** (bugfix):

This investigation is part of a pipeline. Invoke the `/workflow:bridge` skill:

```
Pipeline bridge for: {topic}
Work type: bugfix
Completed phase: investigation

Invoke the workflow:bridge skill to enter plan mode with continuation instructions.
```

**If work_type is not set:**

The session ends here. The investigation document can be used as input to `/start-specification`.

## Quick Reference

- **Template**: **[template.md](references/template.md)** - Structure
- **Analysis Patterns**: **[analysis-patterns.md](references/analysis-patterns.md)** - Code tracing techniques
- **Symptom Gathering**: **[symptom-gathering.md](references/symptom-gathering.md)** - Interview questions
