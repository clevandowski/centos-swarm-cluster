#!/bin/bash

docker exec -i $1 bash << 'EOF'
cd /home
./configRabbitMQServer.sh
exit
EOF


