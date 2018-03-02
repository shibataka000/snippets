# scm-kibana

GitHubとJIRAの利用状況をElasticsearchとKibanaを使って記録・可視化する。

## Usage
http://VMのIPアドレス:5601 にアクセスする。

## Install
1. `terraform apply`
2. VMにログインして `/opt/scm-kibana/put_info.py` に以下の情報を記入する
	- 使用するGitHubアカウント
	- 使用するJIRAアカウント
	- GitHubのOrganization名
	- JIRAのURL

## Maintenance
Elasticsearchに記録する情報を変更する手順は以下の通りとする。

1. [put_info.py](./put_info.py) を修正してcommitする
2. VMにログインして `cd /opt/scm-kibana && git pull` する

## Author
[shibataka000](https://github.com/shibataka000)
