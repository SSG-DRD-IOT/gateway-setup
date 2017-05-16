#!/bin/bash

apt update

apt install wpasupplicant

apt install wireless-tools

rm /etc/network/interfaces

(echo source /etc/network/interfaces.d/*
echo auto lo
echo iface lo inet loopback
echo allow-hotplug enp3s0
echo iface enp3s0 inet dhcp
echo allow-hotplug wlp2s0
echo iface wlp2s0 inet dhcp
echo     wpa-ssid wifi_ssid_here
echo     wpa-psk wifi_password_here) > /etc/network/interfaces

service networking restart

ifup wlp2s0
