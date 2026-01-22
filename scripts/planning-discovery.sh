#!/bin/bash
#
# planning-discovery.sh
#
# Discovers the current state of specifications and plans
# for the /start-planning command.
#
# Outputs structured YAML that the command can consume directly.
#

set -eo pipefail

SPEC_DIR="docs/workflow/specification"
PLAN_DIR="docs/workflow/planning"

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
echo "# Planning Command State Discovery"
echo "# Generated: $(date -Iseconds)"
echo ""

#
# SPECIFICATIONS
#
echo "specifications:"

feature_count=0
feature_ready_count=0
crosscutting_count=0

if [ -d "$SPEC_DIR" ] && [ -n "$(ls -A "$SPEC_DIR" 2>/dev/null)" ]; then
    echo "  exists: true"
    echo "  feature:"

    # First pass: feature specifications
    for file in "$SPEC_DIR"/*.md; do
        [ -f "$file" ] || continue

        name=$(basename "$file" .md)
        status=$(extract_field "$file" "status")
        status=${status:-"active"}
        spec_type=$(extract_field "$file" "type")
        spec_type=${spec_type:-"feature"}

        # Skip cross-cutting specs in this pass
        [ "$spec_type" = "cross-cutting" ] && continue

        # Check if plan exists
        has_plan="false"
        if [ -f "$PLAN_DIR/${name}.md" ]; then
            has_plan="true"
        fi

        echo "    - name: \"$name\""
        echo "      status: \"$status\""
        echo "      has_plan: $has_plan"

        feature_count=$((feature_count + 1))
        # "Complete" specs without plans are ready for planning
        if [ "$status" = "Complete" ] && [ "$has_plan" = "false" ]; then
            feature_ready_count=$((feature_ready_count + 1))
        fi
    done

    if [ "$feature_count" -eq 0 ]; then
        echo "    []  # No feature specifications"
    fi

    echo "  crosscutting:"

    # Second pass: cross-cutting specifications
    for file in "$SPEC_DIR"/*.md; do
        [ -f "$file" ] || continue

        name=$(basename "$file" .md)
        spec_type=$(extract_field "$file" "type")
        spec_type=${spec_type:-"feature"}

        # Only cross-cutting specs in this pass
        [ "$spec_type" != "cross-cutting" ] && continue

        status=$(extract_field "$file" "status")
        status=${status:-"active"}

        echo "    - name: \"$name\""
        echo "      status: \"$status\""

        crosscutting_count=$((crosscutting_count + 1))
    done

    if [ "$crosscutting_count" -eq 0 ]; then
        echo "    []  # No cross-cutting specifications"
    fi

    echo "  counts:"
    echo "    feature: $feature_count"
    echo "    feature_ready: $feature_ready_count"
    echo "    crosscutting: $crosscutting_count"
else
    echo "  exists: false"
    echo "  feature: []"
    echo "  crosscutting: []"
    echo "  counts:"
    echo "    feature: 0"
    echo "    feature_ready: 0"
    echo "    crosscutting: 0"
fi

echo ""

#
# PLANS
#
echo "plans:"

if [ -d "$PLAN_DIR" ] && [ -n "$(ls -A "$PLAN_DIR" 2>/dev/null)" ]; then
    echo "  exists: true"
    echo "  files:"

    for file in "$PLAN_DIR"/*.md; do
        [ -f "$file" ] || continue

        name=$(basename "$file" .md)
        format=$(extract_field "$file" "format")
        format=${format:-"local-markdown"}
        status=$(extract_field "$file" "status")
        status=${status:-"unknown"}

        echo "    - name: \"$name\""
        echo "      format: \"$format\""
        echo "      status: \"$status\""
    done
else
    echo "  exists: false"
    echo "  files: []"
fi

echo ""

#
# WORKFLOW STATE SUMMARY
#
echo "state:"

specs_exist="false"
plans_exist="false"

if [ -d "$SPEC_DIR" ] && [ -n "$(ls -A "$SPEC_DIR" 2>/dev/null)" ]; then
    specs_exist="true"
fi

if [ -d "$PLAN_DIR" ] && [ -n "$(ls -A "$PLAN_DIR" 2>/dev/null)" ]; then
    plans_exist="true"
fi

echo "  has_specifications: $specs_exist"
echo "  has_plans: $plans_exist"

# Determine workflow state for routing
if [ "$specs_exist" = "false" ]; then
    echo "  scenario: \"no_specs\""
elif [ "$feature_ready_count" -eq 0 ]; then
    echo "  scenario: \"no_ready_specs\""
elif [ "$feature_ready_count" -eq 1 ]; then
    echo "  scenario: \"single_ready_spec\""
else
    echo "  scenario: \"multiple_ready_specs\""
fi
