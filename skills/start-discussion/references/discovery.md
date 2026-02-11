# Discovery State

*Reference for **[start-discussion](../SKILL.md)***

---

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

**IMPORTANT**: Use ONLY this script for discovery. Do NOT run additional bash commands (ls, head, cat, etc.) to gather state - the script provides everything needed.
