#!/bin/bash


if [[ $(id -u) -ne 0 ]] ; then echo "Run as root" ; exit 1 ; fi

DOMAIN=""

if [[ ! $DOMAIN ]]; then echo "\$DOMAIN not set"; exit 1; fi

cat << EOF > "/Library/LaunchDaemons/com.$DOMAIN.instant_checkin.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>com.$DOMAIN.instant_checkin</string>
	<key>ProgramArguments</key>
	<array>
		<string>sh</string>
		<string>/Library/Application Support/$DOMAIN/instant_checkin_runner.sh</string>
	</array>
	<key>WatchPaths</key>
	<array>
		<string>/Library/Managed Preferences/com.$DOMAIN.instant_checkin.plist</string>
	</array>
</dict>
</plist>
EOF

mkdir -p "/Library/Application Support/$DOMAIN"

cat << EOF > "/Library/Application Support/$DOMAIN/instant_checkin_runner.sh"
#!/bin/bash

{
if [[ -e "/Library/Managed Preferences/com.$DOMAIN.instant_checkin.plist" ]]; then
	policyid=\$(defaults read "/Library/Managed Preferences/com.$DOMAIN.instant_checkin.plist" policyid)
	if [[ \$policyid =~ ^[0-9]+$ ]]
	then
		echo "policyid \$policyid"
		/usr/local/bin/jamf policy -id \$policyid
	else
		echo "normal checkin"
		/usr/local/bin/jamf policy
	fi

/usr/local/bin/jamf recon -room "Instant Check-in Ready! Run by changing this field to: check-in"

fi

} || {
	echo "error, resetting jamf instant check-in"
    /usr/local/bin/jamf recon -room "Instant Check-in Ready! Run by changing this field to: check-in"
}

EOF

chmod +x "/Library/Application Support/$DOMAIN/instant_checkin_runner.sh"
chown root:wheel /Library/LaunchDaemons/com.$DOMAIN.instant_checkin.plist
chmod 644 /Library/LaunchDaemons/com.$DOMAIN.instant_checkin.plist
launchctl load -w /Library/LaunchDaemons/com.$DOMAIN.instant_checkin.plist
jamf recon -room "Instant Check-in Ready! Run by changing this field to: check-in"

echo -e "\033[0;32m\nInstant Check-in: Ready\n\033[0m"
