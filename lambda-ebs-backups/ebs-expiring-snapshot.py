# Query only the snapshots for your account , and delete expiring snapshots

# standard library imports
import datetime
# related third party imports
import boto3


def lambda_handler(event, context):
    delete_on = datetime.date.today().strftime('%Y-%m-%d')
    filters = [
        {'Name': 'tag-key', 'Values': ['DeleteOn']},
        {'Name': 'tag-value', 'Values': [delete_on]},
    ]
    
# figure out what day it is so we can filter for all the snapshots expiring today.
# Snapshots created by our EBS snapshot worker have a “DeleteOn” tag containing the YYYY-MM-DD formatted expiration date.
    ec2 = boto3.client('ec2')
    account_ids = ['1234']
    snapshot_response = ec2.describe_snapshots(OwnerIds=account_ids, Filters=filters)
# Now that we have the snapshots, deleting them is a simple loop over all the IDs.
    for snap in snapshot_response['Snapshots']:
        print("Deleting snapshot {}".format(snap['SnapshotId']))
        ec2.delete_snapshot(SnapshotId=snap['SnapshotId'])

