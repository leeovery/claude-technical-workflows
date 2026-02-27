#!/bin/bash
#
# Comprehensive workflow discovery for /workflow-start.
#
# Scans all workflow directories and groups artifacts by work_type:
# - greenfield: phase-centric, all topics (work_type: greenfield or unset)
# - features: topics with work_type: feature
# - bugfixes: topics with work_type: bugfix (includes investigations)
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
INVESTIGATION_DIR=".workflows/investigation"

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
echo "# Workflow Discovery (Unified Entry Point)"
echo "# Generated: $(date -Iseconds)"
echo ""

#
# GREENFIELD SECTION (phase-centric view)
#
echo "greenfield:"
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
echo "  discussions:"

greenfield_disc_count=0
greenfield_disc_concluded=0
greenfield_disc_in_progress=0

if [ -d "$DISCUSSION_DIR" ] && [ -n "$(ls -A "$DISCUSSION_DIR" 2>/dev/null)" ]; then
    first=true
    for file in "$DISCUSSION_DIR"/*.md; do
        [ -f "$file" ] || continue
        name=$(basename "$file" .md)
        status=$(extract_field "$file" "status")
        status=${status:-"in-progress"}
        work_type=$(extract_field "$file" "work_type")
        work_type=${work_type:-"greenfield"}

        # Only include greenfield discussions
        [ "$work_type" = "greenfield" ] || continue

        if $first; then
            echo "    files:"
            first=false
        fi

        echo "      - name: \"$name\""
        echo "        status: \"$status\""

        greenfield_disc_count=$((greenfield_disc_count + 1))
        [ "$status" = "concluded" ] && greenfield_disc_concluded=$((greenfield_disc_concluded + 1))
        [ "$status" = "in-progress" ] && greenfield_disc_in_progress=$((greenfield_disc_in_progress + 1))
    done
    if $first; then
        echo "    files: []"
    fi
else
    echo "    files: []"
fi

echo "    count: $greenfield_disc_count"
echo "    concluded: $greenfield_disc_concluded"
echo "    in_progress: $greenfield_disc_in_progress"

echo ""
echo "  specifications:"

greenfield_spec_count=0
greenfield_spec_concluded=0
greenfield_spec_feature=0
greenfield_spec_crosscutting=0

if [ -d "$SPEC_DIR" ] && [ -n "$(ls -A "$SPEC_DIR" 2>/dev/null)" ]; then
    first=true
    for file in "$SPEC_DIR"/*/specification.md; do
        [ -f "$file" ] || continue
        name=$(basename "$(dirname "$file")")
        status=$(extract_field "$file" "status")
        status=${status:-"in-progress"}
        spec_type=$(extract_field "$file" "type")
        spec_type=${spec_type:-"feature"}
        work_type=$(extract_field "$file" "work_type")
        work_type=${work_type:-"greenfield"}

        # Only include greenfield specs
        [ "$work_type" = "greenfield" ] || continue

        if $first; then
            echo "    files:"
            first=false
        fi

        echo "      - name: \"$name\""
        echo "        status: \"$status\""
        echo "        type: \"$spec_type\""

        greenfield_spec_count=$((greenfield_spec_count + 1))
        [ "$status" = "concluded" ] && greenfield_spec_concluded=$((greenfield_spec_concluded + 1))
        [ "$spec_type" = "cross-cutting" ] && greenfield_spec_crosscutting=$((greenfield_spec_crosscutting + 1))
        [ "$spec_type" = "feature" ] && greenfield_spec_feature=$((greenfield_spec_feature + 1))
    done
    if $first; then
        echo "    files: []"
    fi
else
    echo "    files: []"
fi

echo "    count: $greenfield_spec_count"
echo "    concluded: $greenfield_spec_concluded"
echo "    feature: $greenfield_spec_feature"
echo "    crosscutting: $greenfield_spec_crosscutting"

echo ""
echo "  plans:"

