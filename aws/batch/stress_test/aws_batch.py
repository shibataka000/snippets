# coding: utf-8

import json
import time
import logging

import boto3
import click


AWS_REGION_NAME = "us-east-1"

JOB_DEFINITION_INPUT = "./job_definition.json"
COMPUTE_ENVIRONMENT_INPUT = "./compute_environment.json"
JOB_QUEUE_INPUT = "./job_queue.json"

# logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)
logger.addHandler(logging.StreamHandler())


# Job Definition


def register_job_definition():
    with open(JOB_DEFINITION_INPUT) as f:
        config = json.loads(f.read())
    if job_definition_exists(config["jobDefinitionName"]):
        logger.info("Job definition \"{}\" already exists.".format(
            config["jobDefinitionName"]))
    else:
        client = boto3.client("batch", region_name=AWS_REGION_NAME)
        client.register_job_definition(**config)
        logger.info("Register job definition \"{}\".".format(
            config["jobDefinitionName"]))


def deregister_job_definition():
    with open(JOB_DEFINITION_INPUT) as f:
        config = json.loads(f.read())
    if job_definition_exists(config["jobDefinitionName"]):
        client = boto3.client("batch", region_name=AWS_REGION_NAME)
        jd_list = client.describe_job_definitions(
            jobDefinitionName=config["jobDefinitionName"],
            status="ACTIVE"
        )["jobDefinitions"]
        for jd in jd_list:
            job_definition_name = "{}:{}".format(
                jd["jobDefinitionName"],
                jd["revision"]
            )
            client.deregister_job_definition(
                jobDefinition=job_definition_name
            )
            logger.info("Deregister job definition \"{}\".".format(
                job_definition_name))
    else:
        logger.info("Job definition \"{}\" does not exists.".format(
            config["jobDefinitionName"]))


def job_definition_exists(job_definition_name):
    client = boto3.client("batch", region_name=AWS_REGION_NAME)
    jd_list = client.describe_job_definitions(
        jobDefinitionName=job_definition_name,
        status="ACTIVE"
    )["jobDefinitions"]
    return len(jd_list) >= 1


# Compute Environment


def create_compute_environment():
    with open(COMPUTE_ENVIRONMENT_INPUT) as f:
        config = json.loads(f.read())
    if compute_environment_exists(config["computeEnvironmentName"]):
        logger.info("Compute environment \"{}\" already exists.".format(
            config["computeEnvironmentName"]))
    else:
        client = boto3.client("batch", region_name=AWS_REGION_NAME)
        client.create_compute_environment(**config)
        wait_compute_environment_valid(config["computeEnvironmentName"])
        logger.info("Create compute environment \"{}\".".format(
            config["computeEnvironmentName"]))


def delete_compute_environment():
    with open(COMPUTE_ENVIRONMENT_INPUT) as f:
        config = json.loads(f.read())
    if compute_environment_exists(config["computeEnvironmentName"]):
        client = boto3.client("batch", region_name=AWS_REGION_NAME)
        client.update_compute_environment(
            computeEnvironment=config["computeEnvironmentName"],
            state="DISABLED"
        )
        wait_compute_environment_valid(config["computeEnvironmentName"])
        client.delete_compute_environment(
            computeEnvironment=config["computeEnvironmentName"]
        )
        wait_compute_environment_deleted(config["computeEnvironmentName"])
        logger.info("Delete compute environment \"{}\".".format(
            config["computeEnvironmentName"]))
    else:
        logger.info("Compute environment \"{}\" does not exist.".format(
            config["computeEnvironmentName"]))


def wait_compute_environment_valid(compute_environment_name):
    client = boto3.client("batch", region_name=AWS_REGION_NAME)
    while True:
        ce_list = client.describe_compute_environments(
            computeEnvironments=[compute_environment_name]
        )["computeEnvironments"]
        assert len(ce_list) == 1
        ce = ce_list[0]
        if ce["status"] == "VALID":
            break
        else:
            time.sleep(1)


def wait_compute_environment_deleted(compute_environment_name):
    while compute_environment_exists(compute_environment_name):
        time.sleep(1)


def compute_environment_exists(compute_environment_name):
    client = boto3.client("batch", region_name=AWS_REGION_NAME)
    ce_list = client.describe_compute_environments(
        computeEnvironments=[compute_environment_name]
    )["computeEnvironments"]
    return len(ce_list) >= 1


# Job Queue


def create_job_queue():
    with open(JOB_QUEUE_INPUT) as f:
        config = json.loads(f.read())
    if job_queue_exists(config["jobQueueName"]):
        logger.info("Job queue \"{}\" already exists.".format(
            config["jobQueueName"]))
    else:
        client = boto3.client("batch", region_name=AWS_REGION_NAME)
        client.create_job_queue(**config)
        wait_job_queue_valid(config["jobQueueName"])
        logger.info("Create job queue \"{}\".".format(
            config["jobQueueName"]))


def delete_job_queue():
    with open(JOB_QUEUE_INPUT) as f:
        config = json.loads(f.read())
    if job_queue_exists(config["jobQueueName"]):
        client = boto3.client("batch", region_name=AWS_REGION_NAME)
        client.update_job_queue(
            jobQueue=config["jobQueueName"],
            state="DISABLED"
        )
        wait_job_queue_valid(config["jobQueueName"])
        client.delete_job_queue(
            jobQueue=config["jobQueueName"]
        )
        wait_job_queue_deleted(config["jobQueueName"])
        logger.info("Delete job queue \"{}\".".format(
            config["jobQueueName"]))
    else:
        logger.info("Job queue \"{}\" does not exist.".format(
            config["jobQueueName"]))


def wait_job_queue_valid(job_queue_name):
    client = boto3.client("batch", region_name=AWS_REGION_NAME)
    while True:
        jq_list = client.describe_job_queues(
            jobQueues=[job_queue_name]
        )["jobQueues"]
        assert len(jq_list) == 1
        jq = jq_list[0]
        if jq["status"] == "VALID":
            break
        else:
            time.sleep(1)


def wait_job_queue_deleted(job_queue_name):
    while job_queue_exists(job_queue_name):
        time.sleep(1)


def job_queue_exists(job_queue_name):
    client = boto3.client("batch", region_name=AWS_REGION_NAME)
    jq_list = client.describe_job_queues(
        jobQueues=[job_queue_name]
    )["jobQueues"]
    return len(jq_list) >= 1


# Command


@click.group()
def cli():
    pass


@cli.command()
def deploy():
    create_compute_environment()
    create_job_queue()
    register_job_definition()


@cli.command()
def destroy():
    deregister_job_definition()
    delete_job_queue()
    delete_compute_environment()


if __name__ == "__main__":
    cli()
