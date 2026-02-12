#!/bin/bash
#
# Discovers the current state of plans for /start-review command.
#
# Outputs structured YAML that the command can consume directly.
#

set -eo pipefail

PLAN_DIR="docs/workflow/planning"
SPEC_DIR="docs/workflow/specification"

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

# Helper: Extract frontmatter content (between first pair of --- delimiters)
extract_frontmatter() {
    local file="$1"
    awk 'BEGIN{c=0} /^---$/{c++; if(c==2) exit; next} c==1{print}' "$file" 2>/dev/null
}


# Start YAML output
echo "# Review Command State Discovery"
echo "# Generated: $(date -Iseconds)"
echo ""

#
# PLANS
#
echo "plans:"

plan_count=0
implemented_count=0
completed_count=0

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
        format=${format:-"MISSING"}
        specification=$(extract_field "$file" "specification")
        specification=${specification:-"${name}.md"}
        plan_id=$(extract_field "$file" "plan_id")

        # Check if linked specification exists
        spec_exists="false"
        spec_file="$SPEC_DIR/$specification"
        if [ -f "$spec_file" ]; then
            spec_exists="true"
        fi

        # Check implementation status
        impl_tracking="docs/workflow/implementation/${name}/tracking.md"
        impl_status="none"
        if [ -f "$impl_tracking" ]; then
            impl_status_val=$(extract_field "$impl_tracking" "status")
            impl_status=${impl_status_val:-"in-progress"}
        fi

        echo "    - name: \"$name\""
        echo "      topic: \"$topic\""
        echo "      status: \"$status\""
        echo "      date: \"$date\""
        echo "      format: \"$format\""
        echo "      specification: \"$specification\""
        echo "      specification_exists: $spec_exists"
        if [ -n "$plan_id" ]; then
            echo "      plan_id: \"$plan_id\""
        fi
        echo "      implementation_status: \"$impl_status\""

        plan_count=$((plan_count + 1))
        if [ "$impl_status" != "none" ]; then
            implemented_count=$((implemented_count + 1))
        fi
        if [ "$impl_status" = "completed" ]; then
            completed_count=$((completed_count + 1))
        fi
    done

    echo "  count: $plan_count"
else
    echo "  exists: false"
    echo "  files: []"
    echo "  count: 0"
fi

echo ""

#
# WORKFLOW STATE SUMMARY
#
echo "state:"

echo "  has_plans: $([ "$plan_count" -gt 0 ] && echo "true" || echo "false")"
echo "  plan_count: $plan_count"
echo "  implemented_count: $implemented_count"
echo "  completed_count: $completed_count"

# Determine workflow state for routing
if [ "$plan_count" -eq 0 ]; then
    echo "  scenario: \"no_plans\""
elif [ "$plan_count" -eq 1 ]; then
    echo "  scenario: \"single_plan\""
else
    echo "  scenario: \"multiple_plans\""
fi
