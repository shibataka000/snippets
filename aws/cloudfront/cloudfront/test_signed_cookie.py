# coding: utf-8

import requests
import json
import subprocess
import datetime
import time


CLOUDFRONT_KEY_PATH = './sk.pem'
CLOUDFRONT_KEY_PAIR_ID = 'APKAJEL5RQQ36NTUXW6Q'
CLOUDFRONT_URL = 'http://dunfj7ei6w49.cloudfront.net'


def get_cloudfront_policy(url, expires):
    policy = {
        'Statement': [
            {
                'Resource': url,
                'Condition': {'DateLessThan': {'AWS:EpochTime': expires}},
            }
        ]
    }
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


def test_flag_cannot_be_gotten_without_signed_cookie():
    url = '{0}/flag.txt'.format(CLOUDFRONT_URL)
    r = requests.get(url)
    assert r.status_code == 403


def test_flag_can_be_gotten_flag_with_signed_cookie():
    url = '{0}/flag.txt'.format(CLOUDFRONT_URL)
    now = datetime.datetime.now()
    expires = now + datetime.timedelta(days=1)
    expires_unixtime = int(time.mktime(expires.timetuple()))
    cookie = get_cloudfront_signed_cookie(url, expires_unixtime)
    headers = {'Cookie': cookie}
    r = requests.get(url, headers=headers)
    assert r.status_code == 200
    assert r.text.strip() == 'Catch the flag!'
