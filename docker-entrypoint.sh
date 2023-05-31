#!/bin/bash

apk add nfs-utils

mkdir /mnt/dpm-agent/$HOSTNAME
mv /etc/vc-agent-007.conf /mnt/dpm-agent/$HOSTNAME/vc-agent-007.conf

wait_period=0
while true
do
    echo "Time Now: `date +%H:%M:%S`"
    echo "Sleeping for 90 seconds"
    # Here 300 is 300 seconds i.e. 5 minutes * 60 = 300 sec
    wait_period=$(($wait_period+90))
    if [ $wait_period -gt 3000 ];then
       echo "The script successfully ran for 50 minutes, exiting now.."
       break
    else
       sleep 90
    fi
done

