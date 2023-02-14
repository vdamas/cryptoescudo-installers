#!/bin/bash

# Check daemon running
DAEMON=$(ps -ef | awk '/[d]atadir.*daemon/{print $2}' | wc -l)
if [ "$DAEMON" -gt 0 ]; then
 echo "Cryptoescudo daemon is running"
 exit 1
fi

# Absolute path to this script
SCRIPT=$(readlink -f "$0")

# Absolute path this script is in
SCRIPTPATH=$(dirname "$SCRIPT")

# Call daemon start
$SCRIPTPATH/cryptoescudod -datadir=$SCRIPTPATH/data -daemon