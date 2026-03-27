# Invoke Perspective Agents

*Reference for **[workflow-discussion-process](../SKILL.md)***

---

This step handles perspective exploration for contentious decisions. Perspective agents argue for distinct approaches in the background, then a synthesis agent reconciles them. The discussion continues while agents work.

Sections A and B handle the initial offer and dispatch. Section C handles synthesis dispatch — it is invoked separately when perspectives complete.

---

## A. Offer Perspectives

Identify 2-3 distinct perspectives worth exploring. Each should be a genuinely defensible position, not a strawman.

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
This decision has {N} genuinely viable approaches. Want to explore them in depth?

- **`y`/`yes`** — Spin up perspective agents to argue each position
- **`n`/`no`** — Continue without perspectives
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

#### If `no`

→ Return to caller.

#### If `yes`

→ Proceed to **B. Dispatch Perspective Agents**.

---

## B. Dispatch Perspective Agents

### Cache Setup

Ensure the cache directory exists:

```bash
mkdir -p .workflows/.cache/{work_unit}/discussion/{topic}
```

Determine the next set number by checking existing files:

```bash
ls .workflows/.cache/{work_unit}/discussion/{topic}/ 2>/dev/null
```

Use the next available `{NNN}` (zero-padded, e.g., `001`, `002`). All agents in this set share the same `{NNN}`.

### Dispatch

**Agent path**: `../../../agents/workflow-discussion-perspective.md`

Dispatch **all perspective agents in parallel** via the Task tool with `run_in_background: true`.

Each perspective agent receives:

1. **Perspective** — the specific angle to advocate
2. **Decision topic** — the decision being explored
3. **Discussion file path** — `.workflows/{work_unit}/discussion/{topic}.md`
4. **Output file path** — `.workflows/.cache/{work_unit}/discussion/{topic}/perspective-{NNN}-{angle}.md`
5. **Frontmatter** — the frontmatter block to write:
   ```yaml
   ---
   type: perspective
   status: pending
   created: {date}
   set: {NNN}
   perspective: {angle}
   decision: {decision topic}
   ---
   ```

### Announcement

> *Output the next fenced block as a code block:*

```
Dispatched {N} perspective agents: {angle1}, {angle2}, {angle3}.
Results will be surfaced when available.
```

### Expected Result

Each perspective agent returns:

```
STATUS: complete
PERSPECTIVE: {angle}
SUMMARY: {1 sentence}
```

The discussion continues — do not wait for agents to return.

→ Return to caller.

---

## C. Dispatch Synthesis Agent

This section is invoked when all perspective agents in a set have completed. The synthesis agent reconciles their findings into a tradeoff landscape.

### Dispatch

**Agent path**: `../../../agents/workflow-discussion-synthesis.md`

Dispatch **one agent** via the Task tool with `run_in_background: true`.

The synthesis agent receives:

1. **Perspective file paths** — paths to all perspective files in this set
2. **Decision topic** — the decision being explored
3. **Output file path** — `.workflows/.cache/{work_unit}/discussion/{topic}/synthesis-{NNN}.md`
4. **Frontmatter** — the frontmatter block to write:
   ```yaml
   ---
   type: synthesis
   status: pending
   created: {date}
   set: {NNN}
   decision: {decision topic}
   ---
   ```

### Expected Result

The synthesis agent returns:

```
STATUS: complete
DECISION: {topic}
TENSIONS: {N}
SUMMARY: {1-2 sentences}
```

The discussion continues — do not wait for the agent to return. Synthesis findings are surfaced by the orchestrator via the findings integration rules.

→ Return to caller.
