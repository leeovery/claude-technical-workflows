#!/bin/bash
#
# Discovery script for /continue-greenfield.
#
# Scans all workflow directories for greenfield work (work_type: greenfield or unset)
# and builds a phase-centric view with actionable items.
#
# Outputs structured YAML that the skill can consume directly.
#

set -eo pipefail

RESEARCH_DIR=".workflows/research"
DISCUSSION_DIR=".workflows/discussion"
SPEC_DIR=".workflows/specification"
PLAN_DIR=".workflows/planning"
IMPL_DIR=".workflows/implementation"
REVIEW_DIR=".workflows/review"

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
echo "# Continue-Greenfield Discovery"
echo "# Generated: $(date -Iseconds)"
echo ""

#
# RESEARCH
#
echo "research:"

research_count=0
if [ -d "$RESEARCH_DIR" ] && [ -n "$(ls -A "$RESEARCH_DIR" 2>/dev/null)" ]; then
    echo "  exists: true"
    echo "  files:"
    for file in "$RESEARCH_DIR"/*; do
        [ -f "$file" ] || continue
        name=$(basename "$file" .md)
        echo "    - \"$name\""
        research_count=$((research_count + 1))
    done
    echo "  count: $research_count"
else
    echo "  exists: false"
    echo "  files: []"
    echo "  count: 0"
fi

echo ""

#
# DISCUSSIONS (greenfield only)
#
echo "discussions:"

disc_count=0
disc_concluded=0
disc_in_progress=0

if [ -d "$DISCUSSION_DIR" ] && [ -n "$(ls -A "$DISCUSSION_DIR" 2>/dev/null)" ]; then
    first=true
    for file in "$DISCUSSION_DIR"/*.md; do
        [ -f "$file" ] || continue
        work_type=$(extract_field "$file" "work_type")
        work_type=${work_type:-"greenfield"}

        # Only include greenfield discussions
        [ "$work_type" = "greenfield" ] || continue

        name=$(basename "$file" .md)
        status=$(extract_field "$file" "status")
        status=${status:-"in-progress"}

        if $first; then
            echo "  files:"
            first=false
        fi

        echo "    - name: \"$name\""
        echo "      status: \"$status\""

        disc_count=$((disc_count + 1))
        [ "$status" = "concluded" ] && disc_concluded=$((disc_concluded + 1))
        [ "$status" = "in-progress" ] && disc_in_progress=$((disc_in_progress + 1))
    done
    if $first; then
        echo "  files: []"
    fi
else
    echo "  files: []"
fi

echo "  count: $disc_count"
echo "  concluded: $disc_concluded"
echo "  in_progress: $disc_in_progress"

echo ""

#
# SPECIFICATIONS (greenfield only)
#
echo "specifications:"

spec_count=0
spec_concluded=0
spec_in_progress=0
spec_feature=0
spec_crosscutting=0

if [ -d "$SPEC_DIR" ] && [ -n "$(ls -A "$SPEC_DIR" 2>/dev/null)" ]; then
    first=true
    for file in "$SPEC_DIR"/*/specification.md; do
        [ -f "$file" ] || continue
        work_type=$(extract_field "$file" "work_type")
        work_type=${work_type:-"greenfield"}

        # Only include greenfield specs
        [ "$work_type" = "greenfield" ] || continue

        name=$(basename "$(dirname "$file")")
        status=$(extract_field "$file" "status")
        status=${status:-"in-progress"}
        spec_type=$(extract_field "$file" "type")
        spec_type=${spec_type:-"feature"}

        # Check if plan exists for this spec
        has_plan="false"
        [ -f "$PLAN_DIR/${name}/plan.md" ] && has_plan="true"

        if $first; then
            echo "  files:"
            first=false
        fi

        echo "    - name: \"$name\""
        echo "      status: \"$status\""
        echo "      type: \"$spec_type\""
        echo "      has_plan: $has_plan"

        spec_count=$((spec_count + 1))
        [ "$status" = "concluded" ] && spec_concluded=$((spec_concluded + 1))
        [ "$status" = "in-progress" ] && spec_in_progress=$((spec_in_progress + 1))
        [ "$spec_type" = "cross-cutting" ] && spec_crosscutting=$((spec_crosscutting + 1))
        [ "$spec_type" = "feature" ] && spec_feature=$((spec_feature + 1))
    done
    if $first; then
        echo "  files: []"
    fi
else
    echo "  files: []"
fi

