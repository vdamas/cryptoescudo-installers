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
