#!/bin/bash
BASE=/opt
DAEMONBASE=$BASE/cryptoescudo
DAEMON=$DAEMONBASE/cryptoescudod
DAEMONDATA=$DAEMONBASE/data
DAEMONCONF=$DAEMONDATA/cryptoescudo.conf

EXPLORERBASE=/opt/cryptoescudo-explorer

if [ ! -f "$DAEMON" ]; then
    echo "$DAEMON does not exist. Install it first !!!"
else
	cd /tmp

	#curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
	apt-get install -y nodejs
	apt-get install -y npm
	#apt-get install -y mongodb
 
  # MongoDB 6
	apt-get install -y gnupg
  wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add -
	echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list
	apt-get update
	apt-get install -y mongodb-org

	# MongoDB database
	mkdir -p /data/db/

	# Start MongoDB daemon
	nohup mongod &

	cd /opt

	git clone https://github.com/vdamas/cryptoescudo-explorer

	mv cryptoescudo-explorer $EXPLORERBASE

	cd $EXPLORERBASE
	
	# Install node modules
	npm install --production

	IQUIDUSPASS=$(openssl rand -hex 10) # generate pass
	
	# Add iquidus user to MongoDB
	mongosh --eval 'db.createUser( { user: "iquidus", pwd: "'$IQUIDUSPASS'", roles: [ "readWrite" ] } );' explorerdb

	# Set iquidus explorer config file
	RPCPASS=$(grep ^rpcpassword= $DAEMONCONF | awk '{split($0,a,"="); print a[2]}')
