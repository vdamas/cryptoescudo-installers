#!/bin/bash
 
# Check daemon running
DAEMON=$(ps -ef | awk '/[d]atadir.*daemon/{print $2}' | wc -l)
if [ "$DAEMON" -eq 0 ]; then
 echo "Cryptoescudo daemon not running"
 exit 1
fi

kill -9 `ps -ef | awk '/[d]atadir.*daemon/{print $2}'`