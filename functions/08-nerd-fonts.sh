# nerd-fonts - Install Nerd Fonts for Starship and terminal icons

NERD_FONT_VERSION="v3.3.0"
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
      local tmp_zip
      tmp_zip=$(mktemp /tmp/nerd-font-XXXXXX.zip)
      curl -fL "https://github.com/ryanoasis/nerd-fonts/releases/download/$NERD_FONT_VERSION/$NERD_FONT_NAME.zip" -o "$tmp_zip"
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
  local settings_file
  if [[ "$(uname)" == "Darwin" ]]; then
    settings_file="$HOME/Library/Application Support/Code - Insiders/User/settings.json"
  else
    settings_file="$HOME/.config/Code - Insiders/User/settings.json"
  fi

  if [[ ! -f "$settings_file" ]]; then
    mkdir -p "$(dirname "$settings_file")"
    echo '{}' > "$settings_file"
  fi

  local font_family="FiraCode Nerd Font"

  # Use tsx to safely merge JSON settings
  npx tsx -e "
import { readFileSync, writeFileSync } from 'fs';
const [settingsFile, font] = process.argv.slice(2);
const settings = JSON.parse(readFileSync(settingsFile, 'utf8'));
settings['editor.fontFamily'] = font;
settings['terminal.integrated.fontFamily'] = font;
writeFileSync(settingsFile, JSON.stringify(settings, null, 2) + '\n');
" "$settings_file" "$font_family"
  echo " VS Code Insiders font set to $font_family"
}

# Install fonts in setup mode
if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  _nerd_fonts_install
  _nerd_fonts_vscode
fi

# Alias to manually trigger font install
alias nerd-fonts-setup='_nerd_fonts_install'
