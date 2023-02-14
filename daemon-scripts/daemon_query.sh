#!/bin/bash

# Check daemon running
DAEMON=$(ps -ef | awk '/[d]atadir.*daemon/{print $2}' | wc -l)
if [ "$DAEMON" -eq 0 ]; then
 echo "Cryptoescudo daemon not running"
 exit 1
fi

# Absolute path to this script
SCRIPT=$(readlink -f "$0")

# Absolute path this script is in
SCRIPTPATH=$(dirname "$SCRIPT")

if [ -z "$1" ]; then
	# Call daemon help
	$SCRIPTPATH/cryptoescudod -datadir=$SCRIPTPATH/data help
else
	# Call daemon
	$SCRIPTPATH/cryptoescudod -datadir=$SCRIPTPATH/data $1 $2 $3 $4 $5
fi