#!/bin/bash
#
# Unified discovery script for /workflow-bridge.
#
# No arguments — scans all workflow directories and outputs:
# - features: per-topic state with computed next_phase
# - bugfixes: per-topic state with computed next_phase
# - greenfield: phase-centric view across all phases
# - state: summary counts
#
# Outputs structured YAML that the skill can consume directly.
# The skill filters by its known work_type and topic from calling context.
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

# Helper: Check if a review exists for a topic
# Usage: has_review <topic>
has_review() {
    local topic_name="$1"
    if [ -d "$REVIEW_DIR/${topic_name}" ]; then
        for rdir in "$REVIEW_DIR/${topic_name}"/r*/; do
            [ -d "$rdir" ] || continue
            [ -f "${rdir}review.md" ] && echo "true" && return
        done
    fi
    echo "false"
}

# Start YAML output
echo "# Workflow Bridge Discovery"
echo "# Generated: $(date -Iseconds)"
echo ""

#
# FEATURES SECTION (topic-centric view for work_type: feature)
#
echo "features:"

feature_topics=()
feature_seen_list=""

# Scan all phases for work_type: feature
if [ -d "$DISCUSSION_DIR" ]; then
    for file in "$DISCUSSION_DIR"/*.md; do
        [ -f "$file" ] || continue
        work_type=$(extract_field "$file" "work_type")
        if [ "$work_type" = "feature" ]; then
            name=$(basename "$file" .md)
            case ",$feature_seen_list," in
                *,"$name",*) ;;
                *)
                    feature_topics+=("$name")
                    feature_seen_list="${feature_seen_list:+$feature_seen_list,}$name"
                    ;;
            esac
        fi
    done
fi

if [ -d "$RESEARCH_DIR" ]; then
    for file in "$RESEARCH_DIR"/*.md; do
        [ -f "$file" ] || continue
        work_type=$(extract_field "$file" "work_type")
        if [ "$work_type" = "feature" ]; then
            name=$(basename "$file" .md)
            case ",$feature_seen_list," in
                *,"$name",*) ;;
                *)
                    feature_topics+=("$name")
                    feature_seen_list="${feature_seen_list:+$feature_seen_list,}$name"
                    ;;
            esac
        fi
    done
fi

if [ -d "$SPEC_DIR" ]; then
    for file in "$SPEC_DIR"/*/specification.md; do
        [ -f "$file" ] || continue
        work_type=$(extract_field "$file" "work_type")
        if [ "$work_type" = "feature" ]; then
            status=$(extract_field "$file" "status")
            [ "$status" = "superseded" ] && continue
            name=$(basename "$(dirname "$file")")
            case ",$feature_seen_list," in
                *,"$name",*) ;;
                *)
                    feature_topics+=("$name")
                    feature_seen_list="${feature_seen_list:+$feature_seen_list,}$name"
                    ;;
            esac
        fi
    done
fi

if [ -d "$PLAN_DIR" ]; then
    for file in "$PLAN_DIR"/*/plan.md; do
        [ -f "$file" ] || continue
        work_type=$(extract_field "$file" "work_type")
        if [ "$work_type" = "feature" ]; then
            name=$(basename "$(dirname "$file")")
            case ",$feature_seen_list," in
                *,"$name",*) ;;
                *)
                    feature_topics+=("$name")
                    feature_seen_list="${feature_seen_list:+$feature_seen_list,}$name"
                    ;;
            esac
        fi
    done
fi

feature_count=${#feature_topics[@]}

if [ "$feature_count" -eq 0 ]; then
    echo "  topics: []"
else
    echo "  topics:"
    for topic in "${feature_topics[@]}"; do
        # Research state
        research_exists="false"
        research_file="$RESEARCH_DIR/${topic}.md"
        if [ -f "$research_file" ]; then
            file_wt=$(extract_field "$research_file" "work_type")
            [ "$file_wt" = "feature" ] && research_exists="true"
        fi

        # Discussion state
        disc_exists="false"
        disc_status=""
        disc_file="$DISCUSSION_DIR/${topic}.md"
        if [ -f "$disc_file" ]; then
            disc_exists="true"
            disc_status=$(extract_field "$disc_file" "status")
            disc_status=${disc_status:-"in-progress"}
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
        plan_file="$PLAN_DIR/${topic}/plan.md"
        if [ -f "$plan_file" ]; then
            plan_exists="true"
            plan_status=$(extract_field "$plan_file" "status")
            plan_status=${plan_status:-"in-progress"}
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
        review_exists=$(has_review "$topic")

        # Compute next_phase for feature pipeline
        # (Research) → Discussion → Specification → Planning → Implementation → Review
        next_phase=""
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
        elif [ "$disc_exists" = "true" ] && [ "$disc_status" = "concluded" ]; then
            next_phase="specification"
        elif [ "$disc_exists" = "true" ]; then
            next_phase="discussion"
        elif [ "$research_exists" = "true" ]; then
            next_phase="discussion"
        else
            next_phase="unknown"
        fi

        echo "    - name: \"$topic\""
        echo "      next_phase: \"$next_phase\""
        echo "      research:"
        echo "        exists: $research_exists"
        echo "      discussion:"
        echo "        exists: $disc_exists"
        [ "$disc_exists" = "true" ] && echo "        status: \"$disc_status\""
        echo "      specification:"
        echo "        exists: $spec_exists"
        [ "$spec_exists" = "true" ] && echo "        status: \"$spec_status\""
        echo "      plan:"
        echo "        exists: $plan_exists"
        [ "$plan_exists" = "true" ] && echo "        status: \"$plan_status\""
        echo "      implementation:"
        echo "        exists: $impl_exists"
        [ "$impl_exists" = "true" ] && echo "        status: \"$impl_status\""
        echo "      review:"
        echo "        exists: $review_exists"
    done
fi

echo "  count: $feature_count"

echo ""

#
# BUGFIXES SECTION (topic-centric view for work_type: bugfix)
#
echo "bugfixes:"

bugfix_topics=()
bugfix_seen_list=""

# Scan investigation directory first
if [ -d "$INVESTIGATION_DIR" ]; then
    for file in "$INVESTIGATION_DIR"/*/investigation.md; do
        [ -f "$file" ] || continue
        name=$(basename "$(dirname "$file")")
        case ",$bugfix_seen_list," in
            *,"$name",*) ;;
            *)
                bugfix_topics+=("$name")
                bugfix_seen_list="${bugfix_seen_list:+$bugfix_seen_list,}$name"
                ;;
        esac
    done
