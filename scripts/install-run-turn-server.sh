#!/bin/bash -xe
apt update
apt install -y coturn
turnserver -v

sudo systemctl stop coturn

echo 'server-name=fpr-turn-server' | sudo tee /etc/turnserver.conf

echo 'listening-ports=3478' | sudo tee -a /etc/turnserver.conf

echo 'tls-listening-ports=443' | sudo tee -a /etc/turnserver.conf

echo 'listening-ip=172.31.33.224' | sudo tee -a /etc/turnserver.conf

echo 'relay-ip=172.31.33.224' | sudo tee -a /etc/turnserver.conf

echo 'fingerprint' | sudo tee -a /etc/turnserver.conf

echo 'lt-cred-mech' | sudo tee -a /etc/turnserver.conf

echo 'allow-loopback-peers' | sudo tee -a /etc/turnserver.conf

echo 'no-multicast-peers' | sudo tee -a /etc/turnserver.conf

echo "user=turnuser:turn456" | sudo tee -a /etc/turnserver.conf

sudo systemctl start coturn