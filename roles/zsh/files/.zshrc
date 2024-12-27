# == Fixes ==
# Fix zsh-vi-mode keybindings problems with another plugins
export ZVM_INIT_MODE=sourcing

# Fix fzf-tab keybindings
autoload -U compinit; compinit


# == Plugins ==
export ZSH_PLUGINS_DIR="$HOME/.local/share/zsh/plugins"

source "$ZSH_PLUGINS_DIR/fzf-tab/fzf-tab.zsh"
source "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "$ZSH_PLUGINS_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$ZSH_PLUGINS_DIR/zsh-vi-mode/zsh-vi-mode.zsh"
source "$ZSH_PLUGINS_DIR/zsh-you-should-use/zsh-you-should-use.plugin.zsh"


# == Setups ==
# Default editor setup
export VISUAL=nvim
export EDITOR="$VISUAL"

# Starship setup
eval "$(starship init zsh)"

# Zoxide setup
eval "$(zoxide init zsh)"
alias cd="z"

# lsd setup
alias ls="lsd"

# curlie setup
alias curl="curlie"

# bat setup
alias cat="bat"

# fzf setup
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
--color=16
--color=fg+:4,bg+:0
--color=hl:11,hl+:11
--color=prompt:4,spinner:1,pointer:7,info:5
'

# ripgrep setup
export RIPGREP_CONFIG_PATH="$HOME/.config/.ripgreprc"

# psql setup
export PATH="$PATH:/opt/homebrew/opt/libpq/bin"


# == Aliases ==
alias cd1="cd .."
alias cd2="cd ../../"
alias cd3="cd ../../../"
alias cd4="cd ../../../../"
alias cd5="cd ../../../../../"

alias la="ls -la"

alias n="nvim"

alias g="git"

alias t="tmux"
alias tkas="tmux kill-session -a"

alias d="docker"
alias dps="docker ps"
alias dpsa="docker ps -a"
alias dsta="docker ps -q | xargs docker stop"
alias drma="docker ps -a -q | xargs docker rm"

alias history="history 0"

# == Functions ==
gitpreview() {
    local url="$1"
    local repo_name="$(basename -s .git "$url")"
    git clone "$url" "/tmp/$repo_name" && cd "/tmp/$repo_name"
}


# == Keybindings ==
# zsh-autosuggestions
bindkey '^l' autosuggest-accept # Ctrl + L
