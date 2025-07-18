#!/bin/bash
set -e
echo "Start build process"

# avoid some dialogs
export DEBIAN_FRONTEND=noninteractive

find /build -type f -iname "*.sh" -exec chmod +x {} \;

# preparations
/build/apt-get.sh
/build/tzdata.sh

# determinate build platform
. /build/platforms/${TARGETPLATFORM}.sh

# add config
mkdir -p /config
ln -s /home/root/.internxt-cli /config

# install Internxt CLI
/build/internxt-cli.sh

# cleanup
/build/cleanup.sh
