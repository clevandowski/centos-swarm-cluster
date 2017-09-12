#!/bin/bash

path="/home"


#----------------------------------------------------------------------------
#----------------------------- EXCHANGE -------------------------------------
#----------------------------------------------------------------------------
EX_NAME="E-TP-${ZONE}-S-SEC-${ITF}"
# name exchange dead letter
EX_DL=""
# durability (mandatory)
EX_DURABILITY="true"
# auto delete (mandatory)
EX_AUTO_DELETE="false"
# internal (mandatory)
EX_INTERNAL="false"
# (optional) name exchange alternate
EX_ALTERNATE="E-TP-${ZONE}-${ITF}-DEAD"


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
Q_NAME="Q-${ZONE}-${ITF}-${BB_DEST}"
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
Q_RT="*.${ITF}.${BB_DEST}.*"


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


#-------------------------------------------------------------------------------------
#----------------------------- COMMAND RABBIT MQ -------------------------------------
#-------------------------------------------------------------------------------------

# -------------
# Exchange
# -------------
$path/rabbitmqadmin --username=${INFO_SRC_USER} --password=${INFO_SRC_PASS} declare exchange --vhost=${INFO_SRC_VHOST} name=${EX_DEAD_NAME} type=topic durable=${EX_DEAD_DURABILITY} auto_delete=${EX_DEAD_AUTO_DELETE} internal=${EX_DEAD_INTERNAL}


$path/rabbitmqadmin --username=${INFO_SRC_USER} --password=${INFO_SRC_PASS} declare exchange --vhost=${INFO_SRC_VHOST} name=${EX_NAME} type=topic durable=${EX_DURABILITY} auto_delete=${EX_AUTO_DELETE} internal=${EX_INTERNAL} 'arguments={"alternate-exchange":"'${EX_ALTERNATE}'"}'

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

# if  [[ ! -z "${Q_MASTER_LOCATOR}" ]]   
# then
# addQueue+=",\"x-queue-master-locator\":\"min-masters\""
# fi

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
# User account destination
# -------------
user=`rabbitmqctl list_users | egrep user${BB_DEST} | cut -d '[' -f 1 | tr -s ' '`

if [ -z "$user"  ];
then
  echo "Destination user account creating..."
  rabbitmqctl add_user user${BB_DEST} user${BB_DEST}
  #rabbitmqctl set_user_tags $INFO_SRC_USER 
  rabbitmqctl set_permissions -p $INFO_SRC_VHOST user${BB_DEST} "" "" "Q-${ZONE}-${ITF}-${BB_DEST}"
else
  echo "Destination user account updating..."
  permissionWrite=`rabbitmqctl list_user_permissions user${BB_DEST} | egrep ${INFO_SRC_VHOST} | sed s/"\t"/#/g | cut -d '#' -f 3`
  permissionRead=`rabbitmqctl list_user_permissions user${BB_DEST} | egrep ${INFO_SRC_VHOST} | sed s/"\t"/#/g | cut -d '#' -f 4`

 
  permissionWriteConcat="${permissionWrite}" 
       
  # check permission read for queue name if not exist
  if [ -z != ${permissionRead} ]
  then
    if [[ ${permissionRead} != *"${Q_NAME}"* ]]
    then
      #Add permission
      permissionReadConcat="${permissionRead}|${Q_NAME}"
    fi
  else
      permissionReadConcat="${Q_NAME}"	
  fi

  # update permissions
  rabbitmqctl set_permissions -p ${INFO_SRC_VHOST} user${BB_DEST} "" "${permissionWriteConcat}" "${permissionReadConcat}"
fi

#user shovel
# -------------
# Shovel User account
# -------------

userShovel=`rabbitmqctl list_users | egrep user-S-SEC-${ITF} | cut -d '[' -f 1 | tr -s ' '`

if [ -z "$userShovel"  ];
then
  echo "Destination user account creating..."
  rabbitmqctl add_user user-S-SEC-${ITF} "S-SEC-|*_-${ITF}!*-${BB_DEST}|"
  #rabbitmqctl set_user_tags $INFO_SRC_USER 
  rabbitmqctl set_permissions -p $INFO_SRC_VHOST user-S-SEC-${ITF} "" "E-TP-${ZONE}-S-SEC-${ITF}" "Q-SEC-${ITF}-SHO" 
else
  echo "Shovel user account updating..."
  rabbitmqctl set_permissions -p $INFO_SRC_VHOST user-S-SEC-${ITF} "" "E-TP-${ZONE}-S-SEC-${ITF}" "Q-SEC-${ITF}-SHO" 
fi

  





echo ""
echo "---------------------------------------"
echo "Creation RMQ ELT Case 2 PRI Template succeed"
echo "Building block source : ${BB_SRC}"
echo "Building block destination : ${BB_DEST}"
echo "Interface : ${ITF}"
echo "---------------------------------------"
echo ""
