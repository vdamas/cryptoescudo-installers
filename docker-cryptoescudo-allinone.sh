#!/bin/bash

# Time start
res1=$(date +%s.%N)

# Absolute path to this script
SCRIPT=$(readlink -f "$0")

# Absolute path this script is in
SCRIPTPATH=$(dirname "$SCRIPT")

tee "$SCRIPTPATH/set-cronjobs.sh" > /dev/null <<EOF
#!/bin/bash

apt-get update
apt-get install nano
apt-get install cron

# Check if explorer sync stuck
crontab -l | { cat; echo "# Check if explorer sync stuck"; } | crontab -
crontab -l | { cat; echo "*/5 * * * * cd /opt/explorer && find ./tmp/index.pid -type f -mmin +15 -exec rm -f {} + >/dev/null 2>&1"; } | crontab -

# Update explorer index
crontab -l | { cat; echo "# Update explorer index"; } | crontab -
crontab -l | { cat; echo "*/1 * * * * cd /opt/explorer && node ./scripts/sync.js index update &> ./tmp/syncindex.out"; } | crontab -

# Update markets
crontab -l | { cat; echo "# Update explorer markets"; } | crontab -
crontab -l | { cat; echo "*/2 * * * * cd /opt/explorer && node ./scripts/sync.js market &> ./syncmarket.out"; } | crontab -

# Update peers
crontab -l | { cat; echo "# Update explorer peers"; } | crontab -
crontab -l | { cat; echo "*/5 * * * * cd /opt/explorer && node ./scripts/peers.js &> ./syncpeers.out"; } | crontab -

EOF

tee "$SCRIPTPATH/start-all.sh" > /dev/null <<EOF
#!/bin/bash

echo "Starting MongoDB"
nohup mongod > /dev/null 2>&1 &

echo "Starting cryptoescudo daemon"
nohup /opt/cryptoescudo/daemon_start.sh > /dev/null 2>&1 &

cd /opt/explorer
echo "Starting explorer"
nohup ./explorer_start.sh > debug.log 2>&1 &

cd /opt/electrumx
echo "Starting electrumX"
nohup ./electrumx_start.sh > debug.log 2>&1 &

sleep infinity
EOF

tee "$SCRIPTPATH/Dockerfile" > /dev/null <<EOF
FROM ubuntu:22.04

COPY ./install-daemon-v1.3.0.0-20170628.sh /tmp/
COPY ./install-explorer-1.7.4-mongodb6.sh /tmp/
COPY ./install-electrumx-1.13.sh /tmp/
COPY ./set-cronjobs.sh /tmp/
COPY ./start-all.sh /opt

RUN chmod +x /tmp/install-daemon-v1.3.0.0-20170628.sh
RUN chmod +x /tmp/install-explorer-1.7.4-mongodb6.sh
RUN chmod +x /tmp/install-electrumx-1.13.sh
RUN chmod +x /tmp/set-cronjobs.sh
RUN chmod +x /opt/start-all.sh


ENV TZ=Europe/Lisbon
ENV DEBIAN_FRONTEND=noninteractive

# ElectrumX on docker
ENV ALLOW_ROOT=1

# Install daemon
RUN /tmp/install-daemon-v1.3.0.0-20170628.sh

# Update daemon 
RUN /opt/cryptoescudo/chain_update.sh usedrive

# Install explorer (auto updates)
RUN /tmp/install-explorer-1.7.4-mongodb6.sh

# Install electrumX (auto updates)
RUN /tmp/install-electrumx-1.13.sh

# Configure cron jobs
RUN /tmp/set-cronjobs.sh

# 81 - explorer / 50001 50002 electrumX / 61143 - cryptoescudo daemon 
EXPOSE 81 50001 50002 61143

CMD ["/bin/bash", "-c", "/opt/start-all.sh"]
EOF

docker build -t cryptoescudo-allinone:$(date +'%Y%m%d') .

# Calculate time elapsed
res2=$(date +%s.%N)
dt=$(echo "$res2 - $res1" | bc)
dd=$(echo "$dt/86400" | bc)
dt2=$(echo "$dt-86400*$dd" | bc)
dh=$(echo "$dt2/3600" | bc)
dt3=$(echo "$dt2-3600*$dh" | bc)
dm=$(echo "$dt3/60" | bc)
ds=$(echo "$dt3-60*$dm" | bc)

LC_NUMERIC=C printf "Total runtime: %d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds
echo $LC_NUMERIC
