export type OS = "linux" | "darwin" | "win32";
export type Shell = "zsh" | "pwsh";
export type PerOS<T> = Partial<Record<OS, T>>;

export const ALL_OS: OS[] = ["linux", "darwin", "win32"];
export const SHELLS: Shell[] = ["zsh", "pwsh"];

export type Install =
  | { via: "apt"; pkg: string | string[]; repo?: AptRepo }
  | { via: "brew"; pkg: string; cask?: boolean; tap?: string }
  | { via: "winget"; id: string }
  | { via: "cargo"; crate: string; locked?: boolean; git?: string }
  | { via: "gh-release"; repo: string; asset: string; bins: string[]; tag?: string }
  | { via: "script"; url: string; args?: string[]; shell?: "sh" | "bash" }
  | { via: "flatpak"; id: string }
  | { via: "pnpm-global"; pkg: string };

/** A third-party apt repository: the signing key is fetched to `keyring`, `line` goes in sources.list.d. */
export interface AptRepo {
  name: string;
  key: string;
  keyring: string;
  /** `{arch}` and `{keyring}` are filled in; `{codename}` is the Ubuntu codename. */
  line: string;
  /** Pipe the key through `gpg --dearmor` (keys published as ASCII armor but referenced as .gpg). */
  dearmor?: boolean;
}

/**
 * A link target is a logical path the Platform resolves per OS:
 *   "config:x"  native config dir  (~/.config, ~/Library/Application Support, %APPDATA%)
 *   "xdg:x"     ~/.config on Linux and macOS, %APPDATA% on Windows
 *   "data:x"    native data dir    (~/.local/share, ~/Library/Application Support, %LOCALAPPDATA%)
 *   "~/x"       the home directory
 *   "/x"        an absolute path
 */
export interface Link {
  from: string;
  to: string | PerOS<string>;
}

export interface Command {
  desc: string;
  /** Usage hint for the arguments. A command with args goes on the prompt from the picker instead of running. */
  args?: string;
  run: (ctx: Ctx, argv: string[]) => Promise<number | void>;
  /** Also define a shell alias of the same name that runs `ttd <name>`. Default true. */
  alias?: boolean;
}

export interface Completion {
  shell: Shell;
  /** Command that prints the completion script. "ttd-gen-completions <cli>" uses config/generate-completions.ts. */
  argv: string[];
  /** File name: zsh → ~/.zsh/completions/<name>, pwsh → ~/.cache/dotfiles/completions/<name>.ps1 */
  name: string;
}

export interface ModuleDef {
  id: string;
  /** Modules that must come first, in setup and in the generated init. */
  needs?: string[];
  /** Defaults to the keys of `install`, or all three OSes when there is no install. */
  os?: OS[];
  /** Probed with Bun.which. Defaults to `id`. */
  bin?: string;
  /** Override the installed check (fonts, GUI apps, things with no binary). */
  installed?: (ctx: Ctx) => boolean | Promise<boolean>;
  install?: PerOS<Install | Install[]>;
  links?: Link[];
  /** Values: "~/" expands to home, "{repo}" to the dotfiles checkout. */
  env?: Record<string, string | PerOS<string>>;
  path?: (string | PerOS<string>)[];
  aliases?: Record<string, string | Partial<Record<Shell, string>>>;
  commands?: Record<string, Command>;
  /** Static init output, run once at gen time and pasted into the init file. */
  capture?: Partial<Record<Shell, string[]>>;
  completions?: Completion[];
  setup?: (ctx: Ctx) => Promise<void>;
}

export interface Module extends ModuleDef {
  dir: string;
}

export interface RunResult {
  code: number;
  stdout: string;
  stderr: string;
}

export interface Ctx {
  os: OS;
  home: string;
  repo: string;
  dryRun: boolean;
  /** The module this ctx is bound to (its folder, for config files). */
  dir: string;
  /** Resolve a logical path ("config:x", "~/x", …) for this OS. */
  resolve(target: string): string;
  /** Run and capture output. Not skipped in dry run: use for reads only. */
  read(argv: string[], opts?: { cwd?: string; env?: Record<string, string>; stdin?: string }): Promise<RunResult>;
  /** Run with inherited stdio. In dry run, prints the command and returns 0. */
  exec(argv: string[], opts?: { cwd?: string; env?: Record<string, string> }): Promise<number>;
  /** exec with sudo on Linux/macOS; plain exec on Windows. */
  sudo(argv: string[]): Promise<number>;
  has(bin: string): boolean;
  log(msg: string): void;
  /** Queue a message for the end of setup (replaces DOTFILES_SETUP_MESSAGES). */
  notice(msg: string): void;
  /** Write a file (skipped in dry run). */
  write(path: string, text: string): Promise<void>;
  link(from: string, to: string): void;
}
