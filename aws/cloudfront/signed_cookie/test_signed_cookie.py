# coding: utf-8

import requests
import json
import subprocess
import datetime
import time

import boto3

CLOUDFRONT_KEY_PATH = './sk.pem'
CLOUDFRONT_KEY_PAIR_ID = 'APKAJNR3YMALBMFLTE2A'
CLOUDFRONT_URL = 'http://d2ldvv41dbsehy.cloudfront.net'

NUMBER_OF_FLAGS = 2


def get_cloudfront_policy(urls, expires):
    statement = []
    for url in urls:
        statement.append({
            'Resource': url,
            'Condition': {'DateLessThan': {'AWS:EpochTime': expires}},
        })
        policy = {'Statement': statement}
    return json.dumps(policy).replace(' ', '')


def get_cloudfront_policy_base64(url, expires):
    policy = get_cloudfront_policy(url, expires)
    cmd = ('echo \'{0}\' | tr -d "\\n" | openssl base64 |'
           'tr -- "+=/" "-_~"').format(policy)
    output = subprocess.check_output(cmd, shell=True)
    return ''.join(output.split('\n'))


def get_cloudfront_signature(url, expires,
                             key_path=CLOUDFRONT_KEY_PATH):
    policy = get_cloudfront_policy(url, expires)
    cmd = ('echo \'{0}\' | tr -d "\\n" | openssl sha1 -sign {1} |'
           ' openssl base64 | tr -- "+=/" "-_~"').format(policy, key_path)
    output = subprocess.check_output(cmd, shell=True)
    return ''.join(output.split('\n'))


def get_cloudfront_signed_cookie(url, expires):
    cloudfront_policy = get_cloudfront_policy_base64(url, expires)
    cloudfront_signature = get_cloudfront_signature(url, expires)

    return (
        'CloudFront-Signature={0};'
        'CloudFront-Policy={1};'
        'CloudFront-Key-Pair-Id={2};'
    ).format(
        cloudfront_signature,
        cloudfront_policy,
        CLOUDFRONT_KEY_PAIR_ID
    )


def setup():
    s3 = boto3.client("s3")
    s3.upload_file("./flag.txt", "sbtk-sample-bucket", "flag.txt")
    for i in range(NUMBER_OF_FLAGS):
        key = "flag{}.txt".format(i)
        s3.upload_file("./flag.txt", "sbtk-sample-bucket", key)


def test_flag_cannot_be_gotten_without_signed_cookie():
    url = '{0}/flag.txt'.format(CLOUDFRONT_URL)
    r = requests.get(url)
    assert r.status_code == 403


def test_flag_can_be_gotten_with_signed_cookie():
    urls = ['{0}/flag.txt'.format(CLOUDFRONT_URL)]
    now = datetime.datetime.now()
    expires = now + datetime.timedelta(days=1)
    expires_unixtime = int(time.mktime(expires.timetuple()))
    cookie = get_cloudfront_signed_cookie(urls, expires_unixtime)
    headers = {'Cookie': cookie}
    r = requests.get(urls[0], headers=headers)
    assert r.status_code == 200
    assert r.text.strip() == 'Catch the flag!'


def test_flag_can_be_gotten_with_multi_statement_signed_cookie():
    urls = ['{0}/flag{1}.txt'.format(CLOUDFRONT_URL, i)
            for i in range(NUMBER_OF_FLAGS)]
    now = datetime.datetime.now()
    expires = now + datetime.timedelta(days=1)
    expires_unixtime = int(time.mktime(expires.timetuple()))
    cookie = get_cloudfront_signed_cookie(urls, expires_unixtime)
    headers = {'Cookie': cookie}
    for url in urls:
        r = requests.get(url, headers=headers)
        assert r.status_code == 200
        assert r.text.strip() == 'Catch the flag!'
