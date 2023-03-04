#!/bin/bash
BASE=/opt
DAEMONBASE=$BASE/cryptoescudo
DAEMON=$DAEMONBASE/cryptoescudod
DAEMONDATA=$DAEMONBASE/data
DAEMONCONF=$DAEMONDATA/cryptoescudo.conf

ELECTRUMBASE=/opt/electrumX-1.13.0

# Absolute path to this script
SCRIPT=$(readlink -f "$0")

# Absolute path this script is in
SCRIPTPATH=$(dirname "$SCRIPT")

if [ ! -f "$DAEMON" ]; then
    echo "$DAEMON does not exist. Install it first !!!"
else

	# Update 
	apt-get update -y
	apt-get install -y git make build-essential libssl-dev zlib1g-dev \
	libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev \
	libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev \
	libgdbm-dev libnss3-dev libedit-dev libc6-dev libleveldb-dev

	# Install python 3.6
	cd /tmp
	wget https://www.python.org/ftp/python/3.6.15/Python-3.6.15.tgz
	tar -xzf Python-3.6.15.tgz
	cd Python-3.6.15
	#./configure --enable-optimizations  -with-lto  --with-pydebug
	./configure  -with-lto  --with-pydebug
	make -j 8  # adjust for number of your CPU cores
	make altinstall

	# Install python dependencies
	/usr/local/bin/python3.6 -m pip install --upgrade pip setuptools wheel
	/usr/local/bin/python3.6 -m pip install --upgrade aiohttp pylru leveldb plyvel aiorpcx ecdsa aiorpcx


	# Install electrumX-1.13.0
	cd $BASE

	git clone https://github.com/vdamas/cesc-electrumX-1.13.0 electrumX-1.13.0

	cd $ELECTRUMBASE
	/usr/local/bin/python3.6 setup.py install
	mkdir -p $ELECTRUMBASE/.electrumx/db

	# Generate SSL cert
	openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out  server.pass.key
	openssl rsa -passin pass:x -in server.pass.key -out $ELECTRUMBASE/.electrumx/server.key
	rm server.pass.key

	openssl req -new -key $ELECTRUMBASE/.electrumx/server.key -out $ELECTRUMBASE/.electrumx/server.csr -subj "/C=PT/ST=Lisbon/L=Lisbon/O=Cryptoescudo/OU=IT Department/CN=cryptoescudo"
	openssl x509 -req -days 1825 -in $ELECTRUMBASE/.electrumx/server.csr -signkey $ELECTRUMBASE/.electrumx/server.key -out $ELECTRUMBASE/.electrumx/server.crt

	# Generate banner file

cat << EOT > $ELECTRUMBASE/.electrumx/banner_file.txt
**** Cryptoescudo.Network - Hosted for the community ****
Cryptoescudo Version: \$DAEMON_VERSION
Cryptoescudo Subversion: \$DAEMON_SUBVERSION
ElectrumX Server Version: \$SERVER_VERSION
ElectrumX Server Subversion: \$SERVER_SUBVERSION
EOT

	# Set electrumx config file
RPCPASS=$(grep ^rpcpassword= $DAEMONCONF | awk '{split($0,a,"="); print a[2]}')
cat << EOT > $ELECTRUMBASE/.electrumx/electrumx.conf
COIN=Cryptoescudo
DB_DIRECTORY=/opt/electrumX-1.13.0/.electrumx/db
DAEMON_URL=http://cryptoescudorpc:$RPCPASS@127.0.0.1:61142
NET=mainnet
DB_ENGINE=leveldb
HOST=
SSL_CERTFILE=$ELECTRUMBASE/.electrumx/server.crt
SSL_KEYFILE=$ELECTRUMBASE/.electrumx/server.key
BANNER_FILE=$ELECTRUMBASE/.electrumx/banner_file.txt
DONATION_ADDRESS=
SERVICES=rpc://127.0.0.1:8000,tcp://:50001,ssl://:50002
EOT

	# Generate electrumX start script
cat << EOT > $ELECTRUMBASE/electrumX_start.sh
!#/bin/bash

set -a 
source $ELECTRUMBASE/.electrumx/electrumx.conf
/usr/local/bin/python3.6 $ELECTRUMBASE/electrumx_server
EOT
	
	# Get electrumX database
	wget https://cryptoescudo.work/downloads/electrumX-1.13.0-leveldb.tar.gz
	tar -xvf ./electrumX-1.13.0-leveldb.tar.gz ./.electrumx/db/
	rm -f ./electrumX-1.13.0-leveldb-20220216.tar.gz
	
	chmod +x $ELECTRUMBASE/electrumX_start.sh
fi
