#!/bin/bash
apt update
apt upgrade -y
apt install gcc g++ make libssl-dev -y

cd $HOME
wget http://www.squid-cache.org/Versions/v3/3.5/squid-3.5.24.tar.gz
tar -zxvf squid-3.5.24.tar.gz
cd ./squid-3.5.24
./configure --prefix=/usr/local/squid --with-openssl
make all
make install

cd /usr/local/squid/etc
cp squid.conf squid.conf.bak
wget https://raw.githubusercontent.com/shibataka000/snippets/squid/other/squid/squid.conf

cd $HOME
openssl genrsa 2048 > server.key
openssl req -new -key server.key > server.csr
openssl x509 -days 3650 -req -signkey server.key < server.csr > server.crt

/usr/local/squid/sbin/squid
