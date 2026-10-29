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
    # Normal mode: prefix + key → whole pane
    tmux bind-key "$key" capture-pane -J \\\; \
      save-buffer "${TMPDIR:-/tmp}/tmux-buffer" \\\; \
      delete-buffer \\\; \
      send-keys -t . " sh -c 'cat \"${TMPDIR:-/tmp}/tmux-buffer\" | $exe'" Enter

    # Copy-mode-vi: key → selection only (opens in new window to the left)
    # The writer touches a done flag after writing, and the window waits for
    # it: both commands spawn together, and a window that opened the buffer
    # file before the writer's data arrived read an empty selection, which
    # made cg guess nothing and fzf --exit-0 exit without showing its UI.
    tmux bind-key -T copy-mode-vi "$key" \
      send -X pipe-and-cancel "rm -f \"${TMPDIR:-/tmp}/tmux-buffer.ok\"; cat > \"${TMPDIR:-/tmp}/tmux-buffer\"; touch \"${TMPDIR:-/tmp}/tmux-buffer.ok\"" \\\; \
      new-window -b "sh -c 'until [ -e \"${TMPDIR:-/tmp}/tmux-buffer.ok\" ]; do sleep 0.05; done; cat \"${TMPDIR:-/tmp}/tmux-buffer\" | $exe; printf \"\\n[finished]\\a\"; while :; do sleep 2073600; done'"
  fi
done

tmux bind-key \| \
  capture-pane -J \\\; save-buffer "${TMPDIR:-/tmp}/tmux-buffer" \\\; delete-buffer \\\; \
  run-shell "touch \"${TMPDIR:-/tmp}/tmux-buffer.ok\"" \\\; \
  command-prompt -p "Shell command:" "new-window -b sh -c 'until [ -e \"${TMPDIR:-/tmp}/tmux-buffer.ok\" ]; do sleep 0.05; done; cat \"${TMPDIR:-/tmp}/tmux-buffer\" | %%; printf \"\\n[finished]\\a\"; while :; do sleep 2073600; done'"


tmux bind-key -T copy-mode-vi \| \
  send -X pipe-and-cancel "rm -f \"${TMPDIR:-/tmp}/tmux-buffer.ok\"; cat > \"${TMPDIR:-/tmp}/tmux-buffer\"; touch \"${TMPDIR:-/tmp}/tmux-buffer.ok\"" \\\; \
  command-prompt -p "Shell command:" "new-window -b sh -c 'until [ -e \"${TMPDIR:-/tmp}/tmux-buffer.ok\" ]; do sleep 0.05; done; cat \"${TMPDIR:-/tmp}/tmux-buffer\" | %%; printf \"\\n[finished]\\a\"; while :; do sleep 2073600; done'"
