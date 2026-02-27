#!/bin/bash
#
# Topic-specific discovery script for /workflow-bridge.
#
# Usage:
#   discovery.sh --feature --topic <topic>
#   discovery.sh --bugfix --topic <topic>
#   discovery.sh --greenfield
#
# For feature/bugfix: Checks artifacts for a specific topic and computes next_phase.
# For greenfield: Does full phase-centric discovery across all phases.
#
# Outputs structured YAML that the skill can consume directly.
#

set -eo pipefail

RESEARCH_DIR=".workflows/research"
DISCUSSION_DIR=".workflows/discussion"
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

    if head -1 "$file" 2>/dev/null | grep -q "^---$"; then
        value=$(sed -n '2,/^---$/p' "$file" 2>/dev/null | \
            grep -i -m1 "^${field}:" | \
            sed -E "s/^${field}:[[:space:]]*//i" || true)
    fi

    echo "$value"
}

#
# Parse arguments
#
topic=""
work_type=""

while [ $# -gt 0 ]; do
    case "$1" in
        --topic)
            topic="$2"
            shift 2
            ;;
        --greenfield)
            work_type="greenfield"
            shift
            ;;
        --feature)
            work_type="feature"
            shift
            ;;
        --bugfix)
            work_type="bugfix"
            shift
            ;;
        *)
            echo "error: \"Unknown argument: $1\""
            echo "error: \"Usage: discovery.sh --feature|--bugfix --topic <topic> OR discovery.sh --greenfield\""
            exit 1
            ;;
    esac
done

if [ -z "$work_type" ]; then
    echo "error: \"Work type flag required: --greenfield, --feature, or --bugfix\""
    exit 1
fi

if [ "$work_type" != "greenfield" ] && [ -z "$topic" ]; then
    echo "error: \"--topic is required for --feature and --bugfix\""
    exit 1
fi

# Start YAML output
echo "# Workflow Bridge Discovery"
echo "# Generated: $(date -Iseconds)"
echo ""
echo "work_type: \"$work_type\""
echo "topic: \"$topic\""
echo ""

#
# TOPIC-SPECIFIC DISCOVERY (feature/bugfix)
#
if [ "$work_type" = "feature" ] || [ "$work_type" = "bugfix" ]; then
    echo "topic_state:"

    # Research state (feature only)
    research_exists="false"
    research_status=""
    if [ "$work_type" = "feature" ]; then
        research_file="$RESEARCH_DIR/${topic}.md"
        if [ -f "$research_file" ]; then
            file_work_type=$(extract_field "$research_file" "work_type")
            if [ "$file_work_type" = "feature" ]; then
                research_exists="true"
                research_status=$(extract_field "$research_file" "status")
                research_status=${research_status:-"in-progress"}
            fi
        fi
    fi
    echo "  research:"
    echo "    exists: $research_exists"
    [ "$research_exists" = "true" ] && echo "    status: \"$research_status\""

    # Discussion state (feature only)
    discussion_exists="false"
    discussion_status=""
    if [ "$work_type" = "feature" ]; then
        discussion_file="$DISCUSSION_DIR/${topic}.md"
        if [ -f "$discussion_file" ]; then
            discussion_exists="true"
            discussion_status=$(extract_field "$discussion_file" "status")
            discussion_status=${discussion_status:-"in-progress"}
        fi
    fi
    echo "  discussion:"
    echo "    exists: $discussion_exists"
    [ "$discussion_exists" = "true" ] && echo "    status: \"$discussion_status\""

    # Investigation state (bugfix only)
    investigation_exists="false"
    investigation_status=""
    if [ "$work_type" = "bugfix" ]; then
        investigation_file="$INVESTIGATION_DIR/${topic}/investigation.md"
        if [ -f "$investigation_file" ]; then
            investigation_exists="true"
            investigation_status=$(extract_field "$investigation_file" "status")
            investigation_status=${investigation_status:-"in-progress"}
        fi
    fi
    echo "  investigation:"
    echo "    exists: $investigation_exists"
    [ "$investigation_exists" = "true" ] && echo "    status: \"$investigation_status\""

    # Specification state
    spec_exists="false"
    spec_status=""
    spec_file="$SPEC_DIR/${topic}/specification.md"
    if [ -f "$spec_file" ]; then
        spec_exists="true"
        spec_status=$(extract_field "$spec_file" "status")
        spec_status=${spec_status:-"in-progress"}
    fi
    echo "  specification:"
    echo "    exists: $spec_exists"
    [ "$spec_exists" = "true" ] && echo "    status: \"$spec_status\""

    # Plan state
    plan_exists="false"
    plan_status=""
    plan_file="$PLAN_DIR/${topic}/plan.md"
    if [ -f "$plan_file" ]; then
        plan_exists="true"
        plan_status=$(extract_field "$plan_file" "status")
        plan_status=${plan_status:-"in-progress"}
    fi
    echo "  plan:"
    echo "    exists: $plan_exists"
    [ "$plan_exists" = "true" ] && echo "    status: \"$plan_status\""

    # Implementation state
    impl_exists="false"
    impl_status=""
    impl_file="$IMPL_DIR/${topic}/tracking.md"
    if [ -f "$impl_file" ]; then
        impl_exists="true"
        impl_status=$(extract_field "$impl_file" "status")
        impl_status=${impl_status:-"in-progress"}
    fi
    echo "  implementation:"
    echo "    exists: $impl_exists"
    [ "$impl_exists" = "true" ] && echo "    status: \"$impl_status\""

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
    echo "  review:"
    echo "    exists: $review_exists"

    echo ""

    #
    # Compute next_phase for feature pipeline
    # (Research) → Discussion → Specification → Planning → Implementation → Review
    #
    if [ "$work_type" = "feature" ]; then
        if [ "$impl_exists" = "true" ] && [ "$impl_status" = "completed" ] && [ "$review_exists" = "true" ]; then
            next_phase="done"
        elif [ "$impl_exists" = "true" ] && [ "$impl_status" = "completed" ]; then
            next_phase="review"
        elif [ "$impl_exists" = "true" ] && [ "$impl_status" = "in-progress" ]; then
            next_phase="implementation"
        elif [ "$plan_exists" = "true" ] && [ "$plan_status" = "concluded" ]; then
            next_phase="implementation"
        elif [ "$plan_exists" = "true" ]; then
            next_phase="planning"
        elif [ "$spec_exists" = "true" ] && [ "$spec_status" = "superseded" ]; then
            next_phase="superseded"
        elif [ "$spec_exists" = "true" ] && [ "$spec_status" = "concluded" ]; then
            next_phase="planning"
        elif [ "$spec_exists" = "true" ]; then
            next_phase="specification"
        elif [ "$discussion_exists" = "true" ] && [ "$discussion_status" = "concluded" ]; then
            next_phase="specification"
        elif [ "$discussion_exists" = "true" ]; then
            next_phase="discussion"
        elif [ "$research_exists" = "true" ]; then
            next_phase="discussion"
        else
            next_phase="unknown"
        fi
    fi

    #
    # Compute next_phase for bugfix pipeline
    # Investigation → Specification → Planning → Implementation → Review
    #
    if [ "$work_type" = "bugfix" ]; then
        if [ "$impl_exists" = "true" ] && [ "$impl_status" = "completed" ] && [ "$review_exists" = "true" ]; then
            next_phase="done"
        elif [ "$impl_exists" = "true" ] && [ "$impl_status" = "completed" ]; then
            next_phase="review"
        elif [ "$impl_exists" = "true" ] && [ "$impl_status" = "in-progress" ]; then
            next_phase="implementation"
        elif [ "$plan_exists" = "true" ] && [ "$plan_status" = "concluded" ]; then
            next_phase="implementation"
        elif [ "$plan_exists" = "true" ]; then
            next_phase="planning"
        elif [ "$spec_exists" = "true" ] && [ "$spec_status" = "superseded" ]; then
            next_phase="superseded"
        elif [ "$spec_exists" = "true" ] && [ "$spec_status" = "concluded" ]; then
            next_phase="planning"
        elif [ "$spec_exists" = "true" ]; then
            next_phase="specification"
        elif [ "$investigation_exists" = "true" ] && [ "$investigation_status" = "concluded" ]; then
            next_phase="specification"
        elif [ "$investigation_exists" = "true" ]; then
            next_phase="investigation"
        else
            next_phase="unknown"
        fi
    fi

    echo "next_phase: \"$next_phase\""

