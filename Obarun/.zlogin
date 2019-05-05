# Don't do autologin (harmful if we're experimenting with WM's,
# e.g. there's an error in .xinitrc.)

#if [[ -z $DISPLAY ]] && (( $EUID != 0 )) {
#    [[ ${TTY/tty} != $TTY ]] && (( ${TTY:8:1} <= 3 )) &&
#        startx &
#}

# Display a quote from the Dhammapada.
echo
echo
echo
echo
fortune dhammapada 
echo "---------------------------------------------------------------------------------------------------"
