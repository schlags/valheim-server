#!/bin/zsh

red=`tput setaf 1`
reset=`tput sgr0`
green=`tput setaf 2`
set -e
restartScript=$(greadlink -f "$0")

export CONTAINER_TAG=$1

function updateImage()
{
    docker build -t schlags/valheim:$CONTAINER_TAG -t schlags/valheim:latest . --no-cache
    docker push schlags/valheim:latest
    docker push schlags/valheim:$CONTAINER_TAG
}

if [ -f $1 ]; then
    echo "${red}ERROR: No custom tag provided. Please specify a version number or descriptive tag after the script call.${reset}"
    echo "Usage: \n    ./mac-update-server.sh VERSION"
    exit
fi

echo "  ${green}Updating image: schlags/valheim:$CONTAINER_TAG${reset}"
updateImage