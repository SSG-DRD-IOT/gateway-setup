#!/bin/bash

Y='\033[1;33m'
NC='\033[0m'

echo -e "${Y}********** Start of Script ***********${NC}\n"

if [[ $EUID -ne 0 ]]; then
   echo -e "${Y}This script must be run as root${NC}\n" 
   exit 1
fi

create_nodered_service_file()
{
cat <<EOT > /lib/systemd/system/node-red-experience.service
[Unit]
After=syslog.target network.target mraa-imraa.service

[Service]
User=root
ExecStart=/usr/bin/node-red
Environment="NODE_PATH=/usr/lib/node_modules"

[Install]
WantedBy=default.target
EOT
}

echo -e "${Y}Install package dependencies...${NC}\n"
sleep 2

apt-get install -y software-properties-common build-essential libssl-dev libkrb5-dev checkinstall
apt-get install -y avahi-daemon avahi-autoipd avahi-utils libavahi-compat-libdnssd-dev
apt-get install -y libtool automake

echo -e "${Y}Install mosquitto broker and client modules...${NC}\n"
sleep 2
apt-get install -y mosquitto mosquitto-clients

echo -e "${Y}Install Node..${NC}\n"
sleep 2
curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
apt-get install -y nodejs

echo -e "${Y}Install MRAA, UPM and its dependencies..${NC}\n"
sleep 2
add-apt-repository -y ppa:mraa/mraa
apt-get update
apt-get install -y libmraa1 libmraa-dev mraa-tools mraa-imraa python-mraa python3-mraa libupm-dev python-upm python3-upm upm-examples

echo -e "${Y}Install MRAA and UPM plugins for java script...${NC}\n"
sleep 2
#Install MRAA & UPM plugins for java script
npm install -g mraa
npm install -g upm
npm install -g jsupm_grove
npm install -g jsupm_i2clcd

echo -e "${Y}Install Node-Red npm package...${NC}\n"
sleep 2
npm install -g node-red

echo -e "${Y}Create and start Node-Red system service...${NC}\n"
sleep 2
create_nodered_service_file
systemctl enable node-red-experience
systemctl start node-red-experience
systemctl status node-red-experience

echo -e "${Y}Export node path(NODE_PATH) by adding it to bashrc file...${NC}\n"
sleep 2
echo 'export NODE_PATH=/usr/lib/node_modules/' >> ~/.bashrc
#This won't work since it will source it in sub-shell. Need to source the bash file after the
#script exits
source ~/.bashrc

echo -e "${Y}Download and Install Intel XDK daemon, it will be used to connect with Intel XDK...${NC}\n"
sleep 2
wget http://download.xdk.intel.com/iot/xdk-daemon-0100-x64-ubuntu-anyboard-node-4.5.0_master.tar.bz2
tar xvf xdk-daemon-0100-x64-ubuntu-anyboard-node-4.5.0_master.tar.bz2
cd xdk-daemon-0100-x64-node-4.5.0
./setup.sh

echo -e "${Y}********** End of Script ***********${NC}\n"


