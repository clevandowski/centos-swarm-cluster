#!/bin/bash

#!/bin/bash

#!/bin/bash

# User leader/managers/workers
SWARM_USER="adminprod"

# L'adresse du leader
SWARM_LEADER="172.25.252.225"

# Les adresses des managers sÃ©parÃ©es par des espaces
SWARM_MANAGERS="172.25.254.88 172.25.254.89"

# Les adresses des workers sÃ©parÃ©es par des espaces
SWARM_WORKERS="172.25.254.90"

# Chemin complet où se trouve l'image $RABBITMQ_IMAGE_FILE sur le host
RABBITMQ_IMAGE_PATH="../rabbitmqClusterPython.tar"

# Chemin complet du répertoire rabbit_config
RABBITMQ_CONFIG_DIRECTORY="/home/adminprod/CMQ_V2/devOpsRemoteExec/rabbit_config/"

# Répertoire rabbitmq_config_server
RABBITMQ_CONFIG_SERVER_DIRECTORY="/home/adminprod/CMQ_V2/devOpsRemoteExec/volume/"

# Chemin où sont copiées les configurations dans les noeuds
NODE_CONFIGURATION_DIRECTORY="/home/adminprod/"

RABBITMQ_IMAGE_FILE=$(basename $RABBITMQ_IMAGE_PATH)

if [ -n "$SWARM_LEADER" ]; then
  swarm_user_at_leader="$SWARM_USER@$SWARM_LEADER"
  # Image docker
  scp $RABBITMQ_IMAGE_PATH $swarm_user_at_leader:/tmp
  # rabbit_config
  scp -rp $RABBITMQ_CONFIG_DIRECTORY $swarm_user_at_leader:$NODE_CONFIGURATION_DIRECTORY
  # rabbit_config_server
  scp -rp $RABBITMQ_CONFIG_SERVER_DIRECTORY $swarm_user_at_leader:$NODE_CONFIGURATION_DIRECTORY
  ./remoteExec.sh -s "docker-load-rabbitmq-image.sh" -a "/tmp/$RABBITMQ_IMAGE_FILE" -v "$swarm_user_at_leader"
else
  echo "[ERROR] Pas de leader configuré dans SWARM_LEADER"
  exit 1
fi

if [ -n "$SWARM_MANAGERS" ]; then
  swarm_user_at_managers=""
  for swarm_manager in $SWARM_MANAGERS; do
    if [ -z "$swarm_user_at_managers" ]; then
      swarm_user_at_managers="$SWARM_USER@$swarm_manager"
    else
      swarm_user_at_managers="$swarm_user_at_managers $SWARM_USER@$swarm_manager"
    fi
    scp $RABBITMQ_IMAGE_PATH $SWARM_USER@$swarm_manager:/tmp
    # rabbit_config
    scp -rp $RABBITMQ_CONFIG_DIRECTORY $SWARM_USER@$swarm_manager:$NODE_CONFIGURATION_DIRECTORY
    # rabbit_config_server
    scp -rp $RABBITMQ_CONFIG_SERVER_DIRECTORY $SWARM_USER@$swarm_manager:$NODE_CONFIGURATION_DIRECTORY
  done
  ./remoteExec.sh -s "docker-load-rabbitmq-image.sh" -a "/tmp/$RABBITMQ_IMAGE_FILE" -v "$swarm_user_at_managers"
else
  echo "[WARNING] Pas de managers configurés dans SWARM_MANAGERS"
fi

if [ -n "$SWARM_WORKERS" ]; then
  swarm_user_at_workers=""
  for swarm_worker in $SWARM_WORKERS; do
    if [ -z "$swarm_user_at_workers" ]; then
      swarm_user_at_workers="$SWARM_USER@$swarm_worker"
    else
      swarm_user_at_workers="$swarm_user_at_workers $SWARM_USER@$swarm_worker"
    fi
    scp $RABBITMQ_IMAGE_PATH $SWARM_USER@$swarm_worker:/tmp
    # rabbit_config
    scp -rp $RABBITMQ_CONFIG_DIRECTORY $SWARM_USER@$swarm_worker:$NODE_CONFIGURATION_DIRECTORY
    # rabbit_config_server
    scp -rp $RABBITMQ_CONFIG_SERVER_DIRECTORY $SWARM_USER@$swarm_worker:$NODE_CONFIGURATION_DIRECTORY
  done
  ./remoteExec.sh -s "docker-load-rabbitmq-image.sh" -a "/tmp/$RABBITMQ_IMAGE_FILE" -v "$swarm_user_at_workers"
else
  echo "[INFO] Pas de workers configurés dans SWARM_WORKERS"
fi
