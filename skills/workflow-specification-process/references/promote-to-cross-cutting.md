# Promote to Cross-Cutting Work Unit

*Reference for **[workflow-specification-process](../SKILL.md)***

---

Promote an epic specification assessed as cross-cutting to its own cross-cutting work unit.

## A. Collision Check

Check if a work unit with the topic name already exists:

```bash
node .claude/skills/workflow-manifest/scripts/manifest.js exists {topic}
```

#### If `true`

> *Output the next fenced block as a code block:*

```
Promotion Blocked

A work unit named "{topic}" already exists. Cannot promote — name collision.

Resolve the conflict manually (rename the existing work unit or choose
a different topic name) before retrying.
```

**STOP.** Do not proceed — terminal condition.

#### If `false`

→ Proceed to **B. Create Cross-Cutting Work Unit**.

## B. Create Cross-Cutting Work Unit

Create the new cross-cutting work unit and mark it as completed (the pipeline is terminal after spec, and spec is already complete):

```bash
node .claude/skills/workflow-manifest/scripts/manifest.js init {topic} --work-type cross-cutting --description "{one-line summary from spec}"
node .claude/skills/workflow-manifest/scripts/manifest.js set {topic} status completed
```

Set provenance to track the origin:

```bash
node .claude/skills/workflow-manifest/scripts/manifest.js set {topic} source_work_unit {work_unit}
node .claude/skills/workflow-manifest/scripts/manifest.js set {topic} source_topic {topic}
```

→ Proceed to **C. Move Discussion Files**.

## C. Move Discussion Files

Read sources from the epic spec manifest:

```bash
node .claude/skills/workflow-manifest/scripts/manifest.js get {work_unit}.specification.{topic} sources
```

For each source that is a discussion file (check if `.workflows/{work_unit}/discussion/{source}.md` exists), move it to the new work unit:

```bash
mkdir -p .workflows/{topic}/discussion/
mv .workflows/{work_unit}/discussion/{source}.md .workflows/{topic}/discussion/{source}.md
```

Initialize discussion phase in the new manifest for each moved source:

```bash
node .claude/skills/workflow-manifest/scripts/manifest.js init-phase {topic}.discussion.{source}
node .claude/skills/workflow-manifest/scripts/manifest.js set {topic}.discussion.{source} status completed
```

→ Proceed to **D. Move Specification**.

## D. Move Specification

Move the specification directory to the new work unit:

```bash
mkdir -p .workflows/{topic}/specification/
mv .workflows/{work_unit}/specification/{topic}/ .workflows/{topic}/specification/{topic}/
```

Initialize specification phase in the new manifest:

```bash
node .claude/skills/workflow-manifest/scripts/manifest.js init-phase {topic}.specification.{topic}
node .claude/skills/workflow-manifest/scripts/manifest.js set {topic}.specification.{topic} status completed
node .claude/skills/workflow-manifest/scripts/manifest.js set {topic}.specification.{topic} date $(date +%Y-%m-%d)
```

→ Proceed to **E. Update Epic Manifest**.

## E. Update Epic Manifest

Mark the topic as promoted in the epic manifest:

```bash
node .claude/skills/workflow-manifest/scripts/manifest.js set {work_unit}.specification.{topic} status promoted
node .claude/skills/workflow-manifest/scripts/manifest.js set {work_unit}.specification.{topic} promoted_to {topic}
```

→ Proceed to **F. Commit and Display**.

## F. Commit and Display

Commit: `spec({work_unit}): promote {topic} to cross-cutting work unit`

> *Output the next fenced block as a code block:*

```
Promoted to Cross-Cutting

"{topic:(titlecase)}" has been promoted to its own cross-cutting work unit.

  Source: {work_unit}
  Discussion files: moved
  Specification: moved
  Epic status: promoted
```

Invoke the bridge for the EPIC (not the cc work unit — the epic continues its pipeline):

```
Pipeline bridge for: {work_unit}
Completed phase: specification

Invoke the workflow-bridge skill to enter plan mode with continuation instructions.
```

**STOP.** Do not proceed — terminal condition.
