#!/bin/bash
#
# Discovers the current state of discussions, specifications, and cache
# for the /start-specification command.
#
# Outputs structured YAML that the command can consume directly.
#

set -eo pipefail

DISCUSSION_DIR="docs/workflow/discussion"
SPEC_DIR="docs/workflow/specification"
CACHE_FILE="docs/workflow/.cache/discussion-consolidation-analysis.md"

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

# Helper: Extract array field from frontmatter (returns space-separated values)
# Usage: extract_array_field <file> <field_name>
extract_array_field() {
    local file="$1"
    local field="$2"
    local result
    # Look for field followed by array items (- item), excluding --- delimiters
    result=$(sed -n '/^---$/,/^---$/p' "$file" 2>/dev/null | \
        grep -v "^---$" | \
        sed -n "/^${field}:/,/^[a-z_]*:/p" | \
        grep "^[[:space:]]*-" | \
        sed 's/^[[:space:]]*-[[:space:]]*//' | \
        tr '\n' ' ' | \
        sed 's/[[:space:]]*$//' || true)
    echo "$result"
}

# Start YAML output
echo "# Specification Command State Discovery"
echo "# Generated: $(date -Iseconds)"
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

        # Check if this discussion has a corresponding individual spec
        has_individual_spec="false"
        spec_status=""
        if [ -f "$SPEC_DIR/${name}.md" ]; then
            has_individual_spec="true"
            # Extract spec status in real-time (not from cache)
            spec_status=$(extract_field "$SPEC_DIR/${name}.md" "status")
            spec_status=${spec_status:-"in-progress"}
        fi

        echo "  - name: \"$name\""
        echo "    status: \"$status\""
        echo "    has_individual_spec: $has_individual_spec"
        if [ "$has_individual_spec" = "true" ]; then
            echo "    spec_status: \"$spec_status\""
        fi
    done
else
    echo "  []  # No discussions found"
fi

echo ""

#
# SPECIFICATIONS
#
echo "specifications:"

if [ -d "$SPEC_DIR" ] && [ -n "$(ls -A "$SPEC_DIR" 2>/dev/null)" ]; then
    for file in "$SPEC_DIR"/*.md; do
        [ -f "$file" ] || continue

        name=$(basename "$file" .md)
        status=$(extract_field "$file" "status")
        status=${status:-"active"}

        superseded_by=$(extract_field "$file" "superseded_by")
        sources=$(extract_array_field "$file" "sources")

        echo "  - name: \"$name\""
        echo "    status: \"$status\""

        if [ -n "$superseded_by" ]; then
            echo "    superseded_by: \"$superseded_by\""
        fi

        if [ -n "$sources" ]; then
            echo "    sources:"
            for src in $sources; do
                echo "      - \"$src\""
            done
        fi
    done
else
    echo "  []  # No specifications found"
fi

echo ""

#
# CACHE STATE
#
# status: "valid" | "stale" | "none"
#   - valid: cache exists and checksums match
#   - stale: cache exists but discussions have changed
#   - none: no cache file exists
#
echo "cache:"

if [ -f "$CACHE_FILE" ]; then
    cached_checksum=$(extract_field "$CACHE_FILE" "checksum")
    cached_date=$(extract_field "$CACHE_FILE" "generated")

    # Determine status based on checksum comparison
    if [ -d "$DISCUSSION_DIR" ] && [ -n "$(ls -A "$DISCUSSION_DIR" 2>/dev/null)" ]; then
        current_checksum=$(cat "$DISCUSSION_DIR"/*.md 2>/dev/null | md5sum | cut -d' ' -f1)

        if [ "$cached_checksum" = "$current_checksum" ]; then
            echo "  status: \"valid\""
            echo "  reason: \"checksums match\""
        else
            echo "  status: \"stale\""
            echo "  reason: \"discussions have changed since cache was generated\""
        fi
    else
        echo "  status: \"stale\""
        echo "  reason: \"no discussions to compare\""
    fi

    echo "  checksum: \"${cached_checksum:-unknown}\""
    echo "  generated: \"${cached_date:-unknown}\""

    # Extract anchored names (groupings that have existing specs)
    # These are the grouping names from the cache that have corresponding specs
    echo "  anchored_names:"

    # Parse the cache file for grouping names (### Name format)
    # and check if a spec exists for each
    anchored_found=false
    while IFS= read -r grouping_name; do
        # Clean the name (remove any trailing annotations, lowercase, spaces to hyphens)
        clean_name=$(echo "$grouping_name" | sed 's/[[:space:]]*(.*)//' | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
        if [ -f "$SPEC_DIR/${clean_name}.md" ]; then
            echo "    - \"$clean_name\""
            anchored_found=true
        fi
    done < <(grep "^### " "$CACHE_FILE" 2>/dev/null | sed 's/^### //' || true)

    if [ "$anchored_found" = false ]; then
        echo "    []  # No anchored names found"
    fi
else
    echo "  status: \"none\""
    echo "  reason: \"no cache exists\""
    echo "  checksum: null"
    echo "  generated: null"
    echo "  anchored_names: []"
fi

echo ""

#
# CURRENT STATE
#
echo "current_state:"

if [ -d "$DISCUSSION_DIR" ] && [ -n "$(ls -A "$DISCUSSION_DIR" 2>/dev/null)" ]; then
    # Compute checksum of all discussion files (deterministic via sorted glob)
    current_checksum=$(cat "$DISCUSSION_DIR"/*.md 2>/dev/null | md5sum | cut -d' ' -f1)
    echo "  discussions_checksum: \"$current_checksum\""

    # Count concluded discussions
    concluded_count=0
    for file in "$DISCUSSION_DIR"/*.md; do
        [ -f "$file" ] || continue
        status=$(extract_field "$file" "status")
        if [ "$status" = "concluded" ]; then
            concluded_count=$((concluded_count + 1))
        fi
    done
    echo "  concluded_discussion_count: $concluded_count"
else
    echo "  discussions_checksum: null"
    echo "  concluded_discussion_count: 0"
fi
