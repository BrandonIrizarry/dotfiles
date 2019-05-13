#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Export environment variables.
export TERM=xterm-256color
export EDITOR="/usr/local/bin/textadept-curses"
export PATH=$PATH:$HOME/.bin

alias ls='ls --color=auto --human-readable --group-directories-first --classify'
PS1='[\u@\h \W]\$ '

alias sudo='sudo '
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'
alias rmdir='rmdir -v'
alias ln='ln -v'
alias chmod='chmod -c'
alias chown='chown -c'

# Application aliases
alias obarun-shutdown='obshutdown -c $HOME/.config/obshut/exit.rc --run=shutdown'
alias obarun-restart='obshutdown -c $HOME/.config/obshut/exit.rc --run-restart'
alias obarun-logout='obshutdown -c $HOME/.config/obshut/exit.rc --run=logout'
alias mpv='mpv --save-position-on-quit'