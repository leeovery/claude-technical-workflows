# Discovery Flow

*Reference for **[start-planning](../SKILL.md)***

---

Full discovery flow for bare invocation (no topic provided).

## Step A: Run Discovery

!`.claude/skills/start-planning/scripts/discovery.sh`

If the above shows a script invocation rather than YAML output, the dynamic content preprocessor did not run. Execute the script before continuing:

```bash
.claude/skills/start-planning/scripts/discovery.sh
```

If YAML content is already displayed, it has been run on your behalf.

Parse the discovery output to understand:

**From `specifications` section:**
- `exists` - whether any specifications exist
- `feature` - list of feature specs (name, status, has_plan, plan_status, has_impl, impl_status)
- `crosscutting` - list of cross-cutting specs (name, status)
- `counts.feature` - total feature specifications
- `counts.feature_ready` - feature specs ready for planning (concluded + no plan)
- `counts.feature_with_plan` - feature specs that already have plans
- `counts.feature_actionable_with_plan` - specs with plans that are NOT fully implemented
- `counts.feature_implemented` - specs with `impl_status: completed`
- `counts.crosscutting` - total cross-cutting specifications

**From `plans` section:**
- `exists` - whether any plans exist
- `files` - each plan's name, format, status, and plan_id (if present)
- `common_format` - the output format if all existing plans share the same one; empty string otherwise

**From `state` section:**
- `scenario` - one of: `"no_specs"`, `"nothing_actionable"`, `"has_options"`

**IMPORTANT**: Use ONLY this script for discovery. Do NOT run additional bash commands (ls, head, cat, etc.) to gather state.

→ Proceed to **Step B**.

---

## Step B: Route Based on Scenario

Use `state.scenario` from the discovery output to determine the path:

#### If scenario is "no_specs"

No specifications exist yet.

> *Output the next fenced block as a code block:*

```
Planning Overview

No specifications found in .workflows/specification/

The planning phase requires a concluded specification.
Run /start-specification first.
```

**STOP.** Do not proceed — terminal condition.

#### If scenario is "nothing_actionable"

Specifications exist but none are actionable.

→ Proceed to **Step C** to show the state (may have completed or in-progress specs).

#### If scenario is "has_options"

At least one specification is ready for planning.

→ Proceed to **Step C** to present options.

---

## Step C: Present Workflow State and Options

Load **[display-state.md](display-state.md)** and follow its instructions as written.

When selection is made, return to main skill **Step 4** with:
- Selected topic
- Whether plan exists (for route decision)
