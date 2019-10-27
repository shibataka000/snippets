#!/bin/sh

SCRIPTS=$(pwd)/scripts
REMOTE_SCRIPTS=$(pwd)/scripts/remote

TMP=./tmp
mkdir -p $TMP
cd $TMP

echo "==================== Initialize ===================="
. $SCRIPTS/00-init.sh

echo "==================== Provisioning a CA and Generating TLS Certificates ===================="
. $SCRIPTS/04-make-certificate.sh

echo "==================== Generating Kubernetes Configuration Files for Authentication ===================="
. $SCRIPTS/05-make-configuration.sh

echo "==================== Generating the Data Encryption Config and Key ===================="
. $SCRIPTS/06-make-data-encryption-keys.sh

echo "==================== Bootstrapping the etcd Cluster ===================="
. $SCRIPTS/07-bootstrap-etcd.sh $REMOTE_SCRIPTS

echo "==================== Bootstrapping the Kubernetes Control Plane ===================="
. $SCRIPTS/08-bootstrap-kubernetes-controllers.sh $REMOTE_SCRIPTS

echo "==================== Bootstrapping the Kubernetes Worker Nodes ===================="
. $SCRIPTS/09-bootstrap-kubernetes-workers.sh $REMOTE_SCRIPTS

echo "==================== Configuring kubectl for Remote Access ===================="
. $SCRIPTS/10-configure-kubectl.sh

echo "==================== Deploying the DNS Cluster Add-on ===================="
. $SCRIPTS/12-deploy-dns-addon.sh
