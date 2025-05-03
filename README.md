# zsh.conf
my zsh config file

## Installation
```sh
git clone git@github.com:wrnlb666/zsh.conf.git
ln -sf $(pwd)/zsh.conf/.zshrc.local ~/
echo "# my zsh config" >> ~/.zshrc
echo "if [[ -r ~/.zshrc.local ]]; then" >> ~/.zshrc
echo "    source ~/.zshrc.local" >> ~/.zshrc
echo "fi" >> ~/.zshrc
```
