#!/usr/bin/env bash
#
# 002-specification-frontmatter.sh
#
# Migrates specification documents from legacy markdown header format to YAML frontmatter.
#
# Legacy format:
#   # Specification: {Topic}
#
#   **Status**: Building specification | Complete
#   **Type**: feature | cross-cutting
#   **Last Updated**: YYYY-MM-DD
#
# New format:
#   ---
#   topic: {topic-name}
#   status: building | complete
#   type: feature | cross-cutting
#   date: YYYY-MM-DD
#   ---
#
#   # Specification: {Topic}
#
# Status mapping:
#   Building specification, Building, Draft → building
#   Complete, Completed, Done → complete
#
# Type mapping:
#   feature (default if not specified)
#   cross-cutting
#
# This script is sourced by migrate.sh and has access to:
#   - is_migrated "filepath" "migration_id"
#   - record_migration "filepath" "migration_id"
#   - report_update "filepath" "description"
#   - report_skip "filepath"
#

MIGRATION_ID="002"
SPEC_DIR="docs/workflow/specification"

# Skip if no specification directory
if [ ! -d "$SPEC_DIR" ]; then
    return 0
fi

# Process each specification file
for file in "$SPEC_DIR"/*.md; do
    [ -f "$file" ] || continue

    # Check if already migrated via tracking
    if is_migrated "$file" "$MIGRATION_ID"; then
        report_skip "$file"
        continue
    fi

    # Check if file already has YAML frontmatter
    if head -1 "$file" 2>/dev/null | grep -q "^---$"; then
        # Already has frontmatter - just record and skip
        record_migration "$file" "$MIGRATION_ID"
        report_skip "$file"
        continue
    fi

    # Check if file has legacy format (look for **Status**: or **Status:** or **Type**: or **Last Updated**:)
    if ! grep -q '^\*\*Status\*\*:\|^\*\*Status:\*\*\|^\*\*Type\*\*:\|^\*\*Last Updated\*\*:' "$file" 2>/dev/null; then
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

    # Extract status from **Status**: Value or **Status:** Value
    # Handle variations: "Building specification", "Building", "Complete", "Completed", etc.
    status_raw=$(grep -m1 '^\*\*Status\*\*:\|^\*\*Status:\*\*' "$file" | \
        sed 's/^\*\*Status\*\*:[[:space:]]*//' | \
        sed 's/^\*\*Status:\*\*[[:space:]]*//' | \
        tr '[:upper:]' '[:lower:]' | \
        xargs)

    # Map legacy status to new values
    case "$status_raw" in
        "building specification"|"building"|"draft"|"in progress"|"in-progress")
            status_new="building"
            ;;
        "complete"|"completed"|"done"|"finished")
            status_new="complete"
            ;;
        *)
            status_new="building"  # Default for unknown
            ;;
    esac

    # Extract type from **Type**: Value
    type_raw=$(grep -m1 '^\*\*Type\*\*:\|^\*\*Type:\*\*' "$file" | \
        sed 's/^\*\*Type\*\*:[[:space:]]*//' | \
        sed 's/^\*\*Type:\*\*[[:space:]]*//' | \
        tr '[:upper:]' '[:lower:]' | \
        xargs)

    # Normalize type (default to feature if not specified or unrecognized)
    case "$type_raw" in
        "cross-cutting"|"crosscutting"|"cross cutting")
            type_new="cross-cutting"
            ;;
        *)
            type_new="feature"
            ;;
    esac

    # Extract date from **Last Updated**: YYYY-MM-DD or **Date**: YYYY-MM-DD
    date_value=$(grep -m1 '^\*\*Last Updated\*\*:\|^\*\*Date\*\*:' "$file" | \
        grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' || echo "")

    # Use today's date if none found
    if [ -z "$date_value" ]; then
        date_value=$(date +%Y-%m-%d)
    fi

    #
    # Build new file content
    #

    # Create frontmatter
    frontmatter="---
topic: $topic_kebab
status: $status_new
type: $type_new
date: $date_value
---"

    # Extract H1 heading (preserve original)
    h1_heading=$(grep -m1 "^# " "$file")

    # Find line number of first ## heading (start of real content after metadata)
    first_section_line=$(grep -n "^## " "$file" | head -1 | cut -d: -f1)

    # Get content from first ## onwards (preserves all content)
    if [ -n "$first_section_line" ]; then
        content=$(tail -n +$first_section_line "$file")
    else
        # No ## found - take everything after the metadata block
        # Find first blank line after the metadata, then take from there
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
    report_update "$file" "added frontmatter (status: $status_new, type: $type_new)"
done
