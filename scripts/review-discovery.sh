#!/bin/bash
#
# review-discovery.sh
#
# Discovers the current state of plans and specifications
# for the /start-review command.
#
# Outputs structured YAML that the command can consume directly.
#

set -eo pipefail

PLAN_DIR="docs/workflow/planning"
SPEC_DIR="docs/workflow/specification"

# Helper: Extract a frontmatter field value from a file
# Usage: extract_field <file> <field_name>
extract_field() {
    local file="$1"
    local field="$2"
    sed -n '/^---$/,/^---$/p' "$file" 2>/dev/null | \
        grep -m1 "^${field}:" | \
        sed "s/^${field}:[[:space:]]*//" || true
}

# Start YAML output
echo "# Review Command State Discovery"
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

        # Check if a specification exists for this plan
        has_spec="false"
        if [ -f "$SPEC_DIR/${name}.md" ]; then
            has_spec="true"
        fi

        echo "  - name: \"$name\""
        echo "    format: \"$format\""
        echo "    has_specification: $has_spec"
    done
else
    echo "  []  # No plans found"
fi

echo ""

#
# SPECIFICATIONS (for cross-reference)
#
echo "specifications:"

if [ -d "$SPEC_DIR" ] && [ -n "$(ls -A "$SPEC_DIR" 2>/dev/null)" ]; then
    for file in "$SPEC_DIR"/*.md; do
        [ -f "$file" ] || continue

        name=$(basename "$file" .md)
        status=$(extract_field "$file" "status")
        status=${status:-"unknown"}

        spec_type=$(extract_field "$file" "type")
        spec_type=${spec_type:-"feature"}

        echo "  - name: \"$name\""
        echo "    status: \"$status\""
        echo "    type: \"$spec_type\""
    done
else
    echo "  []  # No specifications found"
fi

echo ""

#
# GIT STATUS (for implementation scope)
#
echo "git_status:"

# Check if we're in a git repository
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "  is_repo: true"

    # Get list of changed files (both staged and unstaged)
    changed_files=$(git diff --name-only HEAD 2>/dev/null || git diff --name-only 2>/dev/null || true)
    staged_files=$(git diff --cached --name-only 2>/dev/null || true)

    # Combine and deduplicate
    all_changed=$(echo -e "${changed_files}\n${staged_files}" | sort -u | grep -v "^$" || true)

    if [ -n "$all_changed" ]; then
        echo "  has_changes: true"
        echo "  changed_files:"
        while IFS= read -r file; do
            [ -n "$file" ] && echo "    - \"$file\""
        done <<< "$all_changed"

        # Count by directory (top-level grouping)
        echo "  changed_directories:"
        echo "$all_changed" | cut -d'/' -f1 | sort | uniq -c | while read count dir; do
            echo "    - directory: \"$dir\""
            echo "      count: $count"
        done
    else
        echo "  has_changes: false"
        echo "  changed_files: []"
        echo "  changed_directories: []"
    fi
else
    echo "  is_repo: false"
    echo "  has_changes: null"
    echo "  changed_files: []"
    echo "  changed_directories: []"
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

# Count plans with specifications
plans_with_specs=0
if [ -d "$PLAN_DIR" ] && [ -n "$(ls -A "$PLAN_DIR" 2>/dev/null)" ]; then
    for file in "$PLAN_DIR"/*.md; do
        [ -f "$file" ] || continue
        name=$(basename "$file" .md)
        if [ -f "$SPEC_DIR/${name}.md" ]; then
            plans_with_specs=$((plans_with_specs + 1))
        fi
    done
fi
echo "  plans_with_specifications: $plans_with_specs"
