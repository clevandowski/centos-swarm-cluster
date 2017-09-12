#!/bin/bash

container=`docker ps | grep $1 | tr -s ' ' | cut -d ' ' -f 1 `
echo $container

echo "Manager node configuration..."
./config_CMQ.sh $container


