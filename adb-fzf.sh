#!/bin/bash

# Color Coding
greenColor='\033[0;36m'
redColor='\033[0;31m'
noColor='\033[0m'

# Input from Command Line
totalInput=$(command adb devices | wc -l | xargs)
devicesConnected=$(expr $totalInput - 2)

if [[ "$@" != *"-s "* && $devicesConnected -gt 1 ]];
then
    # Parsing the Input for Internal Use
    devices=(`command adb devices | awk '$2 == "device" || $2 == "offline" || $2 == "unauthorized" {print $1}'`)
    devicesStates=(`command adb devices | awk '$2 == "device" || $2 == "offline" || $2 == "unauthorized" {print $2}'`)
    
    numberOfDevices=${#devices[@]}
    numberOfStates=${#devicesStates[@]}

    # Creating fzf String to show the options
    let "lastIndex=numberOfStates-1"
    if [ "$numberOfDevices" -eq "$numberOfStates" ];
    then
        fzfFinderDeviceString=""
        for (( i=0; i<${numberOfDevices}; i++ ));
        do
            fzfFinderDeviceString+="${devices[$i]} (${devicesStates[$i]})"
            if [ "$i" -ne "${lastIndex}" ];
            then
                fzfFinderDeviceString+="\n"
            fi
        done

        selection=$(echo -e $fzfFinderDeviceString | fzf)
        deviceId=$(echo $selection | awk '{print $1}')

        echo -e "Selected Device : ${greenColor}$selection${noColor}\n"

        command adb -s $deviceId "$@"
    else
        echo -e "${redColor}Something went wrong in scanning devices!${noColor}"
    fi

else
    command adb "$@"
fi