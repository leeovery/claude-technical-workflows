#!/bin/bash
#
# Discovers the current state of discussions, specifications, and cache
# for the /start-specification command.
#
# Uses the manifest CLI for work unit state. Scans discussion files
# within work unit directories for source-level detail.
#
# Outputs structured YAML that the command can consume directly.
#

set -eo pipefail

MANIFEST="node .claude/skills/workflow-manifest/scripts/manifest.js"
WORKFLOWS_DIR=".workflows"
CACHE_DIR_SUFFIX=".state/discussion-consolidation-analysis.md"

# Start YAML output
echo "# Specification Command State Discovery"
echo "# Generated: $(date -Iseconds)"
echo ""

# Get all active work units into a temp file for reuse
tmp_units=$(mktemp)
trap 'rm -f "$tmp_units"' EXIT

$MANIFEST list --status active 2>/dev/null > "$tmp_units" || echo "[]" > "$tmp_units"

work_unit_count=$(node -e "console.log(JSON.parse(require('fs').readFileSync('$tmp_units','utf8')).length)" 2>/dev/null || echo "0")

# Parse work units into name/type pairs
tmp_pairs=$(mktemp)
trap 'rm -f "$tmp_units" "$tmp_pairs"' EXIT

if [ "$work_unit_count" -gt 0 ]; then
    node -e "
        const units = JSON.parse(require('fs').readFileSync('$tmp_units', 'utf8'));
        for (const u of units) {
            console.log(u.name + ' ' + u.work_type);
        }
    " 2>/dev/null > "$tmp_pairs"
fi

#
# DISCUSSIONS
#
echo "discussions:"

discussion_found=false

while IFS=' ' read -r wu_name wu_type; do
    [ -z "$wu_name" ] && continue
    disc_dir="$WORKFLOWS_DIR/$wu_name/discussion"
    [ -d "$disc_dir" ] || continue

    if [ "$wu_type" = "epic" ]; then
        # Epic: multiple discussion files
        for file in "$disc_dir"/*.md; do
            [ -f "$file" ] || continue
            name=$(basename "$file" .md)
            status=$($MANIFEST get "$wu_name" --raw phases.discussion.items."$name".status 2>/dev/null || echo "")
            status=${status:-"unknown"}

            # Check if this discussion is tracked as a spec source via manifest
            has_individual_spec="false"
            spec_status=""
            spec_phase_status=$($MANIFEST get "$wu_name" --raw phases.specification.status 2>/dev/null || echo "")
            if [ -n "$spec_phase_status" ] && [ "$spec_phase_status" != "undefined" ]; then
                # Check if there's a sources entry for this discussion
                source_check=$($MANIFEST get "$wu_name" --raw phases.specification.sources."$name".status 2>/dev/null || echo "")
                if [ -n "$source_check" ] && [ "$source_check" != "undefined" ]; then
                    has_individual_spec="true"
                    spec_status="$spec_phase_status"
                fi
            fi

            echo "  - name: \"$name\""
            echo "    work_unit: \"$wu_name\""
            echo "    status: \"$status\""
            echo "    work_type: \"$wu_type\""
            echo "    has_individual_spec: $has_individual_spec"
            if [ "$has_individual_spec" = "true" ]; then
                echo "    spec_status: \"$spec_status\""
            fi
            discussion_found=true
        done
    else
        # Feature/bugfix: single discussion file (topic = work_unit name)
        file="$disc_dir/${wu_name}.md"
        [ -f "$file" ] || continue
        status=$($MANIFEST get "$wu_name" --raw phases.discussion.status 2>/dev/null || echo "")
        status=${status:-"unknown"}

        # Check specification status via manifest
        has_individual_spec="false"
        spec_status=""
        spec_phase_status=$($MANIFEST get "$wu_name" --raw phases.specification.status 2>/dev/null || echo "")
        if [ -n "$spec_phase_status" ] && [ "$spec_phase_status" != "undefined" ]; then
            has_individual_spec="true"
            spec_status="$spec_phase_status"
        fi

        echo "  - name: \"$wu_name\""
        echo "    work_unit: \"$wu_name\""
        echo "    status: \"$status\""
        echo "    work_type: \"$wu_type\""
        echo "    has_individual_spec: $has_individual_spec"
        if [ "$has_individual_spec" = "true" ]; then
            echo "    spec_status: \"$spec_status\""
        fi
        discussion_found=true
    fi
done < "$tmp_pairs"

if [ "$discussion_found" = false ]; then
    echo "  []  # No discussions found"
fi

echo ""

#
# SPECIFICATIONS
#
echo "specifications:"

spec_found=false

while IFS=' ' read -r wu_name wu_type; do
    [ -z "$wu_name" ] && continue
    spec_file="$WORKFLOWS_DIR/$wu_name/specification/${wu_name}/specification.md"
    [ -f "$spec_file" ] || continue

    spec_status=$($MANIFEST get "$wu_name" --raw phases.specification.status 2>/dev/null || echo "")
    spec_status=${spec_status:-"in-progress"}

    # Check for superseded_by in manifest
    superseded_by=$($MANIFEST get "$wu_name" --raw phases.specification.superseded_by 2>/dev/null || echo "")

    echo "  - name: \"$wu_name\""
    echo "    work_unit: \"$wu_name\""
    echo "    status: \"$spec_status\""
    echo "    work_type: \"$wu_type\""

    if [ -n "$superseded_by" ]; then
        echo "    superseded_by: \"$superseded_by\""
    fi

    # Extract sources from manifest with discussion_status lookup
    sources_json=$($MANIFEST get "$wu_name" --raw phases.specification.sources 2>/dev/null || echo "")
    if [ -n "$sources_json" ] && [ "$sources_json" != "undefined" ]; then
        echo "    sources:"
        # Emit each source with its discussion_status
        node -e "
            const sources = JSON.parse(require('fs').readFileSync('/dev/stdin', 'utf8'));
            for (const [name] of Object.entries(sources)) { console.log(name); }
        " <<< "$sources_json" 2>/dev/null | while IFS= read -r src_name; do
            src_status=$(node -e "
                const sources = JSON.parse('$(echo "$sources_json" | sed "s/'/\\\\'/g")');
                const info = sources['$src_name'];
                console.log(typeof info === 'object' ? (info.status || 'incorporated') : 'incorporated');
            " 2>/dev/null || echo "incorporated")

            echo "      - name: \"$src_name\""
            echo "        status: \"$src_status\""

            # Look up discussion status from manifest
            if [ "$wu_type" = "epic" ]; then
                disc_status=$($MANIFEST get "$wu_name" --raw phases.discussion.items."$src_name".status 2>/dev/null || echo "")
            else
                disc_status=$($MANIFEST get "$wu_name" --raw phases.discussion.status 2>/dev/null || echo "")
            fi
            echo "        discussion_status: \"${disc_status:-unknown}\""
        done
    fi

    spec_found=true
done < "$tmp_pairs"

if [ "$spec_found" = false ]; then
    echo "  []  # No specifications found"
fi

echo ""

#
# CACHE STATE
#
# status: "valid" | "stale" | "none"
#   - valid: cache exists and checksums match
#   - stale: cache exists but discussions have changed
#   - none: no cache file exists
#
echo "cache:"

cache_found=false

while IFS=' ' read -r wu_name wu_type; do
    [ -z "$wu_name" ] && continue
    cache_file="$WORKFLOWS_DIR/$wu_name/$CACHE_DIR_SUFFIX"
    [ -f "$cache_file" ] || continue

    if ! $cache_found; then
        cache_found=true
        echo "  entries:"
    fi

    # Read cache metadata from frontmatter (this is a scratch file the skill creates)
    cached_checksum=$(awk 'BEGIN{c=0} /^---$/{c++; if(c==2) exit; next} c==1 && /^checksum:/{sub(/^checksum:[[:space:]]*/,""); print}' "$cache_file")
    cached_date=$(awk 'BEGIN{c=0} /^---$/{c++; if(c==2) exit; next} c==1 && /^generated:/{sub(/^generated:[[:space:]]*/,""); print}' "$cache_file")

    # Compute current checksum across discussion files in this work unit
    disc_dir="$WORKFLOWS_DIR/$wu_name/discussion"
    disc_files=$(find "$disc_dir" -name "*.md" 2>/dev/null | sort || true)

    cache_status="stale"
    cache_reason="discussions have changed since cache was generated"

    if [ -n "$disc_files" ]; then
        current_checksum=$(echo "$disc_files" | xargs cat 2>/dev/null | md5sum | cut -d' ' -f1)
        if [ "$cached_checksum" = "$current_checksum" ]; then
            cache_status="valid"
            cache_reason="checksums match"
        fi
    else
        cache_reason="no discussions to compare"
    fi

    echo "    - work_unit: \"$wu_name\""
    echo "      status: \"$cache_status\""
    echo "      reason: \"$cache_reason\""
    echo "      checksum: \"${cached_checksum:-unknown}\""
    echo "      generated: \"${cached_date:-unknown}\""

    # Extract anchored names (groupings that have existing specs)
    anchored_found=false
    while IFS= read -r grouping_name; do
        clean_name=$(echo "$grouping_name" | sed 's/[[:space:]]*(.*)//' | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
        if [ -d "$WORKFLOWS_DIR/$clean_name/specification" ] && ls "$WORKFLOWS_DIR/$clean_name/specification"/*/specification.md >/dev/null 2>&1; then
            if ! $anchored_found; then
                echo "      anchored_names:"
                anchored_found=true
            fi
            echo "        - \"$clean_name\""
        fi
    done < <(grep "^### " "$cache_file" 2>/dev/null | sed 's/^### //' || true)

    if ! $anchored_found; then
        echo "      anchored_names: []"
    fi
done < "$tmp_pairs"

if ! $cache_found; then
    echo "  status: \"none\""
    echo "  reason: \"no cache exists\""
    echo "  entries: []"
fi

echo ""

#
# CURRENT STATE
#
echo "current_state:"

# Gather all discussion files across work units
all_disc_files=$(find "$WORKFLOWS_DIR" -path "*/.archive" -prune -o -path "*/discussion/*.md" -print 2>/dev/null | sort)

if [ -n "$all_disc_files" ]; then
    current_checksum=$(echo "$all_disc_files" | xargs cat 2>/dev/null | md5sum | cut -d' ' -f1)
    echo "  discussions_checksum: \"$current_checksum\""

    # Count discussions and specs by status from manifest
    node -e "
        const units = JSON.parse(require('fs').readFileSync('$tmp_units', 'utf8'));
        let discCount = 0, concluded = 0, inProgress = 0, specCount = 0;
        for (const u of units) {
            const dp = u.phases && u.phases.discussion;
            if (dp) {
                if (u.work_type === 'epic') {
                    const items = dp.items || {};
                    for (const [, item] of Object.entries(items)) {
                        discCount++;
                        if (item.status === 'concluded') concluded++;
                        else if (item.status === 'in-progress') inProgress++;
                    }
                    if (Object.keys(items).length === 0 && dp.status) {
                        discCount++;
                        if (dp.status === 'concluded') concluded++;
                        else if (dp.status === 'in-progress') inProgress++;
                    }
                } else if (dp.status) {
                    discCount++;
                    if (dp.status === 'concluded') concluded++;
                    else if (dp.status === 'in-progress') inProgress++;
                }
            }
            const sp = u.phases && u.phases.specification;
            if (sp && sp.status && sp.status !== 'superseded') {
                specCount++;
            }
        }
        console.log('  discussion_count: ' + discCount);
        console.log('  concluded_count: ' + concluded);
        console.log('  in_progress_count: ' + inProgress);
        console.log('  spec_count: ' + specCount);
        console.log('  has_discussions: ' + (discCount > 0));
        console.log('  has_concluded: ' + (concluded > 0));
        console.log('  has_specs: ' + (specCount > 0));
    " 2>/dev/null
else
    echo "  discussions_checksum: null"
    echo "  discussion_count: 0"
    echo "  concluded_count: 0"
    echo "  in_progress_count: 0"
    echo "  spec_count: 0"
    echo "  has_discussions: false"
    echo "  has_concluded: false"
    echo "  has_specs: false"
fi
