#!/bin/bash

# A lancer uniquement sur un noeud contenant un docker-engine configure en manager

# Le nom des noeuds est le champ HOSTNAME lorsqu'on fait la commande 'docker node ls'
# Le champ ID peut aussi fonctionner mais on n'a pas la main dessus, alors que le hostname est posé lorsque la VM est creee
RABBITMQ_INSTANCE1_AUTHORIZED_LOCATIONS=$(echo $1 | tr ',' ' ')
RABBITMQ_INSTANCE2_AUTHORIZED_LOCATIONS=$(echo $2 | tr ',' ' ')

for current_hostname in $RABBITMQ_INSTANCE1_AUTHORIZED_LOCATIONS; do
  for current_node in $RABBITMQ_INSTANCE1_AUTHORIZED_LOCATIONS; do
    # ATTENTION node1=node1 n'est PAS lié au nom d'un des hostname
    docker node update --label-add "node1=node1" $current_node >/dev/null
  done
done

for current_hostname in $RABBITMQ_INSTANCE2_AUTHORIZED_LOCATIONS; do
  for current_node in $RABBITMQ_INSTANCE2_AUTHORIZED_LOCATIONS; do
    # ATTENTION node2=node2 n'est PAS lié au nom d'un des hostname
    docker node update --label-add "node2=node2" $current_node >/dev/null
  done
done