greenfield_plan_count=0
greenfield_plan_concluded=0

if [ -d "$PLAN_DIR" ] && [ -n "$(ls -A "$PLAN_DIR" 2>/dev/null)" ]; then
    first=true
    for file in "$PLAN_DIR"/*/plan.md; do
        [ -f "$file" ] || continue
        name=$(basename "$(dirname "$file")")
        status=$(extract_field "$file" "status")
        status=${status:-"in-progress"}
        work_type=$(extract_field "$file" "work_type")
        work_type=${work_type:-"greenfield"}

        # Only include greenfield plans
        [ "$work_type" = "greenfield" ] || continue

        if $first; then
            echo "    files:"
            first=false
        fi

        echo "      - name: \"$name\""
        echo "        status: \"$status\""

        greenfield_plan_count=$((greenfield_plan_count + 1))
        [ "$status" = "concluded" ] && greenfield_plan_concluded=$((greenfield_plan_concluded + 1))
    done
    if $first; then
        echo "    files: []"
    fi
else
    echo "    files: []"
fi

echo "    count: $greenfield_plan_count"
echo "    concluded: $greenfield_plan_concluded"

echo ""
echo "  implementation:"

greenfield_impl_count=0
greenfield_impl_completed=0

if [ -d "$IMPL_DIR" ] && [ -n "$(ls -A "$IMPL_DIR" 2>/dev/null)" ]; then
    first=true
    for file in "$IMPL_DIR"/*/tracking.md; do
        [ -f "$file" ] || continue
        topic=$(basename "$(dirname "$file")")
        status=$(extract_field "$file" "status")
        status=${status:-"in-progress"}
        work_type=$(extract_field "$file" "work_type")
        work_type=${work_type:-"greenfield"}

        # Only include greenfield implementations
        [ "$work_type" = "greenfield" ] || continue

        if $first; then
            echo "    files:"
            first=false
        fi

        echo "      - topic: \"$topic\""
        echo "        status: \"$status\""

        greenfield_impl_count=$((greenfield_impl_count + 1))
        [ "$status" = "completed" ] && greenfield_impl_completed=$((greenfield_impl_completed + 1))
    done
    if $first; then
        echo "    files: []"
    fi
else
    echo "    files: []"
fi

echo "    count: $greenfield_impl_count"
echo "    completed: $greenfield_impl_completed"

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

