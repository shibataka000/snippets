#!/bin/sh
HOME=/home/ubuntu
NGINX_VERSION=1.14.0

sudo apt install -y gcc make libpcre3-dev zlib1g-dev

mkdir -p $HOME/build
wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz -O $HOME/build/nginx-${NGINX_VERSION}.tar.gz
tar zxvf $HOME/build/nginx-${NGINX_VERSION}.tar.gz -C $HOME/build

cd $HOME/build/nginx-${NGINX_VERSION}
./configure
make
sudo make install

/usr/local/nginx/sbin/nginx