echo "  count: $spec_count"
echo "  concluded: $spec_concluded"
echo "  in_progress: $spec_in_progress"
echo "  feature: $spec_feature"
echo "  crosscutting: $spec_crosscutting"

echo ""

#
# PLANS (greenfield only)
#
echo "plans:"

plan_count=0
plan_concluded=0
plan_in_progress=0

if [ -d "$PLAN_DIR" ] && [ -n "$(ls -A "$PLAN_DIR" 2>/dev/null)" ]; then
    first=true
    for file in "$PLAN_DIR"/*/plan.md; do
        [ -f "$file" ] || continue
        work_type=$(extract_field "$file" "work_type")
        work_type=${work_type:-"greenfield"}

        # Only include greenfield plans
        [ "$work_type" = "greenfield" ] || continue

        name=$(basename "$(dirname "$file")")
        status=$(extract_field "$file" "status")
        status=${status:-"in-progress"}

        # Check if implementation exists for this plan
        has_impl="false"
        [ -f "$IMPL_DIR/${name}/tracking.md" ] && has_impl="true"

        if $first; then
            echo "  files:"
            first=false
        fi

        echo "    - name: \"$name\""
        echo "      status: \"$status\""
        echo "      has_implementation: $has_impl"

        plan_count=$((plan_count + 1))
        [ "$status" = "concluded" ] && plan_concluded=$((plan_concluded + 1))
        { [ "$status" = "in-progress" ] || [ "$status" = "planning" ]; } && plan_in_progress=$((plan_in_progress + 1))
    done
    if $first; then
        echo "  files: []"
    fi
else
    echo "  files: []"
fi

echo "  count: $plan_count"
echo "  concluded: $plan_concluded"
echo "  in_progress: $plan_in_progress"

echo ""

#
# IMPLEMENTATION (greenfield only)
#
echo "implementation:"

impl_count=0
impl_completed=0
impl_in_progress=0

if [ -d "$IMPL_DIR" ] && [ -n "$(ls -A "$IMPL_DIR" 2>/dev/null)" ]; then
    first=true
    for file in "$IMPL_DIR"/*/tracking.md; do
        [ -f "$file" ] || continue
        work_type=$(extract_field "$file" "work_type")
        work_type=${work_type:-"greenfield"}

        # Only include greenfield implementations
        [ "$work_type" = "greenfield" ] || continue

        topic=$(basename "$(dirname "$file")")
        status=$(extract_field "$file" "status")
        status=${status:-"in-progress"}

        # Check if review exists for this implementation
        has_review="false"
        if [ -d "$REVIEW_DIR/${topic}" ]; then
            for rdir in "$REVIEW_DIR/${topic}"/r*/; do
                [ -d "$rdir" ] || continue
                [ -f "${rdir}review.md" ] && has_review="true" && break
            done
        fi

        if $first; then
            echo "  files:"
            first=false
        fi

        echo "    - topic: \"$topic\""
        echo "      status: \"$status\""
        echo "      has_review: $has_review"

        impl_count=$((impl_count + 1))
        [ "$status" = "completed" ] && impl_completed=$((impl_completed + 1))
        [ "$status" = "in-progress" ] && impl_in_progress=$((impl_in_progress + 1))
    done
    if $first; then
        echo "  files: []"
    fi
else
    echo "  files: []"
fi

echo "  count: $impl_count"
echo "  completed: $impl_completed"
echo "  in_progress: $impl_in_progress"

echo ""

#
# STATE SUMMARY
#
echo "state:"
echo "  research_count: $research_count"
echo "  discussion_count: $disc_count"
echo "  discussion_concluded: $disc_concluded"
echo "  discussion_in_progress: $disc_in_progress"
echo "  specification_count: $spec_count"
echo "  specification_concluded: $spec_concluded"
echo "  specification_in_progress: $spec_in_progress"
echo "  plan_count: $plan_count"
echo "  plan_concluded: $plan_concluded"
echo "  plan_in_progress: $plan_in_progress"
echo "  implementation_count: $impl_count"
echo "  implementation_completed: $impl_completed"
echo "  implementation_in_progress: $impl_in_progress"

# Compute what's actionable
has_any_work="false"
if [ "$research_count" -gt 0 ] || [ "$disc_count" -gt 0 ] || [ "$spec_count" -gt 0 ] || \
   [ "$plan_count" -gt 0 ] || [ "$impl_count" -gt 0 ]; then
    has_any_work="true"
fi

echo "  has_any_work: $has_any_work"
