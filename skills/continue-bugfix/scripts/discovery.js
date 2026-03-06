'use strict';

const { loadActiveManifests, phaseStatus, computeNextPhase } = require('../../workflow-shared/scripts/discovery-utils');

const BUGFIX_PIPELINE = ['investigation', 'specification', 'planning', 'implementation', 'review'];

function concludedPhases(manifest) {
  const concluded = [];
  for (const phase of BUGFIX_PIPELINE) {
    const s = phaseStatus(manifest, phase);
    if (s === 'concluded' || s === 'completed') {
      concluded.push(phase);
    }
  }
  return concluded;
}

function discover(cwd, workUnit) {
  if (workUnit) {
    const { loadManifest } = require('../../workflow-shared/scripts/discovery-utils');
    const manifest = loadManifest(cwd, workUnit);
    if (!manifest) return { error: 'not_found', work_unit: workUnit };
    if (manifest.work_type !== 'bugfix') return { error: 'wrong_type', work_unit: workUnit, work_type: manifest.work_type };

    const state = computeNextPhase(manifest);
    if (state.next_phase === 'done') return { error: 'done', work_unit: workUnit };

    return {
      mode: 'single',
      bugfix: {
        name: workUnit,
        next_phase: state.next_phase,
        phase_label: state.phase_label,
        concluded_phases: concludedPhases(manifest),
      },
    };
  }

  const manifests = loadActiveManifests(cwd);
  const bugfixes = [];

  for (const m of manifests) {
    if (m.work_type !== 'bugfix') continue;
    const state = computeNextPhase(m);
    if (state.next_phase === 'done') continue;
    bugfixes.push({
      name: m.name,
      next_phase: state.next_phase,
      phase_label: state.phase_label,
      concluded_phases: concludedPhases(m),
    });
  }

  return {
    mode: 'list',
    bugfixes,
    count: bugfixes.length,
  };
}

function format(result) {
  if (result.error) return `Error: ${result.error} (${result.work_unit})\n`;

  const lines = [];

  if (result.mode === 'single') {
    const b = result.bugfix;
    lines.push(`=== BUGFIX: ${b.name} ===`);
    lines.push(`next_phase: ${b.next_phase}`);
    lines.push(`phase_label: ${b.phase_label}`);
    lines.push(`concluded_phases: ${b.concluded_phases.join(', ') || '(none)'}`);
  } else {
    lines.push(`=== BUGFIXES (${result.count}) ===`);
    for (const b of result.bugfixes) {
      lines.push(`  ${b.name}: ${b.phase_label} [concluded: ${b.concluded_phases.join(', ') || 'none'}]`);
    }
  }

  return lines.join('\n') + '\n';
}

if (require.main === module) {
  const workUnit = process.argv[2] || null;
  process.stdout.write(format(discover(process.cwd(), workUnit)));
}

module.exports = { discover };
