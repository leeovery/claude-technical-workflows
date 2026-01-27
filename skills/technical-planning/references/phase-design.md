# Phase Design

*Reference for **[technical-planning](../SKILL.md)***

---

This reference defines the principles for breaking specifications into implementation phases. It is loaded when phases are first proposed and stays in context through phase approval.

## What Makes a Good Phase

Each phase should:

- **Deliver a working increment** — not a technical layer, but functionality that can be used or tested end-to-end
- **Have clear acceptance criteria** — checkboxes that are pass/fail verifiable
- **Follow natural boundaries** — domain, feature, or capability boundaries, not architectural layers
- **Leave the system working** — every phase ends with a green test suite and deployable code
- **Be independently valuable** — if the project stopped after this phase, something useful would exist

---

## The Walking Skeleton

Phase 1 is always a **walking skeleton** — the thinnest possible end-to-end slice that threads through all system layers and proves the architecture works.

The walking skeleton:

- Touches every architectural component the system needs (database, API, UI, external services)
- Delivers one complete flow, however minimal
- Establishes the patterns subsequent phases will follow
- Is production code, not throwaway — it becomes the foundation

**Example** (Slack clone):

> Phase 1: "Any unauthenticated person can post messages in a hardcoded #general room. Messages persist through page refreshes."
>
> No auth, no accounts, no multiple rooms. Just the thinnest thread through the entire stack.

**Example** (Calendar app):

> Phase 1: "A single event can be created with title, start, and end time, persisted, and retrieved by ID."
>
> No recurrence, no sharing, no notifications. Just one thing working end-to-end.

The skeleton validates architecture assumptions at the cheapest possible moment. If the end-to-end flow doesn't work, you discover it in Phase 1 — not after building three phases of isolated components.

This is the **steel thread** principle: never have big-bang integration. By threading through all layers immediately, integration is the first thing you solve, not the last.

---

## Vertical Phases

After the walking skeleton, each subsequent phase adds complete functionality — a vertical slice through the relevant layers.

**Vertical (prefer):**

```
Phase 1: Walking skeleton — single event CRUD, end-to-end
Phase 2: Recurring events — rules, instance generation, single-instance editing
Phase 3: Sharing and permissions — invite users, permission levels, shared calendars
Phase 4: Notifications — email and push notifications for event changes
```

Each phase delivers something a user or test suite can validate independently.

**Horizontal (avoid):**

```
Phase 1: All database models and migrations
Phase 2: All service classes and business logic
Phase 3: All API endpoints
Phase 4: All UI components
Phase 5: Wire everything together
```

Nothing works until Phase 5. No phase is independently testable. Integration risk concentrates at the end.

A phase may touch multiple architectural layers — that's expected. The test is: **does this phase deliver working functionality, or does it deliver infrastructure that only becomes useful later?**

### Progression

**Skeleton → Core features → Edge cases → Refinement**

- **Skeleton** (Phase 1): Thinnest end-to-end slice proving the architecture
- **Core features**: Each phase adds a complete capability, building on what exists
- **Edge cases**: Handling boundary conditions, error scenarios, unusual inputs
- **Refinement**: Performance optimisation, UX polish, hardening

This ordering means each phase builds on a working system. The skeleton establishes the pattern; core features flesh it out; edge cases harden it; refinement polishes it.

---

## Phase Boundaries

A phase boundary belongs where:

- **A meaningful state change occurs** — the system gains a new capability
- **Human validation is needed** — the approach should be confirmed before building more
- **The risk profile shifts** — different concerns, different complexity, different unknowns
- **The work's nature changes** — from core functionality to edge cases, from features to optimisation

### When to split

- The combined work exceeds what can be reasoned about in a single focused session
- An intermediate state is independently valuable or testable
- You need a checkpoint to validate before investing further
- Different parts have different risk or uncertainty levels

### When to keep together

- High cohesion — changes to one part directly affect the other
- The intermediate state has no independent value
- Splitting would create phases that aren't meaningful milestones
- The overhead of phase management exceeds the benefit

### Granularity check

If a phase has only 1-2 trivial tasks, it's probably too thin — merge it. If a phase has 8+ tasks spanning multiple concerns, it's probably too thick — split it. Most phases land at 3-6 focused tasks.

---

## Cross-Phase Coupling

**Maximize cohesion within a phase, minimize dependencies between phases.**

A well-bounded phase could theoretically be reordered or dropped without cascading failures across other phases. In practice, phases have a natural sequence (the skeleton must come first), but each phase should be as self-contained as possible.

Strategies:

- **Walking skeleton first** — subsequent phases add to a working system rather than depending on future phases
- **Clear interfaces between phases** — each phase produces defined contracts (API shapes, data models, test suites) that subsequent phases consume
- **Shared infrastructure in Phase 1** — if multiple phases need the same foundation, it belongs in the skeleton
- **No forward references** — a phase should never depend on something that hasn't been built yet

---

## Anti-Patterns

**Horizontal phases** — organising by technical layer ("all models, then all services, then all controllers"). Defers integration risk, produces phases that aren't independently valuable. The walking skeleton eliminates this by integrating from the start.

**God phase** — one massive phase covering too many concerns. Results in unclear success criteria, inability to track progress, and cognitive overload. If you can't summarise a phase's goal in one sentence, it needs splitting.

**Trivial phases** — phases so small they're just individual tasks wearing a trenchcoat. Phase management has overhead; don't pay it for work that doesn't warrant a checkpoint.

**Infrastructure-only phases** (after Phase 1) — phases that deliver tooling, configuration, or refactoring with no user-facing value. These should be folded into the phase that needs them, unless they're genuinely cross-cutting prerequisites.

**Speculative phases** — phases planned for hypothetical future requirements. Plan what the specification defines, not what might be needed later.
