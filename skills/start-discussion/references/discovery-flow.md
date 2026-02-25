# Discovery Flow

*Reference for **[start-discussion](../SKILL.md)***

---

Full discovery flow for bare invocation (no topic provided).

## Step A: Run Discovery

!`.claude/skills/start-discussion/scripts/discovery.sh`

If the above shows a script invocation rather than YAML output, the dynamic content preprocessor did not run. Execute the script before continuing:

```bash
.claude/skills/start-discussion/scripts/discovery.sh
```

If YAML content is already displayed, it has been run on your behalf.

Parse the discovery output to understand:

**From `research` section:**
- `exists` - whether research files exist
- `files` - each research file's name and topic
- `checksum` - current checksum of all research files

**From `discussions` section:**
- `exists` - whether discussion files exist
- `files` - each discussion's name, status, and date
- `counts.in_progress` and `counts.concluded` - totals for routing

**From `cache` section:**
- `status` - one of three values:
  - `"valid"` - cache exists and checksums match (safe to load)
  - `"stale"` - cache exists but research has changed (needs re-analysis)
  - `"none"` - no cache file exists
- `reason` - explanation of the status
- `generated` - when the cache was created (null if none)
- `research_files` - list of files that were analyzed

**From `state` section:**
- `scenario` - one of: `"fresh"`, `"research_only"`, `"discussions_only"`, `"research_and_discussions"`

**IMPORTANT**: Use ONLY this script for discovery. Do NOT run additional bash commands (ls, head, cat, etc.) to gather state.

→ Proceed to **Step B**.

---

## Step B: Route Based on Scenario

Use `state.scenario` from the discovery output to determine the path:

#### If scenario is "research_only" or "research_and_discussions"

Research exists and may need analysis.

→ Proceed to **Step C**.

#### If scenario is "discussions_only"

No research exists, but discussions do. Skip research analysis.

→ Proceed to **Step D**.

#### If scenario is "fresh"

No research or discussions exist yet.

```
Starting fresh - no prior research or discussions found.

What topic would you like to discuss?
```

**STOP.** Wait for user response.

When user responds, proceed with their topic.

→ Return to main skill **Step 4** (Gather Context) with topic and path="fresh".

---

## Step C: Research Analysis

Load **[research-analysis.md](research-analysis.md)** and follow its instructions as written.

→ Proceed to **Step D**.

---

## Step D: Present Options

Load **[display-options.md](display-options.md)** and follow its instructions as written.

→ Proceed to **Step E**.

---

## Step E: Handle Selection

Load **[handle-selection.md](handle-selection.md)** and follow its instructions as written.

→ Return to main skill **Step 4** (Gather Context) with selected topic and path.
