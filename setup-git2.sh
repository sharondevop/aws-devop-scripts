#!/bin/bash
################################################################################                                                                            
# Date: 01/2/17
# Install Git2u using IUS repo
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

# Funcation for installing Git2
func_install_git() {
	# Download IUS Community Repository Shell script
	curl 'https://setup.ius.io/' -o setup-ius.sh
	# Install/Enable IUS Community Repositorya
	sudo sh setup-ius.sh
	# Remove old git
	sudo yum -y remove git
	# install  git
	sudo yum -y  --enablerepo=ius install git2u
	sudo yum -y install bash-completion
	rm setup-ius.sh

exit 0
}

# Getting the distribution name, checking for Ubuntu or Redhat.
UNAME=$(uname | tr "[:upper:]" "[:lower:]")
# If Linux, try to determine specific distribution
if [ "$UNAME" == "linux" ]; then
    if [ -f /etc/redhat-release ]; then
         DISTRO="rhel"
    # If available, use LSB to identify distribution
    elif [ -f /etc/lsb-release -o -d /etc/lsb-release.d ]; then
         DISTRO=$(lsb_release -i | cut -d: -f2 | sed s/'^\t'// | tr "[:upper:]" "[:lower:]")

    elif [ -f /etc/os-release ]; then
         DISTRO=$(awk -F= '/^ID=/{print $2}' /etc/os-release | sed s/'"'//g)

    else
         echo "ERROR: No linux distro found"; exit 7
    fi
fi
echo "$DISTRO found"

# check if Distro  Ubuntu or Redhat.
if [ "$DISTRO" == "ubuntu" ]; then
   echo "ERROR: No rhel found"; exit 7

elif [ "$DISTRO" == "rhel" -o "$DISTRO" == "redhatenterpriseserver" ]; then
    func_install_git
fi
exit 0
