#!/bin/bash
#
# discussion-discovery.sh
#
# Discovers the current state of research, discussions, and cache
# for the /start-discussion command.
#
# Outputs structured YAML that the command can consume directly.
#

set -eo pipefail

RESEARCH_DIR="docs/workflow/research"
DISCUSSION_DIR="docs/workflow/discussion"
CACHE_FILE="docs/workflow/.cache/research-analysis.md"

# Helper: Extract a frontmatter field value from a file
# Usage: extract_field <file> <field_name>
extract_field() {
    local file="$1"
    local field="$2"
    sed -n '/^---$/,/^---$/p' "$file" 2>/dev/null | \
        grep -m1 "^${field}:" | \
        sed "s/^${field}:[[:space:]]*//" || true
}

# Start YAML output
echo "# Discussion Command State Discovery"
echo "# Generated: $(date -Iseconds)"
echo ""

#
# RESEARCH
#
echo "research:"

if [ -d "$RESEARCH_DIR" ] && [ -n "$(ls -A "$RESEARCH_DIR" 2>/dev/null)" ]; then
    echo "  exists: true"
    echo "  files:"

    for file in "$RESEARCH_DIR"/*.md; do
        [ -f "$file" ] || continue
        name=$(basename "$file" .md)
        echo "    - \"$name\""
    done

    # Compute checksum of all research files (deterministic via sorted glob)
    current_checksum=$(cat "$RESEARCH_DIR"/*.md 2>/dev/null | md5sum | cut -d' ' -f1)
    echo "  current_checksum: \"$current_checksum\""
else
    echo "  exists: false"
    echo "  files: []"
    echo "  current_checksum: null"
fi

echo ""

#
# DISCUSSIONS
#
echo "discussions:"

if [ -d "$DISCUSSION_DIR" ] && [ -n "$(ls -A "$DISCUSSION_DIR" 2>/dev/null)" ]; then
    for file in "$DISCUSSION_DIR"/*.md; do
        [ -f "$file" ] || continue

        name=$(basename "$file" .md)
        status=$(extract_field "$file" "status")
        status=${status:-"unknown"}

        # Get brief description from context section (first non-empty line after ## Context)
        brief=$(sed -n '/^## Context/,/^##/{/^## Context/d; /^##/d; /^[[:space:]]*$/d; p; q}' "$file" 2>/dev/null | head -c 100 || true)

        echo "  - name: \"$name\""
        echo "    status: \"$status\""
        echo "    brief: \"${brief}\""
    done
else
    echo "  []  # No discussions found"
fi

echo ""

#
# CACHE STATE
#
echo "cache:"

if [ -f "$CACHE_FILE" ]; then
    echo "  exists: true"

    cached_checksum=$(extract_field "$CACHE_FILE" "checksum")
    cached_date=$(extract_field "$CACHE_FILE" "generated")

    echo "  cached_checksum: \"${cached_checksum:-unknown}\""
    echo "  cached_date: \"${cached_date:-unknown}\""

    # Extract topics from cache
    echo "  topics:"

    topics_found=false
    while IFS= read -r topic_name; do
        # Clean the topic name
        clean_name=$(echo "$topic_name" | sed 's/^### //')
        if [ -n "$clean_name" ]; then
            echo "    - \"$clean_name\""
            topics_found=true
        fi
    done < <(grep "^### " "$CACHE_FILE" 2>/dev/null || true)

    if [ "$topics_found" = false ]; then
        echo "    []  # No topics in cache"
    fi
else
    echo "  exists: false"
    echo "  cached_checksum: null"
    echo "  cached_date: null"
    echo "  topics: []"
fi

echo ""

#
# CACHE VALIDITY
#
echo "cache_validity:"

if [ -f "$CACHE_FILE" ]; then
    cached_checksum=$(extract_field "$CACHE_FILE" "checksum")

    if [ -d "$RESEARCH_DIR" ] && [ -n "$(ls -A "$RESEARCH_DIR" 2>/dev/null)" ]; then
        current_checksum=$(cat "$RESEARCH_DIR"/*.md 2>/dev/null | md5sum | cut -d' ' -f1)

        if [ "$cached_checksum" = "$current_checksum" ]; then
            echo "  is_valid: true"
            echo "  reason: \"checksums match\""
        else
            echo "  is_valid: false"
            echo "  reason: \"research has changed since cache was generated\""
        fi
    else
        echo "  is_valid: false"
        echo "  reason: \"no research to compare\""
    fi
else
    echo "  is_valid: false"
    echo "  reason: \"no cache exists\""
fi

echo ""

#
# SUMMARY COUNTS
#
echo "summary:"

# Count research files
research_count=0
if [ -d "$RESEARCH_DIR" ]; then
    research_count=$(find "$RESEARCH_DIR" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
fi
echo "  research_file_count: $research_count"

# Count discussions by status
exploring_count=0
deciding_count=0
concluded_count=0
total_discussions=0

if [ -d "$DISCUSSION_DIR" ] && [ -n "$(ls -A "$DISCUSSION_DIR" 2>/dev/null)" ]; then
    for file in "$DISCUSSION_DIR"/*.md; do
        [ -f "$file" ] || continue
        total_discussions=$((total_discussions + 1))

        status=$(extract_field "$file" "status")
        case "$status" in
            exploring|Exploring) exploring_count=$((exploring_count + 1)) ;;
            deciding|Deciding) deciding_count=$((deciding_count + 1)) ;;
            concluded|Concluded) concluded_count=$((concluded_count + 1)) ;;
        esac
    done
fi

echo "  discussion_count: $total_discussions"
echo "  exploring_count: $exploring_count"
echo "  deciding_count: $deciding_count"
echo "  concluded_count: $concluded_count"
