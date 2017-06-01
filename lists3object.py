#!/usr/bin/python

# create a list bucket key  , and save it a file with timedate.

# standard library imports
import os
from datetime import datetime

# related third party imports
import boto3
import botocore

# Dynamic variables
bucket_id = "imported.anima"  # bucket name i will work on.
current_datetime = datetime.now().strftime("%Y%m%d-%H-%M")      # timedate format "20161227-12-14"
filename_format = "/Users/sharon/tempfile/%s_list_%s.txt" % (bucket_id, current_datetime)     # format filename, used for saving bucket list.
prefix_name = ""                                              # S3 list all keys by folder prefix, if empty list all keys.

# Regions list: http://docs.aws.amazon.com/general/latest/gr/rande.html
# A session stores configuration state and allows you to create
# service clients and resources.
session = boto3.session.Session(region_name='eu-west-1', profile_name='importer')
# Any clients created from this session will use credentials
# from the [importer] section of ~/.aws/credentials.

# Amazon S3 High-level connection using session configuration.
s3 = session.resource('s3')

# Iterable of all ObejectSummary resource in bucket , filter by prefix.

# def

# create a Bucket resource.
bucket = s3.Bucket(bucket_id)
try:
    s3.meta.client.head_bucket(Bucket=bucket_id)   # validate bucket: exists, we have permission to list objects.
    with open(filename_format, 'w+') as myfile:
         object_summary = bucket.objects.filter(Prefix=prefix_name)
         for obj in object_summary:
	     #print (obj.key)
             myfile.write(os.path.basename(obj.key)) # The basename of '/foo/key' returns 'key' , E.g.: the tail of the path.
             myfile.write('\n') # write new line
except botocore.exceptions.ClientError as err:
      print( "%s :Bucket name - %s." % (err, bucket_id))
