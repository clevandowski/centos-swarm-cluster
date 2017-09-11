#!/bin/bash

#!/bin/bash

# User leader/managers/workers
SWARM_USER=""

# L'adresse du leader
SWARM_LEADER=""

# Les adresses des managers séparées par des espaces
SWARM_MANAGERS=""

# Les adresses des workers séparées par des espaces
SWARM_WORKERS=""

# $1 : répertoire où se trouve l'image $RABBITMQ_IMAGE sur le host
RABBITMQ_IMAGE="rabbitmqClusterPython.tar"

if [ -n "$SWARM_LEADER" ]; then
  swarm_user_at_leader="$SWARM_USER@$SWARM_LEADER"
  scp $1/$RABBITMQ_IMAGE $swarm_user_at_leader:/tmp
  ./remoteExec.sh -s "docker-load-rabbitmq-image.sh" -a "/tmp/$RABBITMQ_IMAGE" -v "$swarm_user_at_leader"
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
    scp $1/$RABBITMQ_IMAGE $SWARM_USER@$swarm_manager:/tmp
  done
  ./remoteExec.sh -s "docker-load-rabbitmq-image.sh" -a "/tmp/$RABBITMQ_IMAGE" -v "$swarm_user_at_managers"
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
    scp $1/$RABBITMQ_IMAGE $SWARM_USER@$swarm_worker:/tmp
  done
  ./remoteExec.sh -s "docker-load-rabbitmq-image.sh" -a "/tmp/$RABBITMQ_IMAGE" -v "$swarm_user_at_workers"
else
  echo "[INFO] Pas de workers configurés dans SWARM_WORKERS"
fi
