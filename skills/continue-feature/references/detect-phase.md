# Detect Phase

*Reference for **[continue-feature](../SKILL.md)***

---

Determine the next phase for the selected topic using its artifact state.

## Phase Detection

Either use the `next_phase` from discovery output (if discovery was run), or compute it by checking artifacts directly:

### If discovery was not run (topic provided by caller)

Check artifacts in this order (first match wins):

1. Check `.workflows/review/{topic}/r*/review.md`
   - If any review exists → next_phase is **"done"**

2. Read `.workflows/implementation/{topic}/tracking.md`
   - If exists with `status: completed` → next_phase is **"review"**
   - If exists with `status: in-progress` → next_phase is **"implementation"**

3. Read `.workflows/planning/{topic}/plan.md`
   - If exists with `status: concluded` → next_phase is **"implementation"**
   - If exists with other status → next_phase is **"planning"**

4. Read `.workflows/specification/{topic}/specification.md`
   - If exists with `status: concluded` → next_phase is **"planning"**
   - If exists with other status → next_phase is **"specification"**

5. Check `.workflows/discussion/{topic}.md`
   - If exists with `status: concluded` → next_phase is **"specification"**
   - If exists with other status → next_phase is **"discussion_in_progress"**

6. Check `.workflows/research/{topic}.md`
   - If exists with `status: concluded` → next_phase is **"discussion"** (research done, ready for discussion)
   - If exists with other status → next_phase is **"research"** (research in progress)

7. If none found → next_phase is **"unknown"**

## Routing

#### If next_phase is "specification"

→ Proceed to **Step 3**.

#### If next_phase is "planning"

→ Proceed to **Step 4**.

#### If next_phase is "implementation"

→ Proceed to **Step 5**.

#### If next_phase is "review"

→ Proceed to **Step 6**.

#### If next_phase is "done"

> *Output the next fenced block as a code block:*

```
Pipeline Complete

"{topic:(titlecase)}" has completed all pipeline phases
(implementation and review).

Use /start-review to re-review or synthesize findings.
```

**STOP.** Do not proceed — terminal condition.

#### If next_phase is "discussion" (research concluded, needs discussion)

The topic has completed research and is ready to start discussion.

→ Proceed to **Step 2a** (invoke begin-discussion).

#### If next_phase is "discussion_in_progress"

> *Output the next fenced block as a code block:*

```
Discussion In Progress

"{topic:(titlecase)}" has a discussion that is not yet concluded.

Resume the discussion with /start-discussion, or use /start-feature
to start a new feature from scratch.
```

**STOP.** Do not proceed — terminal condition.

#### If next_phase is "research"

> *Output the next fenced block as a code block:*

```
Research In Progress

"{topic:(titlecase)}" has research that is not yet concluded.

Resume the research by invoking technical-research for this topic.
```

**STOP.** Do not proceed — terminal condition.

#### If next_phase is "unknown"

> *Output the next fenced block as a code block:*

```
No Artifacts Found

No workflow artifacts found for "{topic}".

Start a new feature with /start-feature or begin a discussion
with /start-discussion.
```

**STOP.** Do not proceed — terminal condition.
