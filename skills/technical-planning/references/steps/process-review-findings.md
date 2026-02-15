# Process Review Findings

*Reference for **[plan-review](plan-review.md)***

---

Process findings from a review agent interactively with the user. The agent writes findings — with full fix content — to a tracking file. Read the tracking file and present each finding for approval.

#### If STATUS is `clean`

> *Output the next fenced block as a code block:*

```
{Review type} review complete — no findings.
```

→ Return to **[plan-review.md](plan-review.md)** for the next phase.

#### If STATUS is `findings`

Read the tracking file at the path returned by the agent (`TRACKING_FILE`).

→ Proceed to **A. Summary**.

---

## A. Summary

> *Output the next fenced block as a code block:*

```
{Review type} Review — {N} items found

1. {title} ({type or severity}) — {change_type}
   {1-2 line summary from the Details field}

2. ...
```

> *Output the next fenced block as a code block:*

```
Let's work through these one at a time, starting with #1.
```

→ Proceed to **B. Process One Item at a Time**.

---

## B. Process One Item at a Time

Work through each finding **sequentially**. For each finding: present it, show the proposed fix, wait for approval, then apply or skip.

### Present the Finding

Show the finding with its full fix content, read directly from the tracking file:

**Finding {N} of {total}: {Brief Title}**

For traceability findings:
- **Type**: Missing from plan | Hallucinated content | Incomplete coverage
- **Spec Reference**: {from tracking file}
- **Plan Reference**: {from tracking file}
- **Change Type**: {from tracking file}

For integrity findings:
- **Severity**: Critical | Important | Minor
- **Plan Reference**: {from tracking file}
- **Category**: {from tracking file}
- **Change Type**: {from tracking file}

**Details**: {from tracking file}

**Current**:
{from tracking file — the existing plan content, rendered as markdown}

**Proposed**:
{from tracking file — the replacement content, rendered as markdown}

### Ask for Approval

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

Incorporate feedback and re-present the proposed fix **in full**. Update the tracking file with the revised content. Then ask the same choice again. Repeat until approved or skipped.

#### If approved

1. Apply the fix to the plan — use the **Proposed** content exactly as shown, using the output format adapter to determine how it's written. Do not modify content between approval and writing.
2. Update the tracking file: set resolution to "Fixed", add any discussion notes.
3. > *Output the next fenced block as a code block:*

   ```
   Finding {N} of {total}: {Brief Title} — fixed.
   ```

→ Present the next pending finding, or proceed to **C. After All Findings Processed**.

#### If skipped

1. Update the tracking file: set resolution to "Skipped", note the reason.
2. > *Output the next fenced block as a code block:*

   ```
   Finding {N} of {total}: {Brief Title} — skipped.
   ```

→ Present the next pending finding, or proceed to **C. After All Findings Processed**.

---

## C. After All Findings Processed

1. **Mark the tracking file as complete** — Set `status: complete`.
2. **Commit** the tracking file and any plan changes.
3. > *Output the next fenced block as a code block:*

   ```
   {Review type} review complete — {N} findings processed.
   ```

→ Return to **[plan-review.md](plan-review.md)** for the next phase.
