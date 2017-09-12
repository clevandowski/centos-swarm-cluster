#!/bin/bash -e
# load environment variable

#zone name
export ZONE="ZONE" 
#interface source name
export BB_SRC="BB_SRC"
#interface name
export ITF="ITF"
# Building block name distination
export BB_DEST="BB_DEST"
# virtual host bulding block source
export SRC_SHO_VHOST="virtual host name"
# ip adresse bulding block source
export SRC_SHO_IP_ADDRESS="IP adress"
# port number bulding block source
export SRC_SHO_PORT_NUMBER="5672"
# virtual host source
export INFO_SRC_VHOST="virtual host name"
# password source
export INFO_SRC_PASS="pass"
# user source
export INFO_SRC_USER="user"

cd /home
. ./CREATION-RMQ-ELT-CASE3-SEC-TEMPLATE.sh
