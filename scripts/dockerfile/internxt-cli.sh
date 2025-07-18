#!/bin/bash
set -e
echo "Installing Internxt CLI"

mkdir -p /config
ln -s /config /home/root/.internxt-cli

npm i -g @internxt/cli
