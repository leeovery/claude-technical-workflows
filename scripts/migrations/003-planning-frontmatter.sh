#!/usr/bin/env bash
#
# 003-planning-frontmatter.sh
#
# Migrates plan documents from legacy format to full YAML frontmatter.
#
# Legacy format (partial frontmatter + inline metadata):
#   ---
#   format: local-markdown
#   ---
#
#   # Implementation Plan: {Feature/Project Name}
#
#   **Date**: YYYY-MM-DD
#   **Status**: Draft | Ready | In Progress | Completed
#   **Specification**: `docs/workflow/specification/{topic}.md`
#
# New format (all metadata in frontmatter):
#   ---
#   topic: {topic-name}
#   status: in-progress | concluded
#   date: YYYY-MM-DD
#   format: local-markdown
#   specification: {topic}.md
#   ---
#
#   # Implementation Plan: {Feature/Project Name}
#
# Status mapping (normalized across all document types):
#   Draft, Ready, In Progress → in-progress
#   Completed, Done → concluded
#
# This script is sourced by migrate.sh and has access to:
#   - is_migrated "filepath" "migration_id"
#   - record_migration "filepath" "migration_id"
#   - report_update "filepath" "description"
#   - report_skip "filepath"
#

MIGRATION_ID="003"
PLAN_DIR="docs/workflow/planning"

# Skip if no planning directory
if [ ! -d "$PLAN_DIR" ]; then
    return 0
fi

# Process each plan file
for file in "$PLAN_DIR"/*.md; do
    [ -f "$file" ] || continue

    # Check if already migrated via tracking
    if is_migrated "$file" "$MIGRATION_ID"; then
        report_skip "$file"
        continue
    fi

    # Check if file already has full frontmatter (topic field present)
    if head -10 "$file" 2>/dev/null | grep -q "^topic:"; then
        # Already has full frontmatter - just record and skip
        record_migration "$file" "$MIGRATION_ID"
        report_skip "$file"
        continue
    fi

    # Check if file has legacy format indicators
    # Legacy format has partial frontmatter (format:) OR inline **Date**/**Status**/**Specification**
    has_partial_frontmatter=$(head -5 "$file" 2>/dev/null | grep -c "^format:" || echo "0")
    has_inline_metadata=$(grep -c '^\*\*Date\*\*:\|^\*\*Status\*\*:\|^\*\*Specification\*\*:' "$file" 2>/dev/null || echo "0")

    if [ "$has_partial_frontmatter" = "0" ] && [ "$has_inline_metadata" = "0" ]; then
        # No legacy format found - might be malformed, skip
        record_migration "$file" "$MIGRATION_ID"
        report_skip "$file"
        continue
    fi

    #
    # Extract values from legacy format
    #

    # Use filename as topic (canonical identifier throughout the workflow)
    topic_kebab=$(basename "$file" .md)

    # Extract format from existing frontmatter (if present)
    format_value=$(sed -n '/^---$/,/^---$/p' "$file" 2>/dev/null | grep "^format:" | sed 's/^format:[[:space:]]*//' | xargs || echo "")
    if [ -z "$format_value" ]; then
        format_value="local-markdown"  # Default format
    fi

    # Extract status from **Status**: Value
    status_raw=$(grep -m1 '^\*\*Status\*\*:' "$file" 2>/dev/null | \
        sed 's/^\*\*Status\*\*:[[:space:]]*//' | \
        tr '[:upper:]' '[:lower:]' | \
        xargs || echo "")

    # Map legacy status to normalized values
    case "$status_raw" in
        "draft"|"ready"|"in progress"|"in-progress")
            status_new="in-progress"
            ;;
        "completed"|"complete"|"done"|"concluded")
            status_new="concluded"
            ;;
        *)
            status_new="in-progress"  # Default for unknown
            ;;
    esac

    # Extract date from **Date**: YYYY-MM-DD
    date_value=$(grep -m1 '^\*\*Date\*\*:' "$file" 2>/dev/null | \
        grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' || echo "")

    # Use today's date if none found
    if [ -z "$date_value" ]; then
        date_value=$(date +%Y-%m-%d)
    fi

    # Extract specification from **Specification**: `docs/workflow/specification/{topic}.md`
    # We just want the filename, not the full path
    spec_raw=$(grep -m1 '^\*\*Specification\*\*:' "$file" 2>/dev/null | \
        sed 's/^\*\*Specification\*\*:[[:space:]]*//' | \
        sed 's/`//g' | \
        xargs || echo "")

    # Extract just the filename from the path
    if [ -n "$spec_raw" ]; then
        spec_value=$(basename "$spec_raw")
    else
        spec_value="${topic_kebab}.md"  # Default to topic name
    fi

    #
    # Build new file content
    #

    # Create frontmatter
    frontmatter="---
topic: $topic_kebab
status: $status_new
date: $date_value
format: $format_value
specification: $spec_value
---"

    # Extract H1 heading (preserve original)
    h1_heading=$(grep -m1 "^# " "$file")

    # Find line number of first ## heading (start of real content after metadata)
    first_section_line=$(grep -n "^## " "$file" | head -1 | cut -d: -f1)

    # Get content from first ## onwards (preserves all content)
    if [ -n "$first_section_line" ]; then
        content=$(tail -n +$first_section_line "$file")
    else
        # No ## found - might be empty or malformed
        content=""
    fi

    # Write new content: frontmatter + H1 + blank line + content
    {
        echo "$frontmatter"
        echo ""
        echo "$h1_heading"
        echo ""
        echo "$content"
    } > "$file"

    # Record and report
    record_migration "$file" "$MIGRATION_ID"
    report_update "$file" "added full frontmatter (status: $status_new, format: $format_value)"
done
