---
description: Shift into focused questioning mode to probe an idea more deeply during research or discussion phases.
---

Shift into focused questioning mode to probe an idea more deeply.

## Setup

Before beginning, ask the user:

1. **What stage are you in?** Research or discussion?
2. **What topic or idea do you want to explore?**

Wait for responses before proceeding.

## Process

1. **Check for existing context**:
   - Research: Look for docs in `docs/workflow/research/`
   - Discussion: Look for the topic's file in `docs/workflow/discussion/{topic}.md`

   Read what exists to understand what's already been explored.

2. **Begin interviewing**: Use the AskUserQuestion tool to probe the idea. Focus on:
   - Non-obvious questions (not things already answered)
   - Assumptions and unstated constraints
   - Tradeoffs and concerns
   - What could go wrong
   - The "why" behind decisions

3. **Go where it leads**: Follow tangents if they reveal something valuable. This isn't a checklist—it's a conversation.

4. **Document as you go**: Don't defer writing to the end. Capture insights in the appropriate location:
   - Research: `docs/workflow/research/` (semantic filenames)
   - Discussion: `docs/workflow/discussion/{topic}.md`

   Ask before documenting: "Shall I capture that?"

5. **Commit frequently**: At natural breaks and before context refresh. Don't risk losing detail.

6. **Exit when done**: The user decides when the interview is complete.

## Question quality

Aim for questions that:
- The user hasn't already answered
- Reveal hidden complexity
- Surface concerns early
- Challenge comfortable assumptions

Avoid:
- Restating what's already documented
- Obvious surface-level questions
- Leading questions that assume an answer
