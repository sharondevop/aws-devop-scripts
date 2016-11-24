#!/bin/bash

################################################################################                                                                               
# Send memory usage and disk metrics to Amazon CloudWatch
#  
# This is intended to run on an Amazon EC2 instance and requires an IAM
# role allowing to write CloudWatch metrics. Alternatively, you can create
# a credentials file and rely on it instead. 
# (c) 2016 Sharon Mafgaoker, all rights reserved; 
# You are free to use, modify and redistribute this software in any form
# under the conditions described in the LICENSE file included.
################################################################################