#
# GREENFIELD DISCOVERY (phase-centric)
#
elif [ "$work_type" = "greenfield" ]; then

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
            file_work_type=$(extract_field "$file" "work_type")
            file_work_type=${file_work_type:-"greenfield"}
            [ "$file_work_type" = "greenfield" ] || continue

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

    if [ -d "$SPEC_DIR" ] && [ -n "$(ls -A "$SPEC_DIR" 2>/dev/null)" ]; then
        first=true
        for file in "$SPEC_DIR"/*/specification.md; do
            [ -f "$file" ] || continue
            file_work_type=$(extract_field "$file" "work_type")
            file_work_type=${file_work_type:-"greenfield"}
            [ "$file_work_type" = "greenfield" ] || continue

            name=$(basename "$(dirname "$file")")
            status=$(extract_field "$file" "status")
            status=${status:-"in-progress"}
            spec_type=$(extract_field "$file" "type")
            spec_type=${spec_type:-"feature"}

            # Skip superseded specs — they've been absorbed into another spec
            [ "$status" = "superseded" ] && continue

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
            file_work_type=$(extract_field "$file" "work_type")
            file_work_type=${file_work_type:-"greenfield"}
            [ "$file_work_type" = "greenfield" ] || continue

            name=$(basename "$(dirname "$file")")
            status=$(extract_field "$file" "status")
            status=${status:-"in-progress"}

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
            file_work_type=$(extract_field "$file" "work_type")
            file_work_type=${file_work_type:-"greenfield"}
            [ "$file_work_type" = "greenfield" ] || continue

            topic_name=$(basename "$(dirname "$file")")
            status=$(extract_field "$file" "status")
            status=${status:-"in-progress"}

            has_review="false"
            if [ -d "$REVIEW_DIR/${topic_name}" ]; then
                for rdir in "$REVIEW_DIR/${topic_name}"/r*/; do
                    [ -d "$rdir" ] || continue
                    [ -f "${rdir}review.md" ] && has_review="true" && break
                done
            fi

            if $first; then
                echo "  files:"
                first=false
            fi

            echo "    - topic: \"$topic_name\""
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

    has_any_work="false"
    if [ "$research_count" -gt 0 ] || [ "$disc_count" -gt 0 ] || [ "$spec_count" -gt 0 ] || \
       [ "$plan_count" -gt 0 ] || [ "$impl_count" -gt 0 ]; then
        has_any_work="true"
    fi
    echo "  has_any_work: $has_any_work"
fi
