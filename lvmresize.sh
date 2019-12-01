
#/bin/bash


# variable "usage" gives the percentage of usage of the mongodb database which store in "/data"

output=$(df -TH | grep -vE '^Filesystem|tmpfs|loop|xvda'|awk '{ print $6 " " $1 }')
usage=$(echo $output | awk '{ print $1}' | cut -d'%' -f1  )


# Variable vg_free_int will store the free space remaining on volume group vg1 in integer format. (Example:- Vfree-=3.29 then it store 3)

vg_free_int=$( vgs | grep -vE 'VG' | awk '{print $7}'| awk -F. '{print $1}'|awk '{print substr($1,2); }')

#Variable vg_free will store the actual free space remaining in Volumegroup vg1

vg_free=$(vgs | grep -vE 'VG' | awk '{print $7}')

# this will send the mail to admin when free space on volume group vg1 is less then 1GB.

if [ $vg_free_int -le 1 ];then
  echo "VG-1 is running out of space \"$vg_free is free on $(date)" | mail -s "Alert: VG-1 is out of disk space. Toatal space remaining in VG1 $vg_free" amit.rana@techblue.co.uk

# this section extend the lvm (lv1) and file system to 1GB when disk usage of /data increased to 20%.

elif [ $usage -ge 20];then
         lvextend -L +1G /dev/vg1/lv1
         btrfs filesystem resize max /data/
         btrfs balance start -d -m /data

         echo "Disk size increased by 1G at $(date)" >> /tmp/lvm.log

# This will reduce the size of lvm (lv1) and file system on /data  to default to 2GB when disk usage on lvm (data) reach to 10%.

elif [ $usage -le 10 ];then

         btrfs filesystem resize 2G /data/
         echo y | lvreduce -L 2G /dev/mapper/vg1-lv1
         btrfs balance start -d -m /data
         echo "Disk size reduced at $(date)" >> /tmp/lvm.log
        fi
