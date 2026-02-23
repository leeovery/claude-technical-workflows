#!/bin/bash
#
# Cross-phase discovery script for /continue-feature.
#
# Scans all workflow directories (research, discussion, specification, planning,
# implementation) and builds a unified topic list with phase state
# and next_phase computation.
#
# Outputs structured YAML that the command can consume directly.
#

set -eo pipefail

RESEARCH_DIR=".workflows/research"
DISC_DIR=".workflows/discussion"
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
echo "# Continue-Feature Cross-Phase Discovery"
echo "# Generated: $(date -Iseconds)"
echo ""

#
# Collect all unique topic names from research + discussion + specification
#
declare -a all_topics=()
declare -A topic_seen=()

# Scan research (feature research has topic in frontmatter or filename)
if [ -d "$RESEARCH_DIR" ]; then
    for file in "$RESEARCH_DIR"/*.md; do
        [ -f "$file" ] || continue
        work_type=$(extract_field "$file" "work_type")
        # Only include feature research (has work_type: feature)
        [ "$work_type" = "feature" ] || continue
        name=$(basename "$file" .md)
        if [ -z "${topic_seen[$name]+x}" ]; then
            all_topics+=("$name")
            topic_seen[$name]=1
        fi
    done
fi

# Scan discussions
if [ -d "$DISC_DIR" ]; then
    for file in "$DISC_DIR"/*.md; do
        [ -f "$file" ] || continue
        name=$(basename "$file" .md)
        if [ -z "${topic_seen[$name]+x}" ]; then
            all_topics+=("$name")
            topic_seen[$name]=1
        fi
    done
fi

# Scan specifications
if [ -d "$SPEC_DIR" ]; then
    for dir in "$SPEC_DIR"/*/; do
        [ -d "$dir" ] || continue
        [ -f "${dir}specification.md" ] || continue
        name=$(basename "$dir")
        if [ -z "${topic_seen[$name]+x}" ]; then
            all_topics+=("$name")
            topic_seen[$name]=1
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
        # Research state (feature research)
        research_exists="false"
        research_status=""
        research_file="$RESEARCH_DIR/${topic}.md"
        if [ -f "$research_file" ]; then
            work_type=$(extract_field "$research_file" "work_type")
            if [ "$work_type" = "feature" ]; then
                research_exists="true"
                research_status=$(extract_field "$research_file" "status")
                research_status=${research_status:-"in-progress"}
            fi
        fi

        # Discussion state
        disc_exists="false"
        disc_status=""
        disc_file="$DISC_DIR/${topic}.md"
        if [ -f "$disc_file" ]; then
            disc_exists="true"
            disc_status=$(extract_field "$disc_file" "status")
            disc_status=${disc_status:-"in-progress"}
        fi

        # Specification state
        spec_exists="false"
        spec_status=""
        spec_type=""
        spec_file="$SPEC_DIR/${topic}/specification.md"
        if [ -f "$spec_file" ]; then
            spec_exists="true"
            spec_status=$(extract_field "$spec_file" "status")
            spec_status=${spec_status:-"in-progress"}
            spec_type=$(extract_field "$spec_file" "type")
            spec_type=${spec_type:-"feature"}
        fi

        # Skip cross-cutting specs — they aren't features
        if [ "$spec_type" = "cross-cutting" ]; then
            continue
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
        # Compute next_phase (check from top down, first match wins)
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
        elif [ "$disc_exists" = "true" ] && [ "$disc_status" = "concluded" ]; then
            next_phase="specification"
        elif [ "$disc_exists" = "true" ]; then
            next_phase="discussion"
        elif [ "$research_exists" = "true" ] && [ "$research_status" = "concluded" ]; then
            next_phase="discussion"  # Research done, ready for discussion
        elif [ "$research_exists" = "true" ]; then
            next_phase="research"
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

        echo "    research:"
        echo "      exists: $research_exists"
        if [ "$research_exists" = "true" ]; then
            echo "      status: \"$research_status\""
        fi

        echo "    discussion:"
        echo "      exists: $disc_exists"
        if [ "$disc_exists" = "true" ]; then
            echo "      status: \"$disc_status\""
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
