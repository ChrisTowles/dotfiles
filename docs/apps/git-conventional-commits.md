# Conventional commits

I tend to use [conventional commits](https://www.conventionalcommits.org/) styles for my commits. But not enforced, just manual best effort. However some repos have strict enforcement to generate the changelog from the commits. 

In those cases I use the [commitizen](https://github.com/commitizen/cz-cli) tool to enforce the conventional commits.


## Install
```bash
pnpm install -g commitizen
pnpm install -g cz-conventional-changelog

echo '{ "path": "cz-conventional-changelog" }' > ~/.czrc
```