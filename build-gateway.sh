#!/bin/bash

TGTDEV=/dev/sda

yes | tgt=${TGTDEV} /sbin/reset_media
sed -e 's/\t\([0-9a-zA-Z]*\)[ \t].*/\1/' << EOF | fdisk ${TGTDEV}
	n # create a new partition
	p # primary partition
	  # press return 
	  # for default value
	  # for default value
	w # quit fdisk
EOF
mkfs.ext4 /dev/sda3
mount /dev/sda2 /mnt
echo '/dev/sda3	/data	auto	defaults	1	1' >> /mnt/etc/fstab
mkdir -p /mnt/data/db
wget --directory-prefix=/mnt/root http://fastdl.mongodb.org/linux/mongodb-linux-x86_64-3.0.6.tgz
tar zxvf /mnt/root/mongodb-linux-x86_64-3.0.6.tgz --directory=/mnt/root/
mv /mnt/root/mongodb-linux-x86_64-3.0.6/bin/* /mnt/usr/bin/

