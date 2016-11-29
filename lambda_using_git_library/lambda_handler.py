# coding: utf-8

from __future__ import print_function

import json

import dulwich
from dulwich import server
from dulwich import porcelain
from dulwich.repo import Repo

import git

print('Loading function')


def run(event, context):
    dulwich.client.get_ssh_vendor = git.KeyParamikoSSHVendor
    repo = porcelain.clone(
        "remote_repository",
        "/tmp/repo"
    )
    server.update_server_info(repo)
    with open("/tmp/repo/.git/info/refs") as r:
        print(r.read())
