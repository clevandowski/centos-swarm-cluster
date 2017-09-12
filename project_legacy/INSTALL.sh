#!/bin/bash

IP_REMOTE_SERVER_2=172.25.254.88 # worker1 for swarm, will be a node
IP_REMOTE_SERVER_3=172.25.254.89 # worker2 for swarm, will be a node
IP_REMOTE_SERVER_4=172.25.254.90 # worker3 for swarm, will be a node
IP_REMOTE_SERVER_5=172.25.254.93 # worker4 for swarm, will be a node

PORT_REMOTE_SERVER=2375

# ------------------
# Swarm installation
# ------------------
docker swarm init

#get command for add worker
token=`docker swarm join-token worker`

if [[ $token =~ ^(.*)(swarm.*?)$ ]] 
then 
     echo ""
     echo "------------------------------"
     comm=` echo "${BASH_REMATCH[2]}" | tr -d '\' 2> /dev/null`
     echo "Add worker 1 in swarm [$IP_REMOTE_SERVER_2]"
     docker --host tcp://${IP_REMOTE_SERVER_2}:${PORT_REMOTE_SERVER} $comm
    
     echo "Add worker 2 in swarm [$IP_REMOTE_SERVER_3]"
     docker --host tcp://${IP_REMOTE_SERVER_3}:${PORT_REMOTE_SERVER} $comm
    
     echo "Add worker 3 in swarm [$IP_REMOTE_SERVER_4]"
     docker --host tcp://${IP_REMOTE_SERVER_4}:${PORT_REMOTE_SERVER} $comm
    
#    echo "Add worker 4 in swarm [$IP_REMOTE_SERVER_5]"
#    docker --host tcp://${IP_REMOTE_SERVER_5}:${PORT_REMOTE_SERVER} $comm

else
   echo "Doesn't match"
fi



# ------------------
# Image installation
# ------------------
echo ""
echo "------------------------------"
echo "Image installation"

#Local
echo "For local repository manager node1"
docker load --input rabbitmqClusterPython.tar

#Remote
echo "For node 2 [$IP_REMOTE_SERVER_2]"
docker --host "tcp://${IP_REMOTE_SERVER_2}:${PORT_REMOTE_SERVER}" load -i rabbitmqClusterPython.tar

echo "For node 3 [$IP_REMOTE_SERVER_3]"
docker --host "tcp://${IP_REMOTE_SERVER_3}:${PORT_REMOTE_SERVER}" load -i rabbitmqClusterPython.tar

echo "For node 4 [$IP_REMOTE_SERVER_4]"
docker --host "tcp://${IP_REMOTE_SERVER_4}:${PORT_REMOTE_SERVER}" load -i rabbitmqClusterPython.tar

#echo "For node 5 [$IP_REMOTE_SERVER_1]"
#docker --host "tcp://${IP_REMOTE_SERVER_1}:${PORT_REMOTE_SERVER}" load -i rabbitmqClusterPython.tar

