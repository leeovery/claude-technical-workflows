# Re-Index Work Unit

*Shared reference for skills that need to re-index all completed artifacts of a work unit (e.g., reactivation after cancellation, feature-to-epic pivot).*

---

Re-index every completed artifact in an indexed phase so that chunk metadata stays in sync with the manifest.

## Parameters

The caller provides these via context before loading:

- `work_unit` — the work unit name whose completed artifacts should be re-indexed

## A. Loop Over Indexed Phases

For each phase in `research`, `discussion`, `investigation`, `specification`:

Check whether the work unit has that phase:

```bash
node .claude/skills/workflow-manifest/scripts/manifest.cjs exists {work_unit}.{phase}
```

#### If `false`

Skip this phase. → Continue to the next phase.

#### If `true`

Read all items in this phase with their statuses:

```bash
node .claude/skills/workflow-manifest/scripts/manifest.cjs get '{work_unit}.{phase}.*' status
```

For each item whose status is `completed`, resolve the artifact path by phase:

- research: `.workflows/{work_unit}/research/{topic}.md`
- discussion: `.workflows/{work_unit}/discussion/{topic}.md`
- investigation: `.workflows/{work_unit}/investigation/{topic}.md`
- specification: `.workflows/{work_unit}/specification/{topic}/specification.md`

Then run:

```bash
node .claude/skills/workflow-knowledge/scripts/knowledge.cjs index {artifact_path}
```

If any index command fails, display the error but do not block — the caller's operation is already recorded:

> *Output the next fenced block as a code block:*

```
⚑ Knowledge indexing warning
  {error details}
  Indexing can be retried later.
```

→ Continue to the next item, then the next phase.

## B. Complete

Once every indexed phase has been processed, return to the caller.

→ Return to caller.