fi

# Scan other phases for work_type: bugfix
if [ -d "$SPEC_DIR" ]; then
    for file in "$SPEC_DIR"/*/specification.md; do
        [ -f "$file" ] || continue
        work_type=$(extract_field "$file" "work_type")
        if [ "$work_type" = "bugfix" ]; then
            status=$(extract_field "$file" "status")
            [ "$status" = "superseded" ] && continue
            name=$(basename "$(dirname "$file")")
            case ",$bugfix_seen_list," in
                *,"$name",*) ;;
                *)
                    bugfix_topics+=("$name")
                    bugfix_seen_list="${bugfix_seen_list:+$bugfix_seen_list,}$name"
                    ;;
            esac
        fi
    done
fi

if [ -d "$PLAN_DIR" ]; then
    for file in "$PLAN_DIR"/*/plan.md; do
        [ -f "$file" ] || continue
        work_type=$(extract_field "$file" "work_type")
        if [ "$work_type" = "bugfix" ]; then
            name=$(basename "$(dirname "$file")")
            case ",$bugfix_seen_list," in
                *,"$name",*) ;;
                *)
                    bugfix_topics+=("$name")
                    bugfix_seen_list="${bugfix_seen_list:+$bugfix_seen_list,}$name"
                    ;;
            esac
        fi
    done
fi

