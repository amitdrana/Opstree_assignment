#!/bin/sh
output=$(df -TH | grep -vE '^Filesystem|tmpfs|loop|xvda'|awk '{ print $6 " " $1 }')
        usage=$(echo $output | awk '{ print $1}' | cut -d'%' -f1  )
        echo $usage
        if [ $usage -ge 80 ];then
         lvextend -L +2G /dev/mapper/vg1-data
         resize2fs /dev/mapper/vg1-data
         echo "Disk size increased by 2GB at $(date)" >> /tmp/lvm.log
        elif [ $usage -le 9 ];then
         systemctl stop mongod
         umount /data/
         lvreduce -r -L 2G /dev/mapper/vg1-data
         mount -a
         systemctl start mongod
         echo "Disk size reduced at $(date)" >> /tmp/lvm.log
        fi


