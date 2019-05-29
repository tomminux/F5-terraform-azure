#!/bin/bash

LOG_FILE=/var/log/startup-script.log
LIBS_DIR=/config/cloud/node_modules
DO_RPM_FILE='${do_rpm_file}'
AS3_RPM_FILE='${as3_rpm_file}'
F5_USERNAME='${f5_username}'
F5_PASSWORD='${f5_password}'
F5_CRED='${f5_username}:${f5_password}'
IP=127.0.0.1

## ..:: LOG File Initialization ::..
## ============================================================================
if [ ! -e $LOG_FILE ]
then
     touch $LOG_FILE
     exec >> $LOG_FILE 2>&1
else
    # If file exists, exit as only want to run once
    exit
fi

## ..:: Getting necessary files from the Net ::..
## ============================================================================

# AUTOMATION

curl -o $DO_RPM_FILE --silent --fail --retry 60 -L https://raw.githubusercontent.com/F5Networks/f5-declarative-onboarding/master/dist/$DO_RPM_FILE
curl -o $AS3_RPM_FILE --silent --fail --retry 60 -L https://raw.githubusercontent.com/F5Networks/f5-appsvcs-extension/master/dist/latest/$AS3_RPM_FILE


# CLOUD LIBS FOR ONBOARDING
mkdir -p /config/cloud/node_modules
curl -o /config/cloud/f5-cloud-libs.tar.gz --silent --fail --retry 60 -L https://raw.githubusercontent.com/F5Networks/f5-cloud-libs/master/dist/f5-cloud-libs.tar.gz
tar zxvf /config/cloud/f5-cloud-libs.tar.gz -C $LIBS_DIR

## ..:: Begin Basic OnBoarding
## ============================================================================

. $LIBS_DIR/f5-cloud-libs/scripts/util.sh

# Wait for "mcpd" to be up and ready
wait_for_bigip

# Secure admin suer password and save initial config
tmsh create auth user $F5_USERNAME password $F5_PASSWORD shell bash partition-access replace-all-with { all-partitions { role admin } }
tmsh save /sys config

## ..:: DO Installation ::..
## ============================================================================
LEN=$(wc -c $DO_RPM_FILE | cut -f 1 -d ' ')
curl -kvu $F5_CRED https://$IP/mgmt/shared/file-transfer/uploads/$DO_RPM_FILE -H 'Content-Type: application/octet-stream' -H "Content-Range: 0-$((LEN - 1))/$LEN" -H "Content-Length: $LEN" -H 'Connection: keep-alive' --data-binary @$DO_RPM_FILE

DATA="{\"operation\":\"INSTALL\",\"packageFilePath\":\"/var/config/rest/downloads/$DO_RPM_FILE\"}"
curl -kvu $F5_CRED "https://$IP/mgmt/shared/iapp/package-management-tasks" -H "Origin: https://$IP" -H 'Content-Type: application/json;charset=UTF-8' --data $DATA

## ..:: AS3 Installation ::..
## ============================================================================
LEN=$(wc -c $AS3_RPM_FILE | cut -f 1 -d ' ')
curl -kvu $F5_CRED https://$IP/mgmt/shared/file-transfer/uploads/$AS3_RPM_FILE -H 'Content-Type: application/octet-stream' -H "Content-Range: 0-$((LEN - 1))/$LEN" -H "Content-Length: $LEN" -H 'Connection: keep-alive' --data-binary @$AS3_RPM_FILE

DATA="{\"operation\":\"INSTALL\",\"packageFilePath\":\"/var/config/rest/downloads/$AS3_RPM_FILE\"}"
curl -kvu $F5_CRED "https://$IP/mgmt/shared/iapp/package-management-tasks" -H "Origin: https://$IP" -H 'Content-Type: application/json;charset=UTF-8' --data $DATA
