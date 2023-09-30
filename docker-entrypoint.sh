#!/bin/bash

export ABCDESKTOP_RUN_DIR='/composer/run'
# export VAR to running procces
export KUBERNETES_SERVICE_HOST

CONTAINER_IP_ADDR=$(hostname -i)
echo "Container local ip addr is $CONTAINER_IP_ADDR"
export CONTAINER_IP_ADDR

# replace CONTAINER_IP_ADDR in listen for cupsd
sed -i "s/localhost:631/$CONTAINER_IP_ADDR:631/g" /etc/cups/cupsd.conf 

# overwrite HOME
# to use cups-pdf ANONYMOUS
# export HOME=/var/spool/cups-pdf/ANONYMOUS

if [ -z "$DISABLE_REMOTEIP_FILTERING" ]; then
        DISABLE_REMOTEIP_FILTERING=disabled
fi

if [ "$DISABLE_REMOTEIP_FILTERING"=="enabled" ]; then
	echo "DISABLE_REMOTEIP_FILTERING=$DISABLE_REMOTEIP_FILTERING" >> /var/log/desktop/config.log
else
	DISABLE_REMOTEIP_FILTERING=disabled
fi
export DISABLE_REMOTEIP_FILTERING

# configure file service
# denied upload file 
export ACCEPTFILE=false
# denied list file 
export ACCEPTLISTFILE=false


# start supervisord
/usr/bin/supervisord --pidfile /var/run/desktop/supervisord.pid --nodaemon --configuration /etc/supervisord.conf
