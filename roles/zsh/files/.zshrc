# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ENABLE_CORRECTION="false"
COMPLETION_WAITING_DOTS="true"


# == zsh-vi-mode fixes ==
# Fix keybindings problems with another plugins
export ZVM_INIT_MODE=sourcing


# == Plugins ==
plugins=()
plugins+=(git)
plugins+=(docker)
plugins+=(zsh-syntax-highlighting)
plugins+=(zsh-autosuggestions)
plugins+=(zsh-vi-mode)
plugins+=(fzf-tab)
plugins+=(zsh-you-should-use)

source $ZSH/oh-my-zsh.sh


# == Setups ==
# Default editor setup
export VISUAL=nvim
export EDITOR="$VISUAL"

# Add pycharm to $PATH
export PATH="/Applications/PyCharm CE.app/Contents/MacOS:$PATH"

# asdf setup
. $HOMEBREW_PREFIX/opt/asdf/libexec/asdf.sh
export ASDF_DEFAULT_TOOL_VERSIONS_FILENAME=".dev/.tool-versions"

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
--color=fg+:15,bg+:7
--color=hl:11,hl+:11
--color=prompt:4,spinner:1,pointer:7,info:5
'

# ripgrep setup
export RIPGREP_CONFIG_PATH="$HOME/.config/.ripgreprc"

# psql setup
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# txc setup
export PATH="$HOME/Desktop/txc/target/release/:$PATH"


# == Aliases ==
alias cd1="cd .."
alias cd2="cd ../../"
alias cd3="cd ../../../"
alias cd4="cd ../../../../"
alias cd5="cd ../../../../../"

alias tree='tree -I ".git|venv"'

alias d="docker"
alias dps="docker ps"
alias dpsa="docker ps -a"
alias dsta="docker ps -q | xargs docker stop"
alias drma="docker ps -a -q | xargs docker rm"

alias tkas="tmux kill-session -a"

alias n="nvim"
alias nvimdb="nvim +DBUI"
alias ndb="nvimdb"


# == keybindings ==
# zsh-autosuggestions
bindkey '^l' autosuggest-accept # Ctrl + L
