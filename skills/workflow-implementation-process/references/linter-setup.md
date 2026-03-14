# Linter Setup

*Reference for **[workflow-implementation-process](../SKILL.md)***

---

Discover and configure project linters for use during the TDD cycle's LINT step. Linters run after every REFACTOR to catch mechanical issues (formatting, unused imports, type errors) that are cheaper to fix immediately than in review.

---

Check `linters` via manifest CLI:

```bash
node .claude/skills/workflow-manifest/scripts/manifest.js get {work_unit}.implementation.{topic} linters
```

#### If `linters` is populated

Present the existing configuration for confirmation:

> *Output the next fenced block as markdown (not a code block):*

```
Previous session used these linters:
- **{name}** — `{command}`
- ...

· · · · · · · · · · · ·
Keep these linters?

- **`y`/`yes`** — Keep and proceed
- **`c`/`change`** — Re-discover linters
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

#### If `yes`

→ Return to **[the skill](../SKILL.md)**.

#### If `change`

Clear `linters` and fall through to discovery below.

#### If `linters` is empty

Query the phase-level recommendation:

```bash
node .claude/skills/workflow-manifest/scripts/manifest.js get {work_unit}.implementation linters
```

#### If phase-level is a non-empty array

> *Output the next fenced block as markdown (not a code block):*

```
Previous implementations used these linters:
- **{name}** — `{command}`
- ...

· · · · · · · · · · · ·
Use the same linters?

- **`y`/`yes`** — Use the same and proceed
- **`n`/`no`** — Run full linter discovery
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

**If `yes`:** Copy phase-level array to topic level:
```bash
node .claude/skills/workflow-manifest/scripts/manifest.js set {work_unit}.implementation.{topic} linters [{phase-level values}]
```
→ Return to **[the skill](../SKILL.md)**.

**If `no`:** Fall through to discovery below.

#### If phase-level is an empty array

> *Output the next fenced block as markdown (not a code block):*

```
Previous implementations skipped linters.

· · · · · · · · · · · ·
Skip linters again?

- **`y`/`yes`** — Skip and proceed
- **`n`/`no`** — Run full linter discovery
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

**If `yes`:** → Return to **[the skill](../SKILL.md)**.

**If `no`:** Fall through to discovery below.

#### If no phase-level field exists

Fall through to discovery below.

---

## Discovery Process

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

> *Output the next fenced block as markdown (not a code block):*

```
**Linter discovery:**
- {tool} — `{command}` (installed / not installed)
- ...

Recommendations: {any suggested tools with install commands}

· · · · · · · · · · · ·
Approve these linters?

- **`y`/`yes`** — Approve and proceed
- **`c`/`change`** — Modify the linter list
- **`s`/`skip`** — Skip linter setup (no linting during TDD)
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

#### If `yes`

Store the approved linter commands and write to phase level so future topics receive a recommendation:
```bash
node .claude/skills/workflow-manifest/scripts/manifest.js set {work_unit}.implementation.{topic} linters [...]
node .claude/skills/workflow-manifest/scripts/manifest.js set {work_unit}.implementation linters [...]
```

→ Return to **[the skill](../SKILL.md)**.

#### If `change`

Adjust based on user input, re-present for confirmation.

#### If `skip`

Store empty linters array and write to phase level:
```bash
node .claude/skills/workflow-manifest/scripts/manifest.js set {work_unit}.implementation.{topic} linters []
node .claude/skills/workflow-manifest/scripts/manifest.js set {work_unit}.implementation linters []
```

→ Return to **[the skill](../SKILL.md)**.

## Storage

Linter commands are stored in the manifest as a `linters` array. Write to both topic level and phase level so future topics receive a recommendation.

Each entry has:
- **name** — identifier for display
- **command** — the exact shell command to run (including flags)
