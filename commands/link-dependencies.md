---
description: Scan all plans and wire up cross-topic dependencies. Finds unresolved external dependencies, matches them to tasks in other plans, and updates both the plan index and output format.
---

Link cross-topic dependencies across all existing plans.

---

## Instructions

Follow these steps EXACTLY as written. Do not skip steps or combine them.

**CRITICAL**: After each user interaction, STOP and wait for their response before proceeding. Never assume or anticipate user choices.

Use simple, individual commands. Never combine multiple operations into bash loops or one-liners. Execute commands one at a time.

---

## Step 1: Discover All Plans

Scan the codebase for existing plans:

1. **Find plan files**: Run `ls docs/workflow/planning/` to list plan files
   - Each file is named `{topic}.md`

2. **Extract plan metadata**: For each plan file
   - Read the frontmatter to get the `format:` field
   - Note the format used by each plan

#### If no plans exist

```
No plans found in docs/workflow/planning/

There are no plans to link. Create plans first.
```

**STOP.** Wait for user acknowledgment. Do not proceed.

#### If only one plan exists

```
Only one plan found: {topic}

Cross-topic dependency linking requires at least two plans.
```

**STOP.** Wait for user acknowledgment. Do not proceed.

#### Otherwise (two or more plans exist)

→ Proceed to **Step 2**.

---

## Step 2: Check Output Format Consistency

Compare the `format:` field across all discovered plans.

#### If plans use different output formats

```
Mixed output formats detected:

- {topic-1}: {format-1}
- {topic-2}: {format-2}
- {topic-3}: {format-1}

Cross-topic dependencies can only be wired within the same output format.
Please consolidate your plans to use a single output format before linking dependencies.
```

**STOP.** Wait for user acknowledgment. Do not proceed.

#### If all plans use the same format

→ Proceed to **Step 3**.

---

## Step 3: Extract External Dependencies

For each plan, find and categorize the External Dependencies section:

1. **Read the External Dependencies section** from each plan index file

2. **Categorize each dependency**:
   - **Unresolved**: `- {topic}: {description}` (no arrow, no task ID)
   - **Resolved**: `- {topic}: {description} → {task-id}` (has task ID)
   - **Satisfied externally**: `- ~~{topic}: {description}~~ → satisfied externally`

3. **Present summary**:

```
Dependency Summary

Plan: {topic-1} (format: {format})
  - {dep-topic}: {description} (unresolved)
  - {dep-topic}: {description} → {task-id} (resolved)

Plan: {topic-2} (format: {format})
  - {dep-topic}: {description} (unresolved)
  - ~~{dep-topic}: {description}~~ → satisfied externally

{N} unresolved dependencies found across {M} plans.
```

#### If no unresolved dependencies exist

```
All dependencies are already resolved or satisfied externally. Nothing to link.
```

**STOP.** Wait for user acknowledgment. Do not proceed.

#### Otherwise (unresolved dependencies exist)

→ Proceed to **Step 4**.

---

## Step 4: Match Dependencies to Plans

For each unresolved dependency:

1. **Search for matching plan**: Does `docs/workflow/planning/{dependency-topic}.md` exist?

#### If no matching plan exists

Mark as "no plan exists" - cannot resolve yet.

#### If matching plan exists

1. Load the output format reference file:
   - Read `format:` from the dependency plan's frontmatter
   - Load `skills/technical-planning/references/output-{format}.md`
   - Follow the "Querying Dependencies" section to search for matching tasks

2. **Handle matches**:
   - If exactly one task matches: Use it
   - If multiple tasks could satisfy the dependency: Present options to user

```
Multiple tasks could satisfy dependency "{topic}: {description}":

1. {task-id-1}: {task description}
2. {task-id-2}: {task description}
3. Both (dependency requires multiple tasks)

Which task(s) should this dependency link to?
```

**STOP.** Wait for user to choose.

→ After processing all dependencies, proceed to **Step 5**.

---

## Step 5: Wire Up Dependencies

For each resolved match:

1. **Update the plan index file**:
   - Change `- {topic}: {description}` to `- {topic}: {description} → {task-id}`

2. **Create dependency in output format**:
   - Load `skills/technical-planning/references/output-{format}.md`
   - Follow the "Cross-Epic Dependencies" or equivalent section to create the blocking relationship

→ Proceed to **Step 6**.

---

## Step 6: Bidirectional Check

For each plan that was a dependency target (i.e., other plans depend on it):

1. **Check reverse dependencies**: Are there other plans that should have this wired up?

2. **Offer to update**:

```
Plan {topic-X} depends on tasks you just linked. Update its External Dependencies section? (y/n)
```

**STOP.** Wait for user response for each.

→ Proceed to **Step 7**.

---

## Step 7: Report Results

Present a summary:

```
Dependency Linking Complete

RESOLVED (newly linked):
  - {plan-1} → {plan-2}: {task-id} ({description})
  - {plan-3} → {plan-1}: {task-id} ({description})

ALREADY RESOLVED (no action needed):
  - {plan-1} → {plan-4}: {task-id}

SATISFIED EXTERNALLY (no action needed):
  - {plan-2} → {external-topic}

UNRESOLVED (no matching plan exists):
  - {plan-3} → {topic}: {description}
    These dependencies have no corresponding plan. Either:
    - Create a plan for the topic
    - Mark as "satisfied externally" if already implemented

UPDATED FILES:
  - docs/workflow/planning/{plan-1}.md
  - docs/workflow/planning/{plan-3}.md
```

→ Proceed to **Step 8**.

---

## Step 8: Commit Changes

#### If any files were updated

```
Shall I commit these dependency updates? (y/n)
```

**STOP.** Wait for user response.

#### If user confirms (y)

Commit with message:
```
Link cross-topic dependencies

- {summary of what was linked}
```

#### If user declines (n)

```
Changes left uncommitted. You can commit manually when ready.
```

---

## Notes

- Dependencies can only be linked between plans using the same output format
- The output format reference file contains format-specific instructions for querying and creating dependencies
- Unresolved dependencies with no matching plan cannot be automatically linked
