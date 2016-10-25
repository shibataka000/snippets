# lambdaw\_with\_native\_git

Sample code to clone private repository from GitHub on Lambda function.

## Description
It is necessary to run `git clone` and clone private repository on Lambda.

- Add git binaries and shared libraries to deploy package.
- Use git credential file for authentication.
	- Lambda permits us to write only on `/tmp` directory.
	So set `/tmp` as home directory and copy `.gitconfig` and `git-credentials` to `/tmp`.


## Development environment
- Amazon Linux (ami-1a15c77b)
- Python 2.7.12

## Requirement
- terraform

## Usage
Run Lambda function by AWS console.
Lambda function run python script as same as following command.

```
$ export HOME=/tmp
$ export GIT_EXEC_PATH=/var/task/usr/libexec/git-core
$ export GIT_TEMPLATE_DIR=/var/task/usr/share/git-core/templates
$ cp /var/task/git-credentials /tmp/git-credentials
$ git config --global credential.helper store --file /tmp/git-credentials
$ git clone https://github.com/shibataka000/snippets /tmp/snippets
```

## Install

### Install git
Install git.

```
$ yum install git
```

### Create deploy package
Run `create_zip.sh`.


#### What `create_zip.sh` do?
Add source code.

```
$ zip lambda_with_git.zip *.py
```

Add git binaries.

- `/usr/bin/git`
- `/usr/libexec/git-core`
- `/usr/share/git-core`

Add git config files.

- `.gitconfig`
- `git-credential`

Add shared libraries which are necessary to run git binaries.

### Create Lambda function
```
$ terraform apply
```

## Author
[shibataka000](https://github.com/shibataka000)
