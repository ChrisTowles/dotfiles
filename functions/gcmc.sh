# gcmc - Commit helper that suggests commit message options

gcmc() {
  echo "Initializing git commit message helper..."

  # Check if we're in a git repository
  if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not in a git repository"
    return 1
  fi

  # Check if there are staged changes
  if ! git diff --cached --quiet; then
    echo "Staged changes detected. Proceeding with commit message suggestions..."
  elif ! git diff --quiet; then
    echo "Unstaged changes detected. Staging all changes..."
    git add .
  else
    echo "No changes to commit"
    return 0
  fi

  # Get the diff of staged changes
  local DIFF=$(git diff --cached --name-only | head -10)
  local SUMMARY=$(git diff --cached --stat | tail -1)

  echo "Changes to commit:"
  echo "$SUMMARY"
  echo ""

  # Generate 3 commit message options based on file changes
  echo "Commit message options:"
  echo ""

  local MSG1 MSG2 MSG3

  # Option 1: feat/fix/chore based on file types
  if echo "$DIFF" | grep -q "\.github/workflows"; then
    MSG1="ci: update GitHub workflow configuration"
  elif echo "$DIFF" | grep -q "package\.json\|pnpm-lock\.yaml"; then
    MSG1="chore: update dependencies"
  elif echo "$DIFF" | grep -q "\.md$"; then
    MSG1="docs: update documentation"
  elif echo "$DIFF" | grep -q "\.vue\|\.ts\|\.js"; then
    MSG1="feat: implement new functionality"
  else
    MSG1="chore: update project files"
  fi

  # Option 2: More specific based on directory
  if echo "$DIFF" | grep -q "packages/blog"; then
    MSG2="blog: update blog functionality"
  elif echo "$DIFF" | grep -q "content/"; then
    MSG2="content: add new blog content"
  elif echo "$DIFF" | grep -q "server/"; then
    MSG2="server: update server logic"
  else
    MSG2="refactor: improve code structure"
  fi

  # Option 3: Simple descriptive
  if [ $(echo "$DIFF" | wc -l) -eq 1 ]; then
    local FILENAME=$(basename "$DIFF")
    MSG3="update: modify $FILENAME"
  else
    MSG3="update: modify multiple files"
  fi

  echo "1) $MSG1"
  echo "2) $MSG2"
  echo "3) $MSG3"
  echo ""

  # Prompt for selection
  read "choice?Select commit message (1-3) or enter custom message: "

  local COMMIT_MSG
  case $choice in
    1) COMMIT_MSG="$MSG1" ;;
    2) COMMIT_MSG="$MSG2" ;;
    3) COMMIT_MSG="$MSG3" ;;
    *) COMMIT_MSG="$choice" ;;
  esac

  # Create the commit
  git commit -m "$COMMIT_MSG"
  echo ""
  echo "Committed with message: $COMMIT_MSG"
}
