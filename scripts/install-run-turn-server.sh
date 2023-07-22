#!/bin/bash -xe
apt update
apt install -y coturn
turnserver -v

sudo systemctl stop coturn

echo 'server-name=fpr-turn-server' | sudo tee /etc/turnserver.conf
echo 'realm=fpr-turn-server' | sudo tee -a /etc/turnserver.conf
echo 'listening-port=3478' | sudo tee -a /etc/turnserver.conf
echo 'tls-listening-port=443' | sudo tee -a /etc/turnserver.conf
echo 'listening-ip=172.31.46.178' | sudo tee -a /etc/turnserver.conf
echo 'relay-ip=172.31.46.178' | sudo tee -a /etc/turnserver.conf
echo 'external-ip=13.39.23.24' | sudo tee -a /etc/turnserver.conf
echo 'min-port=49152' | sudo tee -a /etc/turnserver.conf
echo 'max-port=65535' | sudo tee -a /etc/turnserver.conf
echo 'verbose' | sudo tee -a /etc/turnserver.conf
echo 'fingerprint' | sudo tee -a /etc/turnserver.conf
echo 'lt-cred-mech' | sudo tee -a /etc/turnserver.conf
echo "user=fpr-turn:root" | sudo tee -a /etc/turnserver.conf
echo "syslog" | sudo tee -a /etc/turnserver.conf
echo "web-admin" | sudo tee -a /etc/turnserver.conf
echo "web-admin-ip=0.0.0.0" | sudo tee -a /etc/turnserver.conf

sudo systemctl start coturn