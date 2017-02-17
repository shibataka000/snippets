#!/bin/sh
sudo add-apt-repository ppa:openjdk-r/ppa
sudo apt update
sudo apt install -y tar wget git openjdk-8-jdk autoconf libtool build-essential python-dev libcurl4-nss-dev libsasl2-dev libsasl2-modules maven libapr1-dev libsvn-dev zlib1g-dev
update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java

cd /home/ubuntu
wget http://www.apache.org/dist/mesos/1.1.0/mesos-1.1.0.tar.gz
tar -zxf mesos-1.1.0.tar.gz

cd mesos-1.1.0
./bootstrap
mkdir build
cd build
../configure
make
make check
