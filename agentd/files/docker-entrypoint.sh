#!/bin/bash

set -e

CONF="/usr/local/etc/zabbix_agentd.conf.d"

if [ -z ${ZBX_SERVER} ]; then
    echo "No default zabbix-server provided. Exiting ..."
    exit 1
fi

if [ -z ${REMOTE_COMMAND} ]; then
    echo "No Remote Command Configuration Provided. Assuming 0 (no support)"
    REMOTE_COMMAND=0
fi

if [ -z ${ZBX_SERVER_PORT} ];then
    echo "No Zabbix Server Port Provided. Assuming 10051."
    ZBX_SERVER_PORT=10051
fi

cat <<EOT > $CONF/automatic.conf
LogFile=/tmp/zabbix_agentd.log
LogFileSize=1024
LogType=console
ListenPort=10050
DebugLevel=3
EnableRemoteCommands=${REMOTE_COMMAND}
LogRemoteCommands=1
Server=${ZBX_SERVER}
ServerActive=${ZBX_SERVER}:${ZBX_SERVER_PORT}
Timeout=30
EOT

exec proot -r /rootfs -b /usr/local/sbin -m /usr/local/sbin \
     -b /usr/local/bin -m /usr/local/bin \
     -b /usr/local/share/zabbix -m /usr/local/share/zabbix \
     -b /usr/lib -m /usr/lib -b /usr/local/etc -m /usr/local/etc \
     sh -c "LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu /usr/local/sbin/zabbix_agentd -c /usr/local/etc/zabbix_agentd.conf --foreground"

