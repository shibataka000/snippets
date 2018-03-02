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

apt install git python3-pip -y
git clone https://github.com/shibataka000/scm-kibana /opt/scm-kibana
pip3 install pip --upgrade
pip3 install -r /opt/scm-kibana/requirements.txt
chmod 755 /opt/scm-kibana/put_info.sh
ln -s /opt/scm-kibana/put_info.sh /etc/cron.daily/put_info.sh
