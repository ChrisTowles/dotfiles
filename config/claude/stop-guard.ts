#!/usr/bin/env bun

// Stop hook: catches when Claude dismisses issues as "not related to our changes"
// and blocks the response, instructing it to address ALL issues found.

export {};

const input = await Bun.stdin.json();
const message: string = input.last_assistant_message ?? "";

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

  // "separate issue/PR/ticket" (dismissing to future work)
  /separate (issue|problem|PR|ticket)\b/i,
];

const match = dismissivePatterns.find((p) => p.test(message));

if (match) {
  console.log(
    JSON.stringify({
      decision: "block",
      reason:
        "You dismissed an issue as not related to our changes. Address ALL errors and issues found during your work, regardless of their source. Do not defer issues to separate PRs or tickets unless explicitly asked.",
    })
  );
}
