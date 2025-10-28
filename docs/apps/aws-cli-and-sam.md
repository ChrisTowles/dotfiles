## SAM CLI Installation

I had tons of issues with the arm64 version so using x86_64 here.

```bash

curl -L https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip -o aws-sam-cli-linux-x86_64.zip

unzip aws-sam-cli-linux-x86_64.zip -d sam-installation

# install
sudo ./sam-installation/install
# update

sudo ./sam-installation/install --update

# verify install
sam --version

```