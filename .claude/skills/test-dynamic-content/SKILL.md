---
name: test-dynamic-content
description: "Test dynamic content injection. Verifies that the exclamation-backtick syntax auto-executes the discovery script before Claude sees the prompt. Use when testing whether dynamic context injection is working."
allowed-tools: Bash(.claude/skills/test-dynamic-content/scripts/discovery-for-specification.sh)
---

# Dynamic Content Test

This skill tests whether dynamic context injection causes the discovery script to execute automatically before Claude sees the prompt.

## Discovery Output (Dynamic Content)

The following section should contain the YAML output from the discovery script, auto-executed before you see this prompt:

!`bash .claude/skills/test-dynamic-content/scripts/discovery-for-specification.sh`

## Verification

If dynamic content is working correctly:
- The section above should contain actual YAML discovery output (discussions, specifications, cache state)
- You should NOT need to execute the script yourself - it should already be resolved
- You should see entries for: authentication-flow (concluded), api-versioning (concluded), rate-limiting (in-progress)

If dynamic content is NOT working:
- You will see the literal exclamation-backtick syntax instead of YAML output
- You would need to run the script manually as a separate tool call

## Your Task

1. Report whether you see actual YAML discovery output above, or the raw unresolved syntax
2. If you see actual output, confirm what discussions and their statuses were discovered
3. State clearly: "Dynamic content IS working" or "Dynamic content is NOT working"

Do NOT execute the discovery script yourself. The entire point of this test is to see if it was pre-executed.
