#!/bin/bash

# Webdav script
# ------------------
# 1. read config file for webdav protocol and port (default protocol "https" and port "3005")
# 2. start webdav server
# 3. start moniitoring the server

# Monitoring
# ----------
# 1. get the current status codes of webdav response and http server (from inside the container)
# 2. check response codes of webdav server
# 3. check response codes of http server
# 4. if response codes are non 2XX retry up to 3 times (with 3 seconds pause)
# 5. if still non 2XX, exit with status code (prefere webdav status code, http status as fallback)

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

    HTTP_STATUS="0"
    WEBDAV_STATUS="0"
    RETRY_COUNT=0

    # check webdav server up to 3 times
    while [ "$RETRY_COUNT" -lt 3 ]; do
        # check server using curl
        response=$(curl -s -w "%{http_code}" -X PROPFIND -H "Depth: 1" "$URL")
        HTTP_STATUS="${response: -3}"
        body="${response::-3}"

        WEBDAV_STATUS_TEXT=$(echo "$body" | xmllint --xpath 'string(//*[local-name()="status"])' -)
        WEBDAV_STATUS=$(echo "$WEBDAV_STATUS_TEXT" | awk '{print $2}')

        # check webdav and http server status code
        if [[ ! "$HTTP_STATUS" =~ ^2[0-9]{2}$  || ! "$WEBDAV_STATUS" =~ ^2[0-9]{2}$ ]]; then
            RETRY_COUNT=$((RETRY_COUNT + 1))
            echo "$(date '+%Y-%m-%d %H:%M:%S') Error [${RETRY_COUNT}/3]: Webdav Server at $URL responded with invalid status http=$HTTP_STATUS / webdav=$WEBDAV_STATUS"
            sleep 3
        else
            if [ "$RETRY_COUNT" -gt 0 ]; then
                echo "$(date '+%Y-%m-%d %H:%M:%S') Server is available again after ${RETRY_COUNT} retries: http=$HTTP_STATUS / webdav=$WEBDAV_STATUS"
            fi
        fi
    done

    # check if status codes are fine, exit using the status codes if non 2XX (prefere webdav status code as exit code)
    if [[ "$HTTP_STATUS" =~ ^2[0-9]{2}$ && "$WEBDAV_STATUS" =~ ^2[0-9]{2}$ ]]; then
        continue
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') Error: Server at $URL responded with invalid status http=$HTTP_STATUS / webdav=$WEBDAV_STATUS. Exiting."
        # prefere the webdav status code as exit code
        if [ -n "$WEBDAV_STATUS" ] && [ "$WEBDAV_STATUS" != "000" ] || [ "$WEBDAV_STATUS" != "0" ]; then
            if [[ ! "$WEBDAV_STATUS" =~ ^2[0-9]{2}$ ]]; then
                echo "$(date '+%Y-%m-%d %H:%M:%S') Error: Webdav Server at $URL responded with invalid status http=$HTTP_STATUS / webdav=$WEBDAV_STATUS. Exiting."
                exit $((WEBDAV_STATUS))
            fi
        fi

        # webdav status code seems to be fine/not available, use http status code as exit code
        echo "$(date '+%Y-%m-%d %H:%M:%S') Error: Server at $URL responded with invalid status http=$HTTP_STATUS / webdav=$WEBDAV_STATUS. Exiting."
        if [ -z "$HTTP_STATUS" ] || [ "$HTTP_STATUS" == "000" ] || [ "$HTTP_STATUS" == "0" ]; then
            exit 1
        else
            exit $((HTTP_STATUS))
        fi
    fi
done
