from __future__ import print_function
import os
import sys
import subprocess
import boto3

from botocore.client import Config

from dulwich.errors import (
    SendPackError,
    UpdateRefsError,
)
from dulwich.objectspec import (
    parse_object,
    parse_reftuples,
)
from contextlib import closing
from dulwich import porcelain
from dulwich.contrib.paramiko_vendor import ParamikoSSHVendor

import dulwich
import dulwich.repo
import paramiko
import paramiko.client


s3 = boto3.client('s3', config=Config(signature_version='s3v4'))


class KeyParamikoSSHVendor(object):

    def __init__(self):
        self.ssh_kwargs = {'key_filename': './ssh/id_rsa'}

    def run_command(self, host, command, username=None, port=None,
                    progress_stderr=None):
        if not isinstance(command, bytes):
            raise TypeError(command)
        if port is None:
            port = 22

        client = paramiko.SSHClient()

        policy = paramiko.client.MissingHostKeyPolicy()
        client.set_missing_host_key_policy(policy)
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        client.connect(host, username=username, port=port,
                       **self.ssh_kwargs)

        # Open SSH session
        channel = client.get_transport().open_session()

        # Run commands
        channel.exec_command(command)

        from dulwich.contrib.paramiko_vendor import (
            _ParamikoWrapper as ParamikoWrapper)
        return ParamikoWrapper(
            client, channel, progress_stderr=progress_stderr)
