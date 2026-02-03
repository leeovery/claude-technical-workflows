---
name: migrate
description: "Run migrations to keep workflow files in sync with the current system design. This command is mandatory before running any workflow command."
allowed-tools: Bash(.claude/scripts/migrate.sh)
---

# Migrate

Keeps your workflow files up to date with how the system is designed to work. Runs all pending migrations automatically.

## Instructions

Run the migration script:

```bash
.claude/scripts/migrate.sh
```

### If files were updated

The script will list which files were updated. Present this to the user:

```
{list from script output}

Review changes with `git diff`, then proceed when ready.
```

Wait for user acknowledgment before returning control to the calling command.

### If no updates needed

```
All documents up to date.
```

Return control silently - no user interaction needed.

## Notes

- This command is run automatically at the start of every workflow command
- Migrations are tracked in `docs/workflow/.cache/migrations.log`
- To force re-running all migrations, delete the tracking file
- Each migration is idempotent - safe to run multiple times
