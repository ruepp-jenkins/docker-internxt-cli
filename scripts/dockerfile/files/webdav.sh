#!/bin/bash

echo "$(date '+%Y-%m-%d %H:%M:%S') Starting webdav server ..."
/usr/local/bin/internxt webdav enable

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
    echo "$(date '+%Y-%m-%d %H:%M:%S') Config file $CONFIG_FILE not found. Using default PORT=$PORT and PROTOCOL=$PROTOCOL."
fi

URL="${PROTOCOL}://127.0.0.1:${PORT}/"

echo "$(date '+%Y-%m-%d %H:%M:%S') Monitoring WebDAV server at: $URL - Check interval: $WEBDAV_CHECK_INTERVAL seconds"

while true; do
    sleep $WEBDAV_CHECK_INTERVAL

    HTTP_STATUS=$(curl -m $WEBDAV_CHECK_TIMEOUT -k -X PROPFIND -o /dev/null -s -w "%{http_code}" "$URL" -H "Depth: 1")

    if [[ "$HTTP_STATUS" =~ ^2[0-9]{2}$ ]]; then
        continue
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') Error: Server at $URL responded with invalid HTTP status $HTTP_STATUS. Exiting."
        if [ -z "$HTTP_STATUS" ] || [ "$HTTP_STATUS" == "000" ] || [ "$HTTP_STATUS" == "0" ]; then
            exit 1
        else
            exit $((HTTP_STATUS))
        fi
    fi
done
