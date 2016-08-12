# coding: utf-8

import boto3

client = boto3.client("ec2")

image_id = "ami-a21529cc"
instance_type = "t2.micro"
keypair_name = "shibataka000-key-pair-ap-northeast-1"
secgroup_id = "sg-121b1a77"
stop_after = 1
userdata = """#!/bin/sh -v
echo "Hello World!" > ~/hello_world.txt
echo "shutdown -h now" | at now + {0}minutes
""".format(stop_after)

resp = client.run_instances(
    ImageId=image_id,
    MinCount=1,
    MaxCount=1,
    InstanceType=instance_type,
    KeyName=keypair_name,
    UserData=userdata,
    InstanceInitiatedShutdownBehavior="terminate",
    SecurityGroupIds=[secgroup_id]
)

instance_id = resp["Instances"][0]["InstanceId"]
print("Launched instance : {0}".format(instance_id))