cat << EOT > $EXPLORERBASE/settings.json
{
  // name your instance!
  "title": "Cryptoescudo Explorer",

  "address": "127.0.0.1:81",

  // coin name
  "coin": "Cryptoescudo",

  // coin symbol
  "symbol": "CESC",

  // logo
  "logo": "/images/logo.png",
  // Optional header logo - change false to e.g. "/images/headerlogo.png"
  "headerlogo": false,

  // favicon
  "favicon": "public/favicon.ico",

  // Uses bootswatch themes (http://bootswatch.com/)
  // Valid options:
  //     Cerulean, Cosmo, Cyborg, Darkly, Flatly, Journal, Litera, Lumen, 
  //     Lux, Materia, Minty, Pulse, Sandstone, Simplex, Sketchy, Slate, 
  //     Solar, Spacelab, Superhero, United, Yeti
  // theme (see /public/themes for available themes)
  "theme": "Yeti",

  // port to listen for requests on.
  "port" : 81,

  // database settings (MongoDB)
  "dbsettings": {
    "user": "iquidus",
    "password": "$IQUIDUSPASS",
    "database": "explorerdb",
    "address": "localhost",
    "port": 27017
  },

  //update script settings
  "update_timeout": 10,
  "check_timeout": 250,
  "block_parallel_tasks": 1,

  // wallet settings
  "use_rpc": true,

  "wallet": {
    "host": "localhost",
    "port": 61142,
    "username": "cryptoescudorpc",
    "password": "$RPCPASS"
  },

  // confirmations
  "confirmations": 40,

  // language settings
  "locale": "locale/en.json",

  // menu settings
  "display": {
    "api": true,
    "markets": false,
    "richlist": true,
    "twitter": true,
    "facebook": true,
    "googleplus": false,
    "youtube": false,
    "search": true,
    "movement": true,
    "network": true,
    // Settings to switch navbar theme, leaving both false will use the 'primary' navbar
    "navbar_dark": false,
    "navbar_light": true
  },

  // index page (valid options for difficulty are POW, POS or Hybrid)
  "index": {
    "show_hashrate": true,
    // Show Market Cap in header
    "show_market_cap": false,
    // Show Market Cap in place of price box
    "show_market_cap_over_price": false,
    "difficulty": "POW",
    "last_txs": 100,
    "txs_per_page": 10
  },

  // ensure links on API page are valid
  "api": {
    "blockindex": 1337,
    "blockhash": "25cddc2f85c6b7aa1f547996d384c9778b0b6e4fa8824f20bc8caee52b503177",
    "txhash": "af59c7b477dd2539205127615eb0be8b87377a143a09d9f05dbc28612842afb3",
    "address": "CbosDaWAJrHcU7pX6928Ut23HfTifdr78S"
  },

  // market settings
  //included markets: altmarkets, fides, bittrex, poloniex, yobit, bleutrade
  //default market is loaded by default and determines last price in header
  "markets": {
    "coin": "JBS",
    "exchange": "BTC",
    "enabled": ["bittrex"],
    "ccex_key" : "Get-Your-Own-Key",
    "default": "bittrex"
  },

  // richlist/top100 settings
  "richlist": {
    "distribution": true,
    "received": true,
    "balance": true
  },
  // movement page settings
  // min amount: show transactions greater than this value
  // low flag: greater than this value flagged yellow
  // high flag: greater than this value flagged red
  "movement": {
    "min_amount": 100,
    "low_flag": 1000,
    "high_flag": 5000
  },

  // twitter, facebook, googleplus, youtube
  "twitter": "cryptoescudo",
  "facebook": "cryptoescudo",
  "googleplus": "yourgooglepluspage",
  "youtube": "youryoutubechannel",

  //genesis
  "genesis_tx": "719eb8409cc5b1fae88346195a0cf854ee70ecb0269a6e270272f962853acbd8",
  "genesis_block": "1089bfdd6ce386cb0c8b0ec80f1e0359da138f577c448d0077780144c4f75a26",

  //heavy (enable/disable additional heavy features)
  "heavy": false,

  //disable saving blocks & TXs via API during indexing.
  "lock_during_index": false,

  //amount of txs to index per address (stores latest n txs)
  "txcount": 250,
  "txcount_per_page": 50,

  //show total sent & received on address page (set false if PoS)
  "show_sent_received": true,

  // how to calculate current coin supply
  // COINBASE : total sent from coinbase (PoW)
  // GETINFO : retreive from getinfo api call (PoS)
  // HEAVY: retreive from heavys getsupply api call
  // BALANCES : total of all address balances
  // TXOUTSET : retreive from gettxoutsetinfo api call
  // BLOCKNUM : retreive from BLOCKNUM cryptoescudo formula
  "supply": "BLOCKNUM",

  // how to acquire network hashrate
  // getnetworkhashps: uses getnetworkhashps api call, returns in GH/s
  // netmhashps: uses getmininginfo.netmhashpsm returns in MH/s
  "nethash": "getnetworkhashps",

  // nethash unitd: sets nethash API return units
  // valid options: "P" (PH/s), "T" (TH/s), "G" (GH/s), "M" (MH/s), "K" (KH/s)
  "nethash_units": "G",

  // Address labels
  // example : "JhbrvAmM7kNpwA6wD5KoAsbtikLWWMNPcM": {"label": "This is a burn address", "type":"danger", "url":"http://example.com"}
  // label (required) = test to display
  // type (optional) = class of label, valid types: default, primary, warning, danger, success
  // url (optional) = url to link to for more information
  "labels": {
  //  "JSoEdU717hvz8KQVq2HfcqV9A79Wihzusu": {"label": "Developers address", "type":"primary", "url":"http://example.com"},
  //  "JSWVXHWeYNknPdG9uDrcBoZHztKMFCsndw": {"label": "Cryptsy"}
  }
}
EOT

# Get database
wget https://cryptoescudo.work/downloads/explorerdb-1.7.4-mongodb.tar.gz
tar -xvf explorerdb-1.7.4-mongodb.tar.gz
#mongo -eval 'db.dropDatabase()' explorerdb
mongorestore -d explorerdb --gzip ./explorerdb
rm -Rf ./explorerdb

	# Generate explorer start script
cat << EOT > $EXPLORERBASE/explorer_start.sh
cd $EXPLORERBASE
nohup npm start > debug.log 2>&1 &
EOT

	# Generate explorer start script
cat << EOT > $EXPLORERBASE/explorer_stop.sh
cd $EXPLORERBASE
npm stop
EOT

	# Generate explorer debug script
cat << EOT > $EXPLORERBASE/explorer_debug.sh
cd $EXPLORERBASE
tail -f debug.log
EOT

	# Generate explorer sync script
cat << EOT > $EXPLORERBASE/explorer_sync.sh

cd $EXPLORERBASE
node scripts/sync.js index update
node scripts/peers.js
#node scripts/sync.js market
EOT

	
	chmod +x $EXPLORERBASE/explorer_start.sh
	chmod +x $EXPLORERBASE/explorer_stop.sh
	chmod +x $EXPLORERBASE/explorer_debug.sh
	chmod +x $EXPLORERBASE/explorer_sync.sh	

fi
