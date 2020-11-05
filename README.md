# hc_check_maker_macos
## Script to create a https://healthchecks.io check on macOS
Requires:
* jq, https://stedolan.github.io/jq/  
* Your API-key from healthchecks.io

Usage:  
`git clone https://github.com/reboot81/hc_check_maker_macos.git`  
`cd hc_check_maker_macos`  
`chmod a+x hc_check_maker.sh`  
`./hc_check_maker.sh`

Enter your API key and press enter

Your browser will open the checks webpage, within 60s you should see a ping.  
Enable the notifications of your choosing.

Creates the following files:  
* `~/Library/LaunchAgents/local.healthchecks_service.plist`  
* `/usr/local/bin/healthchecks_service.sh`
