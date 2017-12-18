# Backup all Instances volumes with with tag - Backup:Daily|daily in us-east-1 region

# standard library imports
import collections
import datetime
# related third party imports
import boto3

# service clients and resources.
session = boto3.session.Session(region_name='us-east-1', profile_name='tomerd')
# Any clients created from this session will use credentials
# from the [importer] section of ~/.aws/credentials.
#def lambda_handler(event, context):
# Amazon ec2 Low-level connection using session configuration.
ec2 = session.client('ec2')

# #  Get the current time
# t = datetime.time(1, 2, 3)
#  Get the current date
d = datetime.date.today()
formatdate = d.strftime('%d_%m_%Y')
# # Combine time and date
# timestemp = datetime.datetime.combine(d, t)

timestemp = datetime.datetime.today()
#print(timestemp)

# Create defaultdict as a list
to_tag = collections.defaultdict(list)

# Find the instances we’re backing up, use filter to find instance with tag - Backup:Daily|daily 
reservations = ec2.describe_instances(
    Filters=[
            {'Name': 'tag:Backup', 'Values': ['Daily', 'daily']},

        ]
    ).get('Reservations', [])


# Flatten the list of instances in every reservation,
# since a single reservation can contain huge blocks of instances.
instances = sum(
    [
        [i for i in r['Instances']]
        for r in reservations
    ], [])

# instances is a list of `instance` info from ec2.describe_instances()
for instance in instances:
    try:
# This code tries to read a “Retention” tag if it exists, and if not defaults to one week.
        retention_days = [
            int(t.get('Value')) for t in instance['Tags']
            if t['Key'] == 'Retention'][0]
    except IndexError:
        retention_days = 7

# Iterate over Instance and get volume id information. then create snapshots.
    for dev in instance['BlockDeviceMappings']:
        instance_name = {}
        if dev.get('Ebs', None) is None:
            # skip non-EBS volumes
            continue
        vol_id = dev['Ebs']['VolumeId']
        description = ("Daily snapshot of {} created by Lambda backup function ebs-snapshots on {}".format(vol_id, timestemp))
        device_name = dev.get('DeviceName')
        instance_tags = instance['Tags']
        for tag in instance_tags:
            if tag['Key'] == 'Name':
                instance_name = ('{}_{}_{}'.format((tag['Value']), device_name,formatdate))

        # Take the snapshot
        snap = ec2.create_snapshot(
            Description= description,
            VolumeId=vol_id,
         )
        # save the snapshot in a list with others in the same retention
        # time category
        to_tag[retention_days].append(snap['SnapshotId'])
        # Add Name tag to Snapshot
        snapshottag = ec2.create_tags(
            Resources=[snap['SnapshotId']],
            Tags=[{'Key': 'Name', 'Value': instance_name}]
        )
        # save the tags so the snapshots are deleted on time.
        for retention_days in to_tag.keys():
            # get the date X days in the future
            delete_date = d + datetime.timedelta(days=retention_days)
            # format the date as YYYY-MM-DD
            delete_fmt = delete_date.strftime('%Y-%m-%d')
            # Add Deletedate tag to Snapshot
            ec2.create_tags(
                Resources=to_tag[retention_days],
                Tags=[{'Key': 'DeleteOn', 'Value': delete_fmt}]
            )