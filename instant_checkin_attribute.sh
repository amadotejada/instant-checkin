#!/bin/bash

DOMAIN=""

if [[ -f "/Library/Application Support/$DOMAIN/instant_checkin_runner.sh" && -f "/Library/LaunchDaemons/com.$DOMAIN.instant_checkin.plist" ]]; then
    echo "<result>Yes</result>"
    exit 0
else
    echo "<result>No</result>"
    exit 1
fi
