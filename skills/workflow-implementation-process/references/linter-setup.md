# Linter Setup

*Reference for **[workflow-implementation-process](../SKILL.md)***

---

Discover and configure project linters for use during the TDD cycle's LINT step. Linters run after every REFACTOR to catch mechanical issues (formatting, unused imports, type errors) that are cheaper to fix immediately than in review.

---

## A. Resolve Configuration

Read topic-level `linters` via manifest CLI:

```bash
node .claude/skills/workflow-manifest/scripts/manifest.js get {work_unit}.implementation.{topic} linters
```

#### If `linters` is populated

Set `source` = `topic`.

→ Proceed to **B. Confirm Linters**.

#### Otherwise

Check if phase-level `linters` exists via manifest CLI:

```bash
node .claude/skills/workflow-manifest/scripts/manifest.js exists {work_unit}.implementation linters
```

**If `false`:**

→ Proceed to **C. Discovery**.

**If `true`:**

Read phase-level `linters` via manifest CLI:

```bash
node .claude/skills/workflow-manifest/scripts/manifest.js get {work_unit}.implementation linters
```

**If phase-level is populated:**

Set `source` = `phase`.

→ Proceed to **B. Confirm Linters**.

**If phase-level is empty:**

> *Output the next fenced block as a code block:*

```
Previous implementations skipped linters.
```

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
Skip linters again?

- **`y`/`yes`** — Skip and proceed
- **`n`/`no`** — Run full linter discovery
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

**If `yes`:**

→ Return to **[the skill](../SKILL.md)**.

**If `no`:**

→ Proceed to **C. Discovery**.

---

## B. Confirm Linters

List the linters returned by the `source` level manifest query.

> *Output the next fenced block as a code block:*

```
Linters found:

  • {name} — {command}
  • ...
```

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
Use these linters?

- **`y`/`yes`** — Use and proceed
- **`n`/`no`** — Re-discover linters
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

#### If `yes`

**If `source` is `phase`:**

Copy to topic level:
```bash
node .claude/skills/workflow-manifest/scripts/manifest.js set {work_unit}.implementation.{topic} linters [{phase-level values}]
```

→ Return to **[the skill](../SKILL.md)**.

#### If `no`

Clear topic-level `linters` before re-discovery:
```bash
node .claude/skills/workflow-manifest/scripts/manifest.js set {work_unit}.implementation.{topic} linters []
```

→ Proceed to **C. Discovery**.

---

## C. Discovery

1. **Identify project languages** — check file extensions, package files (`composer.json`, `package.json`, `go.mod`, `Cargo.toml`, `pyproject.toml`, etc.), and project skills in `.claude/skills/`
2. **Check for existing linter configs** — look for config files in the project root:
   - PHP: `phpstan.neon`, `phpstan.neon.dist`, `pint.json`, `.php-cs-fixer.php`
   - JavaScript/TypeScript: `.eslintrc*`, `eslint.config.*`, `biome.json`
   - Go: `.golangci.yml`, `.golangci.yaml`
   - Python: `pyproject.toml` (ruff/mypy sections), `setup.cfg`, `.flake8`
   - Rust: `rustfmt.toml`, `clippy.toml`
3. **Verify tools are installed** — run each discovered tool with `--version` or equivalent to confirm it's available
4. **Recommend if none found** — if a language is detected but no linter is configured, suggest best-practice tools (e.g., PHPStan + Pint for PHP, ESLint for JS/TS, golangci-lint for Go). Include install commands.

Present discovery findings to the user:

> *Output the next fenced block as a code block:*

```
Linter discovery:

  • {tool} — {command} (installed / not installed)
  • ...

Recommendations: {any suggested tools with install commands}
```

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
Approve these linters?

- **`y`/`yes`** — Approve and proceed
- **`c`/`change`** — Modify the linter list
- **`s`/`skip`** — Skip linter setup (no linting during TDD)
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

#### If `yes`

Store at both levels:
```bash
node .claude/skills/workflow-manifest/scripts/manifest.js set {work_unit}.implementation.{topic} linters [...]
node .claude/skills/workflow-manifest/scripts/manifest.js set {work_unit}.implementation linters [...]
```

→ Return to **[the skill](../SKILL.md)**.

#### If `change`

Adjust based on user input, re-present for confirmation.

#### If `skip`

Store empty array at both levels:
```bash
node .claude/skills/workflow-manifest/scripts/manifest.js set {work_unit}.implementation.{topic} linters []
node .claude/skills/workflow-manifest/scripts/manifest.js set {work_unit}.implementation linters []
```

→ Return to **[the skill](../SKILL.md)**.

---

## Storage

Linter commands are stored in the manifest as a `linters` array. Write to both topic level and phase level so future topics receive a recommendation.

Each entry has:
- **name** — identifier for display
- **command** — the exact shell command to run (including flags)
