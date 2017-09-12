#!/bin/bash

# on démarre le rabbit -- on relance la CMD de l'image docker de base
/opt/rabbit/startrabbit.sh &

HEALTH_CHECK=""

echo "starting healtcheck"
# On vérifie l'état du serveur rabbit et on boucle tant que le healthcheck ne passe pas
while [ -z ${HEALTH_CHECK} ]
do
    echo "checking ..."
    HEALTH_CHECK=$(rabbitmqctl node_health_check | grep "Health check passed")
    echo ${HEALTH_CHECK}
    sleep 5
done

echo "healthcheck done ${HEALTH_CHECK}"
