# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ENABLE_CORRECTION="true"
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
export PATH="/Applications/PyCharm.app/Contents/MacOS:$PATH"

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

# fzf setup
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


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
