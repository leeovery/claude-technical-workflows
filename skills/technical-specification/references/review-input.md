# Input Review

*Reference for **[spec-review](spec-review.md)***

---

Phase 1 compares the specification against all source material to catch anything missed.

## The Review Process

1. **Re-read ALL source material** — Go back to every source document, discussion, research note, and reference. Don't rely on memory.

2. **Compare systematically** — For each piece of source material:
   - What topics does it cover?
   - Are those topics fully captured in the specification?
   - Are there details, edge cases, or decisions that didn't make it?

3. **Search for the forgotten** — Look specifically for:
   - Edge cases mentioned in passing
   - Constraints or requirements buried in tangential discussions
   - Technical details that seemed minor at the time
   - Decisions made early that may have been overshadowed
   - Error handling, validation rules, or boundary conditions
   - Integration points or data flows mentioned but not elaborated

4. **Collect what you find** — Note each finding for your summary. Categorize:
   - **Enhancing an existing topic** — Details that belong in an already-documented section. Note which section it would enhance.
   - **An entirely missed topic** — Something that warrants its own section but was glossed over. New topics get added at the end.

5. **Never fabricate** — Every item you flag must trace back to specific source material. If you can't point to where it came from, don't suggest it. The goal is to catch missed content, not invent new requirements.

6. **User confirms before inclusion** — Standard workflow applies: present proposed additions, get approval, then log verbatim.

7. **Surface potential gaps** — After reviewing source material, consider whether the specification has gaps that the sources simply didn't address:
   - Edge cases that weren't discussed
   - Error scenarios not covered
   - Integration points that seem implicit but aren't specified
   - Behaviors that are ambiguous without clarification

   Collect these alongside the missed content. This should be infrequent — most gaps will be caught from source material. But occasionally the sources themselves have blind spots worth surfacing.

8. **Create the tracking file** — If findings exist, write them to `review-input-tracking-c{N}.md` using the format from **[review-tracking-format.md](review-tracking-format.md)**. Commit the tracking file.

## What You're NOT Doing in Phase 1

- **Not inventing requirements** — When surfacing gaps not in sources, you're asking questions, not proposing answers
- **Not assuming gaps need filling** — If something isn't in the sources, it may have been intentionally omitted
- **Not padding the spec** — Only add what's genuinely missing and relevant
- **Not re-litigating decisions** — If something was discussed and rejected, it stays rejected

## Completing Phase 1

When you've:
- Systematically reviewed all source material for missed content
- Created the tracking file (if findings exist) and committed it

→ Return to **[spec-review.md](spec-review.md)** for finding processing.
