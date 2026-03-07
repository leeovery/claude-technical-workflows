'use strict';

const { loadActiveManifests, phaseStatus, computeNextPhase } = require('../../workflow-shared/scripts/discovery-utils');

const FEATURE_PIPELINE = ['research', 'discussion', 'specification', 'planning', 'implementation', 'review'];

function concludedPhases(manifest) {
  const concluded = [];
  for (const phase of FEATURE_PIPELINE) {
    const s = phaseStatus(manifest, phase);
    if (s === 'concluded' || s === 'completed') {
      concluded.push(phase);
    }
  }
  return concluded;
}

function discover(cwd) {
  const manifests = loadActiveManifests(cwd);
  const features = [];

  for (const m of manifests) {
    if (m.work_type !== 'feature') continue;
    const state = computeNextPhase(m);
    if (state.next_phase === 'done') continue;
    features.push({
      name: m.name,
      next_phase: state.next_phase,
      phase_label: state.phase_label,
      concluded_phases: concludedPhases(m),
    });
  }

  return {
    features,
    count: features.length,
    summary: features.length === 0
      ? 'no active features'
      : `${features.length} active feature(s)`,
  };
}

function format(result) {
  const lines = [];
  lines.push(`=== FEATURES (${result.count}) ===`);
  lines.push(`summary: ${result.summary}`);
  for (const f of result.features) {
    lines.push(`  ${f.name}: ${f.phase_label} [concluded: ${f.concluded_phases.join(', ') || 'none'}]`);
  }
  return lines.join('\n') + '\n';
}

if (require.main === module) {
  process.stdout.write(format(discover(process.cwd())));
}

module.exports = { discover };
