#!/bin/bash

# Absolute path to this script
SCRIPT=$(readlink -f "$0")

# Absolute path this script is in
SCRIPTPATH=$(dirname "$SCRIPT")

tee "$SCRIPTPATH/Dockerfile" > /dev/null <<EOF
FROM ubuntu:18.04

COPY ./buildinstall-daemon-v1.1.5.1-20141117.sh /tmp/

RUN chmod +x /tmp/buildinstall-daemon-v1.1.5.1-20141117.sh

RUN /tmp/buildinstall-daemon-v1.1.5.1-20141117.sh

EXPOSE 61143
EOF

docker build -t cryptoescudo:v1.1.5.1-20141117 .
