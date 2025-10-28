#!/usr/bin/env tsx
import { readFileSync, writeFileSync } from 'fs';
import { glob } from 'glob';
import { relative, dirname, basename } from 'path';

interface DocFile {
  path: string;
  title: string;
  relativePath: string;
}

interface DirectoryTree {
  [key: string]: DocFile[];
}

const TOC_START_MARKER = '<!-- TOC_START -->';
const TOC_END_MARKER = '<!-- TOC_END -->';
const DOCS_DIR = 'docs';
const GLOB_IGNORE = ['**/node_modules/**', '**/images/**', '**/stopped-using/**'];
const README_PATH = 'README.md';

/**
 * Extract the first H1 heading from a markdown file
 */
function extractTitle(filePath: string): string {
  try {
    const content = readFileSync(filePath, 'utf-8');
    const lines = content.split('\n');

    for (const line of lines) {
      const trimmed = line.trim();
      if (trimmed.startsWith('# ')) {
        return trimmed.substring(2).trim();
      }
    }

    // Fallback to filename if no H1 found
    return formatFilename(basename(filePath, '.md'));
  } catch (error) {
    console.warn(`Warning: Could not read ${filePath}, using filename as title`);
    return formatFilename(basename(filePath, '.md'));
  }
}

/**
 * Convert filename to a readable title
 */
function formatFilename(filename: string): string {
  return filename
    .replace(/-/g, ' ')
    .replace(/_/g, ' ')
    .split(' ')
    .map(word => word.charAt(0).toUpperCase() + word.slice(1))
    .join(' ');
}

/**
 * Generate the table of contents
 */
async function generateTOC(): Promise<string> {
  // Find all markdown files in docs directory, excluding images
  const pattern = `${DOCS_DIR}/**/*.md`;
  const files = await glob(pattern, {
    ignore: GLOB_IGNORE
  });

  if (files.length === 0) {
    console.warn('No markdown files found in docs directory');
    return 'No documentation files found.\n';
  }

  // Build tree structure
  const tree: DirectoryTree = {};

  for (const file of files) {
    const title = extractTitle(file);
    const dir = dirname(file);

    if (!tree[dir]) {
      tree[dir] = [];
    }

    tree[dir].push({
      path: file,
      title,
      relativePath: file
    });
  }

  // Sort files alphabetically by title within each directory
  for (const dir in tree) {
    tree[dir].sort((a, b) => a.title.localeCompare(b.title));
  }

  // Sort directories
  const sortedDirs = Object.keys(tree).sort();

  // Generate markdown
  let toc = '';

  // Group by directory
  for (const dir of sortedDirs) {
    const dirName = dir === DOCS_DIR ? DOCS_DIR : relative(DOCS_DIR, dir);
    const depth = dir === DOCS_DIR ? 0 : dir.split('/').length - 1;
    const indent = '  '.repeat(depth);

    if (dir !== DOCS_DIR) {
      toc += `${indent}- **${basename(dir)}/**\n`;
    }

    for (const file of tree[dir]) {
      const itemIndent = '  '.repeat(depth + (dir === DOCS_DIR ? 0 : 1));
      toc += `${itemIndent}- [${file.title}](${file.relativePath})\n`;
    }
  }

  return toc;
}

/**
 * Update README.md with the generated TOC
 */
async function updateReadme(): Promise<void> {
  try {
    const toc = await generateTOC();
    const readmeContent = readFileSync(README_PATH, 'utf-8');

    const startIndex = readmeContent.indexOf(TOC_START_MARKER);
    const endIndex = readmeContent.indexOf(TOC_END_MARKER);

    if (startIndex === -1 || endIndex === -1) {
      console.error('Error: TOC markers not found in README.md');
      console.error(`Please add the following markers to your README.md where you want the TOC:`);
      console.error(TOC_START_MARKER);
      console.error(TOC_END_MARKER);
      process.exit(1);
    }

    if (startIndex >= endIndex) {
      console.error('Error: TOC_START marker must come before TOC_END marker');
      process.exit(1);
    }

    const before = readmeContent.substring(0, startIndex + TOC_START_MARKER.length);
    const after = readmeContent.substring(endIndex);

    const newContent = `${before}\n${toc}${after}`;

    writeFileSync(README_PATH, newContent, 'utf-8');
    console.log('✅ Table of contents generated successfully!');
    console.log(`📝 Updated ${README_PATH} with ${toc.split('\n').filter(l => l.trim()).length} entries`);
  } catch (error) {
    console.error('Error updating README:', error);
    process.exit(1);
  }
}

// Run the script
updateReadme().catch(error => {
  console.error('Fatal error:', error);
  process.exit(1);
});
