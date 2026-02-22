# Verify Source Material

*Reference for **[technical-planning](../SKILL.md)***

---

Verify that all source material exists and is accessible before entering agent-driven work. Agents will read these files — this step just confirms they are present.

## Verification

1. Read the Plan Index File's frontmatter to get the `specification:` path and any `cross_cutting_specs:` paths
2. For each path, run `ls` to confirm the file exists — do not read the file contents
3. If any file is missing, **STOP** — inform the user which file is missing and do not proceed

### Example

```bash
ls .workflows/specification/{topic}/specification.md
ls .workflows/specification/{cross-cutting-spec}/specification.md
```
