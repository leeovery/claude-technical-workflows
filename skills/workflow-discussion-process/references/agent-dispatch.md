# Agent Dispatch

*Reference for **[workflow-discussion-process](../SKILL.md)***

---

Rules for firing background agents during the discussion session. These agents run in the background — they do not block the conversation. The orchestrator continues discussing with the user while agents work.

## Cache Convention

All agent output is written to the discussion cache directory:

```
.workflows/.cache/{work_unit}/discussion/{topic}/
```

Ensure this directory exists before dispatching any agent.

### File Naming

| Agent type | Pattern | Example |
|-----------|---------|---------|
| Review | `review-{NNN}.md` | `review-001.md` |
| Perspective | `perspective-{NNN}-{angle}.md` | `perspective-001-event-sourcing.md` |
| Synthesis | `synthesis-{NNN}.md` | `synthesis-001.md` |

The `{NNN}` counter is shared across all types and increments with each dispatch set. A dispatch set is one logical trigger — a periodic review is one set, a perspective round (multiple agents + synthesis) is one set. Use the next available number by checking existing files in the cache directory.

### Frontmatter

Every agent output file uses this frontmatter:

```yaml
---
type: review | perspective | synthesis
status: pending
created: {date}
set: {NNN}
perspective: {angle}  # perspective type only
decision: {topic}     # perspective and synthesis types only
---
```

Status values: `pending` → `read` → `incorporated`. Only the orchestrator updates status — agents always write `pending`.

---

## Periodic Review Agent

### When to Fire

Fire a review agent after a **substantive commit** to the discussion file — a commit that adds meaningful content (a decision documented, a question explored, options analysed). Do not fire after minor commits (typo fixes, reformatting, checklist updates).

**Guardrails:**
- Do not fire if a review agent is already in flight (check for running background agents)
- Do not fire on the first commit (the discussion needs enough content to review)
- Do not fire on consecutive commits — allow at least 2-3 conversational exchanges between reviews
- Maximum one review agent in flight at any time

### How to Dispatch

**Agent path**: `../../../agents/workflow-discussion-review.md`

Dispatch **one agent** via the Task tool with `run_in_background: true`.

The review agent receives:

1. **Discussion file path** — `.workflows/{work_unit}/discussion/{topic}.md`
2. **Output file path** — `.workflows/.cache/{work_unit}/discussion/{topic}/review-{NNN}.md`
3. **Frontmatter** — the frontmatter block to write (with `type: review`, `status: pending`, current date, set number)

No CHECKPOINT — the agent runs in the background.

### Conversational Cue

No announcement needed. The review agent fires silently. Its findings are surfaced later via the findings integration process.

### Expected Result

The review agent returns:

```
STATUS: gaps_found | clean
GAPS_COUNT: {N}
QUESTIONS_COUNT: {N}
SUMMARY: {1 sentence}
```

The full analysis is at the output file path.

---

## Perspective Agents

### When to Fire

Fire perspective agents when the orchestrator identifies a decision point with **genuine ambiguity** — two or more viable approaches where the tradeoffs are not obvious. Signals:

- Multiple defensible approaches with no clear winner
- The user expresses uncertainty ("I'm not sure which...", "they both seem fine")
- The domain has known competing paradigms (e.g., relational vs document, monolith vs microservices, sync vs async)
- Explicit disagreement between orchestrator and user on the best approach
- The user or orchestrator suggests exploring perspectives

**Do not fire when:**
- The decision is straightforward with a clear best answer
- The tradeoffs are already well understood
- The user has already made a confident decision

### How to Offer

Perspective agents should be offered conversationally, not fired silently:

> "There are a few genuinely different ways to approach this. Want me to spin up some perspective agents to dig deeper while we continue discussing other things?"

If the user agrees, or if the orchestrator judges the ambiguity is significant enough:

1. Identify 2-3 distinct perspectives worth exploring. Each should be a genuinely defensible position, not a strawman.

### How to Dispatch

**Agent path**: `../../../agents/workflow-discussion-perspective.md`

Dispatch **all perspective agents in parallel** via the Task tool with `run_in_background: true`.

Each perspective agent receives:

1. **Perspective** — the specific angle to advocate
2. **Decision topic** — the decision being explored
3. **Discussion file path** — `.workflows/{work_unit}/discussion/{topic}.md`
4. **Output file path** — `.workflows/.cache/{work_unit}/discussion/{topic}/perspective-{NNN}-{angle}.md`
5. **Frontmatter** — the frontmatter block to write (with `type: perspective`, `status: pending`, current date, set number, perspective name, decision topic)

No CHECKPOINT — agents run in the background.

### Conversational Cue

After firing perspective agents:

> "I've kicked off {N} perspective agents to explore {brief description of the angles}. While they work — {natural transition to another topic or continuation of current discussion}."

### Expected Result

Each perspective agent returns:

```
STATUS: complete
PERSPECTIVE: {angle}
SUMMARY: {1 sentence}
```

---

## Synthesis Agent

### When to Fire

Fire the synthesis agent **automatically** when all perspective agents in a set have completed.

### How to Dispatch

**Agent path**: `../../../agents/workflow-discussion-synthesis.md`

Dispatch **one agent** via the Task tool with `run_in_background: true`.

The synthesis agent receives:

1. **Perspective file paths** — paths to all perspective files in this set
2. **Decision topic** — the decision being explored
3. **Output file path** — `.workflows/.cache/{work_unit}/discussion/{topic}/synthesis-{NNN}.md`
4. **Frontmatter** — the frontmatter block to write (with `type: synthesis`, `status: pending`, current date, set number, decision topic)

No CHECKPOINT — the agent runs in the background.

### Expected Result

The synthesis agent returns:

```
STATUS: complete
DECISION: {topic}
TENSIONS: {N}
SUMMARY: {1-2 sentences}
```

---

## In-Flight Tracking

Track dispatched agents by their background task status. When checking whether agents are in flight or completed, check the background task notifications. When an agent completes, its output file will exist in the cache directory with `status: pending`.

→ Return to caller.
