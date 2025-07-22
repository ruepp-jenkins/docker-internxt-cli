#!/bin/bash

echo "$(date '+%Y-%m-%d %H:%M:%S') Starting webdav server (with login enabled)"

while true; do
  /scripts/login.sh
  /scripts/webdav.sh

  exit_code=$?

  # check if we got logged out (10 = 401 for not logged in)
  if [ $exit_code -ne 10 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') Non recoverable return code $exit_code"
    exit $exit_code
  fi

  # disable webdav server before trying again
  echo "$(date '+%Y-%m-%d %H:%M:%S') Got logged out, stopping current webdav server and restarting login procedure"
  /usr/local/bin/internxt webdav disable
done