bugfix_count=${#bugfix_topics[@]}

if [ "$bugfix_count" -eq 0 ]; then
    echo "  topics: []"
else
    echo "  topics:"
    for topic in "${bugfix_topics[@]}"; do
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
        plan_file="$PLAN_DIR/${topic}/plan.md"
        if [ -f "$plan_file" ]; then
            plan_exists="true"
            plan_status=$(extract_field "$plan_file" "status")
            plan_status=${plan_status:-"in-progress"}
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
        review_exists=$(has_review "$topic")

        # Compute next_phase for bugfix pipeline
        # Investigation → Specification → Planning → Implementation → Review
        next_phase=""
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
        elif [ "$inv_exists" = "true" ] && [ "$inv_status" = "concluded" ]; then
            next_phase="specification"
        elif [ "$inv_exists" = "true" ]; then
            next_phase="investigation"
        else
            next_phase="unknown"
        fi

        echo "    - name: \"$topic\""
        echo "      next_phase: \"$next_phase\""
        echo "      investigation:"
        echo "        exists: $inv_exists"
        [ "$inv_exists" = "true" ] && echo "        status: \"$inv_status\""
        echo "      specification:"
        echo "        exists: $spec_exists"
        [ "$spec_exists" = "true" ] && echo "        status: \"$spec_status\""
        echo "      plan:"
        echo "        exists: $plan_exists"
        [ "$plan_exists" = "true" ] && echo "        status: \"$plan_status\""
        echo "      implementation:"
        echo "        exists: $impl_exists"
        [ "$impl_exists" = "true" ] && echo "        status: \"$impl_status\""
        echo "      review:"
        echo "        exists: $review_exists"
    done
fi

echo "  count: $bugfix_count"

echo ""

#
# GREENFIELD SECTION (phase-centric view)
#
echo "greenfield:"

#
# RESEARCH
#
echo "  research:"
research_count=0
if [ -d "$RESEARCH_DIR" ] && [ -n "$(ls -A "$RESEARCH_DIR" 2>/dev/null)" ]; then
    echo "    exists: true"
    echo "    files:"
    for file in "$RESEARCH_DIR"/*; do
        [ -f "$file" ] || continue
        name=$(basename "$file" .md)
        echo "      - \"$name\""
        research_count=$((research_count + 1))
    done
    echo "    count: $research_count"
else
    echo "    exists: false"
    echo "    files: []"
    echo "    count: 0"
fi

echo ""

#
# DISCUSSIONS (greenfield only)
#
echo "  discussions:"
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
            echo "    files:"
            first=false
        fi

        echo "      - name: \"$name\""
        echo "        status: \"$status\""

        disc_count=$((disc_count + 1))
        [ "$status" = "concluded" ] && disc_concluded=$((disc_concluded + 1))
        [ "$status" = "in-progress" ] && disc_in_progress=$((disc_in_progress + 1))
    done
    if $first; then
        echo "    files: []"
    fi
else
    echo "    files: []"
fi

echo "    count: $disc_count"
echo "    concluded: $disc_concluded"
echo "    in_progress: $disc_in_progress"

echo ""

#
# SPECIFICATIONS (greenfield only)
#
echo "  specifications:"
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
            echo "    files:"
            first=false
        fi

        echo "      - name: \"$name\""
        echo "        status: \"$status\""
        echo "        type: \"$spec_type\""
        echo "        has_plan: $has_plan"

        spec_count=$((spec_count + 1))
        [ "$status" = "concluded" ] && spec_concluded=$((spec_concluded + 1))
        [ "$status" = "in-progress" ] && spec_in_progress=$((spec_in_progress + 1))
    done
    if $first; then
        echo "    files: []"
    fi
else
    echo "    files: []"
fi

echo "    count: $spec_count"
echo "    concluded: $spec_concluded"
echo "    in_progress: $spec_in_progress"

echo ""

#
# PLANS (greenfield only)
#
echo "  plans:"
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
            echo "    files:"
            first=false
        fi

        echo "      - name: \"$name\""
        echo "        status: \"$status\""
        echo "        has_implementation: $has_impl"

        plan_count=$((plan_count + 1))
        [ "$status" = "concluded" ] && plan_concluded=$((plan_concluded + 1))
        { [ "$status" = "in-progress" ] || [ "$status" = "planning" ]; } && plan_in_progress=$((plan_in_progress + 1))
    done
    if $first; then
        echo "    files: []"
    fi
else
    echo "    files: []"
fi

echo "    count: $plan_count"
echo "    concluded: $plan_concluded"
echo "    in_progress: $plan_in_progress"

echo ""

#
# IMPLEMENTATION (greenfield only)
#
echo "  implementation:"
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

        review_flag=$(has_review "$topic_name")

        if $first; then
            echo "    files:"
            first=false
        fi

        echo "      - topic: \"$topic_name\""
        echo "        status: \"$status\""
        echo "        has_review: $review_flag"

        impl_count=$((impl_count + 1))
        [ "$status" = "completed" ] && impl_completed=$((impl_completed + 1))
        [ "$status" = "in-progress" ] && impl_in_progress=$((impl_in_progress + 1))
    done
    if $first; then
        echo "    files: []"
    fi
else
    echo "    files: []"
fi

echo "    count: $impl_count"
echo "    completed: $impl_completed"
echo "    in_progress: $impl_in_progress"

echo ""

#
# STATE SUMMARY
#
echo "  state:"
echo "    research_count: $research_count"
echo "    discussion_count: $disc_count"
echo "    discussion_concluded: $disc_concluded"
echo "    discussion_in_progress: $disc_in_progress"
echo "    specification_count: $spec_count"
echo "    specification_concluded: $spec_concluded"
echo "    specification_in_progress: $spec_in_progress"
echo "    plan_count: $plan_count"
echo "    plan_concluded: $plan_concluded"
echo "    plan_in_progress: $plan_in_progress"
echo "    implementation_count: $impl_count"
echo "    implementation_completed: $impl_completed"
echo "    implementation_in_progress: $impl_in_progress"

has_any_work="false"
if [ "$research_count" -gt 0 ] || [ "$disc_count" -gt 0 ] || [ "$spec_count" -gt 0 ] || \
   [ "$plan_count" -gt 0 ] || [ "$impl_count" -gt 0 ] || \
   [ "$feature_count" -gt 0 ] || [ "$bugfix_count" -gt 0 ]; then
    has_any_work="true"
fi
echo "    has_any_work: $has_any_work"
