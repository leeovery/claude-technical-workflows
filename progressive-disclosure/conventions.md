# Progressive Disclosure Conventions

Conventions for splitting entry-point skills (`start-*`) into backbone + reference files. Established during the `start-research` refactor and based on patterns already used by processing skills (`technical-planning`, `technical-implementation`).

---

## SKILL.md Backbone Structure

The backbone is always loaded. It contains the minimum needed to route through the skill, with Load directives that pull in reference files on demand.

```
Frontmatter
One-liner purpose statement
Workflow context table
"Stay in your lane" instruction
---
Critical instructions (STOP/wait rules, mandatory guidance)
---
Step 0: Run Migrations (always inline)
---
Step 1: {Name}
Load directive → reference file
→ Proceed to Step 2.
---
Step 2: {Name}
Load directive → reference file
```

### What stays inline

- **Migrations** (Step 0) — always needed, always first
- **Simple routing conditionals** — if the routing logic is a few lines, keep it in the backbone rather than extracting a tiny file
- **Frontmatter and critical instructions** — these set the tone for the entire skill

### What gets extracted

- **User interaction sequences** — questions, prompts, STOP/wait cycles (e.g., `gather-context.md`)
- **Display/output formatting** — complex display formats, status presentations (e.g., `display-groupings.md`)
- **Handoff templates** — invocation of processing skills with context fields (e.g., `invoke-skill.md`)
- **Discovery parsing** — interpreting script output (e.g., `discovery.md`)
- **Analysis logic** — multi-step analysis workflows (e.g., `analysis-flow.md`)
- **Routing logic** — when routing involves significant conditional content (e.g., `route.md`)
- **Confirmation flows** — confirm + handoff combined (e.g., `confirm-and-handoff.md`)

---

## Load Directive Format

```markdown
## Step N: {Step Name}

Load **[name.md](references/name.md)** and follow its instructions as written.

→ Proceed to **Step N+1**.
```

Rules:
- No arrow (`→`) before the Load line
- Bold the markdown link: `**[name.md](path)**`
- "Proceed to" appears after the Load directive, separated by a blank line
- The final step has no "Proceed to" (it's terminal)

---

## Reference File Format

```markdown
# {Step Name}

*Reference for **[skill-name](../SKILL.md)***

---

{content}
```

Rules:
- Header matches the step concept, not the filename
- Italic attribution line links back to the parent SKILL.md
- Horizontal rule separates header from content
- Reference files do **NOT** navigate back to the backbone — the backbone owns all step sequencing

---

## Navigation Patterns

**Backbone steps:**
```
→ Proceed to **Step N**.
```

**Reference files:** End without navigation. Once the reference file's instructions are complete, control implicitly returns to the backbone, which has the "Proceed to" directive.

**Between steps:** Horizontal rule (`---`) separates each step in the backbone.

---

## Step Numbering

- Backbone steps are numbered from 0 (migrations) upward
- Internal sub-steps within a reference file use **named sections** (e.g., `## Seed Idea`, `## Current Knowledge`), not numbered steps
- Exception: when a reference file covers multiple logical phases (e.g., `analysis-flow.md` covering context gathering + analysis + display), it may use its own internal step numbering

---

## Reference File Naming

| Name | Purpose |
|------|---------|
| `gather-context.md` | User interview / context gathering questions |
| `invoke-skill.md` | Handoff to processing skill |
| `discovery.md` | Discovery script parsing and interpretation |
| `route.md` | Scenario routing (for skills with branching) |
| `display-{variant}.md` | Display outputs (for skills with multiple displays) |
| `analysis-flow.md` | Multi-step analysis logic |
| `confirm-and-handoff.md` | Confirmation prompt + skill invocation combined |

Not every skill needs all of these. Simple skills like `start-research` only need `gather-context.md` and `invoke-skill.md`. Complex skills like `start-specification` may need most of them.

---

## Interactive Formatting Conventions

These conventions are established in `start-planning` and `start-implementation` and must be followed across all entry-point skills.

### Choice Sections (y/n)

For yes/no prompts, the question leads into the choices inside dotted line separators:

```
· · · · · · · · · · · ·
Proceed with analysis?
- **`y`/`yes`**
- **`n`/`no`**
· · · · · · · · · · · ·
```

When the question provides sufficient context, the shortcuts need no additional description.

### Choice Sections (commands)

For choices with named commands, use letter shortcuts with descriptions:

```
· · · · · · · · · · · ·
- **`c`/`continue`** — Plan without them
- **`s`/`stop`** — Complete them first (/start-specification)
· · · · · · · · · · · ·
```

Rules:
- First letter of the command as shortcut — disambiguate with second letter if first is taken
- Commands (with shortcuts) come first, freeform prompts come second
- Freeform prompts have no shortcut: `- Describe the issue — I'll help resolve it`

### Numbered Menus

Menu entries and prompt are wrapped together in dotted lines as a single interactive unit:

```
· · · · · · · · · · · ·
1. Start "Auth Flow" — 2 ready discussions
2. Continue "Data Model" — 1 source(s) pending extraction
3. Re-analyze groupings

Select an option (enter number):
· · · · · · · · · · · ·
```

### Conditional Headings

Use H4 for routing conditionals within steps. Do not use bold text for conditionals:

```markdown
#### If scenario is "no_specs"

→ Load **[display-blocks.md](...)** and follow its instructions.

#### Otherwise

→ Proceed to **Step 3**.
```

Rules:
- Lowercase after "If" (e.g., `#### If concluded_count == 1`)
- Use `#### Otherwise` for else branches
- No backtick-wrapped code in H4 headings — write conditions as plain text
- Use "and" between conditions, not commas (reads more like code)
- Drop implied conditions (e.g., if Step 2 already gates on concluded_count >= 1, Step 3 doesn't need to repeat `concluded_count >= 2` on every branch)

### Routing Arrows

Use `→` to mark load/proceed instructions:

```markdown
→ Load **[confirm-and-handoff.md](...)** and follow its instructions.
```

The arrow signals "this is a routing instruction" — it directs flow to another file or step.

### STOP Convention

```markdown
**STOP.** Wait for user response.
```

Bold "STOP" with period, followed by the wait instruction.

---

## Guiding Principle

The backbone should read like a table of contents — you can scan it and understand the full flow without loading any reference files. Each Load directive is a clear handoff: "this step's detail lives here." The reference files are self-contained instructions for that step, loaded only when needed.
