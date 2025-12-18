# pr - Push to origin and open GitHub compare view for PR creation

pr() {
  remote=origin
  branch=$(git symbolic-ref --short HEAD)

  if [[ $branch == "master" ]] || [[ $branch == "main" ]]; then
    print_error "In $branch branch, can't do a PR."
    return 1
  else
    # Extract repo from remote URL (foo/bar)
    repo=$(git ls-remote --get-url ${remote} |
      sed 's|^.*.com[:/]\(.*\)$|\1|' |
      sed 's|\(.*\)/$|\1|' |
      sed 's|\(.*\)\(\.git\)|\1|')

    set -x
    git push ${remote} ${branch}
    gh pr create --web
  fi
}
