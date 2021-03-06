#!/bin/bash

path="/home"

#----------------------------------------------------------------------------
#----------------------------- EXCHANGE -------------------------------------
#----------------------------------------------------------------------------
EX_NAME="E-TP-${ZONE}-${BB_SRC}-1"
# name exchange dead letter
EX_DL=""
# durability (mandatory)
EX_DURABILITY="true"
# auto delete (mandatory)
EX_AUTO_DELETE="false"
# internal (mandatory)
EX_INTERNAL="false"



#----------------------------------------------------------------------------
#----------------------------- EXCHANGE DEAD-------------------------------------
#----------------------------------------------------------------------------
EX_DEAD_NAME="E-TP-${ZONE}-${ITF}-DEAD"
# name exchange dead letter
EX_DEAD_DL=""
# durability (mandatory)
EX_DEAD_DURABILITY="true"
# auto delete (mandatory)
EX_DEAD_AUTO_DELETE="false"
# internal (mandatory)
EX_DEAD_INTERNAL="false"
# (optional) name exchange alternate
EX_DEAD_ALTERNATE=""


#----------------------------------------------------------------------------
#----------------------------- QUEUE ----------------------------------------
#----------------------------------------------------------------------------
##queue
Q_NAME="Q-${ZONE}-${ITF}-SHO"
# durability
Q_DURABILITY="true"
# auto delete
Q_AUTO_DELETE="false"
# Time To Live${ITF}_Q_TTL=259200000
Q_TTL=259200000
# auto expire
Q_AUTO_EXPIRE=0
# max length
Q_MAX_LENGTH=10000
# max length bytes
Q_MAX_LENGTH_BYTES=10000000
# dead letter exchange
Q_DL_NAME="E-TP-${ZONE}-${ITF}-DEAD"
# dead letter routing key
Q_DL_RT=""
# binding Routing_Key
Q_RT="${BB_SRC}.${ITF}.${BB_DEST}.*"


#----------------------------------------------------------------------------
#----------------------------- QUEUE DEAD----------------------------------------
#----------------------------------------------------------------------------
##queue
Q_DEAD_NAME="Q-${ZONE}-${ITF}-DEAD"
# durability
Q_DEAD_DURABILITY="true"
# auto delete
Q_DEAD_AUTO_DELETE="false"
# Time To Live${ITF}_Q_TTL=259200000
Q_DEAD_TTL=259200000
# auto expire
Q_DEAD_AUTO_EXPIRE=0
# max length
Q_DEAD_MAX_LENGTH=10000
# max length bytes
Q_DEAD_MAX_LENGTH_BYTES=10000000
Q_DEAD_RT="*.${ITF}.*.*"


#----------------------------------------------------------------------------
#----------------------------- SHOVEL 1 -------------------------------------
#----------------------------------------------------------------------------
##Informations for Shovel N to N-1
# instance 1 (N to N-1) shovel name : S-<NIP AREA>-<INTERFACE>-<FROM|TO>-<NIP AREA>
SHO_INS_1="S-${ZONE}-${ITF}"
# queue name source 
SHO_Q_SRC="Q-${ZONE}-${ITF}-SHO"
# exchange name destination
SHO_EX_DEST="E-TP-PRI-S-${ZONE}-${ITF}"
# prefetch_count (optional), defaut value 1000
SHO_INS_1_PRE_COUNT=1000
# ack_mode (optional) defautl value 'on_confirm'
SHO_INS_1_ACK_MODE="on-confirm"
# publish propertie (optional)
SHO_INS_1_PUB_PROP=""
# add forward headers (optional)
SHO_INS_1_ADD_FORWARD=""
# publish fields (optional)
SHO_INS_1_PUB_FIELD=""
# reconnect delay (optional) default value is 5 seconds
SHO_INS_1_REC_DELAY=5
SHO_DEST_USER="user-S-${ZONE}-${ITF}"
SHO_DEST_PASS="S-${ZONE}-|*_-${ITF}!*-${BB_DEST}|"


#-------------------------------------------------------------------------------------
#----------------------------- COMMAND RABBIT MQ -------------------------------------
#-------------------------------------------------------------------------------------

# -------------
# Exchange
# -------------


$path/rabbitmqadmin --username=${INFO_SRC_USER} --password=${INFO_SRC_PASS} declare exchange --vhost=${INFO_SRC_VHOST} name=${EX_DEAD_NAME} type=topic durable=${EX_DEAD_DURABILITY} auto_delete=${EX_DEAD_AUTO_DELETE} internal=${EX_DEAD_INTERNAL}


$path/rabbitmqadmin --username=${INFO_SRC_USER} --password=${INFO_SRC_PASS} declare exchange --vhost=${INFO_SRC_VHOST} name=${EX_NAME} type=topic durable=${EX_DURABILITY} auto_delete=${EX_AUTO_DELETE} internal=${EX_INTERNAL}


# -------------------
# Queue DEAD-LETTER
# -------------------
addQueueDead="$path/rabbitmqadmin --username=${INFO_SRC_USER} --password=${INFO_SRC_PASS} declare queue --vhost=${INFO_SRC_VHOST} name=${Q_DEAD_NAME} durable=${Q_DEAD_DURABILITY} auto_delete=${Q_DEAD_AUTO_DELETE} arguments={\"x-message-ttl\":${Q_DEAD_TTL},\"x-max-length\":${Q_DEAD_MAX_LENGTH},\"x-max-length-bytes\":${Q_DEAD_MAX_LENGTH_BYTES}"

