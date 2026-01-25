#!/usr/bin/env bash
#
# 004-sources-object-format.sh
#
# Migrates specification sources from simple array format to object format
# with status tracking.
#
# Previous format (from 002-specification-frontmatter.sh):
#   sources:
#     - topic-a
#     - topic-b
#
# New format:
#   sources:
#     - name: topic-a
#       status: incorporated
#     - name: topic-b
#       status: incorporated
#
# Status values:
#   - pending: Source selected but content not yet extracted
#   - incorporated: Source content has been fully woven into the specification
#
# For existing sources, we assume "incorporated" since they were part of
# the specification when it was created/worked on.
#
# This script is sourced by migrate.sh and has access to:
#   - is_migrated "filepath" "migration_id"
#   - record_migration "filepath" "migration_id"
#   - report_update "filepath" "description"
#   - report_skip "filepath"
#

MIGRATION_ID="004"
SPEC_DIR="docs/workflow/specification"

# Skip if no specification directory
if [ ! -d "$SPEC_DIR" ]; then
    return 0
fi

# Helper: Check if sources are already in object format
# Returns 0 if already migrated (has "name:" entries), 1 if not
sources_already_object_format() {
    local file="$1"
    # Look for "- name:" pattern within the sources block
    # This indicates the new object format
    # Using subshell with || false to ensure proper exit code without pipefail issues
    ( sed -n '/^sources:/,/^[a-z_]*:/p' "$file" 2>/dev/null | \
        grep -q "^[[:space:]]*-[[:space:]]*name:" 2>/dev/null ) || return 1
    return 0
}

# Helper: Extract sources array items (simple string format)
# Returns space-separated list of source names
extract_simple_sources() {
    local file="$1"
    # Use || true on greps that may not match to avoid pipefail issues
    sed -n '/^sources:/,/^[a-z_]*:/p' "$file" 2>/dev/null | \
        grep -v "^sources:" | \
        grep -v "^[a-z_]*:" | \
        { grep "^[[:space:]]*-[[:space:]]" || true; } | \
        { grep -v "name:" || true; } | \
        sed 's/^[[:space:]]*-[[:space:]]*//' | \
        sed 's/^"//' | \
        sed 's/"$//' | \
        tr '\n' ' ' | \
        sed 's/[[:space:]]*$//' || true
}

# Process each specification file
for file in "$SPEC_DIR"/*.md; do
    [ -f "$file" ] || continue

    # Check if already migrated via tracking
    if is_migrated "$file" "$MIGRATION_ID"; then
        report_skip "$file"
        continue
    fi

    # Check if file has YAML frontmatter
    if ! head -1 "$file" 2>/dev/null | grep -q "^---$"; then
        record_migration "$file" "$MIGRATION_ID"
        report_skip "$file"
        continue
    fi

    # Check if file has sources field at all
    if ! grep -q "^sources:" "$file" 2>/dev/null; then
        record_migration "$file" "$MIGRATION_ID"
        report_skip "$file"
        continue
    fi

    # Check if sources are already in object format
    if sources_already_object_format "$file"; then
        record_migration "$file" "$MIGRATION_ID"
        report_skip "$file"
        continue
    fi

    # Extract existing sources
    sources=$(extract_simple_sources "$file")

    # If no sources found (empty array), skip
    if [ -z "$sources" ]; then
        record_migration "$file" "$MIGRATION_ID"
        report_skip "$file"
        continue
    fi

    #
    # Build new sources block in object format
    #
    new_sources_block="sources:"
    for src in $sources; do
        # Clean the source name (trim whitespace)
        src=$(echo "$src" | xargs)
        if [ -n "$src" ]; then
            new_sources_block="${new_sources_block}
  - name: $src
    status: incorporated"
        fi
    done

    #
    # Replace sources block in file
    #

    # Extract frontmatter
    frontmatter=$(sed -n '1,/^---$/p' "$file" | tail -n +2 | head -n -1)

    # Remove old sources block from frontmatter and add new one
    # First, remove lines from "sources:" until the next top-level field or end of frontmatter
    new_frontmatter=$(echo "$frontmatter" | sed '/^sources:/,/^[a-z_]*:/{/^sources:/d;/^[a-z_]*:/!d}')

    # Add new sources block at the end
    new_frontmatter="${new_frontmatter}
${new_sources_block}"

    # Extract content after frontmatter (everything after the closing ---)
    content=$(sed '1,/^---$/d' "$file" | sed '1,/^---$/d')

    # Handle case where there's only one --- (malformed, but be safe)
    if [ -z "$content" ]; then
        # Try getting content after second ---
        content=$(awk '/^---$/{count++; if(count==2){found=1; next}} found{print}' "$file")
    fi

    # Write new file
    {
        echo "---"
        echo "$new_frontmatter"
        echo "---"
        echo "$content"
    } > "$file"

    record_migration "$file" "$MIGRATION_ID"
    report_update "$file" "converted sources to object format"
done
