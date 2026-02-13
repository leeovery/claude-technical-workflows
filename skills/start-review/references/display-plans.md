# Display Plans

*Reference for **[start-review](../SKILL.md)***

---

Present all discovered plans with implementation status to help the user understand what's reviewable.

**Present the full state:**

```
Review Phase

Reviewable:
  1. ✓ {topic-1} (completed) - format: {format}, spec: {exists|missing}
  2. ▶ {topic-2} (in-progress) - format: {format}, spec: {exists|missing}

Not reviewable:
  · {topic-3} [no implementation]
```

**Output in a fenced code block exactly as shown above.**

**Formatting rules:**

Reviewable (numbered, selectable):
- **`✓`** — implementation_status: completed
- **`▶`** — implementation_status: in-progress

Not reviewable (not numbered, not selectable):
- **`·`** — implementation_status: none

Omit either section entirely if it has no entries.

**Then route based on what's reviewable:**

#### If no reviewable plans

```
No implemented plans found.

The review phase requires at least one plan with an implementation.
Please run /start-implementation first.
```

**Output in a fenced code block exactly as shown above.**

**STOP.** Wait for user to acknowledge before ending.

#### If single reviewable plan

```
Auto-selecting: {topic} (only reviewable plan)
Scope: single
```

**Output in a fenced code block exactly as shown above.**

→ Proceed directly to **Step 5**.

#### If multiple reviewable plans

· · · · · · · · · · · ·
What scope would you like to review?

- **`s`/`single`** — Review one plan's implementation
- **`m`/`multi`** — Review selected plans together (cross-cutting)
- **`a`/`all`** — Review all implemented plans (full product)
· · · · · · · · · · · ·

Do not wrap the above in a code block — output as raw markdown so bold styling renders.

**STOP.** Wait for user response.

→ Based on user choice, proceed to **Step 4**.
