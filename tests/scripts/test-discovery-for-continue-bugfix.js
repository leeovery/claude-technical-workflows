'use strict';

const { describe, it, beforeEach, afterEach } = require('node:test');
const assert = require('node:assert');
const { setupFixture, cleanupFixture, createManifest } = require('./discovery-test-utils');
const { discover } = require('../../skills/continue-bugfix/scripts/discovery');

describe('continue-bugfix discovery', () => {
  let dir;
  beforeEach(() => { dir = setupFixture(); });
  afterEach(() => { cleanupFixture(dir); });

  describe('list mode', () => {
    it('returns empty when no bugfixes exist', () => {
      const r = discover(dir);
      assert.strictEqual(r.mode, 'list');
      assert.strictEqual(r.count, 0);
    });

    it('lists active bugfixes only', () => {
      createManifest(dir, 'crash', { work_type: 'bugfix', phases: { investigation: { status: 'in-progress' } } });
      createManifest(dir, 'old', { work_type: 'bugfix', status: 'archived' });
      const r = discover(dir);
      assert.strictEqual(r.count, 1);
      assert.strictEqual(r.bugfixes[0].name, 'crash');
    });

    it('excludes non-bugfix work types', () => {
      createManifest(dir, 'crash', { work_type: 'bugfix', phases: { investigation: { status: 'in-progress' } } });
      createManifest(dir, 'auth', { work_type: 'feature' });
      const r = discover(dir);
      assert.strictEqual(r.count, 1);
    });

    it('excludes done bugfixes', () => {
      createManifest(dir, 'done', {
        work_type: 'bugfix',
        phases: {
          investigation: { status: 'concluded' },
          specification: { status: 'concluded' },
          planning: { status: 'concluded' },
          implementation: { status: 'completed' },
          review: { status: 'completed' },
        },
      });
      const r = discover(dir);
      assert.strictEqual(r.count, 0);
    });

    it('includes concluded_phases', () => {
      createManifest(dir, 'crash', {
        work_type: 'bugfix',
        phases: {
          investigation: { status: 'concluded' },
          specification: { status: 'in-progress' },
        },
      });
      const r = discover(dir);
      assert.deepStrictEqual(r.bugfixes[0].concluded_phases, ['investigation']);
    });
  });

  describe('single mode', () => {
    it('returns error for missing work unit', () => {
      const r = discover(dir, 'nonexistent');
      assert.strictEqual(r.error, 'not_found');
    });

    it('returns error for wrong type', () => {
      createManifest(dir, 'auth', { work_type: 'feature' });
      const r = discover(dir, 'auth');
      assert.strictEqual(r.error, 'wrong_type');
    });

    it('returns error for done bugfix', () => {
      createManifest(dir, 'done', {
        work_type: 'bugfix',
        phases: {
          investigation: { status: 'concluded' },
          specification: { status: 'concluded' },
          planning: { status: 'concluded' },
          implementation: { status: 'completed' },
          review: { status: 'completed' },
        },
      });
      const r = discover(dir, 'done');
      assert.strictEqual(r.error, 'done');
    });

    it('returns single bugfix data', () => {
      createManifest(dir, 'crash', {
        work_type: 'bugfix',
        phases: {
          investigation: { status: 'concluded' },
          specification: { status: 'in-progress' },
        },
      });
      const r = discover(dir, 'crash');
      assert.strictEqual(r.mode, 'single');
      assert.strictEqual(r.bugfix.name, 'crash');
      assert.strictEqual(r.bugfix.next_phase, 'specification');
      assert.deepStrictEqual(r.bugfix.concluded_phases, ['investigation']);
    });
  });

  describe('edge cases', () => {
    it('recognizes completed as concluded in concluded_phases', () => {
      createManifest(dir, 'crash', {
        work_type: 'bugfix',
        phases: {
          investigation: { status: 'concluded' },
          specification: { status: 'concluded' },
          planning: { status: 'concluded' },
          implementation: { status: 'completed' },
          review: { status: 'in-progress' },
        },
      });
      const r = discover(dir);
      assert.ok(r.bugfixes[0].concluded_phases.includes('implementation'));
    });

    it('bugfix in review in-progress is listed (not filtered as done)', () => {
      createManifest(dir, 'crash', {
        work_type: 'bugfix',
        phases: {
          investigation: { status: 'concluded' },
          specification: { status: 'concluded' },
          planning: { status: 'concluded' },
          implementation: { status: 'completed' },
          review: { status: 'in-progress' },
        },
      });
      const r = discover(dir);
      assert.strictEqual(r.count, 1);
      assert.strictEqual(r.bugfixes[0].next_phase, 'review');
    });

    it('research is not in bugfix concluded_phases even if present', () => {
      createManifest(dir, 'crash', {
        work_type: 'bugfix',
        phases: {
          research: { status: 'concluded' },
          investigation: { status: 'in-progress' },
        },
      });
      const r = discover(dir);
      // research is not in BUGFIX_PIPELINE, so never in concluded_phases
      assert.ok(!r.bugfixes[0].concluded_phases.includes('research'));
    });
  });
});
