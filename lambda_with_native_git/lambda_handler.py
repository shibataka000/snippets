# coding: utf-8

from __future__ import print_function

import os
import subprocess

print('Loading function')


def run(event, context):
    root = os.path.abspath(os.path.join(__file__, ".."))
    os.environ["GIT_EXEC_PATH"] = os.path.join(root, "usr/lib/git-core")
    os.environ["GIT_TEMPLATE_DIR"] = os.path.join(
        root, "usr/share/git-core/templates"
    )
    git = os.path.join(root, "usr/bin/git")

    url = "git://github.com/shibataka000/snippets"
    path = "/tmp/snippets"

    cmd = "{} clone {} {}".format(git, url, path)
    p = subprocess.Popen(
        cmd,
        shell=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    print(p.wait())
    print(p.stdout.readlines())
    print(p.stderr.readlines())


if __name__ == "__main__":
    run(None, None)
