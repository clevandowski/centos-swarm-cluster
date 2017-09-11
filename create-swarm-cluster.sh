#!/bin/bash

# User leader/managers/workers
SWARM_USER=""

# L'adresse du leader
SWARM_LEADER=""

# Les adresses des managers séparées par des espaces
SWARM_MANAGERS=""

# Les adresses des workers séparées par des espaces
SWARM_WORKERS=""

token_manager=""
token_worker=""
if [ -n "$SWARM_LEADER" ]; then
  result=$(./remoteExec.sh -s init-swarm-cluster.sh -a "$SWARM_LEADER" -v "$SWARM_USER@$SWARM_LEADER")
  if [ "$?" == 0 ]; then
    token_manager=$(echo result | cut -d' ' -f1)
    token_worker=$(echo result | cut -d' ' -f2)
  else
    echo "[ERROR] Erreur lors de l'initialisation du cluster"
    exit 1
  fi
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
  done

  ./remoteExec.sh -s join-swarm-cluster.sh -a "$SWARM_LEADER" -v "$swarm_user_at_managers"
  if [ "$?" != 0 ]; then
    echo "[ERROR] Erreur lors de la jointure des managers"
    exit 1
  fi
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
  done

  ./remoteExec.sh -s join-swarm-cluster.sh -a "$SWARM_LEADER" -v "$swarm_user_at_workers"
  if [ "$?" != 0 ]; then
    echo "[ERROR] Erreur lors de la jointure des workers"
    exit 1
  fi
else
  echo "[INFO] Pas de workers configurés dans SWARM_WORKERS"
fi
