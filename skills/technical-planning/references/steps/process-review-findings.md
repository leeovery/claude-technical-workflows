# Process Review Findings

*Reference for **[plan-review](plan-review.md)***

---

After receiving findings from a review agent, process them interactively with the user. This process is the same for both traceability and integrity reviews.

---

## If STATUS is `clean`

No findings. Announce:

"{Review type} review complete — no findings."

→ Return to **[plan-review.md](plan-review.md)** for the next phase.

---

## If STATUS is `findings`

### Stage 1: Summary

Present all findings as a numbered summary:

"I've completed the {review type} review. {N} items found:

1. **{title}** ({type or severity})
   {2-4 line explanation: what's wrong, where, why it matters}

2. **{title}** ({type or severity})
   {2-4 line explanation}

Let's work through these one at a time, starting with #1."

---

### Stage 2: Process One Item at a Time

Work through each finding **sequentially**. For each finding: present it, propose the fix, wait for approval, then apply it.

#### Present the Finding

Show the finding with full detail:

**Finding {N} of {total}: {Brief Title}**

For traceability findings:
- **Type**: Missing from plan | Hallucinated content | Incomplete coverage
- **Spec Reference**: {section/decision in specification, or "N/A"}
- **Plan Reference**: {phase/task in plan, or "N/A"}

For integrity findings:
- **Severity**: Critical | Important | Minor
- **Plan Reference**: {phase/task in plan}
- **Category**: {which review criterion}

**Details**: {what's wrong and why it matters}

#### Propose the Fix

Present the proposed fix **in the format it will be written to the plan**, rendered as markdown (not in a code block). What the user sees is what gets applied — no changes between approval and writing.

State the action type explicitly so the user knows what's changing structurally:

**Update a task** — change content within an existing task:

**Proposed fix — update Phase {N}, Task {M}:**

**Current:**
{The existing content as it appears in the plan}

**Proposed:**
{The replacement content}

**Add content to a task** — insert into an existing task:

**Proposed fix — add to Phase {N}, Task {M}, {section}:**

{The exact content to be added, in plan format}

**Remove content from a task** — strip content that shouldn't be there:

**Proposed fix — remove from Phase {N}, Task {M}, {section}:**

{The exact content to be removed}

**Add a new task** — a spec section has no plan coverage:

**Proposed fix — add new task to Phase {N}:**

{The complete task in plan format, using the task template}

**Remove a task** — an entire task is not backed by the specification:

**Proposed fix — remove Phase {N}, Task {M}: {Task Name}**

**Reason**: {Why this task should be removed}

**Add a new phase** — a significant area has no plan coverage:

**Proposed fix — add new Phase {N}: {Phase Name}**

{Phase goal, acceptance criteria, and task overview}

**Remove a phase** — an entire phase is not backed by the specification:

**Proposed fix — remove Phase {N}: {Phase Name}**

**Reason**: {Why this phase should be removed}

#### Ask for Approval

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
**Finding {N} of {total}: {Brief Title}**
- **`y`/`yes`** — Approved. Apply to the plan verbatim.
- **`s`/`skip`** — Leave as-is, move to next finding.
- **Or provide feedback** to adjust the fix.
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

#### If the user provides feedback

Incorporate feedback and re-present the proposed fix **in full** using the same format above. Then ask the same choice again. Repeat until approved or skipped.

#### If approved

1. Apply the fix to the plan — as presented, using the output format adapter to determine how it's written. Do not modify content between approval and writing.
2. Update the tracking file: mark resolution as "Fixed", add any discussion notes.
3. Confirm: "Finding {N} of {total}: {Brief Title} — fixed."

#### If skipped

1. Update the tracking file: mark resolution as "Skipped", note the reason.
2. Confirm: "Finding {N} of {total}: {Brief Title} — skipped."

---

### After All Findings Processed

1. **Mark the tracking file as complete** — Set `status: complete`. Do not delete it; it persists as review history.
2. **Commit** the tracking file and any plan changes. This ensures progress survives context refresh.
3. Announce: "{Review type} review complete — {N} findings processed."

→ Return to **[plan-review.md](plan-review.md)** for the next phase.
