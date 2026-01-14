---
description: Scan all plans and wire up cross-topic dependencies. Finds unresolved external dependencies, matches them to tasks in other plans, and updates both the plan index and output format.
---

Link cross-topic dependencies across all existing plans.

## Instructions

Follow these steps EXACTLY as written. Do not skip steps or combine them.

## Important

Use simple, individual commands. Never combine multiple operations into bash loops or one-liners. Execute commands one at a time.

## Step 1: Discover All Plans

Scan the codebase for existing plans:

1. **Find plan files**: Look in `docs/workflow/planning/`
   - Run `ls docs/workflow/planning/` to list plan files
   - Each file is named `{topic}.md`

2. **Extract plan metadata**: For each plan file
   - Read the frontmatter to get the `format:` field
   - Note the epic ID, project ID, or other format-specific identifiers

**If no plans exist:**

```
⚠️ No plans found in docs/workflow/planning/

There are no plans to link. Create plans using /start-planning first.
```

Stop here.

**If only one plan exists:**

```
⚠️ Only one plan found: {topic}

Cross-topic dependency linking requires at least two plans. Create more plans using /start-planning first.
```

Stop here.

## Step 2: Extract External Dependencies

For each plan, find the External Dependencies section:

1. **Read the External Dependencies section** from each plan index file
2. **Categorize each dependency**:
   - **Unresolved**: `- {topic}: {description}` (no arrow, no task ID)
   - **Resolved**: `- {topic}: {description} → {task-id}` (has task ID)
   - **Satisfied externally**: `- ~~{topic}: {description}~~ → satisfied externally`

3. **Build a summary**:

```
📋 Dependency Summary

Plan: authentication
  - billing-system: Invoice generation (unresolved)
  - user-management: User profiles → beads-7x2k (resolved)

Plan: billing-system
  - authentication: User context (unresolved)
  - ~~payment-gateway: Payment processing~~ → satisfied externally

Plan: notifications
  - authentication: User lookup (unresolved)
  - billing-system: Invoice events (unresolved)
```

## Step 3: Match Dependencies to Plans

For each unresolved dependency:

1. **Search for matching plan**: Does `docs/workflow/planning/{dependency-topic}.md` exist?
   - If no match: Mark as "no plan exists" - cannot resolve yet

2. **If plan exists, identify the output format** from its frontmatter

3. **Query the output format for matching tasks**:

   **For Beads**:
   - Run `bd list --tree` or query `.beads/issues.jsonl`
   - Look for tasks that match the dependency description

   **For Linear**:
   - Query Linear MCP for project issues
   - Match by issue title/description

   **For Backlog.md**:
   - Read task files in `backlog/` directory
   - Match by task title/content

   **For Local Markdown**:
   - Read the plan file
   - Find tasks matching the dependency description

4. **Handle ambiguous matches**:
   - If multiple tasks could satisfy the dependency, present options to user:
   ```
   Found 3 potential matches for "authentication: User context" in authentication plan:

   1. beads-a3f8.1.1 - Login endpoint
   2. beads-a3f8.1.2 - Session management
   3. beads-a3f8.2.1 - User context retrieval

   Which task(s) satisfy this dependency? (can select multiple, e.g., "1,3")
   ```

## Step 4: Wire Up Dependencies

For each resolved match:

1. **Update the plan index file**:
   - Change `- {topic}: {description}` to `- {topic}: {description} → {task-id}`

2. **Create dependency in output format** (if supported):

   **For Beads**:
   ```bash
   bd dep add {dependent-task} {dependency-task}
   ```

   **For Linear**:
   - Add blocking relationship via MCP

   **For Backlog.md**:
   - Add to `external_deps` in task frontmatter

   **For Local Markdown**:
   - Update the External Dependencies section with task reference

## Step 5: Bidirectional Check

For each plan that was a dependency target (i.e., other plans depend on it):

1. **Check reverse dependencies**: Are there other plans that should have this wired up?
2. **Offer to update**: "Plan X depends on tasks you just linked. Update its External Dependencies section?"

## Step 6: Report Results

Present a summary:

```
✅ Dependency Linking Complete

RESOLVED (newly linked):
  - authentication → billing-system: beads-b7c2.1.1 (Invoice generation)
  - notifications → authentication: beads-a3f8.1.2 (Session management)

ALREADY RESOLVED (no action needed):
  - authentication → user-management: beads-9m3p

SATISFIED EXTERNALLY (no action needed):
  - billing-system → payment-gateway

UNRESOLVED (no matching plan exists):
  - notifications → email-service: Email delivery

  ⚠️ These dependencies have no corresponding plan. Either:
  - Create a plan for the topic using /start-planning
  - Mark as "satisfied externally" if already implemented

UPDATED FILES:
  - docs/workflow/planning/authentication.md
  - docs/workflow/planning/notifications.md
```

## Step 7: Commit Changes

If any files were updated:

```
Shall I commit these dependency updates? (y/n)
```

If yes, commit with message:
```
Link cross-topic dependencies

- {summary of what was linked}
```

## Notes

- This command is best run after creating multiple plans
- It's a "best effort" process - not all dependencies may be resolvable
- Dependencies without matching plans stay unresolved until those topics are planned
- The `/start-implementation` command will block on unresolved dependencies
