#!/usr/bin/env sh

[ -f ~/.zshrc ] || touch ~/.zshrc

ln -sf $(pwd)/zshrc.zsh ~/.zshrc.local

if ! grep -Fq '# my zsh config' ~/.zshrc; then
    echo "# my zsh config" >> ~/.zshrc
    echo "if [[ -r ~/.zshrc.local ]]; then" >> ~/.zshrc
    echo "    source ~/.zshrc.local" >> ~/.zshrc
    echo "fi" >> ~/.zshrc
fi
