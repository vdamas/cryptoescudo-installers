!#/bin/bash

# Absolute path to this script
SCRIPT=$(readlink -f "$0")

# Absolute path this script is in
SCRIPTPATH=$(dirname "$SCRIPT")

tee "$SCRIPTPATH/Dockerfile" > /dev/null <<EOF
FROM cryptoescudo:v1.3.0.0-20170628

ENV TZ=Europe/Lisbon
ENV DEBIAN_FRONTEND=noninteractive

# ElectrumX on docker
ENV ALLOW_ROOT=1

COPY ./install-electrumX-1.13.sh /tmp/

RUN chmod +x /tmp/install-electrumX-1.13.sh

RUN /tmp/install-electrumX-1.13.sh

EXPOSE 50001 50002 61143
EOF

docker build -t electrumx1.13:v1.3.0.0-20170628 .
