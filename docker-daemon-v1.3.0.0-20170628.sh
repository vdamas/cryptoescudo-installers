#!/bin/bash

# Absolute path to this script
SCRIPT=$(readlink -f "$0")

# Absolute path this script is in
SCRIPTPATH=$(dirname "$SCRIPT")

tee "$SCRIPTPATH/Dockerfile" > /dev/null <<EOF
FROM ubuntu:22.04

COPY ./install-daemon-v1.3.0.0-20170628.sh /tmp/

RUN chmod +x /tmp/install-daemon-v1.3.0.0-20170628.sh

RUN /tmp/install-daemon-v1.3.0.0-20170628.sh

EXPOSE 61143
EOF

docker build -t cryptoescudo:v1.3.0.0-20170628 .
