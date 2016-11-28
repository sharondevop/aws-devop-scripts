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
#!/bin/bash

# select the local disk on wich to report to Cloudwatch, we pass the mount point as parameters.
DISKPATH=$(df -l --type={xfs,ext4} | grep ^/dev | awk '{print "--disk-path="$6 }' | paste -sd ' ')
# Crontask command add to  ec2-user crontab
CRONTASK="*/5 * * * * /opt/aws-scripts-mon/mon-put-instance-data.pl --mem-util --mem-used --mem-avail --disk-space-util  $DISKPATH  --from-cron"
# Tell Cronjob where to save the crontask
CRONFILE="/var/spool/cron/ec2-user"

echo "--> Testing if "$CRONFILE" exists ,if not I will create it for you."
sudo test -e "$CRONFILE"
if [ "$?" -eq 0  ]
then
     echo "--> You have a "$CRONFILE" file. Things are fine."

else
     echo "--> No file found, I am now  creating  ec2-user crontask file in here "$CRONFILE"."
     sudo touch "$CRONFILE"  # create the file
     sudo chmod 600 "$CRONFILE" # set rw permissions
     sudo chown ec2-user:ec2-user "$CRONFILE" # update owner and group
fi

####################################################################
echo "--> Installing Prerequsite package for cloudwatch monitor"
sudo yum install perl-Switch perl-DateTime perl-Sys-Syslog perl-LWP-Protocol-https perl-Digest-SHA -y
sudo yum install perl-IO-Socket-SSL -y
sudo yum install zip unzip -y
sudo curl -L https://raw.githubusercontent.com/miyagawa/cpanminus/master/cpanm | perl - App::cpanminus
sudo /home/ec2-user/perl5/bin/cpanm LWP::Protocol::https
sudo /home/ec2-user/perl5/bin/cpanm Switch


##################################################
echo "--> Cleaning cpanm files"
sudo rm -rf /home/ec2-user/.cpanm/
sudo rm -rf /home/ec2-user/.cpan/
sudo rm -rf /home/ec2-user/perl5/


##################################################
echo "--> Downloading, install, and configure the script"
sudo curl http://aws-cloudwatch.s3.amazonaws.com/downloads/CloudWatchMonitoringScripts-1.2.1.zip -O
sudo unzip -o  CloudWatchMonitoringScripts-1.2.1.zip -d /opt
sudo rm -f CloudWatchMonitoringScripts-1.2.1.zip


# Checking if awscreds.conf exists , if exists createing a  backup
if [ -f /opt/aws-scripts-mon/awscreds.conf ]; then
 	sudo  mv /opt/aws-scripts-mon/awscreds.conf /opt/aws-scripts-mon/awscreds.bak
fi

# Checking if awscreds.sample exists , if exists rename it awscreds.conf
if [ -f /opt/aws-scripts-mon/awscreds.template ]; then
 	sudo  mv /opt/aws-scripts-mon/awscreds.template /opt/aws-scripts-mon/awscreds.conf
else
   	echo "awscreds.template not exists, please set awscreds key if you are not using AMI role"
fi

# Test that communication to Cloudwatch works , and  set a cronjob  schedule for metrics reported to CloudWatch
/opt/aws-scripts-mon/mon-put-instance-data.pl --mem-util --verify --verbose
if [ $? -eq 0 ]
then
     	echo "Test OK, I'm now configure cronjob for ec2-user , with the following command, to  run every 5 minute."
else
   	echo "Faild to test communication to Cloudwatch" >&2
fi
# set a cronjob  schedule for metrics reported to CloudWatch
if [ "$(sudo grep -c "/opt/aws-scripts-mon/mon-put-instance-data.pl" "$CRONFILE")" -eq 0 ]
then
	echo "$CRONTASK" | sudo tee -a "$CRONFILE"
else
   	echo "Crontask exists" >&2
fi
