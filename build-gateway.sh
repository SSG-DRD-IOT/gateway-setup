#!/bin/bash
# Use this command to flash the gateway
# wget -O -  http://bit.ly/iot-gateway | bash 
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

installMongoDB () {
  wget --directory-prefix=/mnt/root http://fastdl.mongodb.org/linux/mongodb-linux-x86_64-3.0.6.tgz
  tar zxvf /mnt/root/mongodb-linux-x86_64-3.0.6.tgz --directory=/mnt/root/
  mv /mnt/root/mongodb-linux-x86_64-3.0.6/bin/* /mnt/usr/bin/
}

randomizeChannel () {
	channels=(3 6 11)
	channel=${channels[$RANDOM % ${#channels[@]}]}
	MAC_FIRST_PART=$(ifconfig | egrep wlan0 | cut -d : -f 6)
	MAC_SECOND_PART=$(ifconfig | egrep wlan0 | cut -d : -f 7)
	SSID="IDPDK-$MAC_FIRST_PART$MAC_SECOND_PART"	
	echo "config wifi-device  wlan0
	option type	mac80211
	option channel	$channel
      	option hwmode	11n
	option path	'pci0000:00/0000:00:1c.1/0000:02:00.0'
	option htmode	HT20
	option disabled	0

config wifi-iface
	option device 	wlan0
	option network 	lan
	option mode 	ap
	option ssid	$SSID
	option encryption psk2
	option key windriveridp" > /mnt/etc/config/wireless
}

whiteListing(){
	paxctl -Cm /mnt/usr/bin/node
	paxctl -Cm /usr/bin/mongod
	paxctl -Cm /usr/bin/mongo	
}

installMongoDB
randomizeChannel
whiteListing


shutdown -h now
