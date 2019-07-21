#!/usr/bin/sh

exec 1>$HOME/xinit.log
exec 2>&1

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

# Apply .Xresources
xrdb $HOME/.Xresources

# 66-tools related
(.scandir &) &
sleep 01
66-all -v3 up

# Launch X, with power management privileges
exec ck-launch-session jwm
