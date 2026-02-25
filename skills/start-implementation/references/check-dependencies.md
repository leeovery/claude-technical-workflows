# Check Dependencies

*Reference for **[start-implementation](../SKILL.md)***

---

Check if plan has unresolved or blocking dependencies from the discovery output.

**If has_unresolved_deps is true:**

> *Output the next fenced block as a code block:*

```
Unresolved Dependencies

The plan for "{topic:(titlecase)}" has unresolved external dependencies.

These must be resolved before implementation can begin.
```

**STOP.** Do not proceed — terminal condition.

**If deps_blocking contains entries:**

> *Output the next fenced block as a code block:*

```
Blocking Dependencies

The plan for "{topic:(titlecase)}" is blocked by incomplete tasks:

@foreach(dep in deps_blocking)
  • {dep.topic}:{dep.task_id} — {dep.reason}
@endforeach

Complete these tasks first, then re-run implementation.
```

**STOP.** Do not proceed — terminal condition.

**If all dependencies satisfied:**

Control returns to the main skill.
