---
description: Start a technical discussion using the technical-discussion skill. Gathers information about the topic and creates discussion documentation in docs/specs/discussions/<topic-name>/
---

Invoke the **technical-discussion** skill for this conversation.

Before beginning, ask the user these questions to properly set up the discussion:

## Essential Information

1. **Discussion Topic**: What are we discussing? (This will be used to create the directory name in `docs/specs/discussions/<topic-name>/`)

2. **Context & Background**:
   - What sparked this discussion?
   - What problem are we trying to solve?
   - Why are we discussing this now?

3. **Foundational Knowledge**:
   - Is there any background information I need to understand before we begin?
   - Are there specific concepts, technologies, or architectures I should know about?
   - Any constraints, requirements, or limitations I should be aware of?

4. **Codebase Review**:
   - Are there specific files in this repository I should read first?
   - Should I explore any particular directories or components?
   - Is there existing code related to this discussion?

## After Gathering Information

Once I have this information:
- Create directory: `docs/specs/discussions/<topic-name>/`
- Start documenting the discussion following the technical-discussion skill structure
- Create initial file (e.g., `discussion.md`)
- Add more files as the discussion evolves (research notes, supporting docs, etc.)
- Commit frequently at natural discussion breaks

Ask these questions clearly and wait for responses before proceeding with the discussion.
