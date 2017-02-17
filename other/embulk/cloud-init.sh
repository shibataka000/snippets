#!/bin/sh
ELASTICSEARCH=elasticsearch-5.2.1
KIBANA=kibana-5.2.1-linux-x86_64

add-apt-repository ppa:openjdk-r/ppa -y
apt update
apt install openjdk-8-jdk -y

wget https://artifacts.elastic.co/downloads/elasticsearch/$ELASTICSEARCH.tar.gz
tar zxvf $ELASTICSEARCH.tar.gz
chown ubuntu:ubuntu $ELASTICSEARCH

wget https://artifacts.elastic.co/downloads/kibana/$KIBANA.tar.gz
tar zxvf $KIBANA.tar.gz
chown ubuntu:ubuntu $KIBANA
