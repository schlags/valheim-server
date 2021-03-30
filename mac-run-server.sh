#!/bin/zsh

red=`tput setaf 1`
reset=`tput sgr0`
green=`tput setaf 2`
set -e
restartScript=$(greadlink -f "$0")

export SERVER_NAME="Schlags Party Time Server"
export WORLD_NAME="Oridiath"
export VALHEIM_PASSWORD=$1

function spinner()
{
    local pid=$!
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf "\e[1A\e[K [%c]  Starting Server... \n" "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

function startServer()
{
    docker run --name=valheim -d \
    -p 2456:2456/udp -p 2457:2457/udp -p 2458:2458/udp \
    -v $(pwd)/data:/home/steam/valheim-data \
    --env VALHEIM_SERVER_NAME=$SERVER_NAME \
    --env VALHEIM_WORLD_NAME=$WORLD_NAME \
    --env VALHEIM_PASSWORD=$VALHEIM_PASSWORD \
    schlags/valheim:latest &
    spinner
}

echo "${green}---Start Valheim Dedicated Server---${reset}"

if [ -f $1 ]; then
    echo "${red}ERROR: No password provided. Please enter the server password value after the script call!${reset}"
    echo "Usage: \n    ./mac-run-server.sh PASSWORD"
    exit
fi

echo "  Ensuring latest docker image is available..."
docker pull schlags/valheim:latest

echo "  $(pwd) is your current working directory."

if [ -d "$(pwd)/data" ]; then
    echo "  ${green}SUCCESS! data/ directory found.${reset}"
    echo "Server name: ${green}$SERVER_NAME${reset} | World name: ${green}$WORLD_NAME${reset} | Password: ${red}$VALHEIM_PASSWORD${reset}\nLAUNCH!"
    startServer 2>&1 | tee .output
    if [[ "$(cat .output && rm .output)" =~ "The container name \"/valheim\" is already in use" ]]; then 
        echo "${red}ERROR: Server likely already running. We can try again after removing the container...${reset}"
        read -q "REPLY?Would you like gracefully stop and remove the container in use now? (Y/N)"
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "${red}Exiting...${reset}"
            exit 1
        fi
        docker stop valheim && docker rm valheim
        exec "$restartScript" "$VALHEIM_PASSWORD"
    fi
    echo "${green}Server started! You can exit the script now if you'd like. :)${reset}\n$(docker logs valheim | tail -n 4)"
    echo "Following logs... Press CTRL+C to exit."
    tail -n 10 -f $(pwd)/data/valheim-logs.txt
else
    echo "${red}ERROR: Could not start server, data directory not found. Are you in the right directory?${reset}"
    echo "${red}Please ensure that your cwd is currently one level higher than the data directory.${reset}"
fi