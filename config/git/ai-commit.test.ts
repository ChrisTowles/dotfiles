import { describe, expect, test } from "bun:test";
import { fuzzyScore, highlightMatch } from "./ai-commit";

describe("fuzzyScore", () => {
  test("exact match scores high", () => {
    expect(fuzzyScore("feat", "feat")).toBeGreaterThan(0);
  });

  test("returns -1 when query chars not found", () => {
    expect(fuzzyScore("xyz", "feat: add thing")).toBe(-1);
  });

  test("returns -1 when query is longer than target", () => {
    expect(fuzzyScore("abcdef", "abc")).toBe(-1);
  });

  test("empty query matches everything", () => {
    expect(fuzzyScore("", "anything")).toBe(0);
  });

  test("case insensitive", () => {
    expect(fuzzyScore("feat", "FEAT: something")).toBeGreaterThan(0);
  });

  test("consecutive matches score higher than spread matches", () => {
    const consecutive = fuzzyScore("fix", "fix: bug");
    const spread = fuzzyScore("fix", "f_i_x");
    expect(consecutive).toBeGreaterThan(spread);
  });

  test("word boundary match scores higher", () => {
    const boundary = fuzzyScore("f", "feat: add");
    const mid = fuzzyScore("e", "feat: add");
    // 'f' at start gets boundary bonus, 'e' mid-word does not
    expect(boundary).toBeGreaterThan(mid);
  });

  test("colon boundary gives bonus", () => {
    const score = fuzzyScore("a", "feat: add");
    // 'a' after ': ' gets word boundary bonus
    expect(score).toBeGreaterThan(0);
  });
});

describe("highlightMatch", () => {
  test("empty query returns target unchanged", () => {
    expect(highlightMatch("", "hello")).toBe("hello");
  });

  test("preserves original casing in output", () => {
    const result = highlightMatch("h", "Hello");
    expect(result).toContain("H");
    expect(result).not.toContain("h");
  });

  test("non-matching chars are not highlighted", () => {
    const result = highlightMatch("h", "Hello world");
    // 'ello world' should appear without escape codes
    expect(result).toContain("ello world");
  });

  test("returns string of same visible content for full match", () => {
    const result = highlightMatch("ab", "ab");
    // Should contain both characters regardless of color wrapping
    expect(result).toContain("a");
    expect(result).toContain("b");
  });
});
