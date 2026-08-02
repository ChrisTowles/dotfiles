# cf - the Cloudflare CLI (https://blog.cloudflare.com/cf-cli-local-explorer/)
# Technical preview; positioned as the next version of Wrangler and eventually
# covering the whole Cloudflare API surface. Ships as the npm package `cf`.
#
# NOT flarectl — that's the CLI in cloudflare-go, which only ever shipped
# binaries on the abandoned v0.x tags and is no longer the tool to use.
#
# Auth is interactive: `cf auth login` (OAuth), `cf auth whoami` to check.
# Named profiles via `cf auth create <name>` + `--profile`.

if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if command -v pnpm >/dev/null 2>&1; then
    echo " Installing Cloudflare CLI (cf)..."
    pnpm install --global cf
  else
    echo " Skipping Cloudflare CLI — pnpm not found"
  fi

  # Generate zsh completions (emits a #compdef file despite the docs
  # suggesting you append it straight to ~/.zshrc)
  if command -v cf >/dev/null 2>&1; then
    echo " Generating Cloudflare CLI completions..."
    cf complete zsh > ~/.zsh/completions/_cf
  fi
fi
