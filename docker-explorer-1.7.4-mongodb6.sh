#!/bin/bash

# Absolute path to this script
SCRIPT=$(readlink -f "$0")

# Absolute path this script is in
SCRIPTPATH=$(dirname "$SCRIPT")

tee "$SCRIPTPATH/Dockerfile" > /dev/null <<EOF
FROM cryptoescudo:v1.3.0.0-20170628

COPY ./install-explorer-1.7.4-mongodb6.sh /tmp/

ENV TZ=Europe/Lisbon
ENV DEBIAN_FRONTEND=noninteractive

RUN chmod +x /tmp/install-explorer-1.7.4-mongodb6.sh

RUN /tmp/install-explorer-1.7.4-mongodb6.sh

EXPOSE 81 61143
EOF

docker build -t cryptoescudo-explorer:1.7.4 .
