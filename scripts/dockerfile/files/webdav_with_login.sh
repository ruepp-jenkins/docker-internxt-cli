#!/bin/bash

while true; do
  echo "Starting webdav server (with login enabled)"
  /scripts/login.sh
  /scripts/webdav.sh

  exit_code=$?

  # check if we got logged out
  if [ $exit_code -ne 401 ]; then
    echo "Non recoverable return code $exit_code"
    exit $exit_code
  fi

  # disable webdav server before trying again
  echo "Got logged out, stopping current webdav server and restarting login procedure"
  /usr/local/bin/internxt webdav disable
done
