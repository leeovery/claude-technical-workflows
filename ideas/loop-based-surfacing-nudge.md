# Loop-Based Surfacing Nudge

## The Idea

Use Claude Code's `/loop` feature (dynamic scheduling, no fixed interval) as a periodic nudge for the orchestrator to check background agent cache files for pending results. The loop fires between turns, prompting the orchestrator to run the surfacing protocol — but the natural-break checklist and never-dump protocol still govern whether anything is actually surfaced.

This is a safety net, not a replacement. The surfacing protocol does all the heavy lifting. The loop just guarantees the check happens even if the orchestrator gets deep into a discussion thread and deprioritises or forgets the cache scan.

## Why This Matters

Currently, surfacing checks are embedded as instructions in the conversation flow ("before each conversational turn, scan cache..."). If the orchestrator is deep in a multi-turn exploration, it may forget or deprioritise these checks. Pending results could sit in cache longer than necessary.

A dynamic loop guarantees periodic cache checks without the orchestrator needing to remember. Claude picks the interval (1min–1hr) based on conversation activity — short during rapid exchanges, longer during deep thought.

## How It Would Work

1. Background review agents still dispatch via Task tool (isolation preserved)
2. Cache files + frontmatter still the state mechanism (persistence preserved)
3. A dynamic loop fires between turns and runs the surfacing check
4. The surfacing protocol (natural-break checklist, never-dump, one-finding-per-turn) still governs output
5. If not a natural break, the loop does nothing — no output, no interruption

## Key Constraint

**Between-turns is not the same as a natural break.** The loop fires when Claude is idle between turns. But "idle between turns" includes moments like:
- Claude just asked a probing question and the user is thinking
- Claude presented options and the user is evaluating
- User is mid-response ("hold on", "let me think")

The natural-break checklist must still run inside the loop iteration. The loop is just the trigger — it doesn't replace the judgment about whether to surface.

## Costs & Trade-offs

- **Token spend**: Every loop fire is a turn in context, even if it decides "not a natural break, do nothing." In long sessions where context is precious, this adds overhead for frequent no-ops.
- **Session-scoped**: Loops die on session exit. Entry/continue skills would need to re-establish the loop on each invocation. Current approach has no such lifecycle concern.
- **50-task cap**: If perspective agents, monitoring loops, and surfacing loops all compete for cron slots, the cap could become a concern in long sessions.
- **Marginal value**: If the embedded surfacing instructions already work reliably, the loop adds complexity for a problem that may not exist in practice.

## Open Question

How often does the orchestrator actually miss pending results? If the answer is "rarely," this idea has low value. If the answer is "sometimes, especially in deep multi-turn threads," the safety net is worthwhile. Real-world observation needed before committing to implementation.

## Decision

Logged for future evaluation. Observe how the current surfacing protocol performs in practice before deciding whether this safety net is needed.
