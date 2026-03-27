# Discussion Session

*Reference for **[workflow-discussion-process](../SKILL.md)***

---

## Findings Integration

Load **[findings-integration.md](findings-integration.md)** — these rules govern how to check for and surface completed agent findings. Apply them throughout the session.

---

## Session Loop

The discussion is a conversation. Follow this loop:

1. **Check for findings** — At natural conversational breaks, check for completed agent findings per the findings integration rules. Skip on the first iteration (no agents have been dispatched yet).
2. **Discuss** — Engage with the user on the current question or topic. Challenge thinking, push back, explore edge cases. Participate as an expert architect.
3. **Document** — At natural pauses, update the discussion file with decisions, debates, options explored, and rationale. Use the per-question structure from the template (Context → Options → Journey → Decision).
4. **Commit** — Git commit after each write. Don't batch.
5. **Consider agents** — After each substantive commit, evaluate:

   **Periodic review**: Fire a review agent if ALL of these conditions are met:
   - The commit added meaningful content (a decision, a question explored, options analysed — not a typo fix or reformatting)
   - No review agent is currently in flight
   - This is not the first commit (the discussion needs enough content to review)
   - At least 2-3 conversational exchanges have passed since the last review dispatch

   If conditions are met → Load **[invoke-review-agent.md](invoke-review-agent.md)** and follow its instructions as written.

   **Perspectives**: If a decision point with genuine ambiguity has emerged — two or more viable approaches where the tradeoffs are not obvious — offer perspective agents to the user. Signals: multiple defensible approaches with no clear winner, user expressing uncertainty, competing paradigms in the domain, explicit disagreement.

   If ambiguity detected → Load **[invoke-perspective-agents.md](invoke-perspective-agents.md)** and follow its instructions as written.

6. **Repeat** — Continue with the next question or follow where the conversation leads.

---

## Per-Question Approach

**Per-question structure** keeps the reasoning contextual. Options considered, false paths, debates, and "aha" moments belong with the specific question they relate to - not as separate top-level sections. This preserves the journey alongside the decision.

Work through questions one at a time. For each:

- Explore options and trade-offs
- Capture the journey — false paths, debates, what changed thinking
- Document the decision and rationale when reached
- Check off completed questions in the Questions list

---

## When the User Signals Conclusion

When the user indicates they want to conclude the discussion (e.g., "that covers it", "let's wrap up", "I think we're done"):

Check for in-flight agents. If agents are still running:

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
There are still {N} background agents working.

- **`w`/`wait`** — Wait for results before concluding
- **`p`/`proceed`** — Conclude now (results will persist in cache for reference)
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

#### If `wait`

Check for agent completion. When all agents have returned, integrate their findings per the findings integration rules.

→ Return to **Session Loop**.

#### If `proceed`

→ Return to caller.

#### If no agents are in flight

→ Return to caller.
