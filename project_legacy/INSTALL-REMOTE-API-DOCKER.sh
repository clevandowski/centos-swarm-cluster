#!/bin/bash

cat > docker.conf <<EOF
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix://var/run/docker.sock
EOF

mv docker.conf /etc/systemd/system/docker.service.d/

systemctl daemon-reload
systemctl restart docker
