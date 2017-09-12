#!/bin/bash

# A lancer uniquement sur un noeud contenant un docker-engine configure en manager

# $1: Pour chaque instance du cluster RabbitMQ (séparée par |), on indique une liste (séparée par ,) de noeuds (au sens Swarm) où l'instance peut se déployer
# On peut donc ajouter autant d'instance de RabbitMQ que nécessaire
# exemple: node1,node3,node4|node2,node3,node4|node3,node4

node_number=1
for rabbitmq_instance_list in $(echo $1 | tr '|' ' '); do
  for rabbitmq_placement_constraint_node in $(echo $rabbitmq_instance_list | tr ',' ' '); do
    echo "$rabbitmq_placement_constraint_node: node$node_number=node$node_number"
    docker node update --label-add "node$node_number=node$node_number" $rabbitmq_placement_constraint_node >/dev/null
  done
  node_number=$((node_number+1))
done
