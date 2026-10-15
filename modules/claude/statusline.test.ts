import { describe, expect, test } from "bun:test";
import { calcCacheRatio, progressBar, contextColor, shortDir } from "./statusline";

describe("calcCacheRatio", () => {
  test("returns 0 for null usage", () => {
    expect(calcCacheRatio(null)).toBe(0);
  });

  test("returns 0 when no cache read tokens", () => {
    expect(calcCacheRatio({ input_tokens: 100, cache_read_input_tokens: 0 })).toBe(0);
  });

  test("returns 0 when zero total input", () => {
    expect(calcCacheRatio({ input_tokens: 0 })).toBe(0);
  });

  test("calculates correct ratio", () => {
    expect(calcCacheRatio({
      input_tokens: 50,
      cache_read_input_tokens: 50,
    })).toBe(50);
  });

  test("100% cache hit", () => {
    expect(calcCacheRatio({
      input_tokens: 0,
      cache_read_input_tokens: 100,
    })).toBe(100);
  });

  test("includes cache creation in total", () => {
    expect(calcCacheRatio({
      input_tokens: 0,
      cache_creation_input_tokens: 50,
      cache_read_input_tokens: 50,
    })).toBe(50);
  });
});

describe("progressBar", () => {
  test("0% is all empty", () => {
    const bar = progressBar(0, 10);
    expect(bar).toBe("▱".repeat(10));
  });

  test("100% is all filled", () => {
    const bar = progressBar(100, 10);
    expect(bar).toBe("▰".repeat(10));
  });

  test("clamps above 100", () => {
    const bar = progressBar(150, 10);
    expect(bar).toBe("▰".repeat(10));
  });

  test("clamps below 0", () => {
    const bar = progressBar(-50, 10);
    expect(bar).toBe("▱".repeat(10));
  });

  test("total length equals width", () => {
    const bar = progressBar(50, 20);
    const chars = bar.replace(/[▰▱]/g, "x");
    expect(chars.length).toBe(20);
  });
});

describe("contextColor", () => {
  test("green under 40%", () => {
    expect(contextColor(0)).toBe("green");
    expect(contextColor(39)).toBe("green");
  });

  test("yellow at 40-59%", () => {
    expect(contextColor(40)).toBe("yellow");
    expect(contextColor(59)).toBe("yellow");
  });

  test("orange at 60-79%", () => {
    expect(contextColor(60)).toBe("orange");
    expect(contextColor(79)).toBe("orange");
  });

  test("red at 80%+", () => {
    expect(contextColor(80)).toBe("red");
    expect(contextColor(100)).toBe("red");
  });
});

describe("shortDir", () => {
  test("replaces /home/user with ~", () => {
    expect(shortDir("/home/ctowles/code")).toBe("~/code");
  });

  test("truncates long paths", () => {
    const result = shortDir("/home/ctowles/very/long/nested/directory/path", 20);
    expect(result.length).toBeLessThanOrEqual(20);
    expect(result.startsWith("...")).toBe(true);
  });

  test("no truncation for short paths", () => {
    expect(shortDir("/tmp")).toBe("/tmp");
  });

  test("preserves non-home paths", () => {
    expect(shortDir("/var/log")).toBe("/var/log");
  });
});
