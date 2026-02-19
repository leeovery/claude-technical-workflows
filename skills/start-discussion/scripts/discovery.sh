#!/bin/bash
#
# Discovers the current state of research, discussions, and cache
# for the /start-discussion command.
#
# Outputs structured YAML that the command can consume directly.
#

set -eo pipefail

RESEARCH_DIR="docs/workflow/research"
DISCUSSION_DIR="docs/workflow/discussion"
CACHE_FILE="docs/workflow/.state/research-analysis.md"

# Helper: Extract a frontmatter field value from a file
# Usage: extract_field <file> <field_name>
extract_field() {
    local file="$1"
    local field="$2"
    local value=""

    # Extract from YAML frontmatter (file must start with ---)
    if head -1 "$file" 2>/dev/null | grep -q "^---$"; then
        value=$(sed -n '2,/^---$/p' "$file" 2>/dev/null | \
            grep -i -m1 "^${field}:" | \
            sed -E "s/^${field}:[[:space:]]*//i" || true)
    fi

    echo "$value"
}

# Start YAML output
echo "# Discussion Command State Discovery"
echo "# Generated: $(date -Iseconds)"
echo ""

#
# RESEARCH FILES
#
echo "research:"

if [ -d "$RESEARCH_DIR" ] && [ -n "$(ls -A "$RESEARCH_DIR" 2>/dev/null)" ]; then
    echo "  exists: true"
    echo "  files:"
    for file in "$RESEARCH_DIR"/*.md; do
        [ -f "$file" ] || continue

        name=$(basename "$file" .md)
        topic=$(extract_field "$file" "topic")
        topic=${topic:-"$name"}

        echo "    - name: \"$name\""
        echo "      topic: \"$topic\""
    done

    # Compute checksum of all research files (deterministic via sorted glob)
    research_checksum=$(cat "$RESEARCH_DIR"/*.md 2>/dev/null | md5sum | cut -d' ' -f1)
    echo "  checksum: \"$research_checksum\""
else
    echo "  exists: false"
    echo "  files: []"
    echo "  checksum: null"
fi

echo ""

#
# DISCUSSIONS
#
echo "discussions:"

if [ -d "$DISCUSSION_DIR" ] && [ -n "$(ls -A "$DISCUSSION_DIR" 2>/dev/null)" ]; then
    echo "  exists: true"
    echo "  files:"

    in_progress_count=0
    concluded_count=0

    for file in "$DISCUSSION_DIR"/*.md; do
        [ -f "$file" ] || continue

        name=$(basename "$file" .md)
        status=$(extract_field "$file" "status")
        status=${status:-"unknown"}
        date=$(extract_field "$file" "date")

        echo "    - name: \"$name\""
        echo "      status: \"$status\""
        if [ -n "$date" ]; then
            echo "      date: \"$date\""
        fi

        if [ "$status" = "in-progress" ]; then
            in_progress_count=$((in_progress_count + 1))
        elif [ "$status" = "concluded" ]; then
            concluded_count=$((concluded_count + 1))
        fi
    done

    echo "  counts:"
    echo "    in_progress: $in_progress_count"
    echo "    concluded: $concluded_count"
else
    echo "  exists: false"
    echo "  files: []"
    echo "  counts:"
    echo "    in_progress: 0"
    echo "    concluded: 0"
fi

echo ""

#
# CACHE STATE
#
# status: "valid" | "stale" | "none"
#   - valid: cache exists and checksums match
#   - stale: cache exists but research has changed
#   - none: no cache file exists
#
echo "cache:"

if [ -f "$CACHE_FILE" ]; then
    cached_checksum=$(extract_field "$CACHE_FILE" "checksum")
    cached_date=$(extract_field "$CACHE_FILE" "generated")

    # Determine status based on checksum comparison
    if [ -d "$RESEARCH_DIR" ] && [ -n "$(ls -A "$RESEARCH_DIR" 2>/dev/null)" ]; then
        current_checksum=$(cat "$RESEARCH_DIR"/*.md 2>/dev/null | md5sum | cut -d' ' -f1)

        if [ "$cached_checksum" = "$current_checksum" ]; then
            echo "  status: \"valid\""
            echo "  reason: \"checksums match\""
        else
            echo "  status: \"stale\""
            echo "  reason: \"research has changed since cache was generated\""
        fi
    else
        echo "  status: \"stale\""
        echo "  reason: \"no research files to compare\""
    fi

    echo "  checksum: \"${cached_checksum:-unknown}\""
    echo "  generated: \"${cached_date:-unknown}\""

    # Extract cached research files list
    echo "  research_files:"
    files_found=false
    while IFS= read -r file; do
        file=$(echo "$file" | sed 's/^[[:space:]]*-[[:space:]]*//' | tr -d ' ')
        if [ -n "$file" ]; then
            echo "    - \"$file\""
            files_found=true
        fi
    done < <(sed -n '/^research_files:/,/^---$/p' "$CACHE_FILE" 2>/dev/null | grep "^[[:space:]]*-" || true)

    if [ "$files_found" = false ]; then
        echo "    []  # No research files in cache"
    fi
else
    echo "  status: \"none\""
    echo "  reason: \"no cache exists\""
    echo "  checksum: null"
    echo "  generated: null"
    echo "  research_files: []"
fi

echo ""

#
# WORKFLOW STATE SUMMARY
#
echo "state:"

research_exists="false"
discussions_exist="false"

if [ -d "$RESEARCH_DIR" ] && [ -n "$(ls -A "$RESEARCH_DIR" 2>/dev/null)" ]; then
    research_exists="true"
fi

if [ -d "$DISCUSSION_DIR" ] && [ -n "$(ls -A "$DISCUSSION_DIR" 2>/dev/null)" ]; then
    discussions_exist="true"
fi

echo "  has_research: $research_exists"
echo "  has_discussions: $discussions_exist"

# Determine workflow state for routing
if [ "$research_exists" = "false" ] && [ "$discussions_exist" = "false" ]; then
    echo "  scenario: \"fresh\""
elif [ "$research_exists" = "true" ] && [ "$discussions_exist" = "false" ]; then
    echo "  scenario: \"research_only\""
elif [ "$research_exists" = "false" ] && [ "$discussions_exist" = "true" ]; then
    echo "  scenario: \"discussions_only\""
else
    echo "  scenario: \"research_and_discussions\""
fi
