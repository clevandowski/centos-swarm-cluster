#!/bin/bash -e
# load environment variable

#zone name
export ZONE="ZONE"
#interface source name
export BB_SRC="BB_SRC"
#interface name
export ITF="ITF"
#interface destination name 
export BB_DEST="BB_DEST"

# virtual host source
export INFO_SRC_VHOST="virtual host name"
# password source
export INFO_SRC_PASS="pass"
# user source
export INFO_SRC_USER="user"

cd /home
. ./CREATION-RMQ-ELT-CASE3-PRI-TEMPLATE.sh
