# cf - the Cloudflare CLI (https://blog.cloudflare.com/cf-cli-local-explorer/)
# Technical preview; positioned as the next version of Wrangler and eventually
# covering the whole Cloudflare API surface. Ships as the npm package `cf`.
#
# NOT flarectl — that's the CLI in cloudflare-go, which only ever shipped
# binaries on the abandoned v0.x tags and is no longer the tool to use.
#
# The binary is named `cf`, but that name belongs to the claude-fable wrapper
# in functions/60-claude-code.sh (a shell function always wins over a PATH
# binary). Use `cloudflare` instead — it forwards to the real binary.
#
# Auth is interactive: `cloudflare auth login` (OAuth), `cloudflare auth whoami`
# to check. Named profiles via `cloudflare auth create <name>` + `--profile`.

cloudflare() { command cf "$@"; }

if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if command -v pnpm >/dev/null 2>&1; then
    echo " Installing Cloudflare CLI (cf)..."
    pnpm install --global cf
  else
    echo " Skipping Cloudflare CLI — pnpm not found"
  fi

  # Generate zsh completions. `cf complete zsh` emits a #compdef file that
  # hardcodes `cf` — both as the command it completes and in the
  # `cf complete -- ...` calls it makes for candidates. Retarget it at
  # `cloudflare` / `command cf`, otherwise the claude-fable wrapper would be
  # invoked instead. `whence -p` (not `command -v`) so the `cf` function
  # defined in 60-claude-code.sh doesn't count as the binary being present.
  if whence -p cf >/dev/null 2>&1; then
    echo " Generating Cloudflare CLI completions..."
    command cf complete zsh \
      | sed -e 's/^#compdef cf$/#compdef cloudflare/' \
            -e 's/^compdef _cf cf$/compdef _cf cloudflare/' \
            -e 's/^\( *requestComp=\)"cf complete -- /\1"command cf complete -- /' \
      > ~/.zsh/completions/_cf
    # compinit caches #compdef -> command mappings in ~/.zcompdump and only
    # rebuilds when the completion file count or fpath changes, so retargeting
    # an existing _cf is invisible to it. Drop the dump; the next shell rebuilds it.
    rm -f "${ZDOTDIR:-$HOME}"/.zcompdump
  fi
fi
