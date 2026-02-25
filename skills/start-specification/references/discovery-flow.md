# Discovery Flow

*Reference for **[start-specification](../SKILL.md)***

---

Full discovery flow for bare invocation (no topic provided).

## Step A: Run Discovery

!`.claude/skills/start-specification/scripts/discovery.sh`

If the above shows a script invocation rather than YAML output, the dynamic content preprocessor did not run. Execute the script before continuing:

```bash
.claude/skills/start-specification/scripts/discovery.sh
```

If YAML content is already displayed, it has been run on your behalf.

Parse the discovery output to understand:

**From `discussions` array:** Each discussion's name, status, and whether it has an individual specification.

**From `specifications` array:** Each specification's name, status, sources, and superseded_by (if applicable). Specifications with `status: superseded` should be noted but excluded from active counts.

**From `cache` section:** `status` (valid/stale/none), `reason`, `generated`, `anchored_names`.

**From `current_state`:** `concluded_count`, `spec_count`, `has_discussions`, `has_concluded`, `has_specs`, and other counts/booleans for routing.

**IMPORTANT**: Use ONLY this script for discovery. Do NOT run additional bash commands (ls, head, cat, etc.) to gather state.

→ Proceed to **Step B**.

---

## Step B: Check Prerequisites

#### If has_discussions is false or has_concluded is false

→ Load **[display-blocks.md](display-blocks.md)** and follow its instructions. **STOP.**

#### Otherwise

→ Proceed to **Step C**.

---

## Step C: Route Based on State

Based on discovery state, load exactly ONE reference file:

#### If concluded_count == 1

→ Load **[display-single.md](display-single.md)** and follow its instructions.

→ Return to main skill **Step 4** (Invoke) with selection.

#### If cache status is "valid"

→ Load **[display-groupings.md](display-groupings.md)** and follow its instructions.

→ Return to main skill **Step 4** (Invoke) with selection.

#### If spec_count == 0 and cache is "none" or "stale"

→ Load **[display-analyze.md](display-analyze.md)** and follow its instructions.

→ Return to main skill **Step 4** (Invoke) with selection.

#### Otherwise

→ Load **[display-specs-menu.md](display-specs-menu.md)** and follow its instructions.

→ Return to main skill **Step 4** (Invoke) with selection.
