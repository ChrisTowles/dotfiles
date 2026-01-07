# conf.d/90-starship.zsh - Starship prompt (fast Rust binary)
# Replaces spaceship-prompt for much faster shell startup


command -v starship &>/dev/null || return 0

eval "$(starship init zsh)"

zsh_debug_section "Starship prompt"
