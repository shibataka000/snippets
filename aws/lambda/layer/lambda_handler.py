import os
import sys
from samplemodule.sample import greet


def find_all_files(directory):
    for root, dirs, files in os.walk(directory):
        yield root
        for file in files:
            yield os.path.join(root, file)


def lambda_handler(event, context):
    greet()
    print(sys.path)
    for file_ in find_all_files("/opt"):
        print(file_)
