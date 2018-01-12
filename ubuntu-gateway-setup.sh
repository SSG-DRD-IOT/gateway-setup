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
UP2_PLATFORM="UP-APL01"
GATEWAY_DIR="gateway-setup-master"
CUR_DIR="${PWD##*/}"
platform=$(cat /sys/devices/virtual/dmi/id/board_name)

download_industrial_labs() {

    echo -e "${Y}Downloading Industrial Labs...${NC}\n"
    cd ~/.
    mkdir answers
        if [ "$platform" == "$UP2_PLATFORM" ]; then
	chown -R upsquared:upsquared answers
    else
	chown -R nuc-user:nuc-user answers
    fi
    cd answers
    git clone https://github.com/SSG-DRD-IOT/lab-industrial-setup-development-environment.git
    git clone https://github.com/SSG-DRD-IOT/lab-digital-sensors-arduino
    git clone https://github.com/SSG-DRD-IOT/lab-pwm-sensors-arduino
    git clone https://github.com/SSG-DRD-IOT/lab-lcd-arduino
    git clone https://github.com/SSG-DRD-IOT/lab-IP-to-LCD-Arduino
    git clone https://github.com/SSG-DRD-IOT/lab-temperature-humidity-arduino
    git clone https://github.com/SSG-DRD-IOT/lab-rotary-angle-sensor-c
    git clone https://github.com/SSG-DRD-IOT/lab-protocols-mqtt-arduino
    git clone https://github.com/SSG-DRD-IOT/lab-sensors-opc-ua
    git clone https://github.com/SSG-DRD-IOT/virtual-sensor
    git clone https://github.com/SSG-DRD-IOT/lab-automation-jupyter    
    git clone https://github.com/SSG-DRD-IOT/lab-iot-automation.git
    git clone https://github.com/SSG-DRD-IOT/lab-nuc-security.git
    git clone https://github.com/SSG-DRD-IOT/lab-opencv-examples.git
    cd ~/.
    if [ "$platform" == "$UP2_PLATFORM" ]; then
	chown -R upsquared:upsquared answers
	sed -i 's/nuc-user/upsquared/g' answers/lab-opencv-examples/config/jupyter.service
	mkdir .jupyter
    else
	chown -R nuc-user:nuc-user answers
    fi
    cp answers/lab-opencv-examples/config/jupyter.service /etc/systemd/system/jupyter.service
    cp answers/lab-opencv-examples/config/jupyter_notebook_config.py .jupyter/
    cp answers/lab-opencv-examples/config/jupyter_notebook_config.json .jupyter/
    systemctl enable jupyter.service
    
}

install_ip_addr_c() {

    echo -e "${Y}Install ip_addr_c as a service...${NC}\n"
    apt-get install -y libpcap0.8-dev
    cd ~/.
    git clone https://github.com/SSG-DRD-IOT/ip_address_c.git
    cd ip_address_c
    #check to see if we need the mraa subplatform
    if [ "$platform" == "$UP2_PLATFORM" ]; then
	make up2
	cp ip_addr_c_up2 /usr/local/bin/ip_addr_c
    else
	make all
	cp ip_addr_c /usr/local/bin/ip_addr_c
    fi
    cp ip_addr_c.service /etc/systemd/system/ip_addr_c.service
    cp ip_addr_c.timer /etc/systemd/system/ip_addr_c.timer
    cd ~/.
    systemctl enable ip_addr_c.service
    rm -rf ip_address_c
}

install_pahomqtt() {

    echo -e "${Y}Install paho mqqt client...${NC}\n"
    cd ~/.
    git clone https://github.com/eclipse/paho.mqtt.c.git
    cd ~/paho.mqtt.c
    make install
    
}

install_jupyter() {
    echo -e "${Y}Install jupyter and it's dependencies...${NC}\n"
    apt-get -y install python2.7 python-pip python-dev
    python --version
    pip --version
    apt-get -y install ipython ipython-notebook
    pip install --upgrade pip
    pip install numpy
    pip install imageio
    apt-get install -y python-matplotlib
    add-apt-repository -y ppa:mc3man/gstffmpeg-keep
    apt-get update
    apt-get install -y ffmpeg gstreamer0.10-ffmpeg
    pip install moviepy
    apt-get -y install python-opencv
    pip install jupyter
    npm install -g ijavascript
    ijs
    if [ "$platform" == "$UP2_PLATFORM" ]; then
	chown -R upsquared:upsquared /home/upsquared/.local/share/jupyter
    else
	chown -R nuc-user:nuc-user /home/nuc-user/.local/share/jupyter
    fi
}

install_docker() {
    echo -e "${Y}Install docker and it's dependencies...${NC}\n"
    apt-get install -y apt-transport-https
    apt-get install -y curl
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
    apt-get install -y curl
    curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
    apt-get install -y nodejs
}

install_mraa_upm_plugins() {
    echo -e "${Y}Install MRAA, UPM and its dependencies..${NC}\n"
    add-apt-repository -y ppa:mraa/mraa
    apt-get update
    apt-get install -y libmraa1 libmraa-dev mraa-tools mraa-imraa python-mraa \
        python3-mraa libupm-dev python-upm python3-upm upm-examples

    echo -e "${Y}Install MRAA and UPM plugins for java script...${NC}\n"
    #Install MRAA & UPM plugins for java script
    #npm install -g mraa@1.7.0
    npm install -g mraa
    npm install -g upm
    #npm install -g jsupm_grove@1.0.2-src
    #npm install -g jsupm_i2clcd@1.0.2-src
    npm install -g jsupm_grove
    npm install -g jsupm_i2clcd
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
apt-get install -y libjson0 libjson0-dev
apt-get install -y cmake
apt-get install -y git

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

#Configuration required only for our labs

#echo -e "${Y}Install InfluxDB database...${NC}\n"
#apt-get install -y influxdb

#echo -e "${Y}Install grafana module...${NC}\n"
#apt-get install -y grafana

#Install and setup docker tool
install_docker

#Install MRAA UPM and plugins for JS
install_mraa_upm_plugins

#Install and configure Helix Device Cloud (HDC) agent
#install_hdc

echo -e "${Y}Install MongoDB package...${NC}\n"
apt-get install -y mongodb

echo -e "${Y}Install mosquitto broker and client modules...${NC}\n"
apt-get install -y mosquitto mosquitto-clients

#Install Atom editor modules
install_atom_modules

#Install bower module for admin interface lab
install_bower

#Install Jupyter Notebook
install_jupyter

#Install paho mqqt
install_pahomqtt

#Download the repos for Industrial Labs
download_industrial_labs

#Download and install ip_addr_c
install_ip_addr_c

echo -e "${Y}Export node path(NODE_PATH) by adding it to bashrc file...${NC}\n"
echo 'export NODE_PATH=/usr/lib/node_modules/' >> ~/.bashrc
#This won't work since it will source it in sub-shell. Need to source the bash file after the
#script exits
source ~/.bashrc

echo -e "${Y}Add nuc-user or upsquared to dialout group for access to ttyACM0 device...${NC}\n"

if [ "$platform" == "$UP2_PLATFORM" ]; then
    usermod upsquared -a -G dialout
else
    usermod nuc-user -a -G dialout
fi


echo -e "\n${Y}********** End of Script ***********${NC}\n"
echo -e "${Y}********** Rebooting after installation **********${NC}\n"
sleep 3
reboot
