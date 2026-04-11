'use strict';

const { describe, it } = require('node:test');
const assert = require('node:assert');

const { chunk } = require('../../src/knowledge/chunker.js');

// Default config — mirrors the shared phase defaults. Tests override fields
// as needed to target a specific behaviour. keep_whole_below is set low
// except in tests that specifically exercise the whole-file gate.
function baseConfig(overrides = {}) {
  return {
    phase: 'test',
    confidence: 'low',
    strategy: 'split-on-heading',
    primary_level: 2,
    fallback_level: 3,
    max_lines: 200,
    keep_whole_below: 0, // disable whole-file gate by default
    special_sections: {},
    strip_frontmatter: true,
    skip_empty_sections: true,
    ...overrides,
  };
}

describe('knowledge chunker', () => {
  it('splits markdown on H2 headings', () => {
    const md = [
      '# Title',
      '',
      'intro paragraph under the title',
      '',
      '## Section A',
      'body a',
      '',
      '## Section B',
      'body b',
      '',
      '## Section C',
      'body c',
      '',
    ].join('\n');
    const result = chunk(md, baseConfig());
    // H1-with-intro chunk + 3 H2 chunks.
    assert.strictEqual(result.length, 4);
    assert.match(result[0].content, /# Title/);
    assert.match(result[0].content, /intro paragraph/);
    assert.match(result[1].content, /## Section A/);
    assert.match(result[2].content, /## Section B/);
    assert.match(result[3].content, /## Section C/);
  });

  it('returns { content } objects, not bare strings', () => {
    const md = '## A\nbody a\n\n## B\nbody b';
    const result = chunk(md, baseConfig());
    for (const c of result) {
      assert.strictEqual(typeof c, 'object');
      assert.strictEqual(typeof c.content, 'string');
      assert.strictEqual(
        Object.prototype.hasOwnProperty.call(c, 'content'),
        true
      );
    }
  });

  it('includes heading text in each chunk content (semantic anchor)', () => {
    const md = '## Alpha\napple\n\n## Beta\nbanana';
    const result = chunk(md, baseConfig());
    assert.match(result[0].content, /## Alpha/);
    assert.match(result[0].content, /apple/);
    assert.match(result[1].content, /## Beta/);
    assert.match(result[1].content, /banana/);
  });

  it('splits oversized H2 sections once at H3 and does not recurse further', () => {
    const big = [];
    big.push('## Big');
    big.push('intro line');
    big.push('');
    for (let i = 0; i < 3; i += 1) {
      big.push('### Sub ' + i);
      // Add many body lines so the parent H2 exceeds max_lines (set small
      // below). Each sub-section is intentionally large to prove no recursion.
      for (let j = 0; j < 15; j += 1) big.push('line ' + j);
      big.push('');
    }
    const md = big.join('\n');
    const result = chunk(md, baseConfig({ max_lines: 20, fallback_level: 3 }));
    // Expect 3 H3 sub-chunks plus possibly a leading H2 header chunk (which
    // here is empty because "intro line" falls under the H2 heading itself).
    // At minimum: one chunk per H3.
    const h3Chunks = result.filter((c) => /^### Sub/.test(c.content.trimStart()));
    assert.strictEqual(h3Chunks.length, 3);
    // Prove no further recursion: each sub-chunk retains its full body
    // (14 "line N" entries) despite still exceeding a hypothetical inner
    // max_lines cap.
    for (const c of h3Chunks) {
      assert.match(c.content, /line 0/);
      assert.match(c.content, /line 14/);
    }
  });

  it('keeps oversized H3 sections as-is (flat fallback chain)', () => {
    const lines = ['## Parent'];
    lines.push('### Sub');
    for (let j = 0; j < 50; j += 1) lines.push('body ' + j);
    const md = lines.join('\n');
    const result = chunk(md, baseConfig({ max_lines: 10 }));
    // Sub-chunks are kept as-is. Body should still be intact.
    const all = result.map((c) => c.content).join('\n');
    assert.match(all, /body 0/);
    assert.match(all, /body 49/);
  });

  it('falls back to H3 when no H2 headings exist', () => {
    const md = [
      '# Title',
      '',
      '### Sub A',
      'body a',
      '',
      '### Sub B',
      'body b',
    ].join('\n');
    const result = chunk(md, baseConfig());
    // Two H3 sections (the H1 + pre-first-H3 content may also form a chunk
    // with just the title — depends on content presence).
    const h3 = result.filter((c) => /^### Sub/.test(c.content.trimStart()));
    assert.strictEqual(h3.length, 2);
  });

  it('returns whole file when no headings at any configured level', () => {
    const md = 'just some text\n\nwith paragraphs\n\nand nothing else\n';
    // Use enough lines to bypass keep_whole_below = 0 by default, but this
    // hits the missing-headings fallback anyway.
    const result = chunk(md, baseConfig());
    assert.strictEqual(result.length, 1);
    assert.match(result[0].content, /just some text/);
    assert.match(result[0].content, /and nothing else/);
  });

  it('returns whole file when content is below keep_whole_below, bypassing heading parsing', () => {
    // This markdown has H2 headings that would normally split, but the
    // whole-file gate fires first and returns a single chunk.
    const md = [
      '## A',
      'body a',
      '## B',
      'body b',
    ].join('\n');
    const result = chunk(md, baseConfig({ keep_whole_below: 50 }));
    assert.strictEqual(result.length, 1);
    assert.match(result[0].content, /## A/);
    assert.match(result[0].content, /## B/);
  });

  it('strips YAML frontmatter', () => {
    const md = [
      '---',
      'title: something',
      'tag: foo',
      '---',
      '',
      '## Section',
      'body',
    ].join('\n');
    const result = chunk(md, baseConfig());
    for (const c of result) {
      assert.doesNotMatch(c.content, /title: something/);
      assert.doesNotMatch(c.content, /tag: foo/);
    }
    assert.strictEqual(result.length, 1);
  });

  it('skips empty sections', () => {
    const md = [
      '## Empty',
      '',
      '## With Body',
      'real content',
    ].join('\n');
    const result = chunk(md, baseConfig());
    assert.strictEqual(result.length, 1);
    assert.match(result[0].content, /## With Body/);
  });

  it('handles own-chunk special sections', () => {
    const md = [
      '## Regular',
      'regular body',
      '',
      '## Discussion Map',
      'map body',
      '',
      '## Another',
      'another body',
    ].join('\n');
    const result = chunk(
      md,
      baseConfig({ special_sections: { 'Discussion Map': 'own-chunk' } })
    );
    assert.strictEqual(result.length, 3);
    const mapChunk = result.find((c) => /## Discussion Map/.test(c.content));
    assert.ok(mapChunk);
    assert.match(mapChunk.content, /map body/);
  });

  it('handles skip special sections', () => {
    const md = [
      '## Keep',
      'keep body',
      '',
      '## Drop',
      'drop body',
      '',
      '## AlsoKeep',
      'also keep body',
    ].join('\n');
    const result = chunk(
      md,
      baseConfig({ special_sections: { Drop: 'skip' } })
    );
    assert.strictEqual(result.length, 2);
    for (const c of result) {
      assert.doesNotMatch(c.content, /drop body/);
      assert.doesNotMatch(c.content, /## Drop/);
    }
  });

  it('handles merge-up special sections', () => {
    const md = [
      '## Parent',
      'parent body',
      '',
      '## Footnote',
      'footnote body',
      '',
      '## Next',
      'next body',
    ].join('\n');
    const result = chunk(
      md,
      baseConfig({ special_sections: { Footnote: 'merge-up' } })
    );
    assert.strictEqual(result.length, 2);
    const parent = result[0];
    assert.match(parent.content, /## Parent/);
    assert.match(parent.content, /parent body/);
    assert.match(parent.content, /## Footnote/);
    assert.match(parent.content, /footnote body/);
    // No standalone Footnote chunk.
    assert.strictEqual(
      result.filter((c) => /^## Footnote/.test(c.content.trimStart())).length,
      0
    );
  });

  it('handles merge-up on the first section (promotes to its own chunk)', () => {
    const md = [
      '## Footnote',
      'footnote body',
      '',
      '## Parent',
      'parent body',
    ].join('\n');
    const result = chunk(
      md,
      baseConfig({ special_sections: { Footnote: 'merge-up' } })
    );
    assert.strictEqual(result.length, 2);
    assert.match(result[0].content, /## Footnote/);
    assert.match(result[0].content, /footnote body/);
    assert.match(result[1].content, /## Parent/);
  });

  it('treats H1 + pre-H2 content as the first chunk', () => {
    const md = [
      '# Document Title',
      '',
      'Intro paragraph describing the doc.',
      '',
      '## Section',
      'section body',
    ].join('\n');
    const result = chunk(md, baseConfig());
    assert.strictEqual(result.length, 2);
    assert.match(result[0].content, /# Document Title/);
    assert.match(result[0].content, /Intro paragraph/);
    assert.match(result[1].content, /## Section/);
  });

  it('ignores headings inside fenced code blocks (markdown parsing correctness)', () => {
    const md = [
      '## Real Section',
      '',
      '```',
      '## Not A Heading',
      '### Also Not',
      '```',
      '',
      'body text',
      '',
      '## Another Real Section',
      'more body',
    ].join('\n');
    const result = chunk(md, baseConfig());
    assert.strictEqual(result.length, 2);
    // The fake headings should be inside the first chunk as fenced content.
    assert.match(result[0].content, /## Not A Heading/);
    assert.match(result[0].content, /body text/);
    assert.match(result[1].content, /## Another Real Section/);
  });

  it('handles file with only frontmatter and no content (empty result)', () => {
    const md = ['---', 'title: empty', '---', ''].join('\n');
    const result = chunk(md, baseConfig());
    assert.deepStrictEqual(result, []);
  });

  it('handles markdown with no headings at all (missing-headings fallback)', () => {
    // Above keep_whole_below to prove we take the fallback path.
    const lines = [];
    for (let i = 0; i < 60; i += 1) lines.push('paragraph line ' + i);
    const md = lines.join('\n');
    const result = chunk(md, baseConfig({ keep_whole_below: 50 }));
    assert.strictEqual(result.length, 1);
    assert.match(result[0].content, /paragraph line 0/);
    assert.match(result[0].content, /paragraph line 59/);
  });

  it('only strips the opening frontmatter block, not later --- horizontal rules', () => {
    const md = [
      '---',
      'title: foo',
      '---',
      '',
      '## Section',
      'body',
      '',
      '---',
      '',
      'more body',
    ].join('\n');
    const result = chunk(md, baseConfig());
    const all = result.map((c) => c.content).join('\n');
    assert.doesNotMatch(all, /title: foo/);
    assert.match(all, /---/); // horizontal rule preserved
    assert.match(all, /more body/);
  });

  it('handles very large files correctly', () => {
    const lines = [];
    for (let s = 0; s < 10; s += 1) {
      lines.push('## Section ' + s);
      for (let j = 0; j < 100; j += 1) lines.push('body ' + s + '-' + j);
      lines.push('');
    }
    const md = lines.join('\n');
    // max_lines=200 — each section is ~101 lines, below the cap, so no
    // fallback. Expect 10 chunks.
    const result = chunk(md, baseConfig());
    assert.strictEqual(result.length, 10);
  });
});

describe('phase chunking configs', () => {
  const path = require('path');
  const fs = require('fs');

  const chunkingDir = path.resolve(
    __dirname,
    '..',
    '..',
    'skills',
    'workflow-knowledge',
    'chunking'
  );

  const phases = ['research', 'discussion', 'investigation', 'specification'];

  for (const phase of phases) {
    it('has a valid ' + phase + '.json config with required fields', () => {
      const file = path.join(chunkingDir, phase + '.json');
      assert.strictEqual(fs.existsSync(file), true, file + ' must exist');
      const cfg = JSON.parse(fs.readFileSync(file, 'utf8'));
      assert.strictEqual(cfg.phase, phase);
      assert.strictEqual(cfg.strategy, 'split-on-heading');
      assert.strictEqual(cfg.primary_level, 2);
      assert.strictEqual(cfg.fallback_level, 3);
      assert.strictEqual(cfg.max_lines, 200);
      assert.strictEqual(cfg.keep_whole_below, 50);
      assert.strictEqual(cfg.strip_frontmatter, true);
      assert.strictEqual(cfg.skip_empty_sections, true);
      assert.strictEqual(typeof cfg.special_sections, 'object');
      assert.strictEqual(typeof cfg.confidence, 'string');
    });
  }

  it('discussion.json declares Discussion Map and Summary as own-chunk', () => {
    const cfg = JSON.parse(
      fs.readFileSync(path.join(chunkingDir, 'discussion.json'), 'utf8')
    );
    assert.strictEqual(cfg.special_sections['Discussion Map'], 'own-chunk');
    assert.strictEqual(cfg.special_sections['Summary'], 'own-chunk');
  });

  it('non-discussion configs have empty special_sections', () => {
    for (const phase of ['research', 'investigation', 'specification']) {
      const cfg = JSON.parse(
        fs.readFileSync(path.join(chunkingDir, phase + '.json'), 'utf8')
      );
      assert.deepStrictEqual(cfg.special_sections, {});
    }
  });
});
