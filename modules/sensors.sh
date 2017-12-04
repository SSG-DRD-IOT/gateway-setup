#!/bin/bash

################################################################################
# sensors.sh - Defines all the dependencies of this lab
################################################################################
echo -e "   ${R}Dependencies: sensors lab${NC}"

declare -a dependencies=(
 "mraa"
)

## now loop through the modules and call the check and install script for each
for i in "${dependencies[@]}"
do
 source "dependencies/${platform}_${i}.sh"
done
