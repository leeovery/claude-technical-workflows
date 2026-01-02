# Environment Setup

*Reference for **[technical-implementation](../SKILL.md)***

---

Before starting implementation, ensure the environment is ready. This step runs once per project (or when setup changes).

## Setup Document Location

Look for: `docs/workflow/environment-setup.md`

This file contains natural language instructions for setting up the implementation environment. It's project-specific and maintained by the team.

## If Setup Document Exists

Read and follow the instructions. Common setup tasks include:

- Installing language extensions (e.g., PHP SQLite extension)
- Installing CLI tools required by the plan format
- Copying environment files (e.g., `cp .env.example .env`)
- Generating application keys
- Running database migrations
- Setting up test databases
- Installing project dependencies

Execute each instruction and verify it succeeds before proceeding.

## If Setup Document Missing

Ask the user:

> "No environment setup document found. Are there any setup instructions I should follow before implementing?"

If they provide instructions, offer to save them:

> "Would you like me to save these instructions to `docs/workflow/environment-setup.md` for future sessions?"

## Plan Format Setup

Some plan formats require specific tools:

### Beads Format

If the plan uses `format: beads`, ensure the `bd` CLI is available:

```bash
# Check if installed
which bd
```

If not installed (common in ephemeral environments like Claude Code on the web):
```bash
curl -sSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash
```

On local systems, beads may already be installed via Homebrew - always check first.

```bash
# Initialize if .beads/ doesn't exist
bd init
```

### Linear Format

Requires Linear MCP server. If unavailable, inform the user.

### Backlog.md Format

Works with Backlog.md MCP or by reading files from `backlog/` directory directly.

## Example Setup Document

```markdown
# Environment Setup

Instructions for setting up the implementation environment.

## First-Time Setup

1. Copy environment file:
   ```bash
   cp .env.example .env
   ```

2. Generate application key:
   ```bash
   php artisan key:generate
   ```

3. Set up test database:
   ```bash
   touch database/testing.sqlite
   php artisan migrate --env=testing
   ```

## Claude Code on the Web

Additional setup for web-based Claude Code sessions:

1. Install PHP SQLite extension:
   ```bash
   sudo apt-get update && sudo apt-get install -y php-sqlite3
   ```

2. If using Beads format:
   ```bash
   curl -sSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash
   ```

## Verification

Run tests to verify setup:
```bash
php artisan test
```
```

## When to Re-Run Setup

- New Claude Code session (especially on the web)
- After pulling changes that modify dependencies
- When switching to a different plan format
- When tests fail due to environment issues
