#!/bin/bash

# Script to create a https://healthchecks.io check
# Requires jq, https://stedolan.github.io/jq/

# Check for jq
if hash jq 2>/dev/null; then
  echo 'Dependencies met: jq'
else
  echo 'Your system does not have jq installed.'
  echo '$brew install jq' >&2
  exit 1
fi

echo Enter HC API key:
read API_KEY

LA_FILE="$HOME/Library/LaunchAgents/local.healthchecks_service.plist"
HC_FILE="/usr/local/bin/healthchecks_service.sh"

# Check's parameters. This example uses system's hostname for check's name.
PAYLOAD='{"name": "'`hostname`'", "timeout": 60, "grace": 300, "unique": ["name"]}'

# Create the check if it does not exist.
# Grab the ping_url from JSON response using the jq utility:
URL=`curl -s https://healthchecks.io/api/v1/checks/  -H "X-Api-Key: $API_KEY" -d "$PAYLOAD"  | jq -r .ping_url`

echo $URL

# Write the script thats run every minute
/bin/cat <<EOF >$HC_FILE
#!/bin/bash
# This file pings https://healthchecks.io/
# Create by hc_check_maker.sh
# using curl (10 second timeout, retry up to 5 times):
curl -fsS -m 10 --retry 5 -o /dev/null $URL

# Alternate method using wget (10 second timeout, retry up to 5 times):
#wget $URL -T 10 -t 5 -O /dev/null
EOF

# Give that file x-permissions
chmod a+x $HC_FILE

# Write the .plist file containing the job definition
/bin/cat <<EOF >$LA_FILE
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>local.healthchecks_service</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/healthchecks_service.sh</string>
    </array>
    <key>StartInterval</key>
    <integer>60</integer>
</dict>
</plist>
EOF

# Load the job
launchctl load -w $HOME/Library/LaunchAgents/local.healthchecks_service.plist

# Open the checks webpage
open $URL
exit 0