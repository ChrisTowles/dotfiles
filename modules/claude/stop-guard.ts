#!/usr/bin/env bun

// Stop hook: catches when Claude ends its turn by brushing off a real issue it
// found (calling it out of scope, pre-existing, or deferring it to a follow-up)
// and blocks the response, instructing it to address ALL issues found.
//
// Only genuine PROSE is checked. Quoted text, inline/fenced code, and markdown
// blockquotes are stripped first, so *describing* or *quoting* these phrases
// (e.g. documenting this very hook) does not trigger a false block.

const dismissivePatterns = [
  // "not related/relevant to our [code] changes/work"
  /not related to .{0,20}\b(changes|work|modifications|task)\b/i,
  /not relevant to .{0,20}\b(changes|work|modifications|task)\b/i,
  /unrelated to .{0,20}\b(changes|work|task)\b/i,

  // "pre-existing issue/bug/error"
  /pre-existing (issue|bug|error|problem|failure)/i,
  /existed before .{0,20}\b(changes|work|commit)\b/i,

  // "outside/beyond the scope of our work"
  /outside .{0,20}\bscope\b/i,
  /beyond .{0,20}\bscope\b/i,

  // "not caused/introduced by our changes"
  /not caused by .{0,20}\b(changes|work|commit|code)\b/i,
  /not introduced by .{0,20}\b(changes|work|commit|code)\b/i,

  // "not something we need to fix/address"
  /not something we .{0,20}\b(fix|address|worry|handle)\b/i,

  // "separate issue/PR/ticket" (deferring to future work)
  /separate (issue|problem|PR|ticket)\b/i,
];

const BLOCK_REASON =
  "You dismissed an issue as not related to our changes. Address ALL errors and issues found during your work, regardless of their source. Do not defer issues to separate PRs or tickets unless explicitly asked.";

// Remove spans where these phrases are quoted or shown as code rather than
// asserted as the model's own conclusion. Single quotes are left alone because
// they collide with apostrophes in ordinary prose (I'll, don't, ...).
export function stripNonProse(text: string): string {
  return text
    .replace(/```[\s\S]*?```/g, " ")        // fenced code blocks
    .replace(/`[^`]*`/g, " ")                // inline code
    .replace(/^\s*>.*$/gm, " ")              // markdown blockquotes
    .replace(/"[^"]*"/g, " ")                // straight double-quoted spans
    .replace(/[“”][^“”]*[“”]/g, " "); // curly double-quoted spans
}

// Returns the block reason if the message dismisses a found issue, else null.
export function evaluate(message: string): string | null {
  const prose = stripNonProse(message);
  return dismissivePatterns.some((p) => p.test(prose)) ? BLOCK_REASON : null;
}

if (import.meta.main) {
  const input = await Bun.stdin.json();
  const reason = evaluate(input.last_assistant_message ?? "");
  if (reason) {
    console.log(JSON.stringify({ decision: "block", reason }));
  }
}
