## Full Setup of vidsrc cli

CLI for the vidsrc cli

```bash

git clone https://github.com/Ciarands/vidsrc-to-resolver.git
cd vidsrc-to-resolver
pyenv virtualenv 3.12.3 vidsrc-to-resolver 
pyenv shell vidsrc-to-resolver  
pyenv local vidsrc-to-resolver  

pip install -r requirements.txt 
sudo apt install mpv  

python3 vidsrc.py