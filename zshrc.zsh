# make $PATH unique
typeset -U PATH

# function to test if executable exists in $PATH
exists() {
    if [[ "$#" -ne 1 ]]; then
        echo '[ERRO]: "exists" requires exactly one argument' >&2
        return 2
    fi
    local cmd="$1"
    if [[ -x "$(command -v "${cmd}")" ]]; then
        return 0
    else
        return 1
    fi
}

# keys
if [[ -r ~/.keyrc ]]; then
    source ~/.keyrc
fi

# starship
if exists starship; then
    if ! [[ -r ~/.config/starship.toml ]]; then
        starship preset tokyo-night -o ~/.config/starship.toml
    fi
    source <(starship init zsh)
fi

# ls
if exists lsd; then
    alias ls="lsd"
fi
alias ll="ls -lha"

# lazygit
if exists lazygit; then
    alias lg="lazygit"
fi

# lazydocker
if exists lazydocker; then
    alias lzd="lazydocker"
fi

# distrobox
if exists distrobox; then
    db() {
        env -u PATH "$(which distrobox)" $@
    }
fi

# python venv
venv() {
    if [[ $# == 0 ]]; then
        local dir=$(pwd)
        while [[ $dir != '/' ]]; do
            for v in "venv" ".venv"; do
                if [[ -d "$dir/$v" && -f "$dir/$v/pyvenv.cfg" ]]; then
                    echo "Entering Virtual Environment '$dir/$v'..."
                    source "$dir/$v/bin/activate"
                    return
                fi
            done
            dir=$(dirname "$dir")
        done
        echo "Creating Virtual Environment './venv'..."
        command python3 -m venv venv
    else
        command python3 -m venv $@
    fi
}

# python uv
if exists uv; then
    source <(uv generate-shell-completion zsh)
fi

# python conda
_setup_conda() {
    local dir
    for dir in "conda" "miniforge3" "miniconda" "miniconda3" "anaconda3" "Conda" "Anaconda"; do
        if [[ -r "${HOME}/${dir}/etc/profile.d/conda.sh" ]]; then
            source "${HOME}/${dir}/etc/profile.d/conda.sh"
            break
        fi
    done
}
_setup_conda

# gomi
if exists gomi; then
    alias rm="gomi"
fi

# man page
if exists bat; then
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
    export MANROFFOPT="-c"
fi

# fzf
if [[ -r /usr/share/fzf/completion.zsh ]]; then
    source /usr/share/fzf/completion.zsh
fi
if [[ -r /usr/share/fzf/key-bindings.zsh ]]; then
    source /usr/share/fzf/key-bindings.zsh
fi
if exists fzf; then
    export FZF_DEFAULT_OPTS=" \
        --color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8 \
        --color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
        --color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
        --color=selected-bg:#45475A \
        --color=border:#6C7086,label:#CDD6F4"
    source <(fzf --zsh)
    if exists fd; then
        export FZF_DEFAULT_COMMAND="fd --type f"
    fi
    if exists bat; then
        fzf() {
            command fzf-tmux \
                --preview " \
                    [[ -f {} ]] && bat --color=always {}; \
                    [[ -d {} ]] && ls -lhA --color=always {}"
        }
    fi
fi

# neovim
if exists nvim; then
    export EDITOR=nvim
    alias view="nvim -RM"
fi

# micro
if exists micro; then
    if ! exists nvim; then
        export EDITOR=micro
    fi
fi

# zoxide
if exists zoxide; then
    source <(zoxide init zsh --cmd z)
    alias cd="z"
fi

# go
if exists go; then
    GOROOT="$(go env GOROOT)"
    GOPATH="$(go env GOPATH)"
    export GOROOT
    export GOPATH
    export PATH=$PATH:$GOPATH/bin
    alias gop="GOPROXY=https://goproxy.cn"
fi

# fastfetch
if exists go; then
    neofetch() {
        fastfetch -c examples/13 $@
    }
fi

# tuios
if exists tuios; then
    source <(tuios completion zsh)
fi

# superfile
spf() {
    os=$(uname -s)
    # Linux
    if [[ "$os" == "Linux" ]]; then
        export SPF_LAST_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/superfile/lastdir"
    fi
    # macOS
    if [[ "$os" == "Darwin" ]]; then
        export SPF_LAST_DIR="$HOME/Library/Application Support/superfile/lastdir"
    fi
    command spf "$@"
    [ ! -f "$SPF_LAST_DIR" ] || {
        . "$SPF_LAST_DIR"
        command rm -f -- "$SPF_LAST_DIR" > /dev/null
    }
}

# rust
export PATH=$PATH:~/.cargo/bin

# gdu
if [[ -x "$(command -v gdu-go)" ]]; then
    alias gdu="gdu-go"
fi

# vscode
if [[ ! -x "$(command -v code)" ]] && flatpak info com.visualstudio.code &> /dev/null; then
    alias code="flatpak run com.visualstudio.code"
fi

# mkj
mkj() {
    local dir="$1"
    mkdir -p "$dir"
    cd "$dir" || exit 1
}

# clear cache
uncache() {
    sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
}

# zsh vi mode
bindkey -v
bindkey -M viins '^?' backward-delete-char
bindkey -M viins 'jj' vi-cmd-mode
bindkey -M viins 'jk' vi-cmd-mode
