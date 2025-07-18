#!/bin/bash
set -e
echo "Get Internxt CLI version ..."

export INTERNXT_CLI_VERSION=$(curl -s https://registry.npmjs.org/@internxt/cli/latest | jq -r '.version')

if [[ -z "$INTERNXT_CLI_VERSION" ]]; then
  echo "Error: INTERNXT_CLI_VERSION not detected" >&2
  exit 1
else
  echo "Detected version: ${INTERNXT_CLI_VERSION}"
fi
