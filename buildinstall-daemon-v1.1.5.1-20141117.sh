#!/bin/bash
BASE=/opt
DAEMONBASE=$BASE/cryptoescudo
DAEMON=$DAEMONBASE/cryptoescudod
DAEMONDATA=$DAEMONBASE/data
DAEMONCONF=$DAEMONDATA/cryptoescudo.conf

DAEMONSCRIPTS=https://raw.githubusercontent.com/vdamas/cryptoescudo-installer/main/daemon-scripts/
DAEMONSTART=$DAEMONBASE/daemon_start.sh
DAEMONDEBUG=$DAEMONBASE/daemon_debug.sh
DAEMONSTOP=$DAEMONBASE/daemon_stop.sh
DAEMONKILL=$DAEMONBASE/daemon_kill.sh
DAEMONQUERY=$DAEMONBASE/daemon_query.sh
DAEMONCHAINUPD=$DAEMONBASE/chain_update.sh


# Absolute path to this script
SCRIPT=$(readlink -f "$0")

# Absolute path this script is in
SCRIPTPATH=$(dirname "$SCRIPT")

if [ -f "$DAEMON" ]; then
    echo "$DAEMON exists."
else

	# Create folders
    [ -d /tmp] || mkdir /tmp
    mkdir $DAEMONBASE
    mkdir $DAEMONDATA
    cd /tmp

	# Apt update
	apt-get update -y

	# Generic Utils
	apt-get install curl wget zip unzip nano apt-utils -y

	# Build utils
	apt-get install build-essential -y

	# Fix Bignum error
	apt-get install libssl-dev -y
	apt-get install libssl1.0-dev -y

	apt-get install libdb4.8-dev -y
	apt-get install libdb4.8++-dev -y
	apt-get install libboost-all-dev -y

	# Fix missing file "db_cxx.h"
	apt-get install libdb++-dev -y

	# Fix fatal error: miniupnpc/miniwget.h
	apt-get remove qt3-dev-tools libqt3-mt-dev -y
	apt-get install libqt4-dev libminiupnpc-dev -y

	# Fix /usr/bin/ld: cannot find -lz
	apt-get install zlib1g-dev -y

	cd $tmpdir
	rm v1.1.5.1-20141117-public.zip
	rm -Rf v1.1.5.1-20141117-public

	# Download source
	wget -O v1.1.5.1-20141117-public.zip http://cryptoescudo.pt/download/20141117/source.zip

	# Unzip source
	unzip v1.1.5.1-20141117-public.zip
	mv source v1.1.5.1-20141117-public
	cd v1.1.5.1-20141117-public/src/

	# Update atomic_pointer.h with ARM64 support
	wget -O leveldb/port/atomic_pointer.h https://raw.githubusercontent.com/VDamas/cryptoescudo/master/src/leveldb/port/atomic_pointer.h
	chmod +x leveldb/build_detect_platform

	make -f makefile.unix

	cp cryptoescudod $DAEMONBASE
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

	# Daemon scripts
	wget $DAEMONSCRIPTS/daemon_start.sh -O $DAEMONSTART
	wget $DAEMONSCRIPTS/daemon_debug.sh -O $DAEMONDEBUG
	wget $DAEMONSCRIPTS/daemon_stop.sh -O $DAEMONSTOP
	wget $DAEMONSCRIPTS/daemon_kill.sh -O $DAEMONKILL
	wget $DAEMONSCRIPTS/daemon_query.sh -O $DAEMONQUERY
	wget $DAEMONSCRIPTS/chain_update.sh -O $DAEMONCHAINUPD

	chmod +x $DAEMONBASE/*.sh

	echo "Done! Check scripts in $DAEMONBASE to manage cryptoescudo daemon !"

fi
