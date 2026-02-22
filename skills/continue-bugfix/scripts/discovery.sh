#!/bin/bash
#
# Cross-phase discovery script for /continue-bugfix.
#
# Scans all workflow directories (investigation, specification, planning,
# implementation, review) for bugfix topics and builds a unified topic list
# with phase state and next_phase computation.
#
# Bugfix pipeline: Investigation → Specification → Planning → Implementation → Review
#
# Outputs structured YAML that the command can consume directly.
#

set -eo pipefail

INVESTIGATION_DIR=".workflows/investigation"
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

    # Extract from YAML frontmatter (file must start with ---)
    if head -1 "$file" 2>/dev/null | grep -q "^---$"; then
        value=$(sed -n '2,/^---$/p' "$file" 2>/dev/null | \
            grep -i -m1 "^${field}:" | \
            sed -E "s/^${field}:[[:space:]]*//i" || true)
    fi

    echo "$value"
}

# Start YAML output
echo "# Continue-Bugfix Cross-Phase Discovery"
echo "# Generated: $(date -Iseconds)"
echo ""

#
# Collect all unique bugfix topic names
#
declare -a all_topics=()
declare -A topic_seen=()

# Scan investigations
if [ -d "$INVESTIGATION_DIR" ]; then
    for dir in "$INVESTIGATION_DIR"/*/; do
        [ -d "$dir" ] || continue
        [ -f "${dir}investigation.md" ] || continue
        name=$(basename "$dir")
        if [ -z "${topic_seen[$name]+x}" ]; then
            all_topics+=("$name")
            topic_seen[$name]=1
        fi
    done
fi

# Scan specifications with work_type: bugfix
if [ -d "$SPEC_DIR" ]; then
    for file in "$SPEC_DIR"/*/specification.md; do
        [ -f "$file" ] || continue
        work_type=$(extract_field "$file" "work_type")
        if [ "$work_type" = "bugfix" ]; then
            name=$(basename "$(dirname "$file")")
            if [ -z "${topic_seen[$name]+x}" ]; then
                all_topics+=("$name")
                topic_seen[$name]=1
            fi
        fi
    done
fi

# Scan plans with work_type: bugfix
if [ -d "$PLAN_DIR" ]; then
    for file in "$PLAN_DIR"/*/plan.md; do
        [ -f "$file" ] || continue
        work_type=$(extract_field "$file" "work_type")
        if [ "$work_type" = "bugfix" ]; then
            name=$(basename "$(dirname "$file")")
            if [ -z "${topic_seen[$name]+x}" ]; then
                all_topics+=("$name")
                topic_seen[$name]=1
            fi
        fi
    done
fi

#
# Build topic entries
#
echo "topics:"

topic_count=0
actionable_count=0

if [ ${#all_topics[@]} -eq 0 ]; then
    echo "  []"
else
    for topic in "${all_topics[@]}"; do
        # Investigation state
        inv_exists="false"
        inv_status=""
        inv_file="$INVESTIGATION_DIR/${topic}/investigation.md"
        if [ -f "$inv_file" ]; then
            inv_exists="true"
            inv_status=$(extract_field "$inv_file" "status")
            inv_status=${inv_status:-"in-progress"}
        fi

        # Specification state
        spec_exists="false"
        spec_status=""
        spec_file="$SPEC_DIR/${topic}/specification.md"
        if [ -f "$spec_file" ]; then
            spec_exists="true"
            spec_status=$(extract_field "$spec_file" "status")
            spec_status=${spec_status:-"in-progress"}
        fi

        # Plan state
        plan_exists="false"
        plan_status=""
        plan_format=""
        plan_file="$PLAN_DIR/${topic}/plan.md"
        if [ -f "$plan_file" ]; then
            plan_exists="true"
            plan_status=$(extract_field "$plan_file" "status")
            plan_status=${plan_status:-"in-progress"}
            plan_format=$(extract_field "$plan_file" "format")
            plan_format=${plan_format:-"unknown"}
        fi

        # Implementation state
        impl_exists="false"
        impl_status=""
        impl_file="$IMPL_DIR/${topic}/tracking.md"
        if [ -f "$impl_file" ]; then
            impl_exists="true"
            impl_status=$(extract_field "$impl_file" "status")
            impl_status=${impl_status:-"in-progress"}
        fi

        # Review state
        review_exists="false"
        if [ -d "$REVIEW_DIR/${topic}" ]; then
            for rdir in "$REVIEW_DIR/${topic}"/r*/; do
                [ -d "$rdir" ] || continue
                [ -f "${rdir}review.md" ] || continue
                review_exists="true"
                break
            done
        fi

        #
        # Compute next_phase for bugfix pipeline
        # Investigation → Specification → Planning → Implementation → Review
        #
        next_phase=""

        if [ "$impl_exists" = "true" ] && [ "$impl_status" = "completed" ] && [ "$review_exists" = "true" ]; then
            next_phase="done"
        elif [ "$impl_exists" = "true" ] && [ "$impl_status" = "completed" ] && [ "$review_exists" = "false" ]; then
            next_phase="review"
        elif [ "$impl_exists" = "true" ] && [ "$impl_status" = "in-progress" ]; then
            next_phase="implementation"
        elif [ "$plan_exists" = "true" ] && [ "$plan_status" = "concluded" ]; then
            next_phase="implementation"
        elif [ "$plan_exists" = "true" ] && [ "$plan_status" != "concluded" ]; then
            next_phase="planning"
        elif [ "$spec_exists" = "true" ] && [ "$spec_status" = "concluded" ]; then
            next_phase="planning"
        elif [ "$spec_exists" = "true" ] && [ "$spec_status" != "concluded" ]; then
            next_phase="specification"
        elif [ "$inv_exists" = "true" ] && [ "$inv_status" = "concluded" ]; then
            next_phase="specification"
        elif [ "$inv_exists" = "true" ]; then
            next_phase="investigation"
        else
            next_phase="unknown"
        fi

        # Actionable = can continue in the pipeline (not done, not unknown)
        actionable="false"
        if [ "$next_phase" != "done" ] && [ "$next_phase" != "unknown" ]; then
            actionable="true"
            actionable_count=$((actionable_count + 1))
        fi

        echo "  - name: \"$topic\""

        echo "    investigation:"
        echo "      exists: $inv_exists"
        if [ "$inv_exists" = "true" ]; then
            echo "      status: \"$inv_status\""
        fi

        echo "    specification:"
        echo "      exists: $spec_exists"
        if [ "$spec_exists" = "true" ]; then
            echo "      status: \"$spec_status\""
        fi

        echo "    plan:"
        echo "      exists: $plan_exists"
        if [ "$plan_exists" = "true" ]; then
            echo "      status: \"$plan_status\""
            echo "      format: \"$plan_format\""
        fi

        echo "    implementation:"
        echo "      exists: $impl_exists"
        if [ "$impl_exists" = "true" ]; then
            echo "      status: \"$impl_status\""
        fi

        echo "    review:"
        echo "      exists: $review_exists"

        echo "    next_phase: \"$next_phase\""
        echo "    actionable: $actionable"

        topic_count=$((topic_count + 1))
    done
fi

echo ""

#
# STATE SUMMARY
#
echo "state:"
echo "  topic_count: $topic_count"
echo "  actionable_count: $actionable_count"

if [ "$topic_count" -eq 0 ]; then
    echo "  scenario: \"no_topics\""
elif [ "$topic_count" -eq 1 ]; then
    echo "  scenario: \"single_topic\""
else
    echo "  scenario: \"multiple_topics\""
fi
