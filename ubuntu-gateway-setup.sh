#!/bin/bash

#Create a log file in same directory to store output of the script
timestamp=$(date +%s)
exec > >(tee -ia ubuntu-gateway-install-log-$timestamp.log)
exec 2> >(tee -ia ubuntu-gateway-install-log-$timestamp.log >&2)

#To change color for text output
Y='\033[1;33m' #Yellow
R='\033[0;31m' #Red
G='\033[0;32m' #Green
NC='\033[0m'   #No color

#Get the board details
ATOM_PLATFORM="DE3815TYKH"
CORE_PLATFORM="NUC5i7RYB"
GATEWAY_DIR="gateway-setup"
CUR_DIR="${PWD##*/}"
platform=$(cat /sys/devices/virtual/dmi/id/board_name)

install_docker() {
    echo -e "${Y}Install docker and it's dependencies...${NC}\n"
    apt-get install -y apt-transport-https
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    apt-key fingerprint 0EBFCD88
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt-get update
    apt-get install -y docker-ce
}

install_hdc() {
    echo -e "${Y}Install and setup configuration for Helix Device Cloud (HDC) agent...${NC}\n"
    apt-get install -y $PWD/conf_files/hdc/hdc-2.3.0-x86_64.deb
    cp conf_files/hdc/startup.bin /var/lib/iot
    #configure using the iot-control utility installed by HDC agent
    iot-control -c /var/lib/iot/startup.bin
}

install_atom_modules() {
    echo -e "${Y}Install atom modules: nuclide and watchman...${NC}\n"

    #Install nuclide version 0.226.0 (same as client version on atom)
    npm install -g nuclide@0.226.0

    #Install facebook's watchman module required for Atom
    git clone https://github.com/facebook/watchman.git
    cd watchman
    git checkout v4.7.0
    ./autogen.sh
    ./configure
    make
    make install
    cd -
}

install_node() {
    echo -e "${Y}Install Node..${NC}\n"
    curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
    apt-get install -y nodejs
}

install_and_setup_node-red() {
    echo -e "${Y}Install Node-Red and it's UPM Grove kit npm packages...${NC}\n"
    npm install -g node-red
    npm install -g node-red-contrib-upm@0.3.5

    echo -e "${Y}Create & add Node-Red and nuc-user user to dialout group for ttyACM0 access${NC}\n"
    useradd node-red -G dialout
    mkdir -p /home/node-red/.node-red
    chown -R node-red:node-red /home/node-red

    echo -e "${Y}Setup imraa & Node-Red services and default flows...${NC}\n"
    cp conf_files/node-red/node-red-experience.timer /lib/systemd/system/node-red-experience.timer
    cp conf_files/node-red/node-red-experience.service /lib/systemd/system/node-red-experience.service
    cp conf_files/mraa-imraa.service /lib/systemd/system/mraa-imraa.service
    cp conf_files/node-red/flows_ip.json /home/node-red/.node-red/flows_$HOSTNAME.json
    cp utils/dfu-util /usr/bin/

    #run daemon-reload for this to take effect
    systemctl daemon-reload

    #Enable node-red timer which will start the service after a short time on boot
    systemctl enable node-red-experience.timer
}

install_mraa_upm_plugins() {
    echo -e "${Y}Install MRAA, UPM and its dependencies..${NC}\n"
    add-apt-repository -y ppa:mraa/mraa
    apt-get update
    apt-get install -y libmraa1 libmraa-dev mraa-tools mraa-imraa python-mraa \
        python3-mraa libupm-dev python-upm python3-upm upm-examples

    echo -e "${Y}Install MRAA and UPM plugins for java script...${NC}\n"
    #Install MRAA & UPM plugins for java script
    npm install -g mraa@1.7.0
    #npm install -g upm
    npm install -g jsupm_grove@1.0.2-src
    npm install -g jsupm_i2clcd@1.0.2-src
}

install_bower() {
    echo -e "${Y}Install bower module required for admin interface...${NC}\n"
    npm install -g bower
}

