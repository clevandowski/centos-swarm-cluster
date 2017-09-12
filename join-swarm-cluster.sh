#/bin/bash

# $1: token manager/worker
# $2: addresse du leader

docker swarm join --token $1 $2:2377
