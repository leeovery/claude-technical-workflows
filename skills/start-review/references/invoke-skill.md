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

Invoke the [technical-review](../../technical-review/SKILL.md) skill for your next instructions. Do not act on the gathered information until the skill is loaded - it contains the instructions for how to proceed. Use the appropriate handoff format based on the gathered context (review or analysis-only).

**Example handoff (single):**
```
Review session for: {topic}
Review scope: single
Plan: docs/workflow/planning/{topic}/plan.md
Format: {format}
Plan ID: {plan_id} (if applicable)
Specification: {specification} (exists: {true|false})

Invoke the technical-review skill.
```

**Example handoff (multi/all):**
```
Review session for: {scope description}
Review scope: {multi | all}
Plans:
  - docs/workflow/planning/{topic-1}/plan.md (format: {format}, spec: {spec})
  - docs/workflow/planning/{topic-2}/plan.md (format: {format}, spec: {spec})

Invoke the technical-review skill.
```

**Example handoff (analysis-only):**
```
Analysis session for: {scope description}
Review mode: analysis-only
Review scope: {single | multi | all}
Reviews:
  - scope: {scope}
    path: docs/workflow/review/{scope}/r{N}/
    plans: [{plan topics}]
    format: {format}
    specification: {spec path}

Invoke the technical-review skill.
```
