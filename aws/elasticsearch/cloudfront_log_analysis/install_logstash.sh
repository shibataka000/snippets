#!/bin/sh

# Install logstash
apt update
apt install -y openjdk-8-jre-headless
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
apt install -y apt-transport-https
echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-6.x.list
apt update
apt install -y logstash

# Install logstash-output-amanzon_es plugin
/usr/share/logstash/bin/logstash-plugin install logstash-output-amazon_es
