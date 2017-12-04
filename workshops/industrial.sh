#!/bin/bash

################################################################################
# Industrial.sh - Defines all the modules in the industrial workshop that will
# have their dependencies installed. A script file for each modules is run that
# defines all of the dependencies required for that module.
################################################################################

# Modules that are taught in this workshop
declare -a modules=(
   "industrial_setup"
   "sensors"
   "industrial_protocols"
   "automation"
   "security"
   "computer_vision"
)

## now loop through the modules and call the check and install script for each
for i in "${modules[@]}"
do
   source "modules/$i.sh"
   echo -e "${Y}${i} Lab Module...${NC}"
done
