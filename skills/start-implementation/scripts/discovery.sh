#!/bin/bash
#
# Discovers the current state of plans for /start-implementation command.
#
# Outputs structured YAML that the command can consume directly.
#

set -eo pipefail

PLAN_DIR="docs/workflow/planning"
SPEC_DIR="docs/workflow/specification"
IMPL_DIR="docs/workflow/implementation"
ENVIRONMENT_FILE="docs/workflow/environment-setup.md"

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

# Helper: Extract external_dependencies from plan frontmatter
# Outputs individual dep entries as: topic|description|state|task_id
extract_external_deps() {
    local file="$1"
    local frontmatter
    frontmatter=$(extract_frontmatter "$file")

    # Check if external_dependencies exists and is not empty array
    if ! echo "$frontmatter" | grep -q "^external_dependencies:" 2>/dev/null; then
        return 0
    fi

    # Check for empty array format
    if echo "$frontmatter" | grep -q "^external_dependencies:[[:space:]]*\[\]" 2>/dev/null; then
        return 0
    fi

    # Extract the external_dependencies block
    echo "$frontmatter" | awk '
/^external_dependencies:/ { in_block=1; next }
in_block && /^[a-z_]+:/ && !/^[[:space:]]/ { exit }
in_block && /^[[:space:]]*- topic:/ {
    # Print previous entry if we have one
    if (topic != "" && state != "") {
        print topic "|" desc "|" state "|" task_id
    }
    # Start new entry
    line=$0; gsub(/^[[:space:]]*- topic:[[:space:]]*/, "", line)
    topic=line; desc=""; state=""; task_id=""
    next
}
in_block && /^[[:space:]]*description:/ {
    line=$0; gsub(/^[[:space:]]*description:[[:space:]]*/, "", line)
    desc=line; next
}
in_block && /^[[:space:]]*state:/ {
    line=$0; gsub(/^[[:space:]]*state:[[:space:]]*/, "", line)
    state=line; next
}
in_block && /^[[:space:]]*task_id:/ {
    line=$0; gsub(/^[[:space:]]*task_id:[[:space:]]*/, "", line)
    task_id=line; next
}
END {
    if (topic != "" && state != "") {
        print topic "|" desc "|" state "|" task_id
    }
}
'
}

# Helper: Extract completed_tasks from implementation tracking file
# Returns space-separated list of task IDs
extract_completed_tasks() {
    local file="$1"
    local frontmatter
    frontmatter=$(extract_frontmatter "$file")

    # Check for empty array
    if echo "$frontmatter" | grep -q "^completed_tasks:[[:space:]]*\[\]" 2>/dev/null; then
        return 0
    fi

    echo "$frontmatter" | awk '
/^completed_tasks:/ { in_block=1; next }
in_block && /^[a-z_]+:/ { exit }
in_block && /^[[:space:]]*-[[:space:]]/ {
    gsub(/^[[:space:]]*-[[:space:]]*/, "")
    gsub(/"/, "")
    print
}
'
}

# Helper: Extract completed_phases from implementation tracking file
# Returns space-separated list of phase numbers
extract_completed_phases() {
    local file="$1"
    local frontmatter
    frontmatter=$(extract_frontmatter "$file")

    # Check for inline array format: [1, 2, 3]
    local inline
    inline=$(echo "$frontmatter" | grep "^completed_phases:" | sed 's/^completed_phases:[[:space:]]*//' || true)
    if echo "$inline" | grep -q '^\['; then
        echo "$inline" | tr -d '[]' | tr ',' '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | grep -v '^$'
        return 0
    fi

    # Check for empty array
    if echo "$frontmatter" | grep -q "^completed_phases:[[:space:]]*\[\]" 2>/dev/null; then
        return 0
    fi

    echo "$frontmatter" | awk '
/^completed_phases:/ { in_block=1; next }
in_block && /^[a-z_]+:/ { exit }
in_block && /^[[:space:]]*-[[:space:]]/ {
    gsub(/^[[:space:]]*-[[:space:]]*/, "")
    print
}
'
}


# Start YAML output
echo "# Implementation Command State Discovery"
echo "# Generated: $(date -Iseconds)"
echo ""

#
# PLANS
#
echo "plans:"

plan_count=0
plans_concluded_count=0
plans_with_unresolved_deps=0

# Arrays to store plan data for cross-referencing
declare -a plan_names=()
declare -a plan_statuses=()

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

        # Track plan data
        plan_names+=("$name")
        plan_statuses+=("$status")

        if [ "$status" = "concluded" ]; then
            plans_concluded_count=$((plans_concluded_count + 1))
        fi

        # Check if linked specification exists
        spec_exists="false"
        spec_file="$SPEC_DIR/$specification"
        if [ -f "$spec_file" ]; then
            spec_exists="true"
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

        #
        # External dependencies from frontmatter
        #
        deps_output=$(extract_external_deps "$file")
        has_unresolved="false"
        unresolved_count=0
        dep_count=0

        echo "      external_deps:"
        if [ -z "$deps_output" ]; then
            echo "        []"
        else
            while IFS='|' read -r dep_topic dep_desc dep_state dep_task_id; do
                [ -z "$dep_topic" ] && continue
                dep_count=$((dep_count + 1))
                echo "        - topic: \"$dep_topic\""
                echo "          state: \"$dep_state\""
                if [ -n "$dep_task_id" ]; then
                    echo "          task_id: \"$dep_task_id\""
                fi
                if [ "$dep_state" = "unresolved" ]; then
                    has_unresolved="true"
                    unresolved_count=$((unresolved_count + 1))
                fi
            done <<< "$deps_output"
        fi
        echo "      has_unresolved_deps: $has_unresolved"
        echo "      unresolved_dep_count: $unresolved_count"

        if [ "$has_unresolved" = "true" ]; then
            plans_with_unresolved_deps=$((plans_with_unresolved_deps + 1))
        fi

        plan_count=$((plan_count + 1))
    done

    echo "  count: $plan_count"
else
    echo "  exists: false"
    echo "  files: []"
    echo "  count: 0"
fi

echo ""

#
# IMPLEMENTATION TRACKING
#
echo "implementation:"

impl_count=0
plans_in_progress_count=0
plans_completed_count=0

if [ -d "$IMPL_DIR" ] && [ -n "$(ls -A "$IMPL_DIR" 2>/dev/null)" ]; then
    echo "  exists: true"
    echo "  files:"

    for file in "$IMPL_DIR"/*/tracking.md; do
        [ -f "$file" ] || continue

        impl_name=$(basename "$(dirname "$file")")
        impl_status=$(extract_field "$file" "status")
        impl_status=${impl_status:-"unknown"}
        current_phase=$(extract_field "$file" "current_phase")
        current_task=$(extract_field "$file" "current_task")

        echo "    - topic: \"$impl_name\""
        echo "      status: \"$impl_status\""

        if [ -n "$current_phase" ] && [ "$current_phase" != "~" ]; then
            echo "      current_phase: $current_phase"
        fi

        # Completed phases
        completed_phases_list=$(extract_completed_phases "$file")
        if [ -n "$completed_phases_list" ]; then
            phases_inline=$(echo "$completed_phases_list" | tr '\n' ',' | sed 's/,$//' | sed 's/,/, /g')
            echo "      completed_phases: [$phases_inline]"
        else
            echo "      completed_phases: []"
        fi

        # Completed tasks
        completed_tasks_list=$(extract_completed_tasks "$file")
        if [ -n "$completed_tasks_list" ]; then
            echo "      completed_tasks:"
            while IFS= read -r task_id; do
                [ -z "$task_id" ] && continue
                echo "        - \"$task_id\""
            done <<< "$completed_tasks_list"
        else
            echo "      completed_tasks: []"
        fi

        # Track counts
        if [ "$impl_status" = "in-progress" ]; then
            plans_in_progress_count=$((plans_in_progress_count + 1))
        elif [ "$impl_status" = "completed" ]; then
            plans_completed_count=$((plans_completed_count + 1))
        fi

        impl_count=$((impl_count + 1))
    done
else
    echo "  exists: false"
    echo "  files: []"
fi

echo ""

#
# DEPENDENCY RESOLUTION (cross-reference resolved deps against tracking files)
#
# For each plan with resolved deps, check if the referenced tasks are actually completed
# by reading the dependency topic's tracking file
#
echo "dependency_resolution:"

if [ "$plan_count" -gt 0 ] && [ -d "$PLAN_DIR" ]; then
    has_resolution_data=false

    for file in "$PLAN_DIR"/*/plan.md; do
        [ -f "$file" ] || continue

        name=$(basename "$(dirname "$file")")
        deps_output=$(extract_external_deps "$file")
        [ -z "$deps_output" ] && continue

        all_satisfied=true
        has_resolved_deps=false
        blocking_entries=""

        while IFS='|' read -r dep_topic dep_desc dep_state dep_task_id; do
            [ -z "$dep_topic" ] && continue

            if [ "$dep_state" = "resolved" ] && [ -n "$dep_task_id" ]; then
                has_resolved_deps=true
                # Check if the dependency topic has a tracking file
                tracking_file="$IMPL_DIR/${dep_topic}/tracking.md"
                task_completed=false

                if [ -f "$tracking_file" ]; then
                    # Check if task_id is in completed_tasks
                    completed=$(extract_completed_tasks "$tracking_file")
                    if echo "$completed" | grep -qx "$dep_task_id" 2>/dev/null; then
                        task_completed=true
                    fi
                fi

                if ! $task_completed; then
                    all_satisfied=false
                    blocking_entries="${blocking_entries}      - topic: \"$dep_topic\"\n        task_id: \"$dep_task_id\"\n        reason: \"task not yet completed\"\n"
                fi
            elif [ "$dep_state" = "unresolved" ]; then
                has_resolved_deps=true
                all_satisfied=false
                blocking_entries="${blocking_entries}      - topic: \"$dep_topic\"\n        reason: \"dependency unresolved\"\n"
            fi
            # satisfied_externally deps don't block
        done <<< "$deps_output"

        if $has_resolved_deps || [ -n "$blocking_entries" ]; then
            if ! $has_resolution_data; then
                has_resolution_data=true
            fi
            echo "  - plan: \"$name\""
            echo "    deps_satisfied: $all_satisfied"
            if [ -n "$blocking_entries" ]; then
                echo "    deps_blocking:"
                echo -e "$blocking_entries" | sed '/^$/d'
            fi
        fi
    done

    if ! $has_resolution_data; then
        echo "  []"
    fi
else
    echo "  []"
fi

echo ""

#
# ENVIRONMENT
#
echo "environment:"

if [ -f "$ENVIRONMENT_FILE" ]; then
    echo "  setup_file_exists: true"
    echo "  setup_file: \"$ENVIRONMENT_FILE\""

    # Check if it says "no special setup required" (case insensitive)
    if grep -qi "no special setup required" "$ENVIRONMENT_FILE" 2>/dev/null; then
        echo "  requires_setup: false"
    else
        echo "  requires_setup: true"
    fi
else
    echo "  setup_file_exists: false"
    echo "  setup_file: \"$ENVIRONMENT_FILE\""
    echo "  requires_setup: unknown"
fi

echo ""

#
# WORKFLOW STATE SUMMARY
#
echo "state:"

echo "  has_plans: $([ "$plan_count" -gt 0 ] && echo "true" || echo "false")"
echo "  plan_count: $plan_count"
echo "  plans_concluded_count: $plans_concluded_count"
echo "  plans_with_unresolved_deps: $plans_with_unresolved_deps"

# Plans ready = concluded + all deps satisfied (no unresolved, all resolved tasks completed)
plans_ready_count=0
if [ "$plan_count" -gt 0 ] && [ -d "$PLAN_DIR" ]; then
    for file in "$PLAN_DIR"/*/plan.md; do
        [ -f "$file" ] || continue
        name=$(basename "$(dirname "$file")")
        status=$(extract_field "$file" "status")

        if [ "$status" = "concluded" ]; then
            deps_output=$(extract_external_deps "$file")
            is_ready=true

            if [ -n "$deps_output" ]; then
                while IFS='|' read -r dep_topic dep_desc dep_state dep_task_id; do
                    [ -z "$dep_topic" ] && continue

                    if [ "$dep_state" = "unresolved" ]; then
                        is_ready=false
                        break
                    elif [ "$dep_state" = "resolved" ] && [ -n "$dep_task_id" ]; then
                        tracking_file="$IMPL_DIR/${dep_topic}/tracking.md"
                        if [ -f "$tracking_file" ]; then
                            completed=$(extract_completed_tasks "$tracking_file")
                            if ! echo "$completed" | grep -qx "$dep_task_id" 2>/dev/null; then
                                is_ready=false
                                break
                            fi
                        else
                            is_ready=false
                            break
                        fi
                    fi
                done <<< "$deps_output"
            fi

            if $is_ready; then
                plans_ready_count=$((plans_ready_count + 1))
            fi
        fi
    done
fi

echo "  plans_ready_count: $plans_ready_count"
echo "  plans_in_progress_count: $plans_in_progress_count"
echo "  plans_completed_count: $plans_completed_count"

# Determine workflow state for routing
if [ "$plan_count" -eq 0 ]; then
    echo "  scenario: \"no_plans\""
elif [ "$plan_count" -eq 1 ]; then
    echo "  scenario: \"single_plan\""
else
    echo "  scenario: \"multiple_plans\""
fi
