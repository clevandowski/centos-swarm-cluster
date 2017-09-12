#!/bin/bash

echo "Stop cluster message queuing..."
docker stack rm $1

sleep 5
echo "Network deleted"


