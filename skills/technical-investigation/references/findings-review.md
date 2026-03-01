# Findings Review & Fix Discussion

*Reference for **[technical-investigation](../SKILL.md)***

---

Present your analysis to the user for validation, then collaboratively agree on fix direction. Simple bugs flow fast (2 STOP gates). Complex bugs expand naturally through discussion.

## A. Present Findings

Summarize the investigation findings in a structured display. Pull from the investigation file — do not invent or embellish.

> *Output the next fenced block as a code block:*

```
Investigation Findings: {topic}

Root Cause:
  {clear, precise root cause statement}

Contributing Factors:
  {factor 1}
  {factor 2}

Blast Radius:
  Directly affected:  {components}
  Potentially affected: {components sharing code/patterns}

Why It Wasn't Caught:
  {testing gap, edge case, recent change}
```

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
Do these findings match your understanding?

- **`y`/`yes`** — Findings are correct, discuss fix direction
- **`n`/`no`** — Something's off
- **`q`/`questions`** — Questions about the analysis
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

#### If no

Address the user's concerns. Re-trace code paths if needed. Update the investigation file with corrections and commit.

Re-present findings using the same format above.

#### If questions

Answer the user's questions about the analysis. Provide supporting evidence from the code trace. Update the investigation file if answers reveal new information, and commit.

Re-present findings using the same format above.

#### If yes

→ Proceed to **B. Fix Direction Discussion**.

---

## B. Fix Direction Discussion

Present 2-3 viable fix approaches. Each should be a genuinely different strategy, not variations of the same idea.

> *Output the next fenced block as a code block:*

```
Fix Approaches for: {topic}

1. {Approach Name}
   What:       {one-line description}
   Trade-offs: {key pros and cons}
   Fits when:  {conditions where this is the right choice}

2. {Approach Name}
   What:       {one-line description}
   Trade-offs: {key pros and cons}
   Fits when:  {conditions where this is the right choice}

3. {Approach Name}
   What:       {one-line description}
   Trade-offs: {key pros and cons}
   Fits when:  {conditions where this is the right choice}
```

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
Which approach, or what direction?

- **Enter a number** to select an approach
- **`d`/`discuss`** — Talk through trade-offs before deciding
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

#### If discuss

Engage in collaborative discussion about the approaches. Stay bounded — focus on:
- Challenging assumptions about each approach
- Surfacing edge cases and risks
- Exploring how each interacts with existing code
- Understanding user priorities (speed, safety, maintainability)

Do not go into implementation detail — that belongs in the specification. When discussion reaches a natural decision point, re-present the approaches (updated if discussion changed them) and ask for selection.

#### If a number is selected

Acknowledge the selection. Present for confirmation:

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
Confirm fix direction: **{chosen approach name}**

- **`y`/`yes`** — Confirm and document
- **Comment** — Add context before confirming
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

#### If Comment

Incorporate the user's context into your understanding. Re-present the same confirmation prompt.

#### If yes

Document the Fix Direction section in the investigation file:

1. **Chosen Approach**: The selected approach with deciding factor
2. **Options Explored**: All approaches presented (including unchosen ones with brief "why not")
3. **Discussion**: Journey notes — user priorities, concerns raised, edge cases surfaced, what shifted thinking. Brief for simple bugs, detailed for complex.
4. **Testing Recommendations**: Informed by the discussion
5. **Risk Assessment**: Informed by the discussion

Commit the updated investigation file.

→ Return to **[the skill](../SKILL.md)**.
