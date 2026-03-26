# Discussion Session

*Reference for **[workflow-discussion-process](../SKILL.md)***

---

## Agent Infrastructure

Load **[agent-dispatch.md](agent-dispatch.md)** — these rules govern when to fire background agents during the session. Apply them throughout.

Load **[findings-integration.md](findings-integration.md)** — these rules govern how to process and surface completed agent findings. Apply them throughout.

## Session Loop

The discussion is a conversation. Follow this loop:

1. **Check for findings** — At natural breaks, check for completed agent findings in the cache directory. If pending findings exist, integrate them per the findings integration rules. This step is lightweight — a quick scan, not a deep read. Skip on the first iteration (no agents have been dispatched yet).
2. **Discuss** — Engage with the user on the current question or topic. Challenge thinking, push back, explore edge cases. Participate as an expert architect.
3. **Document** — At natural pauses, update the discussion file with decisions, debates, options explored, and rationale. Use the per-question structure from the template (Context → Options → Journey → Decision).
4. **Commit** — Git commit after each write. Don't batch.
5. **Consider dispatch** — After each substantive commit, evaluate the agent dispatch rules. Fire a review agent if conditions are met. If a decision point with genuine ambiguity has emerged, offer perspective agents to the user.
6. **Repeat** — Continue with the next question or follow where the conversation leads.

## Per-Question Approach

**Per-question structure** keeps the reasoning contextual. Options considered, false paths, debates, and "aha" moments belong with the specific question they relate to - not as separate top-level sections. This preserves the journey alongside the decision.

Work through questions one at a time. For each:

- Explore options and trade-offs
- Capture the journey — false paths, debates, what changed thinking
- Document the decision and rationale when reached
- Check off completed questions in the Questions list

## When the User Signals Conclusion

When the user indicates they want to conclude the discussion (e.g., "that covers it", "let's wrap up", "I think we're done"):

Check for in-flight agents. If agents are still running, inform the user and let them decide whether to wait or proceed (per findings integration rules).

→ Return to caller.
