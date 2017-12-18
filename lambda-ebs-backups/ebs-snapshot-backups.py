# standard library imports
import datetime

# related third party imports
import boto3

# service clients and resources.
session = boto3.session.Session(region_name='us-east-1', profile_name='tomerd')
# Any clients created from this session will use credentials
# from the [importer] section of ~/.aws/credentials.

# Amazon ec2 Low-level connection using session configuration.
ec2 = session.client('ec2')

# #  Get the current time
# t = datetime.time(1, 2, 3)
# #  Get the current date
# d = datetime.date.today()
# # Combine time and date
# timestemp = datetime.datetime.combine(d, t)

timestemp = datetime.datetime.today()
#print(timestemp)

# Find the instances we’re backing up, use filter to find instance with tag - Backup:Daily|daily 
reservations = ec2.describe_instances(
    Filters=[
            {'Name': 'tag:Backup', 'Values': ['Daily', 'daily']},

        ]
    ).get('Reservations', [])

#print(reservations)

# Flatten the list of instances in every reservation,
# since a single reservation can contain huge blocks of instances.
instances = sum(
    [
        [i for i in r['Instances']]
        for r in reservations
    ], [])

# print("Found {} instances that need backing up".format(len(instances)))
# Iterate over Instance and get volume id information. then create snapshots.
for instance in instances:
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
               instance_name = ('{}_{}'.format((tag['Value']), device_name))
#        print(instance_name)
#        print(description)
#        print('Found EBS volume {} on instance {}'.format(
#            vol_id, instance['InstanceId'])

        # Create Snapshot
        snap = ec2.create_snapshot(
            Description= description,
            VolumeId=vol_id,
        )        
        # Add Name tag to Snapshot
        snapshottag = ec2.create_tags(
            Resources=[snap['SnapshotId']],
            Tags=[{'Key': 'Name', 'Value': instance_name}]
        )

        print(snap['SnapshotId'])