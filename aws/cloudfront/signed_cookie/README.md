# CloudFront Signed Cookie

Snippets about CloudFront signed cookie.

## Requirement
- terraform
- pytest

## Usage

### How to run test.
1. Generate CloudFront key pair and save secret key.
2. Set following parameter in `test_signed_cookie.py`.
    - `CLOUDFRONT_KEY_PATH`: Path to CloudFront secret key.
    - `CLOUDFRONT_KEY_PAIR_ID`: CloudFront key pair id.
    - `CLOUDFRONT_URL`: CloudFront URL (e.g. http://dunfj7ei6w49.cloudfront.net).
3. Run `py.test`.

## Install
1. Run `terraform apply`.

## Author
[shibataka000](https://github.com/shibataka000)
