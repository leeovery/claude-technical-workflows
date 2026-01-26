---
description: Test dynamic content - auto-executes discovery script before Claude sees the prompt
allowed-tools: Bash(scripts/discovery-for-specification.sh)
---

# Dynamic Content Test

This command tests whether dynamic content (`!` backtick syntax) causes the discovery script to execute automatically before Claude receives the prompt.

## Discovery Output (Dynamic Content)

The following section should contain the YAML output from the discovery script, auto-executed before you see this prompt:

!`bash scripts/discovery-for-specification.sh`

## Verification

If dynamic content is working correctly:
- The section above should contain actual YAML discovery output (discussions, specifications, cache state)
- You should NOT need to execute the script yourself - it should already be resolved
- You should see entries for: authentication-flow (concluded), api-versioning (concluded), rate-limiting (in-progress)

If dynamic content is NOT working:
- You'll see the literal text with the exclamation mark and backtick syntax instead of YAML output
- You would need to run the script manually as a separate tool call

## Your Task

1. Report whether you see actual YAML discovery output above, or the literal exclamation-backtick syntax
2. If you see actual output, confirm what discussions and their statuses were discovered
3. State clearly: "Dynamic content IS working" or "Dynamic content is NOT working"

Do NOT execute the discovery script yourself. The entire point of this test is to see if it was pre-executed.
