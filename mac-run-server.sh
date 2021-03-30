#!/bin/zsh

docker run --name=valheim -d \
-p 2456:2456/udp -p 2457:2457/udp -p 2458:2458/udp \
-v /Users/dylanschlager/valheim/valheim-server/data:/home/steam/valheim-data \
--env VALHEIM_SERVER_NAME="Schlags Party Time Server" \
--env VALHEIM_WORLD_NAME="Oridiath" \
--env VALHEIM_PASSWORD="Zenica" \
schlags/valheim-server-updated
