#!/usr/bin/bash

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

list=( $(ls -1 ${HOME}/.66/conf/boot-user) )
for i in ${list[@]};do
    var=$(<${HOME}/.66/conf/boot-user/${i})
    for j in ${var[@]}; do
		export ${j}
    done
done


66-all up
sleep 03

# Merge settings for Xterm.
xrdb $HOME/.Xresources

## Try consolekit
if 66-which -q ck-launch-session; then
	cmd="exec ck-launch-session $@"
else
	cmd="exec $@"
fi

${cmd} fluxbox