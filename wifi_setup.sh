#!/bin/bash

apt install wpa_supplicant

apt install wireless-tools

mv /etc/network/interface /etc/network/interface.old

(
echo source /etc/network/interfaces.d/*
echo auto lo
echo iface lo inet loopback
echo allow-hotplug enp3s0
echo iface enp3s0 inet dhcp
echo allow-hotplug wlp2s0
echo iface wlp2s0 inet dhcp
echo     wpa-ssid <wifi ssid here>
echo     wpa-psk <wifi password here>
