#!/bin/bash
BASE=/opt
DAEMONBASE=$BASE/cryptoescudo
DAEMON=$DAEMONBASE/cryptoescudod
DAEMONDATA=$DAEMONBASE/data
DAEMONCONF=$DAEMONDATA/cryptoescudo.conf

DAEMONSTART=$DAEMONBASE/daemon_start.sh
DAEMONDEBUG=$DAEMONBASE/daemon_debug.sh
DAEMONSTOP=$DAEMONBASE/daemon_stop.sh
DAEMONDEKILL=$DAEMONBASE/daemon_kill.sh
DAEMONQUERY=$DAEMONBASE/daemon_query.sh
DAEMONCHAINUPD=$DAEMONBASE/chain_update.sh

# Absolute path to this script
SCRIPT=$(readlink -f "$0")

# Absolute path this script is in
SCRIPTPATH=$(dirname "$SCRIPT")

if [ -f "$DAEMON" ]; then
    echo "$DAEMON exists."
else

# Apt update
apt-get update -y

# Generic Utils
apt-get install curl wget zip unzip nano apt-utils -y

    [ -d /tmp] || mkdir /tmp
    mkdir $DAEMONBASE
    mkdir $DAEMONDATA
    cd /tmp
    wget http://cryptoescudo.pt/download/01030000/linux/cryptoescudo-1.3.0.0-linux.zip
    unzip -o cryptoescudo-1.3.0.0-linux.zip -d ./cryptoescudo
    cp -R cryptoescudo/cryptoescudo-1.3.0.0-linux/64/* $DAEMONBASE
    chmod +x $DAEMON

# Create cryptoescudo.conf
rpcpass=$(openssl rand -hex 32) # generate pass
tee "$DAEMONCONF" > /dev/null <<EOF
rpcuser=cryptoescudorpc
rpcpassword=$rpcpass
rpcport=61142
rpcallowip=127.0.0.1
server=1
listen=1
txindex=1
EOF

chmod +x $DAEMONBASE/*.sh

echo "Done! Check scripts in $DAEMONBASE to manage cryptoescudo daemon !"

fi

