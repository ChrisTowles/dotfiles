# git-ignored - Show all files not included in Git

git-ignored() {
  print_step "Showing all files not included in Git"
  git ls-files . --ignored --exclude-standard --others | grep -v node_modules
  echo ""
  print_step "Example: you can remove some folders with the following using grep -v (inverse)"
  echo "git ls-files . --ignored --exclude-standard --others | grep -v node_modules"
}
