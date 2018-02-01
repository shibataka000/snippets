#!/bin/sh
apt update
apt install nginx -y
IP=`ifconfig eth0 | awk '/inet / {print $2}' | awk -F: '{print $2}'`
echo $IP > /var/www/html/index.html
