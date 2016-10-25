# coding: utf-8

from __future__ import print_function

import os
import subprocess
import shutil

print('Loading function')


def run(event, context):
    root = os.path.abspath(os.path.join(__file__, ".."))

    os.environ["HOME"] = "/tmp"
    os.environ["GIT_EXEC_PATH"] = os.path.join(
        root, "usr/libexec/git-core"
    )
    os.environ["GIT_TEMPLATE_DIR"] = os.path.join(
        root, "usr/share/git-core/templates"
    )

    shutil.copy(os.path.join(root, "gitconfig"), "/tmp/.gitconfig")
    shutil.copy(os.path.join(root, "git-credentials"), "/tmp/git-credentials")

    path_to_git = os.path.join(root, "usr/bin/git")
    url = "https://github.com/shibataka000/snippets"
    path = "/tmp/snippets"

    cmd = "{} clone {} {}".format(path_to_git, url, path)

    p = subprocess.Popen(
        cmd,
        shell=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    p.wait()
    print("stdout:", p.stdout.readlines())
    print("stderr:", p.stderr.readlines())


if __name__ == "__main__":
    run(None, None)