if [ "${Q_DEAD_AUTO_EXPIRE}" != "0" ]
then
addQueueDead+=",\"x-expires\":${Q_DEAD_AUTO_EXPIRE}"
fi

addQueueDead+="}"
#launch
echo "$(${addQueueDead})"


# -------------
# Queue
# -------------
addQueue="$path/rabbitmqadmin --username=${INFO_SRC_USER} --password=${INFO_SRC_PASS} declare queue --vhost=${INFO_SRC_VHOST} name=${Q_NAME} durable=${Q_DURABILITY} auto_delete=${Q_AUTO_DELETE} arguments={\"x-message-ttl\":${Q_TTL},\"x-max-length\":${Q_MAX_LENGTH},\"x-max-length-bytes\":${Q_MAX_LENGTH_BYTES}"

if [[ ! -z "${EX_DEAD_NAME}" ]] 
then
addQueue+=",\"x-dead-letter-exchange\":\"${EX_DEAD_NAME}\""
fi

if [[ ! -z "${Q_DL_RT}" ]]
then
addQueue+=",\"x-dead-letter-routing-key\":\"${Q_DL_RT}\""
fi

if [ "${Q_AUTO_EXPIRE}" != "0" ]
then
addQueue+=",\"x-expires\":${Q_AUTO_EXPIRE}"
fi

addQueue+="}"
#launch
echo "$(${addQueue})"

# -------------
# Binding
# -------------
$path/rabbitmqadmin --username=${INFO_SRC_USER} --password=${INFO_SRC_PASS} declare binding --vhost=${INFO_SRC_VHOST} source=${EX_NAME}  destination_type="queue" destination=${Q_NAME} routing_key=${Q_RT}


# -------------
# Binding DEAD-LETTER
# -------------
$path/rabbitmqadmin --username=${INFO_SRC_USER} --password=${INFO_SRC_PASS} declare binding --vhost=${INFO_SRC_VHOST} source=${EX_DEAD_NAME}  destination_type="queue" destination=${Q_DEAD_NAME} routing_key=${Q_DEAD_RT}

# -------------
# Shovel
# -------------


addSHOVEL="rabbitmqctl set_parameter shovel ${SHO_INS_1} '{\"src-uri\": \"amqp:///${INFO_SRC_VHOST}\", \"src-queue\": \"${SHO_Q_SRC}\", \"dest-uri\": \"amqp://${SHO_DEST_USER}:${SHO_DEST_PASS}@${SHO_DEST_IP_ADDRESS}:${SHO_DEST_PORT_NUMBER}/${SHO_DEST_VHOST}\", \"dest-exchange\": \"${SHO_EX_DEST}\", \"prefetch-count\": ${SHO_INS_1_PRE_COUNT}, \"ack-mode\": \"${SHO_INS_1_ACK_MODE}\", \"reconnect-delay\": ${SHO_INS_1_REC_DELAY}"

 if [[ ! -z "${SHO_INS_1_PUB_PROP}" ]]
 then
addSHOVEL+=",\"publish-properties\":\"${SHO_INS_1_PUB_PROP}\""
 fi
 if [[ ! -z "${SHO_INS_1_ADD_FORWARD}" ]]
 then
addSHOVEL+=" ,\"add-forward-headers\":\"${SHO_INS_1_ADD_FORWARD}\""
 fi
if [[ ! -z "${SHO_INS_1_PUB_FIELD}" ]] 
 then
 addSHOVEL+=",\"publish-fields\":\"${SHO_INS_1_PUB_FIELD}\""
 fi

 addSHOVEL+="}' -p ${INFO_SRC_VHOST}"

eval $addSHOVEL

# -------------
# User account source
# -------------

user=`rabbitmqctl list_users | egrep user${BB_SRC} | cut -d '[' -f 1 | tr -s ' '`

if [ -z "$user"  ];
then
  echo "Source user account creating..."
  rabbitmqctl add_user user${BB_SRC} user${BB_SRC}
  #rabbitmqctl set_user_tags $INFO_SRC_USER 
  rabbitmqctl set_permissions -p $INFO_SRC_VHOST user${BB_SRC} "" "${EX_NAME}" ""
else
  echo "Destination user account updating..."
  permissionWrite=`rabbitmqctl list_user_permissions user${BB_SRC} | egrep ${INFO_SRC_VHOST} | sed s/"\t"/#/g | cut -d '#' -f 3`
  permissionRead=`rabbitmqctl list_user_permissions user${BB_SRC} | egrep ${INFO_SRC_VHOST} | sed s/"\t"/#/g | cut -d '#' -f 4`

  
   # check permission write for exchange name if not exist
  if [ -z != ${permissionWrite} ]
  then
    if [[ ${permissionWrite} != *"${EX_NAME}"* ]]
    then
      #Add permission
      permissionWriteConcat="${permissionWrite}|${EX_NAME}" 
    fi
  else
	  permissionWriteConcat="${EX_NAME}" 		
  fi
  
  #no change for Read
  permissionReadConcat="${permissionRead}"
  

  # update permissions
  rabbitmqctl set_permissions -p ${INFO_SRC_VHOST} user${BB_SRC} "" "${permissionWriteConcat}" "${permissionReadConcat}"
 
fi

echo ""
echo "---------------------------------------"
echo "Creation RMQ ELT Case 2 PRI Template succeed"
echo "Building block source : ${BB_SRC}"
echo "Building block destination : ${BB_DEST}"
echo "Interface : ${ITF}"
echo "---------------------------------------"
echo ""
echo "File generation and execute command of interface succeed 2"
echo ""
