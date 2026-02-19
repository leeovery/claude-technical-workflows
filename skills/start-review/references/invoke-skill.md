# Invoke the Skill

*Reference for **[start-review](../SKILL.md)***

---

After completing the steps above, this skill's purpose is fulfilled.

## Save Session Bookmark

> *Output the next fenced block as a code block:*

```
Saving session state so Claude can pick up where it left off if the conversation is compacted.
```

```bash
.claude/hooks/workflows/write-session-state.sh \
  "{topic}" \
  "skills/technical-review/SKILL.md" \
  "docs/workflow/review/{scope}/r{N}/review.md"
```

---

## Invoke the Skill

Invoke the [technical-review](../../technical-review/SKILL.md) skill for your next instructions. Do not act on the gathered information until the skill is loaded - it contains the instructions for how to proceed.

Each plan is reviewed independently. When multiple plans are selected, pass all plans in the handoff — the orchestrator will loop through them one at a time.

**Example handoff:**
```
Review session
Plans to review:
  - topic: {topic-1}
    plan: docs/workflow/planning/{topic-1}/plan.md
    format: {format}
    plan_id: {plan_id} (if applicable)
    specification: {specification} (exists: {true|false})
    review_version: r{N}
  - topic: {topic-2}
    plan: docs/workflow/planning/{topic-2}/plan.md
    format: {format}
    specification: {specification} (exists: {true|false})
    review_version: r{N}

Invoke the technical-review skill.
```

**Example handoff (analysis-only):**
```
Analysis session for: {topic}
Review mode: analysis-only
Review path: docs/workflow/review/{topic}/r{N}/
Format: {format}
Specification: {spec path}

Invoke the technical-review skill.
```
