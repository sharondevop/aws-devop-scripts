###############################
# This scrip will send message
# to aws SNS service
###############################
import datetime
import boto3

# Get the current date and time
#now = datetime.datetime.now()

# Create an SNS client
#boto3.session.Session(profile_name='crond')
client = boto3.client('sns',region_name='eu-west-1')

# Publish a message
response = client.publish(
            TopicArn='',
            Message='Cron service is running')
#print("running = %s" % now)
