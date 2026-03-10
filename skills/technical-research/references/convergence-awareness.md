# Convergence Awareness

*Reference for **[research-session.md](research-session.md)***

---

**Never decide for the user.** Even if the answer seems obvious, flag it and ask.

Two types of convergence can occur during epic research:

## Topic Splitting

Threads in the current file could be their own research topics — they have different scopes, stakeholders, or timelines.

Offer to extract them:

> *Output the next fenced block as a code block:*

```
I've noticed distinct threads emerging that could be their own research topics:

  • {thread_1} — {brief description}
  • {thread_2} — {brief description}

Want to split these into separate research files?
```

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
- **`y`/`yes`** — Split them out
- **`n`/`no`** — Keep everything together for now
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

#### If yes

For each split topic:
1. Create `.workflows/{work_unit}/research/{topic}.md` using **[template.md](template.md)**
2. Move content verbatim from the source file — reword only for flow and readability, no summarisation
3. Remove the extracted content from the source file
4. Init manifest item for the new topic:
   ```bash
   node .claude/skills/workflow-manifest/scripts/manifest.js init-phase {work_unit} --phase research --topic {topic}
   ```
5. Set status to in-progress:
   ```bash
   node .claude/skills/workflow-manifest/scripts/manifest.js set {work_unit} --phase research --topic {topic} status in-progress
   ```

Commit after splitting.

Ask which topic to continue with (including staying in the current file).

**STOP.** Wait for user response.

→ Return to **[research-session.md](research-session.md)**.

## Topic Completion

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

→ Return to **[research-session.md](research-session.md)**.

#### If the user keeps digging

Continue exploring. The convergence signal isn't a stop sign — it's an awareness check. The user might want to stress-test the emerging conclusion, explore edge cases, or understand the problem more deeply before moving on. That's valid research work.

→ Return to **[research-session.md](research-session.md)**.

#### If the user splits

→ Proceed to **Topic Splitting** above.
