#!/bin/bash

CONFIG_FILE="/config/config.webdav.inxt"

# Default values
PORT="3005"
PROTOCOL="https"

if [ -f "$CONFIG_FILE" ]; then
    # Extract port and protocol from JSON config using jq
    PORT_TMP=$(jq -r '.port // empty' "$CONFIG_FILE" 2>/dev/null)
    PROTOCOL_TMP=$(jq -r '.protocol // empty' "$CONFIG_FILE" 2>/dev/null)

    # Use values from config if valid
    if [[ -n "$PORT_TMP" && "$PORT_TMP" != "null" ]]; then
        PORT="$PORT_TMP"
    fi
    if [[ -n "$PROTOCOL_TMP" && "$PROTOCOL_TMP" != "null" ]]; then
        PROTOCOL="$PROTOCOL_TMP"
    fi
else
    echo "Config file $CONFIG_FILE not found. Using default PORT=$PORT and PROTOCOL=$PROTOCOL."
fi

URL="${PROTOCOL}://127.0.0.1:${PORT}"

echo "Checking WebDAV server at: $URL"

while true; do
    HTTP_STATUS=$(curl -m 5 -k -o /dev/null -s -w "%{http_code}" "$URL")

    if [ "$HTTP_STATUS" == "404" ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') Server at $URL running."
        sleep 10
        continue
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') Error: Server at $URL responded with invalid HTTP status $HTTP_STATUS. Exiting."
        exit 1
    fi
done
