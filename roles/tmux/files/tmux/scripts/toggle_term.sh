#!/bin/bash
# source: https://gist.github.com/pbnj/67c16c37918ba40bbb233b97f3e38456

set -uo pipefail

POPUP_SESSION_NAME="Float$(tmux display-message -p '#{pane_current_path}')"

if [ "$(tmux display-message -p -F "#{session_name}")" = $POPUP_SESSION_NAME ];then
  tmux -L float detach-clien
else
  tmux popup -d '#{pane_current_path}' -xC -yC -w91% -h80% -E "tmux -L float attach -t $POPUP_SESSION_NAME || tmux -L float -f ~/.config/tmux/float.conf new -s $POPUP_SESSION_NAME"
fi
