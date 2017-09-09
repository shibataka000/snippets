#!/bin/sh
apt update
apt install openjdk-8-jre-headless apt-transport-https -y
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-5.x.list
apt update
apt install elasticsearch kibana -y
echo "server.host: \"0.0.0.0\"" | tee -a /etc/kibana/kibana.yml
systemctl daemon-reload
systemctl enable elasticsearch.service
systemctl start elasticsearch.service
systemctl enable kibana.service
systemctl start kibana.service
