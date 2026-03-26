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

If a synthesis file is pending, prioritise it over individual perspective files. If only perspective files are pending (synthesis not yet complete), wait for the synthesis.

Review files can be surfaced independently at any time.

## Surfacing Findings

### Review Findings

When a review agent's findings are pending:

1. Read the review file
2. Update its frontmatter to `status: read`
3. Assess the findings — which gaps and questions are genuinely valuable?
4. At a natural break, surface relevant findings conversationally

**Do not dump the review output verbatim.** Digest it and derive questions. The review surfaces gaps — you turn gaps into productive discussion.

Example flow:

> "By the way — I ran a background review of our discussion so far. A couple of things worth considering: we haven't touched on what happens when {X fails}, and the caching decision assumed {Y} but we haven't validated that. Want to explore either of those?"

If all findings from a review are minor or already addressed, note it briefly and move on:

> "A background review came back — nothing we haven't already covered."

### Perspective and Synthesis Findings

When a synthesis file is pending (meaning all perspectives + synthesis are complete):

1. Read the synthesis file (and perspective files if needed for detail)
2. Update all files in the set to `status: read`
3. Present a conversational summary of the tradeoff landscape

Example flow:

> "The perspective agents on {decision topic} are back. Here's where they landed:
>
> The core tension is between {X} and {Y}. {Angle A} argues {summary}. {Angle B} makes a strong case for {summary}. The synthesis highlights that if we prioritise {priority}, we'd lean toward {approach}.
>
> A few questions came out of it: {question 1}? {question 2}?
>
> What's your instinct?"

**Do not read out the full perspective files.** Summarise the key tensions, strongest arguments, and decision criteria. The user can ask for more detail on any perspective if they want it.

## Deriving Questions

The most valuable output from agent findings is **new questions for the discussion**. When integrating findings:

1. Extract the most impactful gaps, open questions, and decision criteria
2. Reframe them as questions for the user — not academic questions but practical ones tied to the project's constraints
3. Add unresolved questions to the discussion file's Questions list (as unchecked items)
4. Commit the update

## Marking as Incorporated

After findings have been discussed and their questions explored (or deliberately set aside):

1. Update the file frontmatter to `status: incorporated`
2. No commit needed for cache file status changes — these are scratch files

## When the User Signals Conclusion

If agents are still in flight when the user wants to conclude:

> "There are still {N} background agents working. Want to wait for their results, or proceed to conclude?"

If the user proceeds, the in-flight agents will still write to cache. Their findings won't be integrated into this session but will persist for reference.

→ Return to caller.
