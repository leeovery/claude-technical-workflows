# Invoke Review Agent

*Reference for **[workflow-discussion-process](../SKILL.md)***

---

This step dispatches a `workflow-discussion-review` agent in the background to assess discussion quality. The agent reads the discussion file fresh (no prior context) and writes its findings to the cache directory. The discussion continues while the agent works.

---

## Cache Setup

Ensure the cache directory exists:

```bash
mkdir -p .workflows/.cache/{work_unit}/discussion/{topic}
```

Determine the next set number by checking existing files:

```bash
ls .workflows/.cache/{work_unit}/discussion/{topic}/ 2>/dev/null
```

Use the next available `{NNN}` (zero-padded, e.g., `001`, `002`).

---

## Dispatch the Agent

**Agent path**: `../../../agents/workflow-discussion-review.md`

Dispatch **one agent** via the Task tool with `run_in_background: true`.

The review agent receives:

1. **Discussion file path** — `.workflows/{work_unit}/discussion/{topic}.md`
2. **Output file path** — `.workflows/.cache/{work_unit}/discussion/{topic}/review-{NNN}.md`
3. **Frontmatter** — the frontmatter block to write:
   ```yaml
   ---
   type: review
   status: pending
   created: {date}
   set: {NNN}
   ---
   ```

---

## Announcement

> *Output the next fenced block as a code block:*

```
Background review dispatched. Results will be surfaced when available.
```

The discussion continues — do not wait for the agent to return.

---

## Expected Result

The review agent returns:

```
STATUS: gaps_found | clean
GAPS_COUNT: {N}
QUESTIONS_COUNT: {N}
SUMMARY: {1 sentence}
```

The full analysis is at the output file path. Findings are processed by the orchestrator via the findings integration rules.

→ Return to caller.
