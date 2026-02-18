# Produce Review

*Reference for **[technical-review](../SKILL.md)***

---

Aggregate findings from both stages into a review document using the **[template.md](template.md)**.

Write the review to `docs/workflow/review/{scope}/r{N}/review.md`. The review scope `{scope}` is the topic name (single) or a descriptive scope name (multi/all). The review number `r{N}` is passed in from the entry point.

**QA Verdict** (from Step 3):
- **Approve** — All acceptance criteria met, no blocking issues
- **Request Changes** — Missing requirements, broken functionality, inadequate tests
- **Comments Only** — Minor suggestions, non-blocking observations

**Product Assessment** (from Step 4) — always advisory, presented alongside the verdict.

Commit: `review({topic}): complete review`

Present the review to the user.

Your review feedback can be:
- Addressed by implementation (same or new session)
- Delegated to an agent for fixes
- Overridden by user ("ship it anyway")

You produce feedback. User decides what to do with it.
