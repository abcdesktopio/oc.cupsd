#!/bin/bash

export ABCDESKTOP_RUN_DIR='/composer/run'

CONTAINER_IP_ADDR=$(hostname -i)
echo "Container local ip addr is $CONTAINER_IP_ADDR"
export CONTAINER_IP_ADDR

# replace CONTAINER_IP_ADDR in listen for pulseaudio
sed -i "s/localhost:631/$CONTAINER_IP_ADDR:631/g" /etc/cups/cupsd.conf 

# kerberos
if [ -f /tmp/krb5cc_4096 ]; then
	# copy the krb5cc from ballon to root 
        cp /tmp/krb5cc_4096 /tmp/krb5cc_0
fi

# start supervisord
/usr/bin/supervisord --pidfile /var/run/desktop/supervisord.pid --nodaemon --configuration /etc/supervisord.conf
