#!/bin/bash

while true; do
  echo "Starting webdav server (with login enabled)"
  /scripts/webdav.sh
  exit_code=$?

  if [ $exit_code -eq 401 ]; then
    /scripts/login.sh

    if [ $? -ne 0 ]; then
      echo "Login failed" >&2
      exit 1
    fi
  else
    exit $exit_code
  fi
done
