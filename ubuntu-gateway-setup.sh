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

echo -e "${Y}********** Start of Script ***********${NC}\n"

if [[ $EUID -ne 0 ]]; then
    echo -e "${Y}This script must be run as root${NC}\n"
    exit 1
fi

if [ "$CUR_DIR" != "$GATEWAY_DIR" ]; then
    echo -e "${Y}ERROR!! Check your current working directory!${NC}\n"
    echo -e "${Y}Download your installation script and configuration files from github and then execute this script with following commands:${NC}"
    echo -e "${Y}git clone https://github.com/SSG-DRD-IOT/gateway-setup.git${NC}"
    echo -e "${Y}cd gateway-setup${NC}"
    echo -e "${Y}./ubuntu-corei7-gateway-setup.sh${NC}\n"
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

#Install few packages only required for our labs running with core i7
if [ "$platform" == "$CORE_PLATFORM" ]; then
    echo -e "${Y}Install MongoDB package...${NC}\n"
    apt-get install -y mongodb

    echo -e "${Y}Install mosquitto broker and client modules...${NC}\n"
    apt-get install -y mosquitto mosquitto-clients
    
    echo -e "${Y}Install InfluxDB database...${NC}\n"
    apt-get install -y influxdb

    echo -e "${Y}Install grafana module...${NC}\n"
    apt-get install -y grafana

    echo -e "${Y}Install docker and it's dependencies...${NC}\n"
    apt-get install -y apt-transport-https
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    apt-key fingerprint 0EBFCD88
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt-get update
    apt-get install -y docker-ce
fi

echo -e "${Y}Install Node..${NC}\n"
curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
apt-get install -y nodejs

echo -e "${Y}Install MRAA, UPM and its dependencies..${NC}\n"
add-apt-repository -y ppa:mraa/mraa
apt-get update
apt-get install -y libmraa1 libmraa-dev mraa-tools mraa-imraa python-mraa python3-mraa libupm-dev python-upm python3-upm upm-examples

echo -e "${Y}Install MRAA and UPM plugins for java script...${NC}\n"
#Install MRAA & UPM plugins for java script
npm install -g mraa
#npm install -g upm
npm install -g jsupm_grove
npm install -g jsupm_i2clcd

echo -e "${Y}Install Node-Red and Node-Red UPM Grove kit - npm packages...${NC}\n"
npm install -g node-red
npm install -g node-red-contrib-upm

echo -e "${Y}Create Node-Red user and add it to dialout group for access to ttyACM0 device...${NC}\n"
useradd node-red -G dialout
mkdir -p /home/node-red/.node-red
chown -R node-red:node-red /home/node-red

echo -e "${Y}Setup imraa & Node-Red services and default flows...${NC}\n"
cp node-red-experience.timer /lib/systemd/system/node-red-experience.timer
cp node-red-experience.service /lib/systemd/system/node-red-experience.service
cp mraa-imraa.service /lib/systemd/system/mraa-imraa.service
cp flows_ip.json /home/node-red/.node-red/flows_$HOSTNAME.json
cp dfu-util /usr/bin/

#run daemon-reload for this to take effect
systemctl daemon-reload

#Enable and start the node red service
systemctl enable node-red-experience.timer

echo -e "${Y}Export node path(NODE_PATH) by adding it to bashrc file...${NC}\n"
echo 'export NODE_PATH=/usr/lib/node_modules/' >> ~/.bashrc
#This won't work since it will source it in sub-shell. Need to source the bash file after the
#script exits
source ~/.bashrc

echo -e "${Y}Download and Install Intel XDK daemon, it will be used to connect with Intel XDK...${NC}\n"
wget http://download.xdk.intel.com/iot/xdk-daemon-0100-x64-ubuntu-anyboard-node-4.5.0_master.tar.bz2
tar xvf xdk-daemon-0100-x64-ubuntu-anyboard-node-4.5.0_master.tar.bz2
cd xdk-daemon-0100-x64-node-4.5.0
./setup.sh

echo -e "\n${Y}********** End of Script ***********${NC}\n"
echo -e "${Y}********** Rebooting after installation **********${NC}\n"
sleep 3
reboot
