# Google Chrome setup
# https://www.google.com/chrome/

if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if ! command -v google-chrome >/dev/null 2>&1 && ! command -v google-chrome-stable >/dev/null 2>&1; then
    echo " Installing Google Chrome..."
    case "$(uname -s)" in
      Darwin) brew install --cask google-chrome ;;
      Linux)
        # Add Google Chrome apt repository
        sudo install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list > /dev/null
        sudo apt-get update -qq
        sudo apt-get install -y -qq google-chrome-stable
        ;;
    esac
  fi
fi
