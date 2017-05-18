#!/bin/bash

#Create a log file in same directory to store output of the script
timestamp=$(date +%s)
exec > >(tee -ia ubuntu-gateway-install-log-$timestamp.log)
exec 2> >(tee -ia ubuntu-gateway-install-log-$timestamp.log >&2)

#To change color to yellow for info text
Y='\033[1;33m'
NC='\033[0m'

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
    npm install -g node-red-contrib-upm

    echo -e "${Y}Create & add Node-Red user to dialout group for ttyACM0 access${NC}\n"
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
    npm install -g mraa
    #npm install -g upm
    npm install -g jsupm_grove
    npm install -g jsupm_i2clcd
}

echo -e "${Y}********** Start of Script ***********${NC}\n"

if [[ $EUID -ne 0 ]]; then
    echo -e "${Y}This script must be run as root (e.g. sudo ./ubuntu-gateway-setup.sh)${NC}\n"
    exit 1
fi

if [ "$CUR_DIR" != "$GATEWAY_DIR" ]; then
    echo -e "${Y}ERROR!! Check your current working directory!${NC}\n"
    echo -e "${Y}Download your installation script and configuration files from github and then execute this script with following commands:${NC}"
    echo -e "${Y}git clone https://github.com/SSG-DRD-IOT/gateway-setup.git${NC}"
    echo -e "${Y}cd gateway-setup${NC}"
    echo -e "${Y}sudo ./ubuntu-gateway-setup.sh${NC}\n"
    exit 1
fi

echo -e "${Y}Install package dependencies...${NC}\n"
apt-get install -y software-properties-common build-essential libssl-dev libkrb5-dev checkinstall
apt-get install -y avahi-daemon avahi-autoipd avahi-utils libavahi-compat-libdnssd-dev
apt-get install -y libtool automake
apt-get install -y openssh-client openssh-server

echo -e "${Y}Modify the sshd_config file for ssh access to root user, it is disabled by default and restrart sshd...${NC}\n"
sed -ie 's/prohibit-password/yes/g' /etc/ssh/sshd_config
systemctl restart sshd

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

    #Install Atom editor modules
    install_atom_modules

fi

#Install Node
install_node

#Install MRAA UPM and plugins for JS
install_mraa_upm_plugins

#Install and configure node-red module
install_and_setup_node-red

echo -e "${Y}Export node path(NODE_PATH) by adding it to bashrc file...${NC}\n"
echo 'export NODE_PATH=/usr/lib/node_modules/' >> ~/.bashrc
#This won't work since it will source it in sub-shell. Need to source the bash file after the
#script exits
source ~/.bashrc

echo -e "${Y}Give read & write permission to ttyACM0 device...${NC}\n"
chmod 666 /dev/ttyACM0

echo -e "\n${Y}********** End of Script ***********${NC}\n"
echo -e "${Y}********** Rebooting after installation **********${NC}\n"
sleep 3
reboot
