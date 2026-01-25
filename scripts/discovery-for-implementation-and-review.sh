#!/bin/bash
#
# Discovers the current state of plans for /start-implementation and /start-review commands.
#
# Outputs structured YAML that the commands can consume directly.
#

set -eo pipefail

PLAN_DIR="docs/workflow/planning"
SPEC_DIR="docs/workflow/specification"
ENVIRONMENT_FILE="docs/workflow/environment-setup.md"

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
echo "# Implementation Command State Discovery"
echo "# Generated: $(date -Iseconds)"
echo ""

#
# PLANS
#
echo "plans:"

plan_count=0

if [ -d "$PLAN_DIR" ] && [ -n "$(ls -A "$PLAN_DIR" 2>/dev/null)" ]; then
    echo "  exists: true"
    echo "  files:"

    for file in "$PLAN_DIR"/*.md; do
        [ -f "$file" ] || continue

        name=$(basename "$file" .md)
        topic=$(extract_field "$file" "topic")
        topic=${topic:-"$name"}
        status=$(extract_field "$file" "status")
        status=${status:-"unknown"}
        date=$(extract_field "$file" "date")
        date=${date:-"unknown"}
        format=$(extract_field "$file" "format")
        format=${format:-"local-markdown"}
        specification=$(extract_field "$file" "specification")
        specification=${specification:-"${name}.md"}

        # Check if linked specification exists
        spec_exists="false"
        spec_file="$SPEC_DIR/$specification"
        if [ -f "$spec_file" ]; then
            spec_exists="true"
        fi

        echo "    - name: \"$name\""
        echo "      topic: \"$topic\""
        echo "      status: \"$status\""
        echo "      date: \"$date\""
        echo "      format: \"$format\""
        echo "      specification: \"$specification\""
        echo "      specification_exists: $spec_exists"

        plan_count=$((plan_count + 1))
    done

    echo "  count: $plan_count"
else
    echo "  exists: false"
    echo "  files: []"
    echo "  count: 0"
fi

echo ""

#
# ENVIRONMENT
#
echo "environment:"

if [ -f "$ENVIRONMENT_FILE" ]; then
    echo "  setup_file_exists: true"
    echo "  setup_file: \"$ENVIRONMENT_FILE\""

    # Check if it says "no special setup required" (case insensitive)
    if grep -qi "no special setup required" "$ENVIRONMENT_FILE" 2>/dev/null; then
        echo "  requires_setup: false"
    else
        echo "  requires_setup: true"
    fi
else
    echo "  setup_file_exists: false"
    echo "  setup_file: \"$ENVIRONMENT_FILE\""
    echo "  requires_setup: unknown"
fi

echo ""

#
# WORKFLOW STATE SUMMARY
#
echo "state:"

echo "  has_plans: $([ "$plan_count" -gt 0 ] && echo "true" || echo "false")"
echo "  plan_count: $plan_count"

# Determine workflow state for routing
if [ "$plan_count" -eq 0 ]; then
    echo "  scenario: \"no_plans\""
elif [ "$plan_count" -eq 1 ]; then
    echo "  scenario: \"single_plan\""
else
    echo "  scenario: \"multiple_plans\""
fi
