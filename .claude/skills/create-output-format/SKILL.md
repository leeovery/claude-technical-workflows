---
name: create-output-format
description: Scaffold a new planning output format adapter. Creates a format directory with all required files implementing the output format contract.
disable-model-invocation: true
---

# Create Output Format

Scaffold a new output format adapter for the technical-planning workflow. Each format adapter is a directory of 6 files, one per concern.

## Prerequisites

Before creating a new format, ensure you have:

- A clear understanding of where tasks will be stored (local files, external tool, API)
- Knowledge of any external dependencies (CLI tools, MCP servers, APIs)
- The format name as a kebab-case identifier (e.g., `my-format`)

## Step 1: Understand the Contract

Read **[references/contract.md](references/contract.md)** — this defines the 6-file interface every format must implement.

## Step 2: Create the Format Directory

Create the directory at:

```
skills/technical-planning/references/output-formats/{format-name}/
```

## Step 3: Scaffold the Files

For each of the 6 required files, use the corresponding scaffolding template from **[references/scaffolding/](references/scaffolding/)** as a starting point:

1. Copy each template into the new format directory
2. Replace all `{placeholder}` tokens with format-specific content
3. Remove template guidance comments (lines starting with `<!-- -->`)

The scaffolding templates are:

| Template | Creates |
|----------|---------|
| [about.md](references/scaffolding/about.md) | `{format}/about.md` |
| [authoring.md](references/scaffolding/authoring.md) | `{format}/authoring.md` |
| [reading.md](references/scaffolding/reading.md) | `{format}/reading.md` |
| [updating.md](references/scaffolding/updating.md) | `{format}/updating.md` |
| [dependencies.md](references/scaffolding/dependencies.md) | `{format}/dependencies.md` |
| [frontmatter.md](references/scaffolding/frontmatter.md) | `{format}/frontmatter.md` |

## Step 4: Register the Format

Add an entry to `skills/technical-planning/references/output-formats.md` following the existing pattern:

```markdown
### {Format Name}
format: `{format-name}`

adapter: [{format-name}/](output-formats/{format-name}/)

{One-line description of the format.}

- **Pros**: ...
- **Cons**: ...
- **Best for**: ...
```

## Step 5: Validate

Verify:

- [ ] Directory contains exactly 6 files: about.md, authoring.md, reading.md, updating.md, dependencies.md, frontmatter.md
- [ ] All `{placeholder}` tokens have been replaced
- [ ] Authoring.md describes where/how to store task content (not what the content is — that's the planning skill's concern)
- [ ] Reading.md provides clear instructions for extracting next task
- [ ] Updating.md provides clear instructions for marking tasks complete
- [ ] Frontmatter.md defines both Plan Index and task frontmatter schemas
- [ ] Format is registered in output-formats.md
