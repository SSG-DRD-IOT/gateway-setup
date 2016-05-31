#!/bin/bash
# Use this command to flash the gateway
# wget -O - http://bit.ly/iot-gateway | bash 

flash_gateway () {
	# Flash the image to the Gateway
	yes | /sbin/deploytool -d /dev/sda --reset-media -F
	
	# Mount the logical volume that contains the newly flashed image root
	VOLUME_GROUP_NAME=$(pvscan | egrep sda | cut -d ' ' -f 12)
	vgimport $VOLUME_GROUP_NAME
	vgchange -a y
	LOGICAL_VOLUME_NAME=$(lvdisplay $VOLUME_GROUP_NAME | egrep "LV Name" | sed 's/\s\s*/ /g'|cut -d ' ' -f 4)
	MOUNT_PATH=/dev/$VOLUME_GROUP_NAME/$LOGICAL_VOLUME_NAME
	mount $MOUNT_PATH /mnt
}
	
configure_sftp () {
	perl -pi -w -e "s/\/usr\/lib64\/openssh\/sftp-server/internal-sftp/g" /etc/ssh/sshd_config
}

install_mongodb () {
  mkdir -p /mnt/data/db
  wget --directory-prefix=/mnt/root http://fastdl.mongodb.org/linux/mongodb-linux-x86_64-3.0.6.tgz
  tar zxvf /mnt/root/mongodb-linux-x86_64-3.0.6.tgz --directory=/mnt/root/
  mv /mnt/root/mongodb-linux-x86_64-3.0.6/bin/* /mnt/usr/bin/
}

randomize_channel () {
	channels=(3 6 11)
	channel=${channels[$RANDOM % ${#channels[@]}]}
	MAC_FIRST_PART=$(ifconfig | egrep wlan0 | cut -d : -f 6)
	MAC_SECOND_PART=$(ifconfig | egrep wlan0 | cut -d : -f 7)
	SSID="IDPDK-$MAC_FIRST_PART$MAC_SECOND_PART"	
	echo "config wifi-device  wlan0
	option type	mac80211
	option channel	$channel
      	option hwmode	11ng
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

whitelisting(){
	paxctl -Cm /mnt/usr/bin/node
	paxctl -Cm /mnt/usr/bin/mongod
	paxctl -Cm /mnt/usr/bin/mongo	
}

install_docs () {
	mkdir -p /mnt/root/docs
	cd /mnt/root/docs
	git clone https://github.com/SSG-DRD-IOT/commercial-iot-labs-interface.git
	npm install --prefix /mnt/usr/libs/node_modules/ grunt-cli bower -g
	npm install
	bower install
}

flash_gateway
install_mongodb
randomize_channel
configure_sftp
whitelisting
install_docs


#shutdown -h now
