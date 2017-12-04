#!/bin/bash
################################################################################
# Industrial.sh - Defines all the modules in the industrial workshop that will
# have their dependencies installed. A script file for each modules is run that
# defines all of the dependencies required for that module.
################################################################################

# Modules that are taught in this workshop
declare -a dependencies=(
   "node"
   "atom"
)

## now loop through the modules and call the check and install script for each
for i in "${dependencies[@]}"
do
   # Load the check and install functions for this dependencies
   source "dependencies/${platform}_$i.sh"

   echo -e "  Dependency: ${R}${i}${NC}"
   eval check_${i}

   result=$?
   if [[ $result -eq 0 ]]; then 
     echo -e "  ${R}not installed${NC}"
     install_${i}
   else 
     echo -e "  ${R}installed already.${NC}"
   fi
done
