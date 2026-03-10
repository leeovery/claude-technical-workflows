# Research Session

*Reference for **[technical-research](../SKILL.md)***

---

## Session Loop

Research is a conversation. Follow this loop:

1. **Ask** — Pose a question to the user, probing the topic from a relevant angle
2. **Discuss** — Engage with the answer, challenge assumptions, explore implications
3. **Document** — Update the research file with insights, findings, and open questions
4. **Commit** — Git commit after each write. Don't batch.
5. **Repeat** — Continue with the next question or follow where the conversation leads

## Session Completion

Read `work_type` from the manifest:

```bash
node .claude/skills/workflow-manifest/scripts/manifest.js get {work_unit} work_type
```

#### If work_type is `epic`

**Topic awareness**: When working in a specific topic file and content drifts to another topic's scope, flag it and offer to switch to that topic's file or note it for later. Don't silently let content accumulate in the wrong file.

When you notice convergence signals (loaded in Step 3), flag it and route to the appropriate action:

**If threads are emerging as distinct topics** (different scopes, stakeholders, or timelines):

→ Load **[topic-splitting.md](topic-splitting.md)** and follow its instructions as written.

**If the current topic is converging** (tradeoffs clear, approaching decision territory):

→ Load **[topic-completion.md](topic-completion.md)** and follow its instructions as written.

After handling, both reference files route back to the **Session Loop** when appropriate.

#### If work_type is `feature`

When the topic feels well-explored or the user indicates they're done:

1. Set research status to completed:
   ```bash
   node .claude/skills/workflow-manifest/scripts/manifest.js set {work_unit} --phase research --topic {topic} status completed
   ```
2. Invoke the `/workflow-bridge` skill:
   ```
   Pipeline bridge for: {work_unit}
   Completed phase: research

   Invoke the workflow-bridge skill to enter plan mode with continuation instructions.
   ```

**STOP.** Do not proceed — terminal condition.
