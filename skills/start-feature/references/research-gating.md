# Research Gating

*Reference for **[start-feature](../SKILL.md)***

---

Assess whether the feature has open questions that warrant research before discussion.

## Assess Uncertainties

Based on the gathered context, evaluate if there are significant unknowns:

- **Technical unknowns**: Unfamiliar APIs, libraries, or patterns
- **Design unknowns**: Multiple viable approaches, unclear tradeoffs
- **Integration unknowns**: How existing systems will interact
- **Scope unknowns**: Requirements that need exploration

## Present Assessment

#### If significant uncertainties exist

> *Output the next fenced block as a code block:*

```
Research Assessment

Based on your description, there are open questions that might benefit from research:

• {uncertainty_1}
• {uncertainty_2}
• ...

Research helps explore options and tradeoffs before committing to decisions in discussion.
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

#### If no significant uncertainties

Skip this step silently and proceed to discussion. Do not ask about research if the feature scope is clear.

## Route Based on Response

#### If user chooses research

Return to the main skill with: `research_first: true`

The main skill will:
1. Create a research file with topic + work_type: feature
2. Invoke technical-research
3. When research concludes → workflow:bridge → continue-feature
4. continue-feature routes to begin-discussion (topic already known)

#### If user declines research (or no uncertainties)

Return to the main skill with: `research_first: false`

The main skill will proceed directly to discussion.
