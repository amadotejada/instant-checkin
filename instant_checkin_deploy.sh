#!/bin/bash

# amado.tejada | 01-19-2024

if [[ $(id -u) -ne 0 ]] ; then echo "Run as root" ; exit 1 ; fi

DOMAIN="$4"

if [[ ! $DOMAIN ]]; then echo "Domain not set"; exit 1; fi

cat << EOF > "/Library/LaunchDaemons/com.$DOMAIN.instant_checkin.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>com.\$DOMAIN.instant_checkin</string>
	<key>ProgramArguments</key>
	<array>
		<string>sh</string>
		<string>/Library/Application Support/\$DOMAIN/instant_checkin_runner.sh</string>
	</array>
	<key>WatchPaths</key>
	<array>
		<string>/Library/Managed Preferences/com.\$DOMAIN.instant_checkin.plist</string>
	</array>
</dict>
</plist>
EOF

mkdir -p "/Library/Application Support/$DOMAIN"
rm -f "/Library/Application Support/$DOMAIN/instant_checkin_runner.sh"

cat << EOF > "/Library/Application Support/$DOMAIN/instant_checkin_runner.sh"
#!/bin/bash

# amado.tejada | 01/19/2024

echo "\nStarted: Instant checkin run, \$(date)" >>/var/log/INSTANT_CHECKIN.log

{
	if [ -e "/Library/Managed Preferences/com.$DOMAIN.instant_checkin.plist" ]; then
		policyid=\$(defaults read "/Library/Managed Preferences/com.$DOMAIN.instant_checkin.plist" policyid)
		if [[ "\$policyid" =~ ^[0-9]+$ ]]; then
			/usr/local/bin/jamf policy -id 241
			echo "Running: Policy \$policyid + recon: \$(date)" >>/var/log/INSTANT_CHECKIN.lo
			/usr/local/bin/jamf policy -id \$policyid
		else
			/usr/local/bin/jamf policy -id 241
			echo "Running: Normal policies + recon, \$(date)" >>/var/log/INSTANT_CHECKIN.log
			/usr/local/bin/jamf policy
		fi
	else
		echo "Error: No instant_checkin.plist file found, \$(date)" >>/var/log/INSTANT_CHECKIN.log
	fi

} || {
	echo "Error: No instant_checkin.plist file found, \$(date)" >>/var/log/INSTANT_CHECKIN.log
}

/usr/local/bin/jamf recon
echo "Finished: Instant checkin run, \$(date)" >>/var/log/INSTANT_CHECKIN.log
EOF

chmod +x "/Library/Application Support/$DOMAIN/instant_checkin_runner.sh"
chown root:wheel /Library/LaunchDaemons/com.$DOMAIN.instant_checkin.plist
chmod 644 /Library/LaunchDaemons/com.$DOMAIN.instant_checkin.plist
launchctl unload /Library/LaunchDaemons/com.$DOMAIN.instant_checkin.plist
launchctl load -w /Library/LaunchDaemons/com.$DOMAIN.instant_checkin.plist

echo -e "\nInstalled: instant_checkin_runner.sh, $(date)" >>/var/log/INSTANT_CHECKIN.log
/usr/local/bin/jamf policy -id 241
/usr/local/bin/jamf recon

echo -e "\033[0;32m\nInstant Check-in: Ready\033[0m"

exit 0
