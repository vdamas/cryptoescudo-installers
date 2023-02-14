#!/bin/bash

# Absolute path to this script
SCRIPT=$(readlink -f "$0")

# Absolute path this script is in
SCRIPTPATH=$(dirname "$SCRIPT")

cd $SCRIPTPATH
PS3="Choose chain download source: "
options=('Cryptoescudo.work (slower / up-to-date)' 'Google Drive (faster / maybe up-to-date)')
select opt in "${options[@]}"
do
    case $opt in
        "Cryptoescudo.work (slower / up-to-date)")
            # download from cryptoescudo.work (slower, but updated at 8am every day)
            wget https://letsencrypt.org/certs/lets-encrypt-r3.pem
            wget https://cryptoescudo.work/getchain --ca-certificate=lets-encrypt-r3.pem  -O cryptoescudo.tar.gz
            break
            ;;
        "Google Drive (faster / maybe up-to-date)")
            # download from google drive
            SHAREID=1tlrB2WCa4ijeUan-hRc-kaRyZbER1k8n
            CONFIRM="`wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies 'https://docs.google.com/uc?export=download&id=$SHAREID' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p'`"
            wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$CONFIRM&id=$SHAREID" -O cryptoescudo.tar.gz 
            rm -rf /tmp/cookies.txt
            break;
            ;;
        *) echo "invalid option $REPLY";;
    esac
done

# Stop daemon
./daemon_stop.sh

# Remove old data
rm -Rf data/blocks/ data/chainstate/ data/database/

# Extract chain
tar -xf cryptoescudo.tar.gz

# move chain to tmp
mv cryptoescudo.tar.gz /tmp/cryptoescudo-`date --iso`.tar.gz

# Start daemon
./daemon_start.sh