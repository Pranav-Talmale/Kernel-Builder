#!/bin/bash

# Source Vars
source $CONFIG

#Change to Kernel dir
cd ~/work/Kernel

. $SCRIPT_NAME --$CUSTOM_ARG1=$CUSTOM_ANS1 --$CUSTOM_ARG2=$CUSTOM_ANS2 

exit 0
