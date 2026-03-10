# Topic Completion

*Reference for **[research-session.md](research-session.md)***

---

**Never decide for the user.** Even if the answer seems obvious, flag it and ask.

The current topic is converging — tradeoffs are clear, it's approaching decision territory.

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
- **`c`/`conclude`** — Mark this topic as complete, ready for discussion
- **`k`/`keep`** — Keep digging, there's more to understand
- **`s`/`split`** — Split emerging threads into their own topics first
- Comment — your call
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

#### If the user concludes

Set this topic's research status to completed:

```bash
node .claude/skills/workflow-manifest/scripts/manifest.js set {work_unit} --phase research --topic {topic} status completed
```

Check if ALL research topics are now completed:

```bash
node .claude/skills/workflow-manifest/scripts/manifest.js get {work_unit} --phase research --topic "*" status
```

**If all topics completed**: Invoke the `/workflow-bridge` skill:

```
Pipeline bridge for: {work_unit}
Completed phase: research

Invoke the workflow-bridge skill to enter plan mode with continuation instructions.
```

**STOP.** Do not proceed — terminal condition.

**If some topics still in-progress**:

> *Output the next fenced block as a code block:*

```
Completed: {topic:(titlecase)}

Still in progress:
@foreach(item in remaining_topics)
  • {item.topic:(titlecase)}
@endforeach
```

→ Return to **[research-session.md](research-session.md)** and resume the **Session Loop**.

#### If the user keeps digging

Continue exploring. The convergence signal isn't a stop sign — it's an awareness check. The user might want to stress-test the emerging conclusion, explore edge cases, or understand the problem more deeply before moving on.

→ Return to **[research-session.md](research-session.md)** and resume the **Session Loop**.

#### If the user splits

→ Load **[topic-splitting.md](topic-splitting.md)** and follow its instructions as written.
