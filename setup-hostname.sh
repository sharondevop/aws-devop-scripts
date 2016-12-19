#!/bin/bash
################################################################################                                                                            
# setup linux OS name using new variable name NICKNAME.
# this allow us to save the underline hostname used.
# example:  ip-172-12-12-3.eu-west-1.compute.internal.
# This is intended to run on an Amazon EC2 instance and require sudo 
# permission and hostname argument supplied.
# (c) 2016 Sharon Mafgaoker, all rights reserved; 
# You are free to use, modify and redistribute this software in any form
# under the conditions described in the LICENSE file included.
#################################################################################

# Function for checking if script running as root, if not terminating.
func_check_for_root() {
        if [ ! $( id -u ) -eq "0" ]; then
            echo "ERROR: $0 Must be run as root, Script terminating."; exit 7
        fi
    }
    func_check_for_root

# Check existence of input argument.
if [ "$#" -eq "0" ] ; then
    echo "ERROR: No hostname argument supplied, Script terminating."; exit 7
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
# Replace PS1 h in /etc/bashrc with $NICKNAME ,substitutions using sed
if [ -e /etc/bashrc ]; then
      sed -i.bak '/&&\sPS1="\[.u@.h\s/s/h/$NICKNAME/' /etc/bashrc > /dev/null 
else
     echo "ERROR: /etc/bashrc File does not exist or you don't have permission to edit the file"
     exit 1
fi