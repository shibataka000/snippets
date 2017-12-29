#!/bin/sh
apt update
apt install openjdk-8-jdk -y

cd /home/ubuntu
wget https://s3-ap-northeast-1.amazonaws.com/sbtk-bucket-public/hadoop-2.7.4.tar.gz
tar zxvf hadoop-2.7.4.tar.gz
chown ubuntu:ubuntu /home/ubuntu/hadoop* -R

echo "export PATH=${HOME}/hadoop-2.7.4/bin:${PATH}" | tee -a /home/ubuntu/.bashrc
echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" | tee -a /home/ubuntu/.bashrc
echo "export PATH=${JAVA_HOME}/bin:${PATH}" | tee -a /home/ubuntu/.bashrc
echo "export HADOOP_CLASSPATH=${JAVA_HOME}/lib/tools.jar" | tee -a /home/ubuntu/.bashrc
