#!/bin/bash -xe
apt update
apt install -y coturn
turnserver -v