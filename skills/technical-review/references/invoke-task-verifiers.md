# Invoke Task Verifiers

*Reference for **[technical-review](../SKILL.md)***

---

This step dispatches `review-task-verifier` agents in batches to verify ALL tasks across the selected plan(s). Each verifier independently checks one task for implementation, tests, and code quality, writing its full findings to a file and returning a brief status.

---

## Identify Scope

Build the list of implementation files using git history. For each plan in scope:

```bash
git log --oneline --name-only --pretty=format: --grep="impl({topic}):" | sort -u | grep -v '^$'
```

This captures all files touched by implementation commits for the topic.

---

## Extract All Tasks

From each plan in scope, list every task across all phases:
- Note each task's description
- Note each task's acceptance criteria
- Note expected micro acceptance (test name)
- Assign each task a sequential **index** (1, 2, 3...) for file naming

---

## Create Output Directory

For each topic in scope, ensure the review output directory exists:

```bash
mkdir -p docs/workflow/review/{topic}
```

---

## Batch Dispatch

Dispatch verifiers in **batches of 5** via the Task tool.

- **Agent path**: `../../../agents/review-task-verifier.md`

1. Group tasks into batches of 5
2. For each batch:
   a. Dispatch all agents in the batch in parallel
   b. Wait for all agents in the batch to return
   c. Record statuses
3. After all batches complete, proceed to aggregation

Each verifier receives:

1. **Plan task** — the specific task with acceptance criteria
2. **Specification path** — from the plan's frontmatter (if available)
3. **Plan path** — the full plan for phase context
4. **Project skill paths** — from Step 2 discovery
5. **Review checklist path** — `skills/technical-review/references/review-checklist.md`
6. **Topic name** — for output file path
7. **Task index** — sequential number for file naming (1, 2, 3...)

If any verifier fails (error, timeout), record the failure and continue — aggregate what's available.

---

## Expected Result

Each verifier returns a brief status:

```
STATUS: Complete | Incomplete | Issues Found
FINDINGS_COUNT: {N blocking issues}
SUMMARY: {1 sentence}
```

Full findings are written to `docs/workflow/review/{topic}/qa-task-{index}.md`.

---

## Aggregate Findings

Once all batches have completed:

1. Read all `docs/workflow/review/{topic}/qa-task-*.md` files
2. Synthesize findings from file contents:
   - Collect all tasks with `STATUS: Incomplete` or `STATUS: Issues Found` as blocking issues
   - Collect all test issues (under/over-tested)
   - Collect all code quality concerns
   - Include specific file:line references
   - Check overall plan completion (see [review-checklist.md](review-checklist.md) — Plan Completion Check)
