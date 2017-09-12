#!/bin/bash

container=`docker ps | grep $1 | tr -s ' ' | cut -d ' ' -f 1 `
echo $container

docker exec -i $container bash << 'EOF'
cd /home
./CREATE-RMQ-ELT-CASE3-TYPE_ITF-SEC.sh
exit
EOF


