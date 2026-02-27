#!/bin/bash
#
# Discovery script for /start-investigation.
#
# Scans the investigation directory for existing investigations.
#
# Outputs structured YAML that the skill can consume directly.
#

set -eo pipefail

INVESTIGATION_DIR=".workflows/investigation"

# Helper: Extract a frontmatter field value from a file
# Usage: extract_field <file> <field_name>
extract_field() {
    local file="$1"
    local field="$2"
    local value=""

    if head -1 "$file" 2>/dev/null | grep -q "^---$"; then
        value=$(sed -n '2,/^---$/p' "$file" 2>/dev/null | \
            grep -i -m1 "^${field}:" | \
            sed -E "s/^${field}:[[:space:]]*//i" || true)
    fi

    echo "$value"
}

# Start YAML output
echo "# Start-Investigation Discovery"
echo "# Generated: $(date -Iseconds)"
echo ""

#
# INVESTIGATIONS
#
echo "investigations:"

inv_count=0
inv_in_progress=0
inv_concluded=0

if [ -d "$INVESTIGATION_DIR" ] && [ -n "$(ls -A "$INVESTIGATION_DIR" 2>/dev/null)" ]; then
    echo "  exists: true"
    echo "  files:"
    for dir in "$INVESTIGATION_DIR"/*/; do
        [ -d "$dir" ] || continue
        file="${dir}investigation.md"
        [ -f "$file" ] || continue

        topic=$(basename "$dir")
        status=$(extract_field "$file" "status")
        status=${status:-"in-progress"}
        date=$(extract_field "$file" "date")
        work_type=$(extract_field "$file" "work_type")
        work_type=${work_type:-"bugfix"}

        echo "    - topic: \"$topic\""
        echo "      status: \"$status\""
        echo "      work_type: \"$work_type\""
        [ -n "$date" ] && echo "      date: \"$date\""

        inv_count=$((inv_count + 1))
        [ "$status" = "concluded" ] && inv_concluded=$((inv_concluded + 1))
        [ "$status" = "in-progress" ] && inv_in_progress=$((inv_in_progress + 1))
    done
    echo "  counts:"
    echo "    total: $inv_count"
    echo "    in_progress: $inv_in_progress"
    echo "    concluded: $inv_concluded"
else
    echo "  exists: false"
    echo "  files: []"
    echo "  counts:"
    echo "    total: 0"
    echo "    in_progress: 0"
    echo "    concluded: 0"
fi

echo ""

#
# STATE SUMMARY
#
echo "state:"

if [ "$inv_count" -eq 0 ]; then
    echo "  scenario: \"fresh\""
else
    echo "  scenario: \"has_investigations\""
fi
