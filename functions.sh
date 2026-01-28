# Source all functions from the functions directory
# Add to your .zshrc or .bashrc: source ~/code/p/dotfiles/functions.sh

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

# Helper functions used by other functions
print_step() {
  echo ">>> $1"
}

print_error() {
  echo "ERROR: $1" >&2
}

# Source all function files
for func_file in "$DOTFILES_DIR"/functions/*; do
  if [[ -f "$func_file" ]]; then
    source "$func_file"
  fi
done
