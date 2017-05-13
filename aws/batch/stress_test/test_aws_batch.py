# coding utf-8

import json

import aws_batch as batch


JOB_DEFINITION_INPUT = "./job_definition.json"
COMPUTE_ENVIRONMENT_INPUT = "./compute_environment.json"
JOB_QUEUE_INPUT = "./job_queue.json"


def test_aws_batch():
    with open(JOB_DEFINITION_INPUT) as f:
        config = json.loads(f.read())
        job_definition_name = config["jobDefinitionName"]
    with open(COMPUTE_ENVIRONMENT_INPUT) as f:
        config = json.loads(f.read())
        compute_environment_name = config["computeEnvironmentName"]
    with open(JOB_QUEUE_INPUT) as f:
        config = json.loads(f.read())
        job_queue_name = config["jobQueueName"]

    batch.destroy()

    assert not batch.job_definition_exists(job_definition_name)
    assert not batch.compute_environment_exists(compute_environment_name)
    assert not batch.job_queue_exists(job_queue_name)

    batch.deploy()

    assert batch.job_definition_exists(job_definition_name)
    assert batch.compute_environment_exists(compute_environment_name)
    assert batch.job_queue_exists(job_queue_name)

    batch.destroy()

    assert not batch.job_definition_exists(job_definition_name)
    assert not batch.compute_environment_exists(compute_environment_name)
    assert not batch.job_queue_exists(job_queue_name)
