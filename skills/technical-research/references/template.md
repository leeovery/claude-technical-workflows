# Research Document Template

Use this template when creating research documents.

## Frontmatter

```yaml
---
topic: {topic-name}
date: YYYY-MM-DD
---
```

**Fields:**
- `topic`: Use `exploration` for the initial exploration file. Use semantic names (`market-landscape`, `technical-feasibility`) when splitting into focused files.
- `date`: Date the document was created.

## Structure

```markdown
---
topic: exploration
date: 2026-01-21
---

# Research: {Title}

Brief description of what this research covers and what prompted it.

---

{Content follows - freeform, managed by the skill}
```

## Notes

- The content after the description is intentionally unstructured
- Let themes emerge naturally during exploration
- When splitting into topic files, update the `topic` field to match the filename
- The skill handles content organization during sessions
