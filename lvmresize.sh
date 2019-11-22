#/bin/bash


# variable output and usage gives the percentage of usage databse (/data)

output=$(df -TH | grep -vE '^Filesystem|tmpfs|loop|xvda'|awk '{ print $6 " " $1 }')
usage=$(echo $output | awk '{ print $1}' | cut -d'%' -f1  )


# Variable vg_free_size will store the free space remaining on volume group vg-1 in integer format. (Example:- Vfree-=3.29 then it store 3)

vg_free_size=$(vgs | grep -vE 'VG' | awk '{print $7}'| awk -F. '{print $1}')

#Variable vg_free will store the actual free space remaining in Volumegroup vg1

vg_free=$(vgs | grep -vE 'VG' | awk '{print $7}')


# this will send the mail to admin when free space on volume group vg1 is less then 2GB.

if [ $vg_free_size -le 2 ];then
  echo "VG-1 is running out of space \"$vg_free_size as on $(date)" | mail -s "Alert: VG-1 is out of disk space. Toatal space remaining in VG1 $vg_free" amit.rana@techblue.co.uk

# this section extend the lvm (data) to 10% of free space in Volume group vg1 when disk usage of lvm (data) usage reach greater then 80%.

elif [ $usage -ge 80 ];then
         lvextend -l +10%FREE /dev/vg1/data
         resize2fs /dev/mapper/vg1-data
         echo "Disk size increased by 2GB at $(date)" >> /tmp/lvm.log

# This will reduce the size of lvm (data) to 2GB when disk usage on lvm (data) reach to 9%.

elif [ $usage -le 9 ];then
         systemctl stop mongod
         umount /data/
         lvreduce -r -L 2G /dev/mapper/vg1-data
         mount -a
         systemctl start mongod
         echo "Disk size reduced at $(date)" >> /tmp/lvm.log
        fi

~                                                                                                                                                                                                                  
~                         
