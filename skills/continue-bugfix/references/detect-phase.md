# Detect Phase

*Reference for **[continue-bugfix](../SKILL.md)***

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

5. Check `.workflows/investigation/{topic}/investigation.md`
   - If exists with `status: concluded` → next_phase is **"specification"**
   - If exists with other status → next_phase is **"investigation"**

6. If none found → next_phase is **"unknown"**

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

#### If next_phase is "investigation"

> *Output the next fenced block as a code block:*

```
Investigation In Progress

"{topic:(titlecase)}" has an investigation that is not yet concluded.

Resume the investigation with /start-investigation, or use /start-bugfix
to start a new bugfix from scratch.
```

**STOP.** Do not proceed — terminal condition.

#### If next_phase is "unknown"

> *Output the next fenced block as a code block:*

```
No Artifacts Found

No workflow artifacts found for "{topic}".

Start a new bugfix with /start-bugfix or begin an investigation
with /start-investigation.
```

**STOP.** Do not proceed — terminal condition.
