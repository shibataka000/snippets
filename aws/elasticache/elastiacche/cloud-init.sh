#!/bin/sh
cd /home/ubuntu
apt update
apt install gcc make -y
wget http://download.redis.io/redis-stable.tar.gz
tar xvzf redis-stable.tar.gz
cd redis-stable
make distclean
make
