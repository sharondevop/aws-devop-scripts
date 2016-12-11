#!/bin/bash
# Replace PS1 /h with $NICKNAME

# Patterns to find in the file
pattern='&&\sPS1="\[.u@.h\s'

# Pattern to be replaced
replace="\$NICKNAME"
echo "$replace"
grep --color  "$pattern" /etc/bashrc

ed  /home/ec2-user/bashrch_copy <<< '/\$pattern/s/h/t/'