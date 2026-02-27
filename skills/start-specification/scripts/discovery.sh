#!/bin/bash
#
# Discovers the current state of discussions, specifications, and cache
# for the /start-specification command.
#
# Outputs structured YAML that the command can consume directly.
#

set -eo pipefail

DISCUSSION_DIR=".workflows/discussion"
SPEC_DIR=".workflows/specification"
CACHE_FILE=".workflows/.state/discussion-consolidation-analysis.md"

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
    # Look for field followed by array items (- item), within frontmatter only
    result=$(awk 'BEGIN{c=0} /^---$/{c++; if(c==2) exit; next} c==1{print}' "$file" 2>/dev/null | \
        sed -n "/^${field}:/,/^[a-z_]*:/p" | \
        grep "^[[:space:]]*-" | \
        sed 's/^[[:space:]]*-[[:space:]]*//' | \
        tr '\n' ' ' | \
        sed 's/[[:space:]]*$//' || true)
    echo "$result"
}

# Helper: Extract sources with status from object format
# Outputs YAML-formatted source entries with name, status, and discussion_status
# Usage: extract_sources_with_status <file> [discussion_dir]
#
# Note: This only handles the object format. Legacy simple array format
# is converted by migration 004 before discovery runs.
extract_sources_with_status() {
    local file="$1"
    local discussion_dir="$2"
    local in_sources=false
    local current_name=""
    local current_status=""

    # Helper: output a single source entry with discussion_status lookup
    _emit_source() {
        local name="$1"
        local status="$2"
        echo "      - name: \"$name\""
        echo "        status: \"$status\""
        if [ -n "$discussion_dir" ]; then
            if [ -f "$discussion_dir/${name}.md" ]; then
                local disc_status
                disc_status=$(extract_field "$discussion_dir/${name}.md" "status")
                echo "        discussion_status: \"${disc_status:-unknown}\""
            else
                echo "        discussion_status: \"not-found\""
            fi
        fi
    }

    # Read frontmatter and parse sources block
    while IFS= read -r line; do
        # Detect start of sources block
        if [[ "$line" =~ ^sources: ]]; then
            in_sources=true
            continue
        fi

        # Detect end of sources block (next top-level field)
        if $in_sources && [[ "$line" =~ ^[a-z_]+: ]] && [[ ! "$line" =~ ^[[:space:]] ]]; then
            # Output last source if pending
            if [ -n "$current_name" ]; then
                _emit_source "$current_name" "${current_status:-incorporated}"
            fi
            break
        fi

        if $in_sources; then
            # Object format: "  - name: value"
            if [[ "$line" =~ ^[[:space:]]*-[[:space:]]*name:[[:space:]]*(.+)$ ]]; then
                # Output previous source if exists
                if [ -n "$current_name" ]; then
                    _emit_source "$current_name" "${current_status:-incorporated}"
                fi
                current_name="${BASH_REMATCH[1]}"
                current_name=$(echo "$current_name" | sed 's/^"//' | sed 's/"$//' | xargs)
                current_status=""
            # Status line: "    status: value"
            elif [[ "$line" =~ ^[[:space:]]*status:[[:space:]]*(.+)$ ]]; then
                current_status="${BASH_REMATCH[1]}"
                current_status=$(echo "$current_status" | sed 's/^"//' | sed 's/"$//' | xargs)
            fi
        fi
    done < <(awk 'BEGIN{c=0} /^---$/{c++; if(c==2) exit; next} c==1{print}' "$file" 2>/dev/null)

    # Output last source if pending (end of frontmatter)
    if [ -n "$current_name" ]; then
        _emit_source "$current_name" "${current_status:-incorporated}"
    fi
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
        work_type=$(extract_field "$file" "work_type")
        work_type=${work_type:-"greenfield"}

        # Check if this discussion has a corresponding individual spec
        has_individual_spec="false"
        spec_status=""
        if [ -f "$SPEC_DIR/${name}/specification.md" ]; then
            has_individual_spec="true"
            # Extract spec status in real-time (not from cache)
            spec_status=$(extract_field "$SPEC_DIR/${name}/specification.md" "status")
            spec_status=${spec_status:-"in-progress"}
        fi

        echo "  - name: \"$name\""
        echo "    status: \"$status\""
        echo "    work_type: \"$work_type\""
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
    for file in "$SPEC_DIR"/*/specification.md; do
        [ -f "$file" ] || continue

        name=$(basename "$(dirname "$file")")
        status=$(extract_field "$file" "status")
        status=${status:-"active"}
        work_type=$(extract_field "$file" "work_type")
        work_type=${work_type:-"greenfield"}

        superseded_by=$(extract_field "$file" "superseded_by")

        echo "  - name: \"$name\""
        echo "    status: \"$status\""
        echo "    work_type: \"$work_type\""

        if [ -n "$superseded_by" ]; then
            echo "    superseded_by: \"$superseded_by\""
        fi

        # Extract sources with status (handles both old and new format)
        sources_output=$(extract_sources_with_status "$file" "$DISCUSSION_DIR")
        if [ -n "$sources_output" ]; then
            echo "    sources:"
            echo "$sources_output"
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
        if [ -f "$SPEC_DIR/${clean_name}/specification.md" ]; then
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

    # Count discussions by status
    discussion_count=0
    concluded_count=0
    in_progress_count=0
    for file in "$DISCUSSION_DIR"/*.md; do
        [ -f "$file" ] || continue
        discussion_count=$((discussion_count + 1))
        status=$(extract_field "$file" "status")
        if [ "$status" = "concluded" ]; then
            concluded_count=$((concluded_count + 1))
        elif [ "$status" = "in-progress" ]; then
            in_progress_count=$((in_progress_count + 1))
        fi
    done
    echo "  discussion_count: $discussion_count"
    echo "  concluded_count: $concluded_count"
    echo "  in_progress_count: $in_progress_count"

    # Count non-superseded specifications
    spec_count=0
    if [ -d "$SPEC_DIR" ] && [ -n "$(ls -A "$SPEC_DIR" 2>/dev/null)" ]; then
        for file in "$SPEC_DIR"/*/specification.md; do
            [ -f "$file" ] || continue
            spec_status=$(extract_field "$file" "status")
            if [ "$spec_status" != "superseded" ]; then
                spec_count=$((spec_count + 1))
            fi
        done
    fi
    echo "  spec_count: $spec_count"

    # Boolean helpers
    echo "  has_discussions: true"
    if [ "$concluded_count" -gt 0 ]; then
        echo "  has_concluded: true"
    else
        echo "  has_concluded: false"
    fi
    if [ "$spec_count" -gt 0 ]; then
        echo "  has_specs: true"
    else
        echo "  has_specs: false"
    fi
else
    echo "  discussions_checksum: null"
    echo "  discussion_count: 0"
    echo "  concluded_count: 0"
    echo "  in_progress_count: 0"
    echo "  spec_count: 0"
    echo "  has_discussions: false"
    echo "  has_concluded: false"
    echo "  has_specs: false"
fi
