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
crontab -l | { cat; echo "*/5 * * * * cd /opt/cryptoescudo-explorer && find ./tmp/index.pid -type f -mmin +15 -exec rm -f {} + >/dev/null 2>&1"; } | crontab -

# Update explorer index
crontab -l | { cat; echo "# Update explorer index"; } | crontab -
crontab -l | { cat; echo "*/1 * * * * cd /opt/cryptoescudo-explorer && node ./scripts/sync.js index update &> ./tmp/syncindex.out"; } | crontab -

# Update markets
crontab -l | { cat; echo "# Update explorer markets"; } | crontab -
crontab -l | { cat; echo "*/2 * * * * cd /opt/cryptoescudo-explorer && node ./scripts/sync.js market &> ./syncmarket.out"; } | crontab -

# Update peers
crontab -l | { cat; echo "# Update explorer peers"; } | crontab -
crontab -l | { cat; echo "*/5 * * * * cd /opt/cryptoescudo-explorer && node ./scripts/peers.js &> ./syncpeers.out"; } | crontab -

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

cp $SCRIPTPATH/set-cronjobs.sh /opt
cp $SCRIPTPATH/start-all.sh /opt

chmod +x ./install-daemon-v1.3.0.0-20170628.sh
chmod +x ./install-explorer-1.7.4-mongodb6.sh
chmod +x ./install-electrumx-1.13.sh
chmod +x /opt/set-cronjobs.sh
chmod +x /opt/start-all.sh

TZ=Europe/Lisbon
DEBIAN_FRONTEND=noninteractive

# ElectrumX run with root (to review later)
ALLOW_ROOT=1

# Install daemon
./install-daemon-v1.3.0.0-20170628.sh

# Update daemon 
/opt/cryptoescudo/chain_update.sh usedrive

# Install explorer (auto updates)
./install-explorer-1.7.4-mongodb6.sh

# Install electrumX (auto updates)
./install-electrumx-1.13.sh

# Configure cron jobs
/opt/set-cronjobs.sh

# Start daemon, explorer and electrum
/opt/start-all.sh

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
