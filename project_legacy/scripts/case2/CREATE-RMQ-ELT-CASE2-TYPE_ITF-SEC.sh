#!/bin/bash -e
# load environment variable

#zone name
export ZONE="ZONE" 
#interface source name
export BB_SRC="BB_SRC"
#interface destination name
export BB_DEST="BB_DEST"
#interface source name
export ITF="ITF"

# ip address remote server
export SHO_DEST_IP_ADDRESS="IP adress"
# virtual host remote server
export SHO_DEST_VHOST="virtual host name"
# port number remote server
export SHO_DEST_PORT_NUMBER="5672"

# virtual host source
export INFO_SRC_VHOST="virtual host name"
# password source
export INFO_SRC_PASS="pass"
# user source
export INFO_SRC_USER="user"

cd /home
. ./CREATION-RMQ-ELT-CASE2-SEC-TEMPLATE.sh