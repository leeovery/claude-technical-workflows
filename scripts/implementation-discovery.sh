#!/bin/bash
#
# implementation-discovery.sh
#
# Discovers the current state of plans and environment setup
# for the /start-implementation command.
#
# Outputs structured YAML that the command can consume directly.
#

set -eo pipefail

PLAN_DIR="docs/workflow/planning"
ENV_SETUP_FILE="docs/workflow/environment-setup.md"

# Helper: Extract a frontmatter field value from a file
# Usage: extract_field <file> <field_name>
extract_field() {
    local file="$1"
    local field="$2"
    sed -n '/^---$/,/^---$/p' "$file" 2>/dev/null | \
        grep -m1 "^${field}:" | \
        sed "s/^${field}:[[:space:]]*//" || true
}

# Helper: Extract External Dependencies section from a plan
# Returns dependency lines (- topic: description format)
extract_dependencies() {
    local file="$1"
    # Find External Dependencies section and extract list items
    sed -n '/^## External Dependencies/,/^##/{/^## External Dependencies/d; /^##/d; /^[[:space:]]*$/d; p}' "$file" 2>/dev/null | \
        grep "^-" || true
}

# Start YAML output
echo "# Implementation Command State Discovery"
echo "# Generated: $(date -Iseconds)"
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

        # Extract and categorize dependencies
        deps=$(extract_dependencies "$file")

        unresolved_count=0
        resolved_count=0
        satisfied_count=0

        if [ -n "$deps" ]; then
            echo "    dependencies:"

            while IFS= read -r dep; do
                # Parse dependency line
                # Formats:
                # - topic: description (unresolved)
                # - topic: description → task-id (resolved)
                # - ~~topic: description~~ → satisfied externally

                if echo "$dep" | grep -q "~~.*~~.*satisfied externally"; then
                    satisfied_count=$((satisfied_count + 1))
                    topic=$(echo "$dep" | sed 's/^-[[:space:]]*~~//' | sed 's/:.*$//')
                    echo "      - topic: \"$topic\""
                    echo "        state: \"satisfied_externally\""
                elif echo "$dep" | grep -q "→"; then
                    resolved_count=$((resolved_count + 1))
                    topic=$(echo "$dep" | sed 's/^-[[:space:]]*//' | sed 's/:.*$//')
                    task_id=$(echo "$dep" | sed 's/.*→[[:space:]]*//')
                    echo "      - topic: \"$topic\""
                    echo "        state: \"resolved\""
                    echo "        task_id: \"$task_id\""
                else
                    unresolved_count=$((unresolved_count + 1))
                    topic=$(echo "$dep" | sed 's/^-[[:space:]]*//' | sed 's/:.*$//')
                    desc=$(echo "$dep" | sed 's/^-[[:space:]]*[^:]*:[[:space:]]*//')
                    echo "      - topic: \"$topic\""
                    echo "        state: \"unresolved\""
                    echo "        description: \"$desc\""
                fi
            done <<< "$deps"
        else
            echo "    dependencies: []"
        fi

        echo "    dependency_summary:"
        echo "      unresolved: $unresolved_count"
        echo "      resolved: $resolved_count"
        echo "      satisfied: $satisfied_count"
    done
else
    echo "  []  # No plans found"
fi

echo ""

#
# ENVIRONMENT SETUP
#
echo "environment:"

if [ -f "$ENV_SETUP_FILE" ]; then
    echo "  setup_exists: true"
    echo "  setup_file: \"$ENV_SETUP_FILE\""

    # Check if it's just "No special setup required"
    content=$(cat "$ENV_SETUP_FILE" 2>/dev/null | grep -v "^---" | grep -v "^#" | tr -d '[:space:]')
    if [ "$content" = "Nospecialsetuprequired." ] || [ "$content" = "Nospecialsetuprequired" ]; then
        echo "  has_setup_steps: false"
    else
        echo "  has_setup_steps: true"
    fi
else
    echo "  setup_exists: false"
    echo "  setup_file: null"
    echo "  has_setup_steps: null"
fi

echo ""

#
# SUMMARY
#
echo "summary:"

# Count plans
plan_count=0
if [ -d "$PLAN_DIR" ]; then
    plan_count=$(find "$PLAN_DIR" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
fi
echo "  plan_count: $plan_count"

# Count plans with unresolved dependencies
plans_with_unresolved=0
plans_ready=0

if [ -d "$PLAN_DIR" ] && [ -n "$(ls -A "$PLAN_DIR" 2>/dev/null)" ]; then
    for file in "$PLAN_DIR"/*.md; do
        [ -f "$file" ] || continue

        deps=$(extract_dependencies "$file")
        has_unresolved=false

        if [ -n "$deps" ]; then
            while IFS= read -r dep; do
                # Check for unresolved (no → and no ~~)
                if ! echo "$dep" | grep -q "→" && ! echo "$dep" | grep -q "~~"; then
                    has_unresolved=true
                    break
                fi
            done <<< "$deps"
        fi

        if [ "$has_unresolved" = true ]; then
            plans_with_unresolved=$((plans_with_unresolved + 1))
        else
            plans_ready=$((plans_ready + 1))
        fi
    done
fi

echo "  plans_ready: $plans_ready"
echo "  plans_with_unresolved_deps: $plans_with_unresolved"
