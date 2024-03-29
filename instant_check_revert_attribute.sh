#!/bin/bash

# amado.tejada | 01-19-2024

jamfserver="$4"
API_USER="$5"
API_PASS="$6"
getudid=$(system_profiler SPHardwareDataType | grep UUID | awk '{print $3}')
eaID="$7"
value="Last run: $(date)"

update_attribute() {
curl -X PUT -sfku $API_USER:$API_PASS "https://$jamfserver/JSSResource/computers/udid/$getudid/subset/extension_attributes" \
    -H "Content-Type: application/xml" \
    -H "Accept: application/xml" \
    -d "<computer><extension_attributes><extension_attribute><id>$eaID</id><value>$value</value></extension_attribute></extension_attributes></computer>"
}

if update_attribute; then
    echo "Updated: Custom Attribute, $(date)" >>/var/log/INSTANT_CHECKIN.log
    exit 0
else
    echo "Error: Attribute not updated, $(date)" >>/var/log/INSTANT_CHECKIN.log
    exit 1
fi
