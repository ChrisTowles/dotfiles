Your task is to help the user to generate a commit message and commit the changes using git.

## Guidelines
- use the `git status -s` command to check for any files that have been modified but not staged.
- list all unstaged files that have been modified, and advise the user to stage them.
- ask if these files should be added to the commit.
- if yes, generate a commit message based on the changes in the staged files.
- Follow the rules below for the commit message.

## Format

```
<type>:<space><message title>
```

## Example Titles

```
feat(auth): add JWT login flow
fix(ui): handle null pointer in sidebar
refactor(api): split user controller logic
docs(readme): add usage section
```

* title is lowercase, no period at the end.
* Title should be a clear summary, max 50 characters.

Avoid

* Vague titles like: "update", "fix stuff"
* Overly long or unfocused titles
* Excessive detail in bullet points

## Allowed Types

| Type     | Description                           |
| -------- | ------------------------------------- |
| feat     | New feature                           |
| fix      | Bug fix                               |
| chore    | Maintenance (e.g., tooling, deps)     |
| docs     | Documentation changes                 |
| refactor | Code restructure (no behavior change) |
| test     | Adding or refactoring tests           |
| style    | Code formatting (no logic change)     |
| perf     | Performance improvements              |