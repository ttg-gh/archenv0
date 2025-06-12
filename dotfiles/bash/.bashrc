#
# ~/.bashrc
#

eval "$(starship init bash)"

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '


cd_tmux_fzf() {
  local dir
  dir=$(find ~/projects ~/work ~/ -type d -maxdepth 3 2>/dev/null | fzf) || return
  cd "$dir" || return
  local session_name
  session_name=$(basename "$dir")
  tmux new-session -A -s "$session_name"
}
bind -x '"\C-f": cd_tmux_fzf'

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}
