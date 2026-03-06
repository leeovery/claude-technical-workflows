# Route to First Phase

*Reference for **[start-epic](../SKILL.md)***

---

Assess whether the epic should start with research or go directly to discussion.

## Assess Unknowns

Based on the gathered context, evaluate if there are significant unknowns:

- **Technical unknowns**: Unfamiliar technologies, platforms, or architectural patterns
- **Market unknowns**: User needs, competitive landscape, viability questions
- **Design unknowns**: Multiple viable architectures, unclear tradeoffs at scale
- **Scope unknowns**: Requirements that need exploration before committing

Epics are large initiatives — research is more commonly needed than with features.

## Present Assessment

#### If significant unknowns exist

> *Output the next fenced block as a code block:*

```
Research Assessment

Based on your description, there are areas that would benefit from research:

• {uncertainty_1}
• {uncertainty_2}
• ...

Research helps explore options and validate assumptions before committing to architectural decisions.
```

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
Would you like to explore these in research first?

- **`y`/`yes`** — Start with research, then continue to discussion
- **`n`/`no`** — Proceed directly to discussion
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

#### If no significant unknowns

Set phase="discussion".

→ Return to **[the skill](../SKILL.md)**.

## Route Based on Response

#### If user chooses research

Set phase="research".

→ Return to **[the skill](../SKILL.md)**.

#### If user declines research

Set phase="discussion".

→ Return to **[the skill](../SKILL.md)**.
