#!/usr/bin/env node
/**
 * Validate agent markdown files have required frontmatter.
 *
 * Handles all YAML value styles used in agent files:
 *   - Plain scalars:        key: value
 *   - Folded multi-line:    key: >\n  line1\n  line2
 *   - Literal multi-line:   key: |\n  line1\n  line2
 *   - Block sequences:      key:\n  - item1\n  - item2
 *   - Inline JSON arrays:   key: ["item1", "item2"]
 */

'use strict';

const fs = require('fs');
const path = require('path');

const AGENTS_DIR = path.join(__dirname, '../../agents');
const REQUIRED_FIELDS = ['tools']; // model is optional — agents without it inherit the parent session's model

// Accept both generic aliases and specific Claude model IDs.
const VALID_MODEL_ALIASES = new Set(['haiku', 'sonnet', 'opus']);
const VALID_MODEL_ID_PREFIXES = [
  'claude-haiku-',
  'claude-sonnet-',
  'claude-opus-',
];

// ---------------------------------------------------------------------------
// Minimal YAML frontmatter parser
// ---------------------------------------------------------------------------

/**
 * Parse the YAML block between the opening and closing `---` delimiters.
 * Returns a plain object where list values are stored as string arrays and
 * scalar/folded values are stored as strings.
 *
 * @param {string} content - Full file content
 * @returns {Record<string, string|string[]>|null}
 */
function extractFrontmatter(content) {
  // Strip UTF-8 BOM if present.
  const cleaned = content.replace(/^﻿/, '');

  // Match the opening --- ... closing --- block, tolerating CRLF.
  const match = cleaned.match(/^---\r?\n([\s\S]*?)\r?\n---/);
  if (!match) return null;

  const lines = match[1].split(/\r?\n/);
  const result = {};
  let i = 0;

  while (i < lines.length) {
    const line = lines[i];

    // Skip blank lines and lines that are continuations of a previous value
    // (they are consumed in-place below when we detect them).
    if (!line.trim() || /^\s/.test(line)) {
      i += 1;
      continue;
    }

    const colonIdx = line.indexOf(':');
    if (colonIdx <= 0) {
      i += 1;
      continue;
    }

    const key = line.slice(0, colonIdx).trim();
    const rest = line.slice(colonIdx + 1).trim();

    // ── Folded / literal multi-line scalar  (key: >  or  key: |) ──────────
    if (rest === '>' || rest === '>-' || rest === '|' || rest === '|-') {
      const parts = [];
      i += 1;
      while (i < lines.length && /^\s+/.test(lines[i])) {
        parts.push(lines[i].trim());
        i += 1;
      }
      result[key] = parts.join(' ');
      continue;
    }

    // ── Block sequence  (key:\n  - item1\n  - item2) ─────────────────────
    if (rest === '') {
      const items = [];
      let j = i + 1;
      while (j < lines.length && /^\s+-\s+/.test(lines[j])) {
        items.push(lines[j].replace(/^\s+-\s+/, '').trim());
        j += 1;
      }
      if (items.length > 0) {
        result[key] = items;
        i = j;
        continue;
      }
      // Empty value with no following list — store as empty string.
      result[key] = '';
      i += 1;
      continue;
    }

    // ── Inline JSON array  (key: ["item1", "item2"]) ─────────────────────
    if (rest.startsWith('[')) {
      try {
        result[key] = JSON.parse(rest);
      } catch {
        // Malformed inline array — store raw for later error reporting.
        result[key] = rest;
      }
      i += 1;
      continue;
    }

    // ── Plain scalar ──────────────────────────────────────────────────────
    result[key] = rest;
    i += 1;
  }

  return result;
}

// ---------------------------------------------------------------------------
// Validation helpers
// ---------------------------------------------------------------------------

/**
 * Returns true when the parsed value counts as "present and non-empty",
 * regardless of whether it was stored as an array or a string.
 *
 * @param {unknown} value
 * @returns {boolean}
 */
function isNonEmpty(value) {
  if (Array.isArray(value)) return value.length > 0;
  return typeof value === 'string' && value.trim().length > 0;
}

/**
 * Returns true when the model string is an accepted alias or a recognised
 * Claude model ID.
 *
 * @param {string} model
 * @returns {boolean}
 */
function isValidModel(model) {
  if (VALID_MODEL_ALIASES.has(model)) return true;
  return VALID_MODEL_ID_PREFIXES.some(prefix => model.startsWith(prefix));
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

function validateAgents() {
  if (!fs.existsSync(AGENTS_DIR)) {
    console.log('No agents directory found, skipping validation');
    process.exit(0);
  }

  const files = fs.readdirSync(AGENTS_DIR).filter(f => f.endsWith('.md'));
  let hasErrors = false;

  for (const file of files) {
    const filePath = path.join(AGENTS_DIR, file);
    let content;

    try {
      content = fs.readFileSync(filePath, 'utf-8');
    } catch (err) {
      console.error(`ERROR: ${file} - ${err.message}`);
      hasErrors = true;
      continue;
    }

    const frontmatter = extractFrontmatter(content);

    if (!frontmatter) {
      console.error(`ERROR: ${file} - Missing frontmatter`);
      hasErrors = true;
      continue;
    }

    // Check all required fields are present and non-empty.
    for (const field of REQUIRED_FIELDS) {
      if (!isNonEmpty(frontmatter[field])) {
        console.error(`ERROR: ${file} - Missing required field: ${field}`);
        hasErrors = true;
      }
    }

    // Validate model value.
    if (frontmatter.model && !isValidModel(frontmatter.model)) {
      const hint = [...VALID_MODEL_ALIASES].join(', ');
      console.error(
        `ERROR: ${file} - Invalid model '${frontmatter.model}'. ` +
        `Expected one of: ${hint} (or a full claude-<family>-<version> ID)`
      );
      hasErrors = true;
    }
  }

  if (hasErrors) {
    process.exit(1);
  }

  console.log(`Validated ${files.length} agent files`);
}

validateAgents();
