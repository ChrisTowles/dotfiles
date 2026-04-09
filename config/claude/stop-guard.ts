#!/usr/bin/env bun

// Stop hook: catches when Claude dismisses issues as "not related to our changes"
// and blocks the response, instructing it to address ALL issues found.

export {};

const input = await Bun.stdin.json();
const message: string = input.last_assistant_message ?? "";

const dismissivePatterns = [
  /not (related|relevant) to (our|the|these|my) (changes|work|modifications)/i,
  /pre-existing (issue|bug|error|problem)/i,
  /outside (the |our |of )?scope/i,
  /unrelated to (our|the|my) (work|changes|task)/i,
  /not (caused|introduced) by (our|the|this|my)/i,
  /existed before (our|the|this|my)/i,
  /not something we (need to|should) (fix|address)/i,
  /beyond (the |our )?scope/i,
  /separate (issue|concern|problem|PR|ticket)/i,
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
