#!/usr/bin/env bash

get_tmux_option() {
  local option=$1
  local option_value=$(tmux show-option -gqv "$option")
  if [ -z $option_value ]; then
    tmux display-message "tmux-externalpipe: empty option $option"
  else
    echo $option_value
  fi
}

find_executable() {
  local cmd=$1
  if type $1 >/dev/null 2>&1; then
    echo "$1"
  fi
}


for opt in $(tmux show-options -gq | grep '@externalpipe.*key' | cut -d' ' -f1); do
  name="$(echo "$opt" | cut -d'-' -f 2)"
  key="$(get_tmux_option "@externalpipe-$name-key")"
  cmd="$(get_tmux_option "@externalpipe-$name-cmd")"
  exe="$(find_executable "$cmd")"

  if [ -z "$exe" ]; then
    tmux display-message "tmux-externalpipe: $cmd was not found on the PATH"
  else
    tmux bind-key "$key" capture-pane -J \\\; \
      save-buffer "${TMPDIR:-/tmp}/tmux-buffer" \\\; \
      delete-buffer \\\; \
      send-keys -t . " sh -c 'cat \"${TMPDIR:-/tmp}/tmux-buffer\" | $exe'" Enter
  fi
done

tmux bind-key \| \
  capture-pane -J \\\; \
  save-buffer "${TMPDIR:-/tmp}/tmux-buffer" \\\; \
  delete-buffer \\\; \
  command-prompt -p "Shell command:" "split-window sh -c 'cat \"${TMPDIR:-/tmp}/tmux-buffer\" | %%'"
