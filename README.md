# Cryptoescudo installer (linux)

   1. clone this repo and enter directory  

### Install cryptoescudo v1.3.0.0-20170628 (ubuntu 22.04)
     
   2. sudo chmod +x install-daemon-v1.3.0.0-20170628.sh   
   3. sudo ./install-daemon-v1.3.0.0-20170628.sh
   4. cd /opt/cryptescudo
   5 sudo ./chain_update.sh (fetch full blockchain backup and starts daemon)
   or
   5. sudo ./daemon_start.sh 
   
### Install cryptoescudo v1.3.0.0-20170628 on docker (ubuntu 22.04)
   
   2. sudo chmod +x docker-daemon-v1.3.0.0-20170628.sh   
   3. sudo ./docker-daemon-v1.3.0.0-20170628.sh
   4. docker run -it cryptoescudo:v1.3.0.0-20170628
   5. cd /opt/cryptescudo
   6. sudo ./daemon_start.sh

### Install install-electrumX-1.13 (ubuntu 22.04)
     
   2. sudo chmod +x install-electrumx-1.13.sh   
   3. sudo ./install-electrumx-1.13.sh
   4. cd /opt/electrumx-1.13.0
   5. chown -R $(id -u) .
   5. ./electrumx_start.sh

### Install cryptoescudo v1.1.5.1-20141117 (ubuntu 18.04)
     
   2. sudo chmod +x buildinstall-daemon-v1.1.5.1-20141117.sh   
   3. sudo ./buildinstall-daemon-v1.1.5.1-20141117.sh
   4. cd /opt/cryptescudo
   5. sudo ./daemon_start.sh
   
### Install cryptoescudo v1.1.5.1-20141117.sh on docker (ubuntu 18.04)
    
   2. sudo chmod +x docker-daemon-v1.1.5.1-20141117.sh   
   3. sudo ./docker-daemon-v1.1.5.1-20141117.sh
   4. docker run -it cryptoescudo:v1.1.5.1-20141117
   5. cd /opt/cryptescudo
   6. sudo ./daemon_start.sh

### Install cryptoescudo v1.3.0.0-20170628 + explorer 1.7.4 + electrumX 1.13 on docker (ubuntu 22.04)
   
   2. sudo chmod +x docker-cryptoescudo-allinone.sh
   3. sudo ./docker-cryptoescudo-allinone.sh
   4. docker run -d docker run -d cryptoescudo-allinone:yyyymmdd -p 81:81 -p 50001:50001 -p 50002:50002 -p 61143:61143 
      a. yyyymmdd - check with: docker image ls
   6. enter container to debug : docker exec -it [containerid] /bin/bash
      a. debug daemon: /opt/cryptoescudo/daemon_debug.sh
      b. debug explorer: /opt/explorer/explorer_debug.sh
      c. debug daemon: /opt/electrumx/electrumx_debug.sh  
