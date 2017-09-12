#!/bin/bash -e
echo ""
echo "#--------------------------"
echo " Configuration Rabbit MQ Server launched"
echo "#--------------------------"

rabbitmq-plugins enable rabbitmq_management

user=`rabbitmqctl list_users | egrep guest | cut -d '[' -f 1 | tr -s ' '`

if [ ! -z "$user" ];
then
  rabbitmqctl delete_user guest
fi

# creating 2 vhosts
vh=`rabbitmqctl list_vhosts | egrep POC-VHOST | cut -d '[' -f 1 | tr -s ' '`
if [ -z "$vh" ];
then
  rabbitmqctl add_vhost POC-VHOST
fi

## Compte administrateur
administrator=`rabbitmqctl list_users | egrep admin | cut -d '[' -f 1 | tr -s ' '`
if [ -z "$administrator" ];
then
  rabbitmqctl add_user admin admin
  rabbitmqctl set_user_tags admin administrator
  rabbitmqctl set_permissions -p POC-VHOST admin ".*" ".*" ".*"
fi

## Compte utilisateur operationnel
operational=`rabbitmqctl list_users | egrep oper | cut -d '[' -f 1 | tr -s ' '`
if [ -z "$operational" ];
then
  rabbitmqctl add_user oper oper
  rabbitmqctl set_user_tags oper management
  rabbitmqctl set_permissions -p POC-VHOST oper "" "" ""
fi

## Compte utilisateur interface
#user_interface=`rabbitmqctl list_users | egrep userMIPF | cut -d '[' -f 1 | tr -s ' '`
#if [ $user_interface != "userMIPF" ];
#then
#  rabbitmqctl add_user userMIPF userMIPF 
#  rabbitmqctl set_permissions -p POC-VHOST userMIPF "" "^(Q-SEC-IRS_OE-MIPF)$" "^(E-TP-SEC-MIPF-1)$"
#fi

#cd /home
#. ./init.sh

#enable shovel plugin and management
rabbitmq-plugins enable rabbitmq_shovel rabbitmq_shovel_management

echo ""
echo "#--------------------------"
echo " Mirroring configuration"
echo "#--------------------------"

rabbitmqctl set_policy -p POC-VHOST ha-all "" '{"ha-mode":"all","queue-mode":"lazy"}'
#rabbitmqctl set_policy -p POC-VHOST qml "^MinMasterQueue\." '{"queue-master-locator":"min-masters"}' --apply-to queues 

echo "#--------------------------"
exit 0
