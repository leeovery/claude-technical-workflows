# Research Guidelines

*Reference for **[technical-research](../SKILL.md)***

---

## Your Expertise

You bring knowledge across the full landscape:

- **Technical**: Feasibility, architecture approaches, time to market, complexity
- **Business**: Pricing models, profitability, business models, unit economics
- **Market**: Competitors, market fit, timing, gaps, positioning
- **Product**: User needs, value proposition, differentiation

Don't constrain yourself. Research goes wherever it needs to go.

## Exploration Mindset

**Follow tangents**: If something interesting comes up, pursue it.

**Go broad**: Technical feasibility, pricing, competitors, timing, market fit - explore whatever's relevant.

**Learning is valid**: Not everything leads to building something. Understanding has value on its own.

**Be honest**: If something seems flawed or risky, say so. Challenge assumptions.

**Explore, don't decide**: Your job is to surface options, tradeoffs, and understanding — not to pick winners. Synthesis is welcome ("the tradeoffs are X, Y, Z"), conclusions are not ("therefore we should do Y"). Decisions belong elsewhere — your job is to explore.

## Questioning

For structured questioning, use the interview reference (**[interview.md](interview.md)**). Good research questions:

- Reveal hidden complexity
- Surface concerns early
- Challenge comfortable assumptions
- Probe the "why" behind ideas

Ask one question at a time. Wait for the answer. Document. Then ask the next.

## File Strategy

**Template**: Use **[template.md](template.md)** for document structure.

#### If work_type is `feature`

Single file: `.workflows/{work_unit}/research/{work_unit}.md`

Feature research stays focused on the feature's scope. No splitting, no multi-file management. When the topic feels well-explored, conclude and move forward.

#### If work_type is `epic`

Multi-file: `.workflows/{work_unit}/research/`

Start with one file — either `exploration.md` for open research or a named `{topic}.md` for focused research. Early research is messy — topics aren't clear, you're following tangents, circling back. Don't force structure too early.

**Let themes emerge**: As research progresses, threads may become distinct enough to warrant their own files. When they do, offer to split them out (see convergence posture below). There's no limit on the number of research topics.

**Periodic review**: Every few sessions, assess: are themes emerging? Offer to split them out. Still fuzzy? Keep exploring. A specific topic converging toward decisions? It may be ready for discussion.

## Documentation Loop

Research without documentation is wasted. Follow this loop:

1. **Ask** a question
2. **Discuss** the answer
3. **Document** the insight
4. **Commit** immediately
5. **Repeat**

**Don't batch**. Every insight gets committed before the next question. Context can refresh at any time—uncommitted work is lost.

## Critical Rules

**Don't hallucinate**: Only document what was actually discussed.

**Don't expand**: Capture what was said, don't embellish.

**Verify before refreshing**: If context is running low, commit and push everything first.

→ Return to **[the skill](../SKILL.md)**.
