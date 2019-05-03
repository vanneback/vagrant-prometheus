#!/bin/bash
set -e
version=2.9.2
directory=prometheus
export MASTER_IP=192.168.10.10
wget https://github.com/prometheus/prometheus/releases/download/v${version}/prometheus-${version}.linux-amd64.tar.gz
tar xvfz prometheus-*.tar.gz -C $directory --strip-components 1
envsubst '\$MASTER_IP' < ${directory}/template.yaml > ${directory}/config.yaml
chown -R vagrant:vagrant $directory 
cd $directory
#./prometheus --config.file=config.yaml &
