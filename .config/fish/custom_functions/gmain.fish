function gmain --description "Switch to main/master branch, stash changes and pull latest"
    # Stash any uncommitted changes
    git stash
    
    # Check if main branch exists locally
    set main_branch (git branch -l main | string trim)
    
    if test -z "$main_branch"
        set_color yellow
        echo "checking out master"
        set_color normal
        git checkout master
    else
        set_color yellow
        echo "checking out main"
        set_color normal
        git checkout main
    end
    
    # Pull latest changes
    git pull
end