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

# install Internxt CLI
/build/internxt-cli.sh

# add persistent files
mkdir -p /run
mv /build/files/webdav.sh /run/

# cleanup
/build/cleanup.sh
