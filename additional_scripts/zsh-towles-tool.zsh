# zsh-towles-tool.zsh
# @towles/tool CLI aliases and functions

# install @towles/tool
# npm i -g @towles/tool
alias tt="towles-tool"
alias today="towles-tool journal today"
alias meeting="towles-tool journal meeting"
alias note="towles-tool journal note"

# temporary commit until i move it into `@towles/tool` - https://www.npmjs.com/package/@towles/tool
alias branch='towles-tool gh-branch' # use my cli tool to create a branch from an issue
alias branch-me='towles-tool gh-branch --assigned-to-me'

zsh_debug_section "Towles tool setup"