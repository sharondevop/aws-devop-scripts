#!/bin/bash
# Replace PS1 /h in /etc/bashrc with $NICKNAME

# Patterns to find in the file '&&\sPS1="\[.u@.h\s'

# Check if need to replace the file.
if grep -q '&&\sPS1="\[.u@.$NICKNAME\s' /etc/bashrc ; then
   echo "\$NICKNAME  In place"
   exit 0
fi

#copy the original file  /etc/bashrc
if [ -e /etc/bashrc ]; then
        sudo cp /etc/bashrc /etc/bashrc.bak >&2
        #Substitutions using ed
        sudo ed -s /etc/bashrc  <<< $'H\n/&&\sPS1="\[.u@.h\s/s/h/$NICKNAME/\n,w' > /dev/null 2>&1
else
     echo ">>> ERROR /etc/bashrc file not found or you don't have permission to edit the file"
     exit 1
fi

# Setup hostname
#currhost=$(cat /etc/hostname)
#echo "Enter a hostname for this pi: "
#read newhost
#sudo sed -i "s/$currhost/$newhost/g" /etc/{hosts,hostname}