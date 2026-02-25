# Discovery Flow

*Reference for **[start-investigation](../SKILL.md)***

---

Full discovery flow for bare invocation (no topic provided).

## Step A: Run Discovery

!`.claude/skills/start-investigation/scripts/discovery.sh`

If the above shows a script invocation rather than YAML output, the dynamic content preprocessor did not run. Execute the script before continuing:

```bash
.claude/skills/start-investigation/scripts/discovery.sh
```

Parse the discovery output to understand:

**From `investigations` section:**
- `exists` - whether investigation files exist
- `files` - each investigation's topic, status, and date
- `counts.in_progress` and `counts.concluded` - totals for routing

**From `state` section:**
- `scenario` - one of: `"fresh"`, `"has_investigations"`

**IMPORTANT**: Use ONLY this script for discovery. Do NOT run additional bash commands (ls, head, cat, etc.) to gather state.

→ Proceed to **Step B**.

---

## Step B: Route Based on Scenario

Use `state.scenario` from the discovery output to determine the path:

#### If scenario is "has_investigations"

> *Output the next fenced block as a code block:*

```
Investigations Overview

@if(investigations.counts.in_progress > 0)
In Progress:
@foreach(inv in investigations.files where status is in-progress)
  • {inv.topic}
@endforeach
@endif

@if(investigations.counts.concluded > 0)
Concluded:
@foreach(inv in investigations.files where status is concluded)
  • {inv.topic}
@endforeach
@endif
```

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
What would you like to do?

@if(in_progress investigations exist)
{N}. Resume "{topic}" investigation
@endforeach
@endif
{N}. Start new investigation
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

If resuming → return to main skill **Step 4** with topic and resume=true.
If new → proceed to **Step C**.

#### If scenario is "fresh"

> *Output the next fenced block as a code block:*

```
No existing investigations found.
```

→ Proceed to **Step C**.

---

## Step C: Gather Bug Context

> *Output the next fenced block as a code block:*

```
Starting new investigation.

What bug are you investigating? Please provide:
- A short identifier/name for tracking (e.g., "login-timeout-bug")
- What's broken (expected vs actual behavior)
- Any initial context (error messages, how it manifests)
```

**STOP.** Wait for user response.

→ Proceed to **Step D**.

---

## Step D: Topic Name and Conflict Check

If the user didn't provide a clear topic name, suggest one based on the bug description:

> *Output the next fenced block as a code block:*

```
Suggested topic name: {suggested-topic:(kebabcase)}

This will create: .workflows/investigation/{suggested-topic}/investigation.md
```

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
Is this name okay?

- **`y`/`yes`** — Use this name
- **`s`/`something else`** — Suggest a different name
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

Once the topic name is confirmed, check for naming conflicts in the discovery output.

If an investigation with the same name exists, inform the user:

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
An investigation named "{topic}" already exists.

- **`r`/`resume`** — Resume the existing investigation
- **`n`/`new`** — Choose a different name
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

If resuming, check the investigation status. If concluded → suggest `/start-specification` with topic + bugfix. If in-progress → return to main skill **Step 4**.

→ Return to main skill **Step 4** with topic and gathered context.
