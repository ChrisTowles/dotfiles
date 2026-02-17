# i - Quick directory navigation
# Usage: i p -> cd ~/code/p (personal)
#        i w -> cd ~/code/w (work)
#        i f -> cd ~/code/f (fork)

# Setup: create project directories
if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  mkdir -p ~/code/{p,w,f}
fi

i() {
  cd ~/code/$1
}
