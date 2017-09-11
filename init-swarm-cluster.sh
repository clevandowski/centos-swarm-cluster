#!/bin/bash

docker swarm init --advertise-addr $1

token-manager=$(docker swarm join-token manager)
token-worker=$(docker swarm join-token worker)

echo $token-manager $token-worker

