---
name: create-output-format
description: Scaffold a new planning output format adapter. Creates a format directory with all required files implementing the output format contract.
disable-model-invocation: true
---

# Create Output Format

Scaffold a new output format adapter for the technical-planning workflow. Each format adapter is a directory of 5 files, one per concern.

## Step 1: Gather Information

Before writing anything, interview the user to understand the format. Use AskUserQuestion for each area where information is missing or unclear.

### Required Information

Gather all of the following. If the user provided some upfront (e.g., in their initial message), skip those questions.

1. **Tool/system name** — What is the external tool or system? (e.g., Linear, Jira, Notion, Tick)
2. **Format key** — A kebab-case identifier for directory naming (e.g., `linear`, `jira`, `notion`). Suggest one based on the tool name; confirm with user.
3. **Why this format** — What's the motivation? Why would someone choose this over local markdown? What are the benefits?
4. **How tasks are stored** — Where do tasks live? (API, database, files, etc.) How are they created, read, updated?
5. **How to interact** — What's the interface? (MCP server, REST API, CLI tool, filesystem) What are the specific commands or calls?
6. **Setup requirements** — What needs to be installed or configured? (accounts, API keys, MCP servers, CLI tools)
7. **Documentation** — Links to official docs, API references, MCP server documentation. Ask for anything that would help understand the system's capabilities and constraints.
8. **Dependencies and limitations** — Does it support blocking/dependency relationships between tasks? Any known limitations?

### Research Documentation

If the user provides documentation links:

1. Fetch and read each link using WebFetch
2. Extract information relevant to task storage: creating, reading, updating, querying, dependencies
3. Note any constraints or limitations that affect how the format adapter should work
4. Summarise what you've learned and confirm your understanding with the user before proceeding

If the user doesn't have links, ask if they can point you to docs. If no docs are available, proceed with what the user can describe directly — but flag gaps where documentation would help.

### Confirm Understanding

Before moving to scaffolding, present a brief summary of what you've gathered:

- **Format**: {name} (`{format-key}`)
- **Storage**: {where tasks live}
- **Interface**: {how to interact — MCP/API/CLI/etc.}
- **Setup**: {what's required}
- **Dependencies**: {supported/not supported/limited}
- **Key constraints**: {any limitations to be aware of}

Ask the user to confirm or correct. Do not proceed until confirmed.

## Step 2: Understand the Contract

Read **[references/contract.md](references/contract.md)** — this defines the 5-file interface every format must implement.

## Step 3: Create the Format Directory

Create the directory at:

```
skills/technical-planning/references/output-formats/{format-key}/
```

## Step 4: Write the Files

Using the information gathered in Step 1, write each of the 5 required files. Use the scaffolding templates from **[references/scaffolding/](references/scaffolding/)** as structural guides:

| Template | Creates |
|----------|---------|
| [about.md](references/scaffolding/about.md) | `{format}/about.md` |
| [authoring.md](references/scaffolding/authoring.md) | `{format}/authoring.md` |
| [reading.md](references/scaffolding/reading.md) | `{format}/reading.md` |
| [updating.md](references/scaffolding/updating.md) | `{format}/updating.md` |
| [dependencies.md](references/scaffolding/dependencies.md) | `{format}/dependencies.md` |

For each file:

1. Start from the scaffolding template structure
2. Replace all `{placeholder}` tokens with format-specific content from your gathered information
3. Remove template guidance comments (lines starting with `<!-- -->`)
4. Include concrete commands, API calls, or MCP operations — not vague descriptions

## Step 5: Register the Format

Add an entry to `skills/technical-planning/references/output-formats.md` following the existing pattern:

```markdown
### {Format Name}
format: `{format-key}`

adapter: [{format-key}/](output-formats/{format-key}/)

{One-line description of the format.}

- **Pros**: ...
- **Cons**: ...
- **Best for**: ...
```

## Step 6: Validate

Verify:

- [ ] Directory contains exactly 5 files: about.md, authoring.md, reading.md, updating.md, dependencies.md
- [ ] All `{placeholder}` tokens have been replaced
- [ ] Authoring.md describes where/how to store task content with concrete operations
- [ ] Reading.md provides clear instructions for extracting next task
- [ ] Updating.md provides clear instructions for marking tasks complete
- [ ] Dependencies.md describes dependency support (or explicitly states it's unsupported)
- [ ] Format is registered in output-formats.md
