# gmain - Switch to main/master branch and pull

gmain() {
  git stash
  main_branch=$(git branch -l main)
  if [ -z "${main_branch}" ]; then
    print_step "checking out master"
    git checkout master
  else
    print_step "checking out main"
    git checkout main
  fi
  git pull
}
