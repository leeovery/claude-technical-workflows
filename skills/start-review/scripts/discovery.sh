#!/bin/bash
#
# Discovers the current state of plans for /start-review command.
#
# Outputs structured YAML that the command can consume directly.
#

set -eo pipefail

PLAN_DIR="docs/workflow/planning"
SPEC_DIR="docs/workflow/specification"
REVIEW_DIR="docs/workflow/review"
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

    for file in "$PLAN_DIR"/*/plan.md; do
        [ -f "$file" ] || continue

        name=$(basename "$(dirname "$file")")
        topic=$(extract_field "$file" "topic")
        topic=${topic:-"$name"}
        status=$(extract_field "$file" "status")
        status=${status:-"unknown"}
        date=$(extract_field "$file" "date")
        date=${date:-"unknown"}
        format=$(extract_field "$file" "format")
        format=${format:-"MISSING"}
        specification=$(extract_field "$file" "specification")
        specification=${specification:-"${name}/specification.md"}
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
# REVIEWS
#
echo "reviews:"

reviewed_plan_count=0
# Track which plan names have been reviewed (space-separated)
reviewed_plans=""

if [ -d "$REVIEW_DIR" ]; then
    # Check for any review directories with r*/review.md
    has_reviews="false"
    for topic_dir in "$REVIEW_DIR"/*/; do
        [ -d "$topic_dir" ] || continue
        if ls -d "$topic_dir"r*/review.md >/dev/null 2>&1; then
            has_reviews="true"
            break
        fi
    done

    echo "  exists: $has_reviews"

    if [ "$has_reviews" = "true" ]; then
        echo "  entries:"

        for topic_dir in "$REVIEW_DIR"/*/; do
            [ -d "$topic_dir" ] || continue
            topic=$(basename "$topic_dir")
            # Count r*/ versions
            versions=0
            latest_version=0
            latest_path=""
            for rdir in "$topic_dir"r*/; do
                [ -d "$rdir" ] || continue
                [ -f "${rdir}review.md" ] || continue
                rnum=${rdir##*r}
                rnum=${rnum%/}
                versions=$((versions + 1))
                if [ "$rnum" -gt "$latest_version" ] 2>/dev/null; then
                    latest_version=$rnum
                    latest_path="$rdir"
                fi
            done

            [ "$versions" -eq 0 ] && continue

            # Extract verdict from latest review.md
            latest_verdict=""
            if [ -f "${latest_path}review.md" ]; then
                latest_verdict=$(grep -m1 '\*\*QA Verdict\*\*:' "${latest_path}review.md" 2>/dev/null | \
                    sed -E 's/.*\*\*QA Verdict\*\*:[[:space:]]*//' || true)
            fi

            # Check for synthesis: look for review-tasks-c*.md in implementation dir
            has_synthesis="false"
            if ls "$IMPL_DIR/$topic"/review-tasks-c*.md >/dev/null 2>&1; then
                has_synthesis="true"
            fi

            # Track reviewed plans
            if ! echo " $reviewed_plans " | grep -q " $topic "; then
                reviewed_plans="$reviewed_plans $topic"
                reviewed_plan_count=$((reviewed_plan_count + 1))
            fi

            echo "    - topic: \"$topic\""
            echo "      versions: $versions"
            echo "      latest_version: $latest_version"
            echo "      latest_verdict: \"$latest_verdict\""
            echo "      latest_path: \"$latest_path\""
            echo "      has_synthesis: $has_synthesis"
        done
    fi
else
    echo "  exists: false"
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
echo "  reviewed_plan_count: $reviewed_plan_count"

# Determine if all implemented plans have been reviewed
all_reviewed="false"
if [ "$implemented_count" -gt 0 ] && [ "$reviewed_plan_count" -ge "$implemented_count" ]; then
    all_reviewed="true"
fi
echo "  all_reviewed: $all_reviewed"

# Determine workflow state for routing
if [ "$plan_count" -eq 0 ]; then
    echo "  scenario: \"no_plans\""
elif [ "$plan_count" -eq 1 ]; then
    echo "  scenario: \"single_plan\""
else
    echo "  scenario: \"multiple_plans\""
fi
