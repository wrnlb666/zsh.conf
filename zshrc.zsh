# make $PATH unique
typeset -U PATH

# function to test if executable exists in $PATH
exists() {
    local cmd="${1:-cat}"
    [[ -x "$(command -v "${cmd}")" ]]
}

# keys
if [[ -r ~/.keyrc ]]; then
    source ~/.keyrc
fi

# starship
if exists starship && [[ -r ~/.config/starship.toml ]]; then
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
        env -u PATH "$(which distrobox)" "$@"
    }
fi

# python venv
venv() {
    if [[ $# == 0 ]]; then
        local dir=$(pwd)
        while [[ $dir != '/' ]]; do
            for v in ".venv" "venv"; do
                if [[ -d "$dir/$v" && -f "$dir/$v/pyvenv.cfg" ]]; then
                    echo "Entering Virtual Environment '$dir/$v'..."
                    source "$dir/$v/bin/activate"
                    return
                fi
            done
            dir=$(dirname "$dir")
        done
        echo "Creating Virtual Environment './.venv'..."
        if exists uv; then
            command uv venv .venv
        else
            command python3 -m venv .venv
        fi
    else
        if exists uv; then
            command uv venv "$@"
        else
            command python3 -m venv "$@"
        fi
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

# trash-cli && gomi
if exists gomi; then
    alias rm="gomi"
elif exists trash-put; then
    alias rm="trash-put"
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
            local fzf_cmd="fzf"
            if [[ -n "${TMUX}" ]] && exists fzf-tmux; then
                fzf_cmd="fzf-tmux"
            fi
            if [[ $# -ne 0 ]]; then
                command "${fzf_cmd}" "$@"
                return
            fi
            command "${fzf_cmd}" \
                --preview '
                    [[ -f {} ]] && bat --color=always {};
                    [[ -d {} ]] && ls -lhA --color=always {}
                '
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

# flutter
if exists fvm; then
    flutter() {
        fvm flutter "$@"
    }
    source <(fvm flutter zsh-completion 2> /dev/null)
elif exists flutter; then
    source <(flutter zsh-completion)
fi

# fastfetch
if exists fastfetch; then
    neofetch() {
        fastfetch -c examples/13 "$@"
    }
fi

# _spf_export
_spf_export() {
    os=$(uname -s)
    # Linux
    if [[ "$os" == "Linux" ]]; then
        export SPF_LAST_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/superfile/lastdir"
    fi
    # macOS
    if [[ "$os" == "Darwin" ]]; then
        export SPF_LAST_DIR="$HOME/Library/Application Support/superfile/lastdir"
    fi
}
_spf_export

# superfile
spf() {
    command spf "$@"
    [ ! -f "$SPF_LAST_DIR" ] || {
        . "$SPF_LAST_DIR"
        command rm -f -- "$SPF_LAST_DIR" > /dev/null
    }
}

# tmux-spf
tmux_spf_popup() {
    local target="$1"
    command spf
    [[ -f "$SPF_LAST_DIR" ]] || return 0
    local cmd
    cmd="$(cat "$SPF_LAST_DIR")"
    command rm -f -- "$SPF_LAST_DIR"
    tmux send-keys -t "$target" -- "builtin $cmd" C-m
}

# opencode
if exists opencode; then
    #compdef opencode
    ###-begin-opencode-completions-###
    #
    # yargs command completion script
    #
    # Installation: opencode completion >> ~/.zshrc
    #    or opencode completion >> ~/.zprofile on OSX.
    #
    _opencode_yargs_completions()
    {
        local reply
        local si=$IFS
        IFS=$'
    '   reply=($(COMP_CWORD="$((CURRENT-1))" COMP_LINE="$BUFFER" COMP_POINT="$CURSOR" opencode --get-yargs-completions "${words[@]}"))
        IFS=$si
        if [[ ${#reply} -gt 0 ]]; then
            _describe 'values' reply
        else
            _default
        fi
    }
    if [[ "'${zsh_eval_context[-1]}" == "loadautofunc" ]]; then
        _opencode_yargs_completions "$@"
    else
        compdef _opencode_yargs_completions opencode
    fi
    ###-end-opencode-completions-###
fi

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
bindkey -M vicmd 'v' edit-command-line