echo -e "${Y}********** Start of Script ***********${NC}\n"

if [[ $EUID -ne 0 ]]; then
    echo -e "${R}This script must be run as root (e.g. sudo ./ubuntu-gateway-setup.sh)${NC}\n"
    exit 1
fi

if [ "$CUR_DIR" != "$GATEWAY_DIR" ]; then
    echo -e "${R}ERROR!! Check your current working directory!${NC}\n"
    echo -e "${Y}Download your installation script and configuration files from github and then execute this script with following commands:${NC}"
    echo -e "${G}git clone https://github.com/SSG-DRD-IOT/gateway-setup.git${NC}"
    echo -e "${G}cd gateway-setup${NC}"
    echo -e "${G}sudo ./ubuntu-gateway-setup.sh${NC}\n"
    exit 1
fi

usage="sudo "$0" [-h] [-p n] -- script to setup your Ubuntu server for Intel NUC gateway

where:
    -h  show this help text
    -p  set the proxy value in format http://<proxy>:<port> (default is blank)"

PROXY_VAR=
while getopts ':hp:' option; do
  case "$option" in
    h) echo -e "$usage"
       exit
       ;;
    p) PROXY_VAR=$OPTARG
       ;;
    :) printf "${R}missing argument for -%s\n${NC}" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
   \?) printf "${R}illegal option: -%s\n${NC}" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
  esac
done
shift $((OPTIND - 1))

echo -e "${Y}Proxy variable is set as ${G}$PROXY_VAR${NC}\n"

echo -e "${Y}Install package dependencies...${NC}\n"
apt-get install -y software-properties-common build-essential libssl-dev libkrb5-dev checkinstall
apt-get install -y avahi-daemon avahi-autoipd avahi-utils libavahi-compat-libdnssd-dev python-dev
apt-get install -y libtool automake
apt-get install -y openssh-client openssh-server

echo -e "${Y}Modify the sshd_config file for ssh access to root user, it is disabled by default and restrart sshd...${NC}\n"
sed -ie 's/prohibit-password/yes/g' /etc/ssh/sshd_config
systemctl restart sshd

#system proxy settings
if [ -n "$PROXY_VAR" ]; then
    export http_proxy=$PROXY_VAR
    export https_proxy=$PROXY_VAR
fi

#Install Node
install_node

#npm proxy settings
if [ -n "$PROXY_VAR" ]; then
    npm config set proxy $PROXY_VAR
    npm config set https-proxy $PROXY_VAR
fi

#Configuration required only for our labs running core i7
if [ "$platform" == "$CORE_PLATFORM" ]; then
    echo -e "${Y}Install MongoDB package...${NC}\n"
    apt-get install -y mongodb

    echo -e "${Y}Install mosquitto broker and client modules...${NC}\n"
    apt-get install -y mosquitto mosquitto-clients
    
    echo -e "${Y}Install InfluxDB database...${NC}\n"
    apt-get install -y influxdb

    echo -e "${Y}Install grafana module...${NC}\n"
    apt-get install -y grafana

    #Install and setup docker tool
    install_docker

    #Install and configure Helix Device Cloud (HDC) agent
    install_hdc



fi

#Install Atom editor modules
install_atom_modules

#Install MRAA UPM and plugins for JS
install_mraa_upm_plugins

#Install and configure node-red module
install_and_setup_node-red

#Install bower module for admin interface lab
install_bower

echo -e "${Y}Export node path(NODE_PATH) by adding it to bashrc file...${NC}\n"
echo 'export NODE_PATH=/usr/lib/node_modules/' >> ~/.bashrc
#This won't work since it will source it in sub-shell. Need to source the bash file after the
#script exits
source ~/.bashrc

echo -e "${Y}Add nuc-user to dialout group for access to ttyACM0 device...${NC}\n"
usermod nuc-user -a -G dialout

echo -e "\n${Y}********** End of Script ***********${NC}\n"
echo -e "${Y}********** Rebooting after installation **********${NC}\n"
sleep 3
reboot
