#!/bin/bash

# Check required environment variables
if [[ -z "$INTERNXT_USERNAME" || -z "$INTERNXT_PASSWORD" ]]; then
  echo "Error: INTERNXT_USERNAME and INTERNXT_PASSWORD must be set."
  exit 1
fi

# Pre check if already logged in
response=$(/usr/local/bin/internxt whoami)

# Check if the response contains "You are logged in as:"
if [[ $response == *"You are logged in as:"* ]]; then
  username=$(echo "$response" | grep -oP 'You are logged in as: \K.*')
  echo "$(date '+%Y-%m-%d %H:%M:%S') Already logged in as ${username}."
  exit 0
fi

# Initialize command arguments
cmd=( /usr/local/bin/internxt login -x -e "$INTERNXT_USERNAME" -p "$INTERNXT_PASSWORD" )

# If INTERNXT_SECRET is set, generate TOTP and add -w option
if [[ -n "$INTERNXT_SECRET" ]]; then
  # Generate 6-digit TOTP code from INTERNXT_SECRET
  OTP_CODE=$(oathtool --totp -b "$INTERNXT_SECRET")

  if [[ -z "$OTP_CODE" ]]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') Error: Failed to generate OTP from INTERNXT_SECRET."
    exit 1
  fi

  # Append the OTP argument
  cmd+=( -w "$OTP_CODE" )
fi

# Execute the command
echo "$(date '+%Y-%m-%d %H:%M:%S') Login to user account..."
"${cmd[@]}"

if [ $? -ne 0 ]; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') Login failed" >&2
  exit 1
else
  echo "$(date '+%Y-%m-%d %H:%M:%S') Logged in."
fi
