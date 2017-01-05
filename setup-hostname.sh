#!/bin/bash
################################################################################                                                                            
# setup linux OS name using new variable name NICKNAME.
# this allow us to save the underline hostname used.
# example:  ip-172-12-12-3.eu-west-1.compute.internal.
# This is intended to run on an Amazon EC2 instance and require sudo 
# permission and hostname argument supplied.
# Tested on Ubnutu and rhel.
# (c) 2017 Sharon Mafgaoker, all rights reserved; 
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
if [ -d /etc/profile.d ]; then
   echo "export NICKNAME=$HOSTNAME" > /etc/profile.d/prompt.sh
else
    echo "ERROR: /etc/profile.d directory  does not exist or you don't have permission to edit it"
    exit 7
fi

func_run_for_ubuntu(){
# Replace PS1 \h with $NICKNAME in every /home/username/.bashrc file
     for i in /home/*
     do
        if [ -e "$i/.bashrc" ]; then
            if ! grep -q '\\u@$NICKNAME' "$i/.bashrc"; then
                echo "\$NICKNAME does not exists in $i/.bashrc I'm going to create it."
       # backup the original file  /home/username/.bashrc , and replace \h with $NICKNAME
                sed -i.bak '/\u@\\h/s/\\h/$NICKNAME/g' "$i/.bashrc" > /dev/null
            fi
        else
            echo "ERROR: $i/.bashrc File does not exists or you don't have permission to edit the file"
        fi 
     done

 # Replace PS1 \h in /etc/bash.bashrc with $NICKNAME, substitutions using sed
     if [ -e /etc/bash.bashrc ]; then
         if ! grep -q '\\u@$NICKNAME' /etc/bash.bashrc; then
             echo "\$NICKNAME not exists in /etc/bash.bashrc, I'm going to create it."
       # backup the original file  /etc/bash.bashrc , and replace \h with $NICKNAME
             sed -i.bak '/PS1=/s/\\h/$NICKNAME/' /etc/bash.bashrc > /dev/null
         fi
            if ! grep -q '/etc/profile.d/prompt.sh' /etc/bash.bashrc; then
                echo "/etc/profile.d/prompt.sh not exists in  /etc/bash.bashrc, I'm going to add it."
       # Execute the shell scripts  /etc/profile.d/prompts.sh if the users shell is Login Shell.
                echo "# Execute the shell scripts /etc/profile.d/prompts.sh for Non-interactive  Shells." >> /etc/bash.bashrc
                echo ". /etc/profile.d/prompt.sh" >> /etc/bash.bashrc
            fi
     else 
         echo "ERROR: /etc/bash.bashrc File does not exists or you don't have permission to edit the file"
         exit 7
     fi

echo "You are ready to go, please logout to see the changes."
return 0
# Source env variable , to get immediate effect. not set for now.

}

func_run_for_rhel(){
# sets the terminal title to username@hostname: directory:
echo '''echo -ne "\033]0;${USER}@${NICKNAME}: ${PWD}\007"''' > /etc/sysconfig/bash-prompt-xterm
chmod +x /etc/sysconfig/bash-prompt-xterm

# Patterns to find in the file
# '&&\sPS1="\[.u@.h\s'
if grep -q '&&\sPS1="\[.u@.$NICKNAME\s' /etc/bashrc; then
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
echo "You are ready to go, please logout to see the changes."

return 0
}

# Getting the distribution name, checking for Ubuntu or Redhat.
UNAME=$(uname | tr "[:upper:]" "[:lower:]")
# If Linux, try to determine specific distribution
if [ "$UNAME" == "linux" ]; then
    # If available, use LSB to identify distribution
    if [ -f /etc/lsb-release -o -d /etc/lsb-release.d ]; then
         DISTRO=$(lsb_release -i | cut -d: -f2 | sed s/'^\t'// | tr "[:upper:]" "[:lower:]")
     
    elif [ -f /etc/os-release ]; then
         DISTRO=$(awk -F= '/^ID=/{print $2}' /etc/os-release | sed s/'"'//g)

    elif [ -f /etc/redhat-release ]; then
         DISTRO="rhel"
    else
         echo "ERROR: No linux distro found"; exit 7
    fi
fi
echo "$DISTRO found"

# check if Distro  Ubuntu or Redhat.
if [ "$DISTRO" == "ubuntu" ]; then
   func_run_for_ubuntu

elif [ "$DISTRO" == "rhel" ]; then
    func_run_for_rhel
else
   echo "ERROR: No Ubuntu found"; exit 7
fi
exit 0
