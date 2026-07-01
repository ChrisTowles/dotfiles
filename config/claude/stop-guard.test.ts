import { describe, expect, test } from "bun:test";
import { evaluate, stripNonProse } from "./stop-guard";

describe("evaluate — blocks genuine dismissals", () => {
  test("brushing off a pre-existing failure", () => {
    expect(evaluate("That's a pre-existing bug, so I left it alone.")).not.toBeNull();
  });

  test("deferring to a separate ticket", () => {
    expect(evaluate("That belongs in a separate ticket; I'll open a follow-up.")).not.toBeNull();
  });

  test("declaring work out of scope", () => {
    expect(evaluate("Fixing the lint config is outside the scope here.")).not.toBeNull();
  });

  test("claiming an error is unrelated to the task", () => {
    expect(evaluate("This error is unrelated to the task, leaving as-is.")).not.toBeNull();
  });
});

describe("evaluate — does not block when phrases are quoted or documented", () => {
  test("phrase inside double quotes (the false positive that fired on this hook)", () => {
    const msg = 'The hook pattern-matches phrases like "separate PR" and "pre-existing issue".';
    expect(evaluate(msg)).toBeNull();
  });

  test("phrase inside inline code", () => {
    expect(evaluate("It flags `outside the scope` in the final message.")).toBeNull();
  });

  test("phrase inside a fenced code block", () => {
    const msg = "Here is the regex:\n```\n/pre-existing (issue|bug)/i\n```\nLooks good.";
    expect(evaluate(msg)).toBeNull();
  });

  test("phrase inside a markdown blockquote", () => {
    expect(evaluate("> not something we need to fix\n\nThat quote is the hook's reason.")).toBeNull();
  });
});

describe("evaluate — clean messages pass", () => {
  test("ordinary summary with apostrophes is untouched", () => {
    expect(evaluate("I'll wire it up and don't expect issues.")).toBeNull();
  });

  test("empty message", () => {
    expect(evaluate("")).toBeNull();
  });
});

describe("stripNonProse", () => {
  test("keeps apostrophes in ordinary prose", () => {
    expect(stripNonProse("I'll fix it and don't defer")).toBe("I'll fix it and don't defer");
  });
});
