#!/bin/bash
# the script set ec2-instance name using new variable name NICKNAME.
# this allow us to save the underline hostname used.

# Function for checking if script running as root, if not terminating.
func_check_for_root() {
        if [ ! $( id -u ) -eq "0" ]; then
            echo "ERROR: $0 Must be run as root, Script terminating."; exit 7
        fi
    }
    func_check_for_root

# Check existence of input argument.
if [ "$#" -eq "0" ] ; then
    echo "ERROR: No hostname arguments supplied, Script terminating."; exit 7
fi

# set the name
HOSTNAME="$1"
echo "export NICKNAME=$HOSTNAME" > /etc/profile.d/prompt.sh

# sets the terminal title to username@hostname: directory:
echo '''echo -ne "\033]0;${USER}@${NICKNAME}: ${PWD}\007"''' > /etc/sysconfig/bash-prompt-xterm
chmod +x /etc/sysconfig/bash-prompt-xterm

# Patterns to find in the file
# '&&\sPS1="\[.u@.h\s'
if grep -q '&&\sPS1="\[.u@.$NICKNAME\s' /etc/bashrc; then
   echo "\$NICKNAME  In place"
   exit 0
fi

# backup the original file  /etc/bashrc
if [ -e /etc/bashrc ]; then
      cp /etc/bashrc /etc/bashrc.bak >&2
       # Replace PS1 h in /etc/bashrc with $NICKNAME ,substitutions using ed
      ed -s /etc/bashrc  <<< $'H\n/&&\sPS1="\[.u@.h\s/s/h/$NICKNAME/\n,w' > /dev/null 2>&1
else
     echo "ERROR: /etc/bashrc File does not exist or you don't have permission to edit the file"
     exit 1
fi