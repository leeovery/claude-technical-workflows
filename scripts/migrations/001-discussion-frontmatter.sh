#!/bin/bash
#
# 001-discussion-frontmatter.sh
#
# Migrates discussion documents from legacy markdown header format to YAML frontmatter.
#
# Legacy format:
#   # Discussion: {Topic}
#
#   **Date**: YYYY-MM-DD
#   **Status**: Exploring | Deciding | Concluded
#
# New format:
#   ---
#   topic: {topic-name}
#   status: in-progress | concluded
#   date: YYYY-MM-DD
#   ---
#
#   # Discussion: {Topic}
#
# Status mapping:
#   Exploring, Deciding → in-progress
#   Concluded → concluded
#
# This script is sourced by migrate-documents.sh and has access to:
#   - is_migrated "filepath" "migration_id"
#   - record_migration "filepath" "migration_id"
#   - report_update "filepath" "description"
#   - report_skip "filepath"
#

MIGRATION_ID="001"
DISCUSSION_DIR="docs/workflow/discussion"

# Skip if no discussion directory
if [ ! -d "$DISCUSSION_DIR" ]; then
    echo "  No discussion directory found"
    return 0
fi

# Process each discussion file
for file in "$DISCUSSION_DIR"/*.md; do
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

    # Check if file has legacy format (look for **Status**: or **Date**:)
    if ! grep -q '^\*\*Status\*\*:\|^\*\*Date\*\*:' "$file" 2>/dev/null; then
        # No legacy format found - might be malformed, skip
        record_migration "$file" "$MIGRATION_ID"
        report_skip "$file"
        continue
    fi

    #
    # Extract values from legacy format
    #

    # Extract topic from "# Discussion: {Topic}" heading
    topic=$(grep -m1 "^# Discussion:" "$file" | sed 's/^# Discussion:[[:space:]]*//')
    # Convert to kebab-case for frontmatter (lowercase, spaces to hyphens)
    topic_kebab=$(echo "$topic" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/[^a-z0-9-]//g')

    # Extract date from **Date**: YYYY-MM-DD
    date_value=$(grep -m1 '^\*\*Date\*\*:' "$file" | sed 's/^\*\*Date\*\*:[[:space:]]*//' | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' || echo "")

    # Extract status from **Status**: Value
    status_raw=$(grep -m1 '^\*\*Status\*\*:' "$file" | sed 's/^\*\*Status\*\*:[[:space:]]*//' | tr '[:upper:]' '[:lower:]')

    # Map legacy status to new values
    case "$status_raw" in
        exploring|deciding)
            status_new="in-progress"
            ;;
        concluded)
            status_new="concluded"
            ;;
        *)
            status_new="in-progress"  # Default for unknown
            ;;
    esac

    # Use today's date if none found
    if [ -z "$date_value" ]; then
        date_value=$(date +%Y-%m-%d)
    fi

    # Use filename as topic if none found
    if [ -z "$topic_kebab" ]; then
        topic_kebab=$(basename "$file" .md)
    fi

    #
    # Build new file content
    #

    # Create frontmatter
    frontmatter="---
topic: $topic_kebab
status: $status_new
date: $date_value
---"

    # Get file content, removing old header lines
    # Remove: **Date**: ... and **Status**: ... lines
    # Keep everything else
    content=$(sed '/^\*\*Date\*\*:/d; /^\*\*Status\*\*:/d' "$file")

    # Collapse multiple blank lines after # Discussion: heading to single blank line
    # (The removed **Date**/**Status** lines leave extra blank lines)
    content=$(echo "$content" | awk '
        /^# Discussion:/ {
            print
            # Skip all blank lines after heading
            while ((getline line) > 0 && line ~ /^[[:space:]]*$/) {}
            # Print a single blank line, then the non-blank line we found
            print ""
            print line
            next
        }
        { print }
    ')

    # Write new content
    {
        echo "$frontmatter"
        echo ""
        echo "$content"
    } > "$file"

    # Record and report
    record_migration "$file" "$MIGRATION_ID"
    report_update "$file" "added frontmatter"
done
