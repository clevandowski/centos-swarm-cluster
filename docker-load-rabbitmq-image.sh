#!/bin/bash

# $1 : chemin complet où se trouve l'image $RABBITMQ_IMAGE sur le host (ex: /tmp/$RABBITMQ_IMAGE)

docker image load --input $1
