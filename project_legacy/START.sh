#!/bin/bash

echo "Docker stack deploy..."
docker stack deploy --compose-file=docker-compose.yml $1




