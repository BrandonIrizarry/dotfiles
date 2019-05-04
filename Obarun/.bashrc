#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export TERM=xterm-256color
alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '
