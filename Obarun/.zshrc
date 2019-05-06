# .zshrc
# Author: Piotr Karbowski <piotr.karbowski@gmail.com>
# License: ISC.
# modified by : Eric vidal <eric@obarun.org> for Obarun OS

# Basic zsh config.

ZDOTDIR=${ZDOTDIR:-${HOME}}
ZSHDDIR="${HOME}/.config/zsh.d"
HISTFILE="${ZDOTDIR}/.zsh_history"
HISTSIZE='10000'
SAVEHIST="${HISTSIZE}"
export EDITOR="/usr/bin/mcedit"

## can be useful :)
#source /usr/lib/obarun/common_functions

TMP=${HOME}/tmp
if [ ! -d "${TMP}" ]; then mkdir -m1777 "${TMP}"; fi

# Colors.
red='\e[0;31m'
RED='\e[1;31m'
green='\e[0;32m'
GREEN='\e[1;32m'
yellow='\e[0;33m'
YELLOW='\e[1;33m'
blue='\e[0;34m'
BLUE='\e[1;34m'
purple='\e[0;35m'
PURPLE='\e[1;35m'
cyan='\e[0;36m'
CYAN='\e[1;36m'
NC='\e[0m'

# Functions
if [ -f '/etc/profile.d/prll.sh' ]; then
    . "/etc/profile.d/prll.sh"
fi

function reload() {
	if [[ "$#*" -eq 0 ]]; then
		test -r ~/.zshrc && . ~/.zshrc
		return 0
	else
		local fn
		for fn in $*; do
			unfunction $fn
			autoload -U $fn
		done
	fi
}

fkill() {
  local pid
  pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')

  if [ "x$pid" != "x" ]
  then
    echo $pid | xargs kill -${1:-9}
  fi
}

fshow() {
  git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
      --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
FZF-EOF"
}

search_in_file() {
	local search="${1}"
	for i in $(find);do
		if grep -qns "${search}" $i; then
			printf "found in : ${GREEN}%s${NC}\n" $i
			grep -n "${search}" $i
			printf "\n"
		fi
	done
}

over_ssh() {
    if [ -n "${SSH_CLIENT}" ]; then
        return 0
    else
        return 1
    fi
}

reload() {
	if [[ "$#*" -eq 0 ]]; then
		test -r ~/.zshrc && . ~/.zshrc
		return 0
	else
		local fn
		for fn in $*; do
			unfunction $fn
			autoload -U $fn
		done
	fi
}

confirm() {
    local answer
    echo -ne "zsh: sure you want to run '${YELLOW}$*${NC}' [yN]? "
    read -q answer
        echo
    if [[ "${answer}" =~ ^[Yy]$ ]]; then
        command "${@}"
    else
        return 1
    fi
}

confirm_wrapper() {
    if [ "$1" = '--root' ]; then
        local as_root='true'
        shift
    fi

    local prefix=''

    if [ "${as_root}" = 'true' ] && [ "${USER}" != 'root' ]; then
        prefix="sudo"
    fi
    confirm ${prefix} "$@"
}
escape() {
    # Uber useful when you need to translate weird as fuck path into single-argument string.
    local escape_string_input
    echo -n "String to escape: "
    read escape_string_input
    printf '%q\n' "$escape_string_input"
}

confirm() {
    local answer
    echo -ne "zsh: sure you want to run '${YELLOW}$*${NC}' [yN]? "
    read -q answer
        echo
    if [[ "${answer}" =~ ^[Yy]$ ]]; then
        command "${@}"
    else
        return 1
    fi
}

poweroff() { confirm_wrapper --root $0 "$@"; }
reboot() { confirm_wrapper --root $0 "$@"; }
hibernate() { confirm_wrapper --root $0 "$@"; }

detox() {
    if [ "$#" -ge 1 ]; then
        confirm detox "$@"
    else    
        command detox "$@"
    fi
}

has() {
    local string="${1}"
    shift
    local element=''
    for element in "$@"; do
        if [ "${string}" = "${element}" ]; then
            return 0
        fi
    done
    return 1
}

begin_with() {
    local string="${1}"
    shift
    local element=''
    for element in "$@"; do
        if [[ "${string}" =~ "^${element}" ]]; then
            return 0
        fi
    done
    return 1

}

termtitle() {
    case "$TERM" in
        rxvt*|xterm|nxterm|gnome|screen|screen-*)
            local prompt_host="${(%):-%m}"
            local prompt_user="${(%):-%n}"
            local prompt_char="${(%):-%~}"
            case "$1" in
                precmd)
                    printf '\e]0;%s@%s: %s\a' "${prompt_user}" "${prompt_host}" "${prompt_char}"
                ;;
                preexec)
                    printf '\e]0;%s [%s@%s: %s]\a' "$2" "${prompt_user}" "${prompt_host}" "${prompt_char}"
                ;;
            esac
        ;;
    esac
}

git_check_if_worktree() {
    # This function intend to be only executed in chpwd().
    # Check if the current path is in git repo. 

    # We would want stop this function, on some big git repos it can take some time to cd into.
    if [ -n "${skip_zsh_git}" ]; then
        git_pwd_is_worktree='false'
        return 1
    fi
    # The : separated list of paths where we will run check for git repo.
    # If not set, then we will do it only for /root and /home.
    if [ "${UID}" = '0' ]; then
        # running 'git' in repo changes owner of git's index files to root, skip prompt git magic if CWD=/home/*
        git_check_if_workdir_path="${git_check_if_workdir_path:-/root:/etc}"
    else
        git_check_if_workdir_path="${git_check_if_workdir_path:-/home}"
        git_check_if_workdir_path_exclude="${git_check_if_workdir_path_exclude:-${HOME}/_sshfs}"
    fi

    if begin_with "${PWD}" ${=git_check_if_workdir_path//:/ }; then
        if ! begin_with "${PWD}" ${=git_check_if_workdir_path_exclude//:/ }; then
            local git_pwd_is_worktree_match='true'
        else
            local git_pwd_is_worktree_match='false'
        fi
    fi

    if ! [ "${git_pwd_is_worktree_match}" = 'true' ]; then
        git_pwd_is_worktree='false'
        return 1
    fi

    # todo: Prevent checking for /.git or /home/.git, if PWD=/home or PWD=/ maybe...
    #   damn annoying RBAC messages about Access denied there.
    if [ -d '.git' ] || [ "$(git rev-parse --is-inside-work-tree 2> /dev/null)" = 'true' ]; then
        git_pwd_is_worktree='true'
        git_worktree_is_bare="$(git config core.bare)"
    else
        unset git_branch git_worktree_is_bare
        git_pwd_is_worktree='false'
    fi
}

git_branch() {
    git_branch="$(git symbolic-ref HEAD 2>/dev/null)"
    git_branch="${git_branch##*/}"
    git_branch="${git_branch:-no branch}"
}

git_dirty() {
    if [ "${git_worktree_is_bare}" = 'false' ] && [ -n "$(git status --untracked-files='no' --porcelain)" ]; then
        git_dirty='%F{green}*'
    else
        unset git_dirty
    fi
}

precmd() {
    # Set terminal title.
    termtitle precmd

    if [ "${git_pwd_is_worktree}" = 'true' ]; then
        git_branch
        git_dirty
            
        git_prompt=" %F{blue}[%F{253}${git_branch}${git_dirty}%F{blue}]"
    else
        unset git_prompt
    fi

# Maybe to be used someday, too annoying with vim and other interactive apps.
#   # $REPORTTIME is about cpu time, not real time.
#   if [ "${executed_on}" ]; then
#       local current_timestamp=${(%):-'%D{%s}'}
#       local last_cmd_took=$(( current_timestamp - executed_on ))
#       if [ "${last_cmd_took}" -gt 60 ]; then
#           printf "\n>>> [INFO] Execution took %ss\n\n" "$last_cmd_took"
#       fi
#       unset executed_on
#   fi
}

preexec() {
    # Set terminal title along with current executed command pass as second argument
    termtitle preexec "${(V)1}"

#   # Save timestamp when we executed this command
#   executed_on=${(%):-'%D{%s}'}
}

chpwd() {
    git_check_if_worktree
}

man() {
    if command -v vimmanpager >/dev/null 2>&1; then
        PAGER="vimmanpager" command man "$@"
    else
        command man "$@"
    fi
}


# Check if we started zsh in git worktree, useful with tmux when your new zsh may spawn in source dir.
git_check_if_worktree
if [ "${git_pwd_is_worktree}" = 'true' ]; then
    git_branch
    git_dirty
    git_prompt=" %F{blue}[%F{253}${git_branch}${git_dirty}%F{blue}]"
else
    unset git_prompt
fi

dot_progress() {
    # Fancy progress function from Landley's Aboriginal Linux.
    # Useful for long rm, tar and such.
    # Usage: 
    #     rm -rfv /foo | dot_progress
    local i='0'
    local line=''

    while read line; do
        i="$((i+1))"
        if [ "${i}" = '25' ]; then
            printf '.'
            i='0'
        fi
    done
    printf '\n'
}


# Le features!
# extended globbing, awesome!
setopt extendedGlob

# zmv -  a command for renaming files by means of shell patterns.
autoload -U zmv

# zargs, as an alternative to find -exec and xargs.
autoload -U zargs

# Turn on command substitution in the prompt (and parameter expansion and arithmetic expansion).
setopt promptsubst

# Control-x-e to open current line in $EDITOR, awesome when writting functions or editing multiline commands.
autoload -U edit-command-line
zle -N edit-command-line

# Include user-specified configs.
if [ ! -d "${ZSHDDIR}" ]; then
    mkdir -p "${ZSHDDIR}" && echo "# Put your user-specified config here." > "${ZSHDDIR}/example.zsh"
fi

for zshd in $(ls -A ${HOME}/.config/zsh.d/^*.(z)sh$); do
    . "${zshd}"
done

# Completion.
autoload -Uz compinit
compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' completer _expand _complete _ignored _approximate
zstyle ':completion:*' menu select=2
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion:*:descriptions' format '%U%F{cyan}%d%f%u'
zstyle ':completion:*' rehash true

# If running as root and nice >0, renice to 0.
if [ "$EUID" = "0" ] && [ "$(cut -d ' ' -f 19 /proc/$$/stat)" -gt 0 ]; then
    renice -n 0 -p "$$" && echo "# Adjusted nice level for current shell to 0."
fi

# Fancy prompt.
if over_ssh && [ -z "${TMUX}" ]; then
    prompt_is_ssh='%F{blue}[%F{red}SSH%F{blue}] '
elif over_ssh; then
    prompt_is_ssh='%F{blue}[%F{253}SSH%F{blue}] '
else
    unset prompt_is_ssh
fi

case $EUID in
    0)
        PROMPT='%B%F{red}%n@%m%k %(?..%F{blue}[%F{red}%?%F{blue}] )${prompt_is_ssh}%B%F{blue}%1~${git_prompt}%F{blue} %# %b%f%k'
    ;;

    *)  
        PROMPT='%B%F{blue}%n@%m%k %(?..%F{blue}[%F{red}%?%F{blue}] )${prompt_is_ssh}%B%F{cyan}%1~${git_prompt}%F{cyan} %# %b%f%k'

    ;;
