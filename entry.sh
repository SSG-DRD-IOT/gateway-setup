#!/bin/bash

<<<<<<< HEAD
#  entry.sh - Determines which IoT Board the install script is running on
#  and deligates to an install script for that board

################################################################################
# Constant Variable Declarations
################################################################################
# Color for text output
=======
#Create a log file in same directory to store output of the script
timestamp=$(date +%s)
#exec > >(tee -ia install-log-$timestamp.log)
#exec 2> >(tee -ia install-log-$timestamp.log >&2)

#To change color for text output
>>>>>>> bed5032c2703593dbb93e9c131785a28f3be9d3b
Y='\033[1;33m' #Yellow
R='\033[0;31m' #Red
G='\033[0;32m' #Green
NC='\033[0m'   #No color

<<<<<<< HEAD
# Workshop Definitions
INDUSTRIAL_WORKSHOP="industrial"
ALLIANCE_WORKSHOP="alliance"

# Platform Definitions
CORE_PLATFORM="NUC5i7RYB"
UP2_PLATFORM="UP-APL01"

################################################################################
# Find current platform type
platform=$(cat /sys/devices/virtual/dmi/id/board_name)

################################################################################
# Parse command line args
################################################################################
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -w|--workshop)
    workshop="$2"
    shift # past argument
    shift # past value
    ;;
    -i|--industrial)
    workshop=$INDUSTRIAL_WORKSHOP
    shift # past argument
    shift # past value
    ;;
    -a|--alliance)
    workshop=$ALLIANCE_WORKSHOP
    shift # past argument
    shift # past value
    ;;
    -c|--check)
    CHECK_INSTALL=1
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters
################################################################################

# Print helpful "We are starting message"
echo -e "${Y}Beginning ${workshop} workshop installation${NC}"

# Call the installation script for the specificied workshop
if [ "$workshop" == "$INDUSTRIAL_WORKSHOP" ]; then
  source workshops/industrial.sh
elif [[ "$workshop" == "$ALLIANCE_WORKSHOP" ]]; then
  source workshops/alliance.sh
=======
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
>>>>>>> bed5032c2703593dbb93e9c131785a28f3be9d3b
fi
