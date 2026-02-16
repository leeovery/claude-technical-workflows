---
name: continue-feature
description: "Continue a feature through the pipeline. Routes to the next phase (specification, planning, or implementation) based on artifact state. Can be invoked manually or from plan mode bridges."
allowed-tools: Bash(.claude/skills/continue-feature/scripts/discovery.sh)
---

Route a feature to its next pipeline phase.

> **⚠️ ZERO OUTPUT RULE**: Do not narrate your processing. Produce no output until a step or reference file explicitly specifies display content. No "proceeding with...", no discovery summaries, no routing decisions, no transition text. Your first output must be content explicitly called for by the instructions.

## Instructions

Follow these steps EXACTLY as written. Do not skip steps or combine them. Present output using the EXACT format shown in examples - do not simplify or alter the formatting.

**CRITICAL**: This guidance is mandatory.

- After each user interaction, STOP and wait for their response before proceeding
- Never assume or anticipate user choices
- Complete each step fully before moving to the next

---

## Step 0: Run Migrations

**This step is mandatory. You must complete it before proceeding.**

Invoke the `/migrate` skill and assess its output.

**If files were updated**: STOP and wait for the user to review the changes (e.g., via `git diff`) and confirm before proceeding to Step 1. Do not continue automatically.

**If no updates needed**: Proceed to Step 1.

---

## Step 1: Determine Topic

Check whether a topic was provided by the caller (e.g., from a plan mode bridge: "invoke continue-feature for {topic}").

#### If topic was provided

Use the provided topic directly.

→ Proceed to **Step 2**.

#### If no topic provided (bare invocation)

Run the discovery script:

```bash
.claude/skills/continue-feature/scripts/discovery.sh
```

Parse the output to understand:

**From `topics` array:** Each topic's name, discussion/specification/plan/implementation state, next_phase, and actionable flag.

**From `state` section:** topic_count, actionable_count, scenario.

**IMPORTANT**: Use ONLY this script for discovery. Do NOT run additional bash commands (ls, head, cat, etc.) to gather state.

**Route by scenario:**

#### If scenario is "no_topics"

> *Output the next fenced block as a code block:*

```
Continue Feature

No feature topics found in the workflow directories.

Start a new feature with /start-feature or begin a discussion
with /start-discussion.
```

**STOP.** Do not proceed — terminal condition.

#### If scenario is "single_topic"

If the topic is actionable:

> *Output the next fenced block as a code block:*

```
Automatically proceeding with "{topic:(titlecase)}".
```

Use this topic.

If the topic is not actionable (done or unknown), handle as terminal — see Step 2.

→ Proceed to **Step 2**.

#### If scenario is "multiple_topics"

Present all topics with their state:

> *Output the next fenced block as a code block:*

```
Continue Feature

{N} feature topics found. {M} actionable.

1. {topic:(titlecase)}
   └─ Next: {next_phase}
   └─ Discussion: @if(disc_exists) {disc_status} @else (none) @endif
   └─ Spec: @if(spec_exists) {spec_status} @else (none) @endif
   └─ Plan: @if(plan_exists) {plan_status} ({format}) @else (none) @endif
   └─ Implementation: @if(impl_exists) {impl_status} @else (none) @endif

2. ...
```

If any topics are not actionable (done), show them in a separate block:

> *Output the next fenced block as a code block:*

```
Completed features:

  • {topic} (done)
```

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
1. Continue "{Topic}" — next: {next_phase}
2. Continue "{Topic}" — next: {next_phase}

Select a feature to continue (enter number):
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

→ Proceed to **Step 2**.

---

## Step 2: Detect Phase and Route

Load **[detect-phase.md](references/detect-phase.md)** and follow its instructions to determine routing.

The detect-phase reference will direct you to one of:
- **Step 3** (specification)
- **Step 4** (planning)
- **Step 5** (implementation)
- **Terminal** (done or discussion)

---

## Step 3: Specification Phase

Load **[invoke-specification.md](references/invoke-specification.md)** and follow its instructions.

After the processing skill concludes (specification status becomes "concluded"):

→ Proceed to **Step 6**.

**Recovery checkpoint**: If context was compacted, check `docs/workflow/specification/{topic}/specification.md`. If it exists and has `status: concluded` → proceed to Step 6. If `status: in-progress` → resume specification. If absent → re-enter Step 3.

---

## Step 4: Planning Phase

Load **[invoke-planning.md](references/invoke-planning.md)** and follow its instructions.

After the processing skill concludes (plan status becomes "concluded"):

→ Proceed to **Step 6**.

**Recovery checkpoint**: If context was compacted, check `docs/workflow/planning/{topic}/plan.md`. If it exists and has `status: concluded` → proceed to Step 6. If `status: in-progress` or `status: planning` → resume planning. If absent → re-enter Step 4.

---

## Step 5: Implementation Phase

Load **[invoke-implementation.md](references/invoke-implementation.md)** and follow its instructions.

After the processing skill concludes (implementation tracking status becomes "completed"):

→ Proceed to **Step 6**.

**Recovery checkpoint**: If context was compacted, check `docs/workflow/implementation/{topic}/tracking.md`. If it exists and has `status: completed` → proceed to Step 6. If `status: in-progress` → resume implementation. If absent → re-enter Step 5.

---

## Step 6: Phase Bridge

Load **[phase-bridge.md](references/phase-bridge.md)** and follow its instructions.

The bridge will enter plan mode with instructions to invoke continue-feature for the topic in the next session.
