# Invoke Task Verifiers

*Reference for **[technical-review](../SKILL.md)***

---

This step dispatches `review-task-verifier` agents in parallel to verify ALL tasks across the selected plan(s). Each verifier independently checks one task for implementation, tests, and code quality.

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

---

## Dispatch Verifiers

Dispatch **one verifier per task, all in parallel** via the Task tool.

- **Agent path**: `../../../agents/review-task-verifier.md`

Each verifier receives:

1. **Plan task** — the specific task with acceptance criteria
2. **Specification path** — from the plan's frontmatter (if available)
3. **Plan path** — the full plan for phase context
4. **Project skill paths** — from Step 2 discovery
5. **Review checklist path** — `skills/technical-review/references/review-checklist.md`

---

## Wait for Completion

**STOP.** Do not proceed until all verifiers have returned.

Each verifier returns a structured finding. If any verifier fails (error, timeout), record the failure and continue — aggregate what's available.

---

## Expected Result

Each verifier returns:

```
TASK: [Task name/description]

ACCEPTANCE CRITERIA: [List from plan]

STATUS: Complete | Incomplete | Issues Found

SPEC CONTEXT: [Brief summary of relevant spec context]

IMPLEMENTATION:
- Status: [Implemented/Missing/Partial/Drifted]
- Location: [file:line references]
- Notes: [Any concerns]

TESTS:
- Status: [Adequate/Under-tested/Over-tested/Missing]
- Coverage: [What is/isn't tested]
- Notes: [Specific issues]

CODE QUALITY:
- Project conventions: [Followed/Violations/N/A]
- SOLID principles: [Good/Concerns]
- Complexity: [Low/Acceptable/High]
- Modern idioms: [Yes/Opportunities]
- Readability: [Good/Concerns]
- Issues: [Specific problems if any]

BLOCKING ISSUES:
- [List any issues that must be fixed]

NON-BLOCKING NOTES:
- [Suggestions for improvement]
```

---

## Aggregate Findings

Once all verifiers have returned, synthesize their reports:

- Collect all tasks with `STATUS: Incomplete` or `STATUS: Issues Found` as blocking issues
- Collect all test issues (under/over-tested)
- Collect all code quality concerns
- Include specific file:line references
- Check overall plan completion (see [review-checklist.md](review-checklist.md) — Plan Completion Check)
