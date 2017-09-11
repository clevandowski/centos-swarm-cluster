#!/bin/bash

docker swarm init --advertise-addr &>/dev/null

token_manager=$(docker swarm join-token manager -q)
token_worker=$(docker swarm join-token worker -q)

echo $token_manager $token_worker

