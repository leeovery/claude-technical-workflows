#!/bin/bash
#
# Discovers the full workflow state across all phases
# for the /status command.
#
# Outputs structured YAML that the command can consume directly.
#

set -eo pipefail

RESEARCH_DIR="docs/workflow/research"
DISCUSSION_DIR="docs/workflow/discussion"
SPEC_DIR="docs/workflow/specification"
PLAN_DIR="docs/workflow/planning"
IMPL_DIR="docs/workflow/implementation"

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

# Helper: Extract frontmatter content (between first pair of --- delimiters)
extract_frontmatter() {
    local file="$1"
    awk 'BEGIN{c=0} /^---$/{c++; if(c==2) exit; next} c==1{print}' "$file" 2>/dev/null
}

# Helper: Extract sources from specification frontmatter
# Outputs: name|status per line (object format only; legacy converted by migration 004)
extract_sources() {
    local file="$1"
    local in_sources=false
    local current_name=""
    local current_status=""

    while IFS= read -r line; do
        if [[ "$line" =~ ^sources: ]]; then
            in_sources=true
            continue
        fi

        if $in_sources && [[ "$line" =~ ^[a-z_]+: ]] && [[ ! "$line" =~ ^[[:space:]] ]]; then
            if [ -n "$current_name" ]; then
                echo "${current_name}|${current_status:-incorporated}"
            fi
            break
        fi

        if $in_sources; then
            if [[ "$line" =~ ^[[:space:]]*-[[:space:]]*name:[[:space:]]*(.+)$ ]]; then
                if [ -n "$current_name" ]; then
                    echo "${current_name}|${current_status:-incorporated}"
                fi
                current_name="${BASH_REMATCH[1]}"
                current_name=$(echo "$current_name" | sed 's/^"//' | sed 's/"$//' | xargs)
                current_status=""
            elif [[ "$line" =~ ^[[:space:]]*status:[[:space:]]*(.+)$ ]]; then
                current_status="${BASH_REMATCH[1]}"
                current_status=$(echo "$current_status" | sed 's/^"//' | sed 's/"$//' | xargs)
            fi
        fi
    done < <(extract_frontmatter "$file")

    if [ -n "$current_name" ]; then
        echo "${current_name}|${current_status:-incorporated}"
    fi
}

# Helper: Extract external_dependencies from plan frontmatter
# Outputs: topic|state|task_id per line
extract_external_deps() {
    local file="$1"
    local frontmatter
    frontmatter=$(extract_frontmatter "$file")

    if ! echo "$frontmatter" | grep -q "^external_dependencies:" 2>/dev/null; then
        return 0
    fi

    if echo "$frontmatter" | grep -q "^external_dependencies:[[:space:]]*\[\]" 2>/dev/null; then
        return 0
    fi

    echo "$frontmatter" | awk '
/^external_dependencies:/ { in_block=1; next }
in_block && /^[a-z_]+:/ && !/^[[:space:]]/ { exit }
in_block && /^[[:space:]]*- topic:/ {
    if (topic != "") print topic "|" state "|" task_id
    line=$0; gsub(/^[[:space:]]*- topic:[[:space:]]*/, "", line)
    topic=line; state=""; task_id=""
    next
}
in_block && /^[[:space:]]*state:/ {
    line=$0; gsub(/^[[:space:]]*state:[[:space:]]*/, "", line)
    state=line; next
}
in_block && /^[[:space:]]*task_id:/ {
    line=$0; gsub(/^[[:space:]]*task_id:[[:space:]]*/, "", line)
    task_id=line; next
}
END { if (topic != "") print topic "|" state "|" task_id }
'
}

# Helper: Count completed tasks from implementation tracking
count_completed_tasks() {
    local file="$1"
    local frontmatter
    frontmatter=$(extract_frontmatter "$file")

    if echo "$frontmatter" | grep -q "^completed_tasks:[[:space:]]*\[\]" 2>/dev/null; then
        echo 0
        return
    fi

    local count
    count=$(echo "$frontmatter" | awk '
/^completed_tasks:/ { in_block=1; next }
in_block && /^[a-z_]+:/ { exit }
in_block && /^[[:space:]]*-[[:space:]]/ { c++ }
END { print c+0 }
')
    echo "$count"
}

# Helper: Count completed phases from implementation tracking
count_completed_phases() {
    local file="$1"
    local frontmatter
    frontmatter=$(extract_frontmatter "$file")

    # Handle inline array format: [1, 2, 3]
    local inline
    inline=$(echo "$frontmatter" | grep "^completed_phases:" | sed 's/^completed_phases:[[:space:]]*//' || true)
    if echo "$inline" | grep -q '^\['; then
        local items
        items=$(echo "$inline" | tr -d '[]' | tr ',' '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | grep -v '^$')
        if [ -n "$items" ]; then
            echo "$items" | wc -l | tr -d ' '
        else
            echo 0
        fi
        return
    fi

    if echo "$frontmatter" | grep -q "^completed_phases:[[:space:]]*\[\]" 2>/dev/null; then
        echo 0
        return
    fi

    local count
    count=$(echo "$frontmatter" | awk '
/^completed_phases:/ { in_block=1; next }
in_block && /^[a-z_]+:/ { exit }
in_block && /^[[:space:]]*-[[:space:]]/ { c++ }
END { print c+0 }
')
    echo "$count"
}


# Start YAML output
echo "# Workflow Status Discovery"
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
# DISCUSSIONS
#
echo "discussions:"

disc_count=0
disc_concluded=0
disc_in_progress=0

if [ -d "$DISCUSSION_DIR" ] && [ -n "$(ls -A "$DISCUSSION_DIR" 2>/dev/null)" ]; then
    echo "  exists: true"
    echo "  files:"
    for file in "$DISCUSSION_DIR"/*.md; do
        [ -f "$file" ] || continue
        name=$(basename "$file" .md)
        status=$(extract_field "$file" "status")
        status=${status:-"unknown"}

        echo "    - name: \"$name\""
        echo "      status: \"$status\""

        disc_count=$((disc_count + 1))
        [ "$status" = "concluded" ] && disc_concluded=$((disc_concluded + 1))
        [ "$status" = "in-progress" ] && disc_in_progress=$((disc_in_progress + 1))
    done
    echo "  count: $disc_count"
    echo "  concluded: $disc_concluded"
    echo "  in_progress: $disc_in_progress"
else
    echo "  exists: false"
    echo "  files: []"
    echo "  count: 0"
    echo "  concluded: 0"
    echo "  in_progress: 0"
fi

echo ""

#
# SPECIFICATIONS
#
echo "specifications:"

spec_count=0
spec_active=0
spec_superseded=0
spec_feature=0
spec_crosscutting=0

if [ -d "$SPEC_DIR" ] && [ -n "$(ls -A "$SPEC_DIR" 2>/dev/null)" ]; then
    echo "  exists: true"
    echo "  files:"
    for file in "$SPEC_DIR"/*.md; do
        [ -f "$file" ] || continue
        name=$(basename "$file" .md)
        status=$(extract_field "$file" "status")
        status=${status:-"in-progress"}
        spec_type=$(extract_field "$file" "type")
        spec_type=${spec_type:-"feature"}
        superseded_by=$(extract_field "$file" "superseded_by")

        echo "    - name: \"$name\""
        echo "      status: \"$status\""
        echo "      type: \"$spec_type\""
        [ -n "$superseded_by" ] && echo "      superseded_by: \"$superseded_by\""

        # Sources
        sources_output=$(extract_sources "$file")
        if [ -n "$sources_output" ]; then
            echo "      sources:"
            while IFS='|' read -r src_name src_status; do
                [ -z "$src_name" ] && continue
                echo "        - name: \"$src_name\""
                echo "          status: \"$src_status\""
            done <<< "$sources_output"
        else
            echo "      sources: []"
        fi

        spec_count=$((spec_count + 1))
        if [ "$status" = "superseded" ]; then
            spec_superseded=$((spec_superseded + 1))
        else
            spec_active=$((spec_active + 1))
            [ "$spec_type" = "cross-cutting" ] && spec_crosscutting=$((spec_crosscutting + 1))
            [ "$spec_type" != "cross-cutting" ] && spec_feature=$((spec_feature + 1))
        fi
    done
    echo "  count: $spec_count"
    echo "  active: $spec_active"
    echo "  superseded: $spec_superseded"
    echo "  feature: $spec_feature"
    echo "  crosscutting: $spec_crosscutting"
else
    echo "  exists: false"
    echo "  files: []"
    echo "  count: 0"
    echo "  active: 0"
    echo "  superseded: 0"
    echo "  feature: 0"
    echo "  crosscutting: 0"
fi

echo ""

#
# PLANS
#
echo "plans:"

plan_count=0
plan_concluded=0
plan_in_progress=0

if [ -d "$PLAN_DIR" ] && [ -n "$(ls -A "$PLAN_DIR" 2>/dev/null)" ]; then
    echo "  exists: true"
    echo "  files:"
    for file in "$PLAN_DIR"/*.md; do
        [ -f "$file" ] || continue
        name=$(basename "$file" .md)
        status=$(extract_field "$file" "status")
        status=${status:-"unknown"}
        format=$(extract_field "$file" "format")
        format=${format:-"unknown"}
        specification=$(extract_field "$file" "specification")
        specification=${specification:-"${name}.md"}

        echo "    - name: \"$name\""
        echo "      status: \"$status\""
        echo "      format: \"$format\""
        echo "      specification: \"$specification\""

        # External dependencies
        deps_output=$(extract_external_deps "$file")
        has_unresolved="false"
        if [ -n "$deps_output" ]; then
            echo "      external_deps:"
            while IFS='|' read -r dep_topic dep_state dep_task_id; do
                [ -z "$dep_topic" ] && continue
                echo "        - topic: \"$dep_topic\""
                echo "          state: \"$dep_state\""
                [ -n "$dep_task_id" ] && echo "          task_id: \"$dep_task_id\""
                [ "$dep_state" = "unresolved" ] && has_unresolved="true"
            done <<< "$deps_output"
        else
            echo "      external_deps: []"
        fi
        echo "      has_unresolved_deps: $has_unresolved"

        plan_count=$((plan_count + 1))
        [ "$status" = "concluded" ] && plan_concluded=$((plan_concluded + 1))
        { [ "$status" = "planning" ] || [ "$status" = "in-progress" ]; } && plan_in_progress=$((plan_in_progress + 1))
    done
    echo "  count: $plan_count"
    echo "  concluded: $plan_concluded"
    echo "  in_progress: $plan_in_progress"
else
    echo "  exists: false"
    echo "  files: []"
    echo "  count: 0"
    echo "  concluded: 0"
    echo "  in_progress: 0"
fi

echo ""

#
# IMPLEMENTATION
#
echo "implementation:"

impl_count=0
impl_completed=0
impl_in_progress=0

if [ -d "$IMPL_DIR" ] && [ -n "$(ls -A "$IMPL_DIR" 2>/dev/null)" ]; then
    echo "  exists: true"
    echo "  files:"
    for file in "$IMPL_DIR"/*/tracking.md; do
        [ -f "$file" ] || continue
        topic=$(basename "$(dirname "$file")")
        status=$(extract_field "$file" "status")
        status=${status:-"unknown"}
        current_phase=$(extract_field "$file" "current_phase")

        completed_tasks=$(count_completed_tasks "$file")
        completed_phases=$(count_completed_phases "$file")

        # Count total tasks from plan directory (local-markdown format)
        total_tasks=0
        plan_file="$PLAN_DIR/${topic}.md"
        if [ -f "$plan_file" ]; then
            plan_format=$(extract_field "$plan_file" "format")
            if [ "$plan_format" = "local-markdown" ] && [ -d "$PLAN_DIR/${topic}" ]; then
                total_tasks=$(ls -1 "$PLAN_DIR/${topic}/"*.md 2>/dev/null | wc -l | tr -d ' ')
            fi
        fi

        echo "    - topic: \"$topic\""
        echo "      status: \"$status\""
        [ -n "$current_phase" ] && [ "$current_phase" != "~" ] && echo "      current_phase: $current_phase"
        echo "      completed_tasks: $completed_tasks"
        echo "      completed_phases: $completed_phases"
        echo "      total_tasks: $total_tasks"

        impl_count=$((impl_count + 1))
        [ "$status" = "completed" ] && impl_completed=$((impl_completed + 1))
        [ "$status" = "in-progress" ] && impl_in_progress=$((impl_in_progress + 1))
    done
    echo "  count: $impl_count"
    echo "  completed: $impl_completed"
    echo "  in_progress: $impl_in_progress"
else
    echo "  exists: false"
    echo "  files: []"
    echo "  count: 0"
    echo "  completed: 0"
    echo "  in_progress: 0"
fi
