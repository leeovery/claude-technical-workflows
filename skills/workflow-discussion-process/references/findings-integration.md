# Findings Integration

*Reference for **[workflow-discussion-process](../SKILL.md)***

---

Rules for how the orchestrator processes completed agent findings and weaves them back into the discussion. Apply these throughout the discussion session.

## Checking for Findings

Scan the discussion cache directory for files with `status: pending` in their frontmatter:

```
.workflows/.cache/{work_unit}/discussion/{topic}/
```

Check at **natural conversational breaks** — after completing a topic, when transitioning between questions, or when there's a pause. Do not interrupt mid-exchange to check. Do not check after every single exchange — use judgment.

### Perspective Completion Detection

When checking for findings, also check whether all perspective agents in a set have completed but no synthesis file exists for that set. If so:

→ Load **[invoke-perspective-agents.md](invoke-perspective-agents.md)** for **C. Dispatch Synthesis Agent**.

After the synthesis agent is dispatched, continue checking for findings normally. The synthesis file will appear in the cache with `status: pending` when the agent completes.

### Priority

If a synthesis file is pending, prioritise it over individual perspective files. If only perspective files are pending (synthesis not yet complete), wait for the synthesis.

Review files can be surfaced independently at any time.

---

## Surfacing Review Findings

When a review agent's findings are pending:

1. Read the review file
2. Update its frontmatter to `status: read`
3. Assess the findings — which gaps and questions are genuinely valuable?
4. At a natural break, surface relevant findings conversationally

**Do not dump the review output verbatim.** Digest it and derive questions. The review surfaces gaps — you turn gaps into productive discussion.

Example phrasing — adapt naturally:

> "A background review flagged a couple of gaps worth considering: we haven't touched on what happens when {X fails}, and the caching decision assumed {Y} but we haven't validated that. Want to explore either of those?"

If all findings from a review are minor or already addressed:

> "A background review came back — nothing we haven't already covered."

---

## Surfacing Perspective and Synthesis Findings

When a synthesis file is pending (meaning all perspectives + synthesis are complete):

1. Read the synthesis file (and perspective files if needed for detail)
2. Update all files in the set to `status: read`
3. Present the tradeoff landscape conversationally

> *Output the next fenced block as a code block:*

```
Perspective analysis complete: {decision topic}

{N} perspectives explored. {M} key tensions identified.
```

Then summarise the key tensions, strongest arguments, and decision criteria conversationally. The user can ask for more detail on any perspective.

**Do not read out the full perspective files.** Surface the tradeoff landscape — what's at stake, what the decision hinges on.

---

## Deriving Questions

The most valuable output from agent findings is **new questions for the discussion**. When integrating findings:

1. Extract the most impactful gaps, open questions, and decision criteria
2. Reframe them as questions for the user — practical questions tied to the project's constraints, not academic ones
3. Add unresolved questions to the discussion file's Questions list (as unchecked items)
4. Commit the update

---

## Marking as Incorporated

After findings have been discussed and their questions explored (or deliberately set aside):

1. Update the file frontmatter to `status: incorporated`
2. No commit needed for cache file status changes — these are scratch files

→ Return to caller.
