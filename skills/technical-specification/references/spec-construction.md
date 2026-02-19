# Spec Construction

*Reference for **[technical-specification](../SKILL.md)***

---

Work through the specification **topic by topic**. For each topic, follow the cycle below.

## 1. Review (Exhaustive Extraction)

Load **[exhaustive-extraction.md](exhaustive-extraction.md)** and follow its instructions for the current topic.

When working with multiple sources, search each one — information about a single topic may be scattered across documents.

## 2. Synthesize and Present

Present your understanding to the user **in the format it would appear in the specification**:

> *Output the next fenced block as markdown (not a code block):*

```
Here's what I understand about [topic] based on the reference material. This is exactly what I'll write into the specification:

[content as rendered markdown]
```

Then, **separately from the content above** (clear visual break):

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
**To proceed:**
- **`y`/`yes`** — Approved. I'll add the above to the specification **verbatim** (exactly as shown, no modifications).
- **Or tell me what to change.**
· · · · · · · · · · · ·
```

Content and choices must be visually distinct (not run together).

> **CHECKPOINT**: After presenting, you MUST STOP and wait for the user's response. Do NOT proceed to logging. Do NOT present the next topic. WAIT.

## 3. Discuss and Refine

Work through the content together:
- Validate what's accurate
- Remove what's wrong, outdated, or hallucinated
- Add what's missing through brief discussion
- **Course correct** based on knowledge from subsequent project work
- Refine wording and structure

This is a **human-level conversation**, not form-filling. The user brings context from across the project that may not be in the reference material — decisions from other topics, implications from later work, or knowledge that can't all fit in context.

## 4. Wait for Explicit Approval

**DO NOT PROCEED TO LOGGING WITHOUT EXPLICIT USER APPROVAL.**

If you are uncertain whether the user approved, **ASK**: "Ready to log it, or do you want to change something?"

> **CHECKPOINT**: If you are about to write to the specification and the user's last message was not explicit approval, **STOP**. Present the choices again.

## 5. Log When Approved

Only after receiving explicit approval, write to the specification — **verbatim** as presented and approved. No silent modifications.

## 6. Update Source Status

After completing exhaustive extraction from a source (all relevant content presented and logged), update that source's status to `incorporated` in the specification frontmatter. See **[specification-format.md](specification-format.md)** for source status details.

## 7. Repeat

Move to the next topic. Commit at natural breaks — after significant exchanges, after each major topic, and before any context refresh.

---

## Context Resurfacing

When you discover information that affects **already-logged topics**, resurface them. Even mid-discussion — interrupt, flag what you found, and discuss whether it changes anything.

If it does: summarize what's changing in the chat, then re-present the full updated topic. The summary is for discussion only — the specification just gets the clean replacement. **Standard workflow applies: user approves before you update.**

> **CHECKPOINT**: Even when resurfacing content, you MUST NOT update the specification until the user explicitly approves the change. Present the updated version, wait for approval, then update.

This is encouraged. Better to resurface and confirm "already covered" than let something slip past.
