#!/bin/bash

docker swarm init --advertise-addr $1

token_manager=$(docker swarm join-token manager)
token_worker=$(docker swarm join-token worker)

echo $token_manager $token_worker