if [ -d "$SPEC_DIR" ]; then
    for file in "$SPEC_DIR"/*/specification.md; do
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
        # Determine phase state for this topic
        disc_exists="false"
        disc_status=""
        disc_file="$DISCUSSION_DIR/${topic}.md"
        if [ -f "$disc_file" ]; then
            disc_exists="true"
            disc_status=$(extract_field "$disc_file" "status")
            disc_status=${disc_status:-"in-progress"}
        fi

        spec_exists="false"
        spec_status=""
        spec_file="$SPEC_DIR/${topic}/specification.md"
        if [ -f "$spec_file" ]; then
            spec_exists="true"
            spec_status=$(extract_field "$spec_file" "status")
            spec_status=${spec_status:-"in-progress"}
        fi

        plan_exists="false"
        plan_status=""
        plan_file="$PLAN_DIR/${topic}/plan.md"
        if [ -f "$plan_file" ]; then
            plan_exists="true"
            plan_status=$(extract_field "$plan_file" "status")
            plan_status=${plan_status:-"in-progress"}
        fi

        impl_exists="false"
        impl_status=""
        impl_file="$IMPL_DIR/${topic}/tracking.md"
        if [ -f "$impl_file" ]; then
            impl_exists="true"
            impl_status=$(extract_field "$impl_file" "status")
            impl_status=${impl_status:-"in-progress"}
        fi

        review_exists="false"
        if [ -d "$REVIEW_DIR/${topic}" ]; then
            for rdir in "$REVIEW_DIR/${topic}"/r*/; do
                [ -d "$rdir" ] || continue
                [ -f "${rdir}review.md" ] && review_exists="true" && break
            done
        fi

        # Compute next_phase
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
        elif [ "$spec_exists" = "true" ] && [ "$spec_status" = "concluded" ]; then
            next_phase="planning"
        elif [ "$spec_exists" = "true" ]; then
            next_phase="specification"
        elif [ "$disc_exists" = "true" ] && [ "$disc_status" = "concluded" ]; then
            next_phase="specification"
        elif [ "$disc_exists" = "true" ]; then
            next_phase="discussion"
        else
            next_phase="unknown"
        fi

        echo "    - name: \"$topic\""
        echo "      next_phase: \"$next_phase\""
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
if [ -d "$DISCUSSION_DIR" ]; then
    for file in "$DISCUSSION_DIR"/*.md; do
        [ -f "$file" ] || continue
        work_type=$(extract_field "$file" "work_type")
        if [ "$work_type" = "bugfix" ]; then
            name=$(basename "$file" .md)
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

if [ -d "$SPEC_DIR" ]; then
    for file in "$SPEC_DIR"/*/specification.md; do
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
        # Determine phase state for this topic (investigation → spec → plan → impl → review)
        inv_exists="false"
        inv_status=""
        inv_file="$INVESTIGATION_DIR/${topic}/investigation.md"
        if [ -f "$inv_file" ]; then
            inv_exists="true"
            inv_status=$(extract_field "$inv_file" "status")
            inv_status=${inv_status:-"in-progress"}
        fi

        spec_exists="false"
        spec_status=""
        spec_file="$SPEC_DIR/${topic}/specification.md"
        if [ -f "$spec_file" ]; then
            spec_exists="true"
            spec_status=$(extract_field "$spec_file" "status")
            spec_status=${spec_status:-"in-progress"}
        fi

        plan_exists="false"
        plan_status=""
        plan_file="$PLAN_DIR/${topic}/plan.md"
        if [ -f "$plan_file" ]; then
            plan_exists="true"
            plan_status=$(extract_field "$plan_file" "status")
            plan_status=${plan_status:-"in-progress"}
        fi

        impl_exists="false"
        impl_status=""
        impl_file="$IMPL_DIR/${topic}/tracking.md"
        if [ -f "$impl_file" ]; then
            impl_exists="true"
            impl_status=$(extract_field "$impl_file" "status")
            impl_status=${impl_status:-"in-progress"}
        fi

        review_exists="false"
        if [ -d "$REVIEW_DIR/${topic}" ]; then
            for rdir in "$REVIEW_DIR/${topic}"/r*/; do
                [ -d "$rdir" ] || continue
                [ -f "${rdir}review.md" ] && review_exists="true" && break
            done
        fi

        # Compute next_phase for bugfix pipeline
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
# STATE SUMMARY
#
echo "state:"

has_any_work="false"
if [ "$research_count" -gt 0 ] || [ "$greenfield_disc_count" -gt 0 ] || [ "$greenfield_spec_count" -gt 0 ] || \
   [ "$greenfield_plan_count" -gt 0 ] || [ "$greenfield_impl_count" -gt 0 ] || \
   [ "$feature_count" -gt 0 ] || [ "$bugfix_count" -gt 0 ]; then
    has_any_work="true"
fi

echo "  has_any_work: $has_any_work"
echo "  greenfield:"
echo "    research_count: $research_count"
echo "    discussion_count: $greenfield_disc_count"
echo "    discussion_concluded: $greenfield_disc_concluded"
echo "    specification_count: $greenfield_spec_count"
echo "    specification_concluded: $greenfield_spec_concluded"
echo "    plan_count: $greenfield_plan_count"
echo "    plan_concluded: $greenfield_plan_concluded"
echo "    implementation_count: $greenfield_impl_count"
echo "    implementation_completed: $greenfield_impl_completed"
echo "  feature_count: $feature_count"
echo "  bugfix_count: $bugfix_count"
