#!/bin/bash

#Create a log file in same directory to store output of the script
timestamp=$(date +%s)
#exec > >(tee -ia install-log-$timestamp.log)
#exec 2> >(tee -ia install-log-$timestamp.log >&2)

#To change color for text output
Y='\033[1;33m' #Yellow
R='\033[0;31m' #Red
G='\033[0;32m' #Green
NC='\033[0m'   #No color

#Get the board details
ATOM_PLATFORM="DE3815TYKH"
CORE_PLATFORM="NUC5i7RYB"
UP2_PLATFORM="UP-APL01"
platform=$(cat /sys/devices/virtual/dmi/id/board_name)

# Check that this script is run as root
if [[ $EUID -ne 0 ]]; then
    echo -e "${R}This script must be run as root (e.g. sudo ./entry.sh)${NC}\n"
    exit 1
fi

echo $platform
echo "$CORE_PLATFORM"

# Configuration required only for our labs running core i7
if [ "$platform" != "$CORE_PLATFORM" ]; then
    echo -e "${Y}Installing dependencies for Intel NUC NUC5i7RYB ...${NC}\n"
elif [ $platform == $UP2_PLATFORM ]; then
  echo -e "${Y}Installing dependencies for Up2 Board ...${NC}\n"
fi
