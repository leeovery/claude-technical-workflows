'use strict';

// Generic markdown chunking engine for the knowledge base.
//
// Pure function — no external dependencies. Given a markdown string and a
// phase config, returns an array of { content } objects. Each `content`
// includes the heading line so it travels with its body as a semantic
// anchor (see knowledge-base/design.md finding #9).
//
// The algorithm is the same for every phase — only the config parameters
// change. See the `chunk()` function for the execution order; the order
// matters and resolves ambiguity between `keep_whole_below` (whole-file
// gate) and `special_sections` (split-time behaviour).

const FENCE_RE = /^\s*(```+|~~~+)/;
const FRONTMATTER_DELIM = /^---\s*$/;

/**
 * Chunk a markdown string according to the given config.
 *
 * @param {string} markdown
 * @param {object} config
 * @returns {Array<{ content: string }>}
 */
function chunk(markdown, config) {
  if (typeof markdown !== 'string') {
    throw new TypeError('chunk: markdown must be a string');
  }
  if (!config || typeof config !== 'object') {
    throw new TypeError('chunk: config must be an object');
  }

  const {
    primary_level: primaryLevel = 2,
    fallback_level: fallbackLevel = 3,
    max_lines: maxLines = 200,
    keep_whole_below: keepWholeBelow = 50,
    special_sections: specialSections = {},
    strip_frontmatter: stripFrontmatter = true,
    skip_empty_sections: skipEmptySections = true,
  } = config;

  // 1. Strip YAML frontmatter if configured.
  const body = stripFrontmatter ? stripOpeningFrontmatter(markdown) : markdown;

  // Empty body after frontmatter stripping — no chunks.
  if (body.trim() === '') {
    return [];
  }

  const lines = body.split('\n');

  // 2. Whole-file gate: below keep_whole_below lines returns whole file as a
  //    single chunk. Do NOT proceed to heading parsing or special_sections.
  if (lines.length < keepWholeBelow) {
    return [{ content: body.replace(/\s+$/, '') }];
  }

  // 3. Parse into headings, tracking fenced code blocks so headings inside
  //    them do not trigger splits.
  const headings = parseHeadings(lines);

  if (headings.length === 0) {
    return [{ content: body.replace(/\s+$/, '') }];
  }

  // Fallback chain for missing headings: primary -> fallback -> whole file.
  const hasPrimary = headings.some((h) => h.level === primaryLevel);
  const hasFallback = headings.some((h) => h.level === fallbackLevel);

  let splitLevel;
  if (hasPrimary) {
    splitLevel = primaryLevel;
  } else if (hasFallback) {
    splitLevel = fallbackLevel;
  } else {
    return [{ content: body.replace(/\s+$/, '') }];
  }

  // 4. Build sections at splitLevel. Content before the first splitLevel
  //    heading (typically an H1 title + intro) becomes the first chunk,
  //    with the H1 line serving as its heading.
  const sections = buildSections(lines, headings, splitLevel);

  // 5. Apply special_sections, 6. size fallback, 7. skip empty.
  const chunks = [];
  for (let i = 0; i < sections.length; i += 1) {
    const section = sections[i];
    const trimmedHeading = section.heading ? section.heading.trim() : '';
    const specialAction = specialSections[trimmedHeading];

    if (specialAction === 'skip') {
      continue;
    }

    if (specialAction === 'merge-up') {
      if (chunks.length === 0) {
        // First-section merge-up: promote to its own chunk.
        if (skipEmptySections && isEmptySection(section)) continue;
        chunks.push({ content: section.text });
      } else {
        const prev = chunks[chunks.length - 1];
        prev.content = prev.content + '\n\n' + section.text;
      }
      continue;
    }

    if (specialAction === 'own-chunk') {
      // Always its own chunk. No size fallback for special sections.
      if (skipEmptySections && isEmptySection(section)) continue;
      chunks.push({ content: section.text });
      continue;
    }

    // Regular section.
    if (skipEmptySections && isEmptySection(section)) continue;

    const sectionLines = section.text.split('\n');
    if (sectionLines.length > maxLines) {
      // Split once at fallback_level. No recursion.
      const subs = splitAtLevel(section, fallbackLevel);
      for (const sub of subs) {
        if (skipEmptySections && isEmptySection(sub)) continue;
        chunks.push({ content: sub.text });
      }
    } else {
      chunks.push({ content: section.text });
    }
  }

  return chunks;
}

// ---------------------------------------------------------------------------
// Internal helpers
// ---------------------------------------------------------------------------

/**
 * Strip only the opening YAML frontmatter block. A `---` on its own line at
 * the start of the file opens the block; the next `---` closes it. If there
 * is no opening frontmatter, the markdown is returned unchanged so a
 * horizontal-rule `---` later in the file is preserved.
 */
function stripOpeningFrontmatter(markdown) {
  const lines = markdown.split('\n');
  if (lines.length === 0 || !FRONTMATTER_DELIM.test(lines[0] || '')) {
    return markdown;
  }
  for (let i = 1; i < lines.length; i += 1) {
    if (FRONTMATTER_DELIM.test(lines[i])) {
      return lines.slice(i + 1).join('\n').replace(/^\n+/, '');
    }
  }
  // Unclosed frontmatter — treat whole file as frontmatter (empty body).
  return '';
}

/**
 * Parse markdown lines into a list of heading descriptors, tracking fenced
 * code blocks so headings inside them are ignored. Returns an array of
 * { level, text, line } entries in document order.
 */
function parseHeadings(lines) {
  const headings = [];
  let inFence = false;
  let fenceMarker = '';

  for (let i = 0; i < lines.length; i += 1) {
    const line = lines[i];
    const fenceMatch = FENCE_RE.exec(line);
    if (fenceMatch) {
      const marker = fenceMatch[1][0]; // ` or ~
      if (!inFence) {
        inFence = true;
        fenceMarker = marker;
      } else if (marker === fenceMarker) {
        inFence = false;
        fenceMarker = '';
      }
      continue;
    }
    if (inFence) continue;

    const headingMatch = /^(#{1,6})\s+(.*)$/.exec(line);
    if (headingMatch) {
      headings.push({
        level: headingMatch[1].length,
        text: headingMatch[2].trim(),
        line: i,
      });
    }
  }

  return headings;
}

