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

### How to Fire

Read **[agent-review.md](agent-review.md)** and use its content to construct the sub-agent prompt. Fire using the Agent tool with `run_in_background: true`.

Provide the agent with:
1. The full content of agent-review.md as its instructions
2. The discussion file path: `.workflows/{work_unit}/discussion/{topic}.md`
3. The output file path: `.workflows/.cache/{work_unit}/discussion/{topic}/review-{NNN}.md`
4. The frontmatter to use (with `type: review`, `status: pending`, current date, set number)

### Conversational Cue

No announcement needed. The review agent fires silently in the background. Its findings are surfaced later via the findings integration process.

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
2. Read **[agent-perspective.md](agent-perspective.md)** and use its content to construct each sub-agent prompt.
3. Fire each perspective agent using the Agent tool with `run_in_background: true`.
4. Provide each agent with:
   - The full content of agent-perspective.md as its instructions
   - The assigned perspective/angle to advocate
   - The decision topic being explored
   - The discussion file path for context
   - The output file path: `.workflows/.cache/{work_unit}/discussion/{topic}/perspective-{NNN}-{angle}.md`
   - The frontmatter to use

### After Perspective Agents Return

When all perspective agents in a set have completed, automatically fire the synthesis agent:

1. Read **[agent-synthesis.md](agent-synthesis.md)** and use its content to construct the prompt.
2. Fire using the Agent tool with `run_in_background: true`.
3. Provide:
   - The full content of agent-synthesis.md as its instructions
   - The paths to all perspective files in this set
   - The output file path: `.workflows/.cache/{work_unit}/discussion/{topic}/synthesis-{NNN}.md`
   - The frontmatter to use

### Conversational Cue

After firing perspective agents:

> "I've kicked off {N} perspective agents to explore {brief description of the angles}. While they work — {natural transition to another topic or continuation of current discussion}."

---

## In-Flight Tracking

Track dispatched agents by their background task status. When checking whether agents are in flight or completed, check the background task notifications. When an agent completes, its output file will exist in the cache directory with `status: pending`.

→ Return to caller.
