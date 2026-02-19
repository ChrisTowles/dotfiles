# nerd-fonts - Install Nerd Fonts for Starship and terminal icons

_NERD_FONTS_DIR="${0:a:h}"
NERD_FONT_NAME="FiraCode"

_nerd_fonts_install() {
  if [[ "$(uname)" == "Darwin" ]]; then
    # macOS: use Homebrew cask
    if ! command -v brew >/dev/null 2>&1; then
      echo " Homebrew not found, install it first: https://brew.sh"
      return 1
    fi
    if brew list --cask font-fira-code-nerd-font &>/dev/null; then
      echo " $NERD_FONT_NAME Nerd Font already installed (brew cask)"
    else
      echo " Installing $NERD_FONT_NAME Nerd Font via Homebrew..."
      brew install --cask font-fira-code-nerd-font
    fi
  else
    # Linux: download to ~/.local/share/fonts
    local font_dir="$HOME/.local/share/fonts/$NERD_FONT_NAME"
    if [[ -d "$font_dir" ]]; then
      echo " $NERD_FONT_NAME Nerd Font already installed at $font_dir"
    else
      echo " Installing $NERD_FONT_NAME Nerd Font..."
      gh release download --repo ryanoasis/nerd-fonts --pattern "${NERD_FONT_NAME}.zip" -D /tmp --clobber
      local tmp_zip="/tmp/${NERD_FONT_NAME}.zip"
      mkdir -p "$font_dir"
      unzip -o "$tmp_zip" -d "$font_dir"
      rm -f "$tmp_zip"
      fc-cache -fv
      echo " $NERD_FONT_NAME Nerd Font installed to $font_dir"
    fi
  fi
}

# Configure VS Code Insiders to use the Nerd Font
_nerd_fonts_vscode() {
  bun run "$_NERD_FONTS_DIR/../config/vscode/setup-settings.ts" "FiraCode Nerd Font"
  echo " VS Code Insiders font set to FiraCode Nerd Font"
}

# Install fonts in setup mode
if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  _nerd_fonts_install
  _nerd_fonts_vscode
fi

# Alias to manually trigger font install
alias nerd-fonts-setup='_nerd_fonts_install'