esac

# Ignore lines prefixed with '#'.
setopt interactivecomments

# Ignore duplicate in history.
setopt hist_ignore_dups

# Prevent record in history entry if preceding them with at least one space
setopt hist_ignore_space

# Nobody need flow control anymore. Troublesome feature.
#stty -ixon
setopt noflowcontrol

# Fix for tmux on linux.
case "$(uname -o)" in
    'GNU/Linux')
        export EVENT_NOEPOLL=1
    ;;
esac

# Another tmux fix (some terminal emulators, textadept-curses).
stty ek

# Aliases
alias sudo='sudo '
alias cp='cp -iv'
alias rcp='rsync -v --progress'
alias rmv='rsync -v --progress --remove-source-files'
alias mv='mv -iv'
alias rm='rm -iv'
alias rmdir='rmdir -v'
alias ln='ln -v'
alias chmod="chmod -c"
alias chown="chown -c"


if command -v colordiff > /dev/null 2>&1; then
    alias diff="colordiff -Nuar"
else
    alias diff="diff -Nuar"
fi

alias grep='grep --colour=auto'
alias egrep='egrep --colour=auto'
alias ls='ls --color=auto --human-readable --group-directories-first --classify'
##replace mygpg by your own
alias sign='gpg --detach-sign --use-agent -u mygpg --no-armor' 
alias pkg='f(){sudo pacman -$@;unset -f f;};f'

alias obarun-adios='obshutdown -c $HOME/.config/obshut/exit.rc --run=shutdown'
alias obarun-hasta-luego='obshutdown -c $HOME/.config/obshut/exit.rc --run=restart'
alias obarun-vengo-ahorita='obshutdown -c $HOME/.config/obshut/exit.rc --run=logout'

##Binkey

bindkey -e

bindkey '^[[H' beginning-of-line # home key
bindkey '^[[F'  end-of-line # end key

bindkey '^[[3~' delete-char # del key

bindkey '^U' backward-kill-line # control + u
bindkey "^H" backward-kill-word # control + backspace

bindkey "^[[A" history-beginning-search-backward # search history from given command
bindkey "^[[B" history-beginning-search-forward # search history from given command

bindkey -s '^[S' '^Asudo ^E' # alt + shift + s add sudo at the beginning of the line

bindkey '^[[1;5D' backward-word # control + left arrow
bindkey '^[[1;5C' forward-word # control + right arrow

bindkey "^R" history-incremental-pattern-search-backward 
bindkey "^S" history-incremental-pattern-search-forward
bindkey "^X^E" edit-command-line

# Backspace stops working here - we'd have to fix it.
# Launch tmux automatically when opening a shell in a graphical environment.
#if [[ $DISPLAY ]]; then
#	# If not running interactively, do not do anything
#	[[ $- != *i* ]] && return 
#	[[ -z "$TMUX" ]] && exec tmux
#fi

export PATH=$PATH:$HOME/.bin