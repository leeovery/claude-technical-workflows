# Process Review Findings

*Reference for **[plan-review](plan-review.md)***

---

Process findings from a review agent interactively with the user. The agent writes findings — with full fix content — to a tracking file. Read the tracking file and present each finding for approval.

**Review type**: `{review_type:[traceability|integrity]}` — set by the calling context (B or C in plan-review.md).

#### If `STATUS` is `clean`

> *Output the next fenced block as a code block:*

```
{Review type} review complete — no findings.
```

→ Return to caller.

#### If `STATUS` is `findings`

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

Work through each finding **sequentially**. For each finding: present it, show the proposed fix, then route through the gate.

### Present Finding

Show the finding metadata, read directly from the tracking file:

> *Output the next fenced block as markdown (not a code block):*

```
**Finding {N} of {total}: {Brief Title}**

@if(review_type = traceability)
- **Type**: Missing from plan | Hallucinated content | Incomplete coverage
- **Spec Reference**: {from tracking file}
- **Plan Reference**: {from tracking file}
- **Change Type**: {from tracking file}
@else
- **Severity**: Critical | Important | Minor
- **Plan Reference**: {from tracking file}
- **Category**: {from tracking file}
- **Change Type**: {from tracking file}
@endif

**Details**: {from tracking file}
```

Then present the content based on **Change Type**:

**If Change Type is `update-task`, `add-to-task`, or `remove-from-task`:**

Present the changes as a diff. Read Current and Proposed from the tracking file. Show only the changed lines with 2 lines of context above and below:

> *Output the next fenced block as a code block:*

```
╭─ Finding {N}: {Brief Title} ──────────────────────╮
```

> *Output the next fenced block as a code block:*

```diff
 {2 context lines above}
-{lines from Current}
+{lines from Proposed}
 {2 context lines below}
```

> *Output the next fenced block as a code block:*

```
╰───────────────────────────────────────────────────╯
```

**If Change Type is `add-task`, `add-phase`, `remove-task`, or `remove-phase`:**

Present full content from the tracking file. Include **Proposed** for additions, **Current** for removals — as written by the review agent:

> *Output the next fenced block as markdown (not a code block):*

```
@if(Change Type is add-task or add-phase)
**Proposed**:
{from tracking file — the new content}
@else
**Current**:
{from tracking file — the content being removed}
@endif
```

### Check Gate Mode

Check `finding_gate_mode` via manifest CLI:
```bash
node .claude/skills/workflow-manifest/scripts/manifest.cjs get {work_unit}.planning.{topic} finding_gate_mode
```

#### If `finding_gate_mode: auto`

1. Apply the fix to the plan (use **Proposed** content exactly as in tracking file)
2. Update the tracking file: set resolution to "Fixed"
3. Commit the tracking file and plan changes

> *Output the next fenced block as a code block:*

```
Finding {N} of {total}: {Brief Title} — approved. Applied to plan.
```

→ Present the next pending finding, or proceed to **C. After All Findings Processed**.

#### If `finding_gate_mode: gated`

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
**Finding {N} of {total}: {Brief Title}**

- **`y`/`yes`** — Apply to the plan verbatim
@if(Change Type is update-task, add-to-task, or remove-from-task)
- **`v`/`view full`** — Show full Current and Proposed content
@endif
- **`a`/`auto`** — Approve this and all remaining findings automatically
- **`s`/`skip`** — Leave as-is, move to next finding
- **Provide feedback** — Adjust before approving
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

#### If `view full`

Re-present the finding's **Current** and **Proposed** content in full from the tracking file. Then re-present the approval menu.

→ Return to **B. Process One Item at a Time**.

#### If the user provides feedback

Incorporate feedback and update the tracking file with the revised content. Re-present the finding using the same presentation format (diff or full) as the original.

→ Return to **B. Process One Item at a Time**.

#### If `approved`

1. Apply the fix to the plan — use the **Proposed** content exactly as shown, using the output format adapter to determine how it's written. Do not modify content between approval and writing.
2. Update the tracking file: set resolution to "Fixed", add any discussion notes.
3. Commit the tracking file and any plan changes — ensures progress survives context refresh.
4. > *Output the next fenced block as a code block:*

   ```
   Finding {N} of {total}: {Brief Title} — fixed.
   ```

→ Present the next pending finding, or proceed to **C. After All Findings Processed**.

#### If `auto`

1. Apply the fix (same as "If approved" above)
2. Update the tracking file: set resolution to "Fixed"
3. Update `finding_gate_mode` in the manifest:
   ```bash
   node .claude/skills/workflow-manifest/scripts/manifest.cjs set {work_unit}.planning.{topic} finding_gate_mode auto
   ```
4. Commit
5. Process all remaining findings using the auto-mode flow above

→ After all processed, proceed to **C. After All Findings Processed**.

#### If `skipped`

1. Update the tracking file: set resolution to "Skipped", note the reason.
2. Commit the tracking file — ensures progress survives context refresh.
3. > *Output the next fenced block as a code block:*

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

→ Return to caller.
