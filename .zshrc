# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ENABLE_CORRECTION="true"

COMPLETION_WAITING_DOTS="true"

plugins=(git docker zsh-vi-mode zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh



# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi
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

# == Aliases ==
alias cd1="cd .."
alias cd2="cd ../../"
alias cd3="cd ../../../"
alias cd4="cd ../../../../"
alias cd5="cd ../../../../../"

alias tree='tree -I ".git|venv"'

alias g="git"

alias d="docker"
alias dps="docker ps"
alias dpsa="docker ps -a"
alias dsta="docker stop $(docker ps -a -q)"
alias drma="docker rm $(docker ps -a -q)"
