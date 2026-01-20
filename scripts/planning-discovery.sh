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
    sed -n '/^---$/,/^---$/p' "$file" 2>/dev/null | \
        grep -m1 "^${field}:" | \
        sed "s/^${field}:[[:space:]]*//" || true
}

# Start YAML output
echo "# Planning Command State Discovery"
echo "# Generated: $(date -Iseconds)"
echo ""

#
# SPECIFICATIONS
#
echo "specifications:"

feature_specs=()
crosscutting_specs=()

if [ -d "$SPEC_DIR" ] && [ -n "$(ls -A "$SPEC_DIR" 2>/dev/null)" ]; then
    for file in "$SPEC_DIR"/*.md; do
        [ -f "$file" ] || continue

        name=$(basename "$file" .md)
        status=$(extract_field "$file" "status")
        status=${status:-"unknown"}

        spec_type=$(extract_field "$file" "type")
        spec_type=${spec_type:-"feature"}

        # Check if a plan exists for this spec
        has_plan="false"
        if [ -f "$PLAN_DIR/${name}.md" ]; then
            has_plan="true"
        fi

        echo "  - name: \"$name\""
        echo "    status: \"$status\""
        echo "    type: \"$spec_type\""
        echo "    has_plan: $has_plan"

        # Track for summary
        if [ "$spec_type" = "cross-cutting" ]; then
            crosscutting_specs+=("$name")
        else
            feature_specs+=("$name")
        fi
    done
else
    echo "  []  # No specifications found"
fi

echo ""

#
# PLANS
#
echo "plans:"

if [ -d "$PLAN_DIR" ] && [ -n "$(ls -A "$PLAN_DIR" 2>/dev/null)" ]; then
    for file in "$PLAN_DIR"/*.md; do
        [ -f "$file" ] || continue

        name=$(basename "$file" .md)
        format=$(extract_field "$file" "format")
        format=${format:-"unknown"}

        echo "  - name: \"$name\""
        echo "    format: \"$format\""
    done
else
    echo "  []  # No plans found"
fi

echo ""

#
# SUMMARY
#
echo "summary:"

# Count specifications by type and status
feature_count=0
feature_complete=0
feature_building=0
crosscutting_count=0
crosscutting_complete=0

if [ -d "$SPEC_DIR" ] && [ -n "$(ls -A "$SPEC_DIR" 2>/dev/null)" ]; then
    for file in "$SPEC_DIR"/*.md; do
        [ -f "$file" ] || continue

        status=$(extract_field "$file" "status")
        spec_type=$(extract_field "$file" "type")
        spec_type=${spec_type:-"feature"}

        if [ "$spec_type" = "cross-cutting" ]; then
            crosscutting_count=$((crosscutting_count + 1))
            if [ "$status" = "complete" ] || [ "$status" = "Complete" ]; then
                crosscutting_complete=$((crosscutting_complete + 1))
            fi
        else
            feature_count=$((feature_count + 1))
            if [ "$status" = "complete" ] || [ "$status" = "Complete" ]; then
                feature_complete=$((feature_complete + 1))
            elif [ "$status" = "building" ] || [ "$status" = "Building specification" ]; then
                feature_building=$((feature_building + 1))
            fi
        fi
    done
fi

echo "  feature_spec_count: $feature_count"
echo "  feature_complete_count: $feature_complete"
echo "  feature_building_count: $feature_building"
echo "  crosscutting_spec_count: $crosscutting_count"
echo "  crosscutting_complete_count: $crosscutting_complete"

# Count plans
plan_count=0
if [ -d "$PLAN_DIR" ]; then
    plan_count=$(find "$PLAN_DIR" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
fi
echo "  plan_count: $plan_count"

# Feature specs ready for planning (complete, no plan yet)
ready_for_planning=0
if [ -d "$SPEC_DIR" ] && [ -n "$(ls -A "$SPEC_DIR" 2>/dev/null)" ]; then
    for file in "$SPEC_DIR"/*.md; do
        [ -f "$file" ] || continue

        name=$(basename "$file" .md)
        status=$(extract_field "$file" "status")
        spec_type=$(extract_field "$file" "type")
        spec_type=${spec_type:-"feature"}

        # Only count feature specs that are complete and don't have a plan
        if [ "$spec_type" != "cross-cutting" ]; then
            if [ "$status" = "complete" ] || [ "$status" = "Complete" ]; then
                if [ ! -f "$PLAN_DIR/${name}.md" ]; then
                    ready_for_planning=$((ready_for_planning + 1))
                fi
            fi
        fi
    done
fi
echo "  ready_for_planning: $ready_for_planning"
