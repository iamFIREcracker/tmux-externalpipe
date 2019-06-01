# Tmux externalpipe

Easily pipe Tmux pane content into an external command of choice.

# Background

Heavily inspired by `st`'s
[externalpipe](https://st.suckless.org/patches/externalpipe/) patch,
`tmux-externalpipe` lets you define mappings to pipe the content of the current
Tmux pane into an external command of choice.

I am fond of similar plugins such as
[tmux-urlview](https://github.com/tmux-plugins/tmux-urlview) or
[tmux-fpp](https://github.com/tmux-plugins/tmux-fpp), but when I found myself
in need of creating a new one for [cg](https://github.com/iamFIREcracker/cg)
-- which, as expected, turned out being a 1% custom, and 99% copypasta --
I decided it was time for something more generic, and reusable.

_enters `tmux-externalpipe`.._

# Install

Clone the repo:

    git clone https://github.com/iamFIREcracker/tmux-externalpipe ~/.tmux-plugins/

Add this line to the bottom of `.tmux.conf`:

    run-shell ~/.tmux-plugins/tmux-externalpipe/externalpipe.tmux

Reload Tmux -- you should be all set.

# Configuration

> How do I define custom mappings?  For example, "u" to pipe the current Tmux
> pane into `urlview`?

Put the following in `tmux.conf`:

    set -g @externalpipe-urlview-cmd 'urlview'
    set -g @externalpipe-urlview-key 'u'

Reload Tmux.  You can find the following at the bottom of my
[.tmux.conf](https://github.com/iamFIREcracker/dotfiles/blob/master/.tmux.conf):

    # tmux-externalpipe
    set -g @externalpipe-cg-cmd      'cg-fzf'
    set -g @externalpipe-cg-key      'Enter'
    set -g @externalpipe-fpp-cmd     'fpp'
    set -g @externalpipe-fpp-key     'p'
    set -g @externalpipe-urlview-cmd 'urlview'
    set -g @externalpipe-urlview-key 'u'
    run-shell ~/.tmux-plugins/tmux-externalpipe/externalpipe.tmux
