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

When you notice convergence signals (loaded in Step 2), flag it and give the user options:

→ Load **[convergence-awareness.md](convergence-awareness.md)** and follow its instructions.

After convergence handling (if the user chooses to keep digging), resume the session loop above.

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
