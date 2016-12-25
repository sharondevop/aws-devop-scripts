#!/usr/bin/python

######################################################################################                                                                            
# psmonitor can act if an error situation should occur, e.g.; if crond is not running
# psmonitor can start crond again automatically and send you an alert message. 
#  
# This is intended to run on an Amazon EC2 instance and requires an IAM
# role allowing to write CloudWatch metrics. Alternatively, you can create
# a credentials file and rely on it instead. 
# (c) 2016 Sharon Mafgaoker, all rights reserved; 
# You are free to use, modify and redistribute this software in any form
# under the conditions described in the LICENSE file included.
######################################################################################

import os
import subprocess

# Set program.pid file location.
file_pid = "/var/run/crond.pid"
# Set program name to check_service.
prog_name = "crond"

# Function definition, to run checks to determine if the program_file exists and PID exists and running.
def check_prog(pidfile):
        try:
            # create file object with variable 'file'
            with open(pidfile) as file:
             # read program pid number, and remove trailing
             pid = (file.readline().rstrip())
             # checking if pid exists and running.
             pid_running = (os.path.isdir('/proc/%s/task' % pid))
        # Errors detected during execution.
        except (IOError, NameError, OSError) as err:
            # print error to log file
            print(err)
            return False
        else:
            # Return False if pid not running, Retrun True if pid is running.
            return pid_running

# Evaluating if check_service is True,if not restart program.
def status(program):
    if check_prog(file_pid):
       # Write to log Service is up
       #print("is True")
       return 1
    else:
        # Restart program
        subprocess.call('sudo /sbin/service %s restart' % program,  shell=True)
        # Write to log & send Email for the action.
        #print("is not True")
        return 0

# Run check status function.
if status(prog_name):
    print("all good")
else:
    print("problem")
#print(status(prog))