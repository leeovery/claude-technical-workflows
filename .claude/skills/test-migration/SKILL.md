---
name: test-migration
description: "Run migration integration tests against a real workflow directory. Copies files, runs migrate.sh, and asserts log normalization, idempotency, and file integrity."
allowed-tools: Bash(tests/scripts/test-migration-integration.sh *), Bash(tests/scripts/test-migration-*.sh)
---

# Test Migration

Run the migration integration test suite against a real project's workflow files.

## Instructions

Ask the user for the path to a workflow directory if not provided as an argument. The path should point to a `docs/workflow` directory containing discussion, specification, planning files, and a `.cache/migrations.log`.

Run the integration test:

```bash
bash tests/scripts/test-migration-integration.sh {path-to-docs/workflow}
```

Present the output to the user. If all tests pass, offer to also run the individual migration unit tests (001–007):

```bash
bash tests/scripts/test-migration-001.sh
bash tests/scripts/test-migration-002.sh
bash tests/scripts/test-migration-003.sh
bash tests/scripts/test-migration-004.sh
bash tests/scripts/test-migration-005.sh
bash tests/scripts/test-migration-006.sh
bash tests/scripts/test-migration-007.sh
```
