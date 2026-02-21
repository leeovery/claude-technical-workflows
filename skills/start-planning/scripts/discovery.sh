#!/bin/bash
#
# Discovers the current state of specifications and plans
# for the /start-planning command.
#
# Outputs structured YAML that the command can consume directly.
#

set -eo pipefail

SPEC_DIR="docs/workflow/specification"
PLAN_DIR="docs/workflow/planning"
IMPL_DIR="docs/workflow/implementation"

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
feature_with_plan_count=0
feature_actionable_with_plan_count=0
feature_implemented_count=0
crosscutting_count=0

if [ -d "$SPEC_DIR" ] && [ -n "$(ls -A "$SPEC_DIR" 2>/dev/null)" ]; then
    echo "  exists: true"
    echo "  feature:"

    # First pass: feature specifications
    for file in "$SPEC_DIR"/*/specification.md; do
        [ -f "$file" ] || continue

        name=$(basename "$(dirname "$file")")
        status=$(extract_field "$file" "status")
        status=${status:-"active"}
        spec_type=$(extract_field "$file" "type")
        spec_type=${spec_type:-"feature"}

        # Skip cross-cutting specs in this pass
        [ "$spec_type" = "cross-cutting" ] && continue

        # Check if plan exists and its status
        has_plan="false"
        plan_status=""
        if [ -f "$PLAN_DIR/${name}/plan.md" ]; then
            has_plan="true"
            plan_status=$(extract_field "$PLAN_DIR/${name}/plan.md" "status")
            plan_status=${plan_status:-"unknown"}
        fi

        # Check if implementation tracking exists and its status
        has_impl="false"
        impl_status=""
        if [ -f "$IMPL_DIR/${name}/tracking.md" ]; then
            has_impl="true"
            impl_status=$(extract_field "$IMPL_DIR/${name}/tracking.md" "status")
            impl_status=${impl_status:-"unknown"}
        fi

        echo "    - name: \"$name\""
        echo "      status: \"$status\""
        echo "      has_plan: $has_plan"
        if [ "$has_plan" = "true" ]; then
            echo "      plan_status: \"$plan_status\""
        fi
        echo "      has_impl: $has_impl"
        if [ "$has_impl" = "true" ]; then
            echo "      impl_status: \"$impl_status\""
        fi

        feature_count=$((feature_count + 1))
        # "concluded" specs without plans are ready for planning
        if [ "$status" = "concluded" ] && [ "$has_plan" = "false" ]; then
            feature_ready_count=$((feature_ready_count + 1))
        fi
        if [ "$has_plan" = "true" ]; then
            feature_with_plan_count=$((feature_with_plan_count + 1))
            # Track specs with plans that are still actionable (not fully implemented)
            if [ "$impl_status" != "completed" ]; then
                feature_actionable_with_plan_count=$((feature_actionable_with_plan_count + 1))
            fi
        fi
        # Track fully implemented specs
        if [ "$impl_status" = "completed" ]; then
            feature_implemented_count=$((feature_implemented_count + 1))
        fi
    done

    if [ "$feature_count" -eq 0 ]; then
        echo "    []  # No feature specifications"
    fi

    echo "  crosscutting:"

    # Second pass: cross-cutting specifications
    for file in "$SPEC_DIR"/*/specification.md; do
        [ -f "$file" ] || continue

        name=$(basename "$(dirname "$file")")
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
    echo "    feature_with_plan: $feature_with_plan_count"
    echo "    feature_actionable_with_plan: $feature_actionable_with_plan_count"
    echo "    feature_implemented: $feature_implemented_count"
    echo "    crosscutting: $crosscutting_count"
else
    echo "  exists: false"
    echo "  feature: []"
    echo "  crosscutting: []"
    echo "  counts:"
    echo "    feature: 0"
    echo "    feature_ready: 0"
    echo "    feature_with_plan: 0"
    echo "    feature_actionable_with_plan: 0"
    echo "    feature_implemented: 0"
    echo "    crosscutting: 0"
fi

echo ""

#
# PLANS
#
echo "plans:"

plan_format_seen=""
plan_format_unanimous="true"

if [ -d "$PLAN_DIR" ] && [ -n "$(ls -A "$PLAN_DIR" 2>/dev/null)" ]; then
    echo "  exists: true"
    echo "  files:"

    for file in "$PLAN_DIR"/*/plan.md; do
        [ -f "$file" ] || continue

        name=$(basename "$(dirname "$file")")
        format=$(extract_field "$file" "format")
        format=${format:-"MISSING"}

        if [ "$format" != "MISSING" ]; then
            if [ -z "$plan_format_seen" ]; then
                plan_format_seen="$format"
            elif [ "$plan_format_seen" != "$format" ]; then
                plan_format_unanimous="false"
            fi
        fi

        status=$(extract_field "$file" "status")
        status=${status:-"unknown"}
        plan_id=$(extract_field "$file" "plan_id")

        echo "    - name: \"$name\""
        echo "      format: \"$format\""
        echo "      status: \"$status\""
        if [ -n "$plan_id" ]; then
            echo "      plan_id: \"$plan_id\""
        fi
    done

    if [ "$plan_format_unanimous" = "true" ] && [ -n "$plan_format_seen" ]; then
        echo "  common_format: \"$plan_format_seen\""
    else
        echo "  common_format: \"\""
    fi
else
    echo "  exists: false"
    echo "  files: []"
    echo "  common_format: \"\""
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
# Actionable = ready for new plan OR has plan that's not fully implemented
if [ "$specs_exist" = "false" ]; then
    echo "  scenario: \"no_specs\""
elif [ "$feature_ready_count" -eq 0 ] && [ "$feature_actionable_with_plan_count" -eq 0 ]; then
    echo "  scenario: \"nothing_actionable\""
else
    echo "  scenario: \"has_options\""
fi