/**
 * Build a flat list of sections split at `splitLevel`. Content before the
 * first splitLevel heading — including an H1 and any intro text — becomes
 * the first section, with the H1 line used as its heading text if present.
 */
function buildSections(lines, headings, splitLevel) {
  const splitIndices = headings
    .filter((h) => h.level === splitLevel)
    .map((h) => h.line);

  const sections = [];

  // Leading pre-split content (H1 + intro).
  const firstSplitLine =
    splitIndices.length > 0 ? splitIndices[0] : lines.length;
  if (firstSplitLine > 0) {
    const preLines = lines.slice(0, firstSplitLine);
    const h1 = headings.find((h) => h.level === 1 && h.line < firstSplitLine);
    const text = preLines.join('\n').replace(/\s+$/, '');
    if (text.trim() !== '') {
      sections.push({
        heading: h1 ? h1.text : '',
        headingLine: h1 ? lines[h1.line] : '',
        text,
      });
    }
  }

  for (let i = 0; i < splitIndices.length; i += 1) {
    const start = splitIndices[i];
    const end = i + 1 < splitIndices.length ? splitIndices[i + 1] : lines.length;
    const sliceLines = lines.slice(start, end);
    const headingText = /^#+\s+(.*)$/.exec(lines[start])[1].trim();
    sections.push({
      heading: headingText,
      headingLine: lines[start],
      text: sliceLines.join('\n').replace(/\s+$/, ''),
    });
  }

  return sections;
}

/**
 * Split an oversized section once at `fallbackLevel`. The original section's
 * heading and any content before the first fallbackLevel heading form the
 * first sub-section. No recursion — oversized sub-sections are returned as
 * they are and reported by `knowledge status` (Phase 4).
 */
function splitAtLevel(section, fallbackLevel) {
  const lines = section.text.split('\n');
  const headings = parseHeadings(lines);
  const subIndices = headings
    .filter((h) => h.level === fallbackLevel)
    .map((h) => h.line);

  if (subIndices.length === 0) {
    // Nothing to split at this level — keep as-is.
    return [section];
  }

  const subs = [];

  // Leading content: the original heading + any content before the first
  // fallbackLevel heading.
  const firstSub = subIndices[0];
  if (firstSub > 0) {
    const preLines = lines.slice(0, firstSub);
    const text = preLines.join('\n').replace(/\s+$/, '');
    if (text.trim() !== '') {
      subs.push({
        heading: section.heading,
        headingLine: section.headingLine,
        text,
      });
    }
  }

  for (let i = 0; i < subIndices.length; i += 1) {
    const start = subIndices[i];
    const end = i + 1 < subIndices.length ? subIndices[i + 1] : lines.length;
    const sliceLines = lines.slice(start, end);
    const headingText = /^#+\s+(.*)$/.exec(lines[start])[1].trim();
    subs.push({
      heading: headingText,
      headingLine: lines[start],
      text: sliceLines.join('\n').replace(/\s+$/, ''),
    });
  }

  return subs;
}

/**
 * A section is empty if, after removing its heading line, the remaining
 * text has no non-whitespace characters.
 */
function isEmptySection(section) {
  if (!section || typeof section.text !== 'string') return true;
  const lines = section.text.split('\n');
  const bodyStart =
    section.headingLine && lines[0] === section.headingLine ? 1 : 0;
  const body = lines.slice(bodyStart).join('\n');
  return body.trim() === '';
}

module.exports = { chunk };
