 # Github
 
 I kept having issue with claude code using github api and it would fallback to gh commands. which worked but i wanted to fix.
 
  The fix was to configure git to use the GitHub CLI's credential helper instead of the basic store helper.


  **Before:** Git was using `credential.helper = store` which wasn't working properly
  **After:** Git now uses `credential.helper = !gh auth git-credential` which leverages your existing GitHub CLI authentication


```bash
git config --global credential.helper '!gh auth git-credential'
```
