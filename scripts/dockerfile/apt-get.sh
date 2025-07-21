#!/bin/bash
set -e
echo "Install packages"

apt-get update
apt-get install -y \
        jq \
        libxml2-utils \
        oathtool \
        tzdata
