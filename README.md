# Ubuntu on NUC

Below are two paths to setup the NUC Gateway with Ubuntu 16.04 and all the prerequisites to get started with our Workshops and Tutorials. The first path is for the Intel IoT Developer Kit ONLY - It is an image of the Developer Kit gateway and will not work on anything without that specific hardware. 

# IoT Developer Kit NUC:

# Required: DE3815TYKE NUC with 4GB Ram and Only the built in 4GB EMMC storage - This is the NUC from the IoT Developer Kit

* Download the iso image from: https://s3.amazonaws.com/meks3bucket/isos/4GB-NUC-UBUNTU-SCRIPT-8-10-2017.iso

* Flash this iso onto a USB stick - 2GB minimum size is required. You can use any USB creation tool, if you are not sure what to use try the following:

- OSX: Etcher - https://etcher.io/
- Windows: Win32 Disk Imager: https://sourceforge.net/projects/win32diskimager/
- Linux: unetbootin: http://unetbootin.github.io/

* Insert the USB with the burned iso into a usb port on the NUC and boot

* At the start of boot hit f10 to access the boot menu 

* Select UEFI: USB : xxxx : OS Bootloader 

* This will boot into the Clonezilla interface, slect the first option and hit enter

* Clonezilla should take care of the rest. After a bit it will ask you if you are sure you want to continue, enter "y" and hit enter for both questions 

* The process should take about 10 minutes, after it finishes you will see a message to remove the live-medium - remove the usb at this point and hit enter - once the NUC powers off, turn it back on.

* Thats it, the nuc is now ready!


## Other NUCs:

## Install Ubuntu Server

### Boot USB in UEFI mode - press f10 at boot and select uefi usb as boot device

English all (default settings, just hit enter)

* Hostname: ubuntu-nuc
* Username: nuc-user
* Password: root
* Use weak password - YES
* Encryption - No


### If installing over Windriver:

* Configure Logical Volume Manager
* YES
* Delete logical volume
* Select volume group
* Reduce Volume Group
* Select /dev/mmcblk0p2 and /dev/mmcblk0p2 
* Go Back
* Force UEFI Install -YES
* Reboot and continue to manual partition

### If 64GB or more:
* use guided partition: use entire disk
* No proxy
* Install security updates automatically
* Install openSSH server and standard system utilities (use space to select)


### If 4GB model:
* Manual partition:
* Delete all partitions 
* Create 150MB logical at beginning, use as EFI system partition area – bootable flag on
* Create 3.7GB primary at beginning, use as Ext4, mount point /, bootable flag off
* Create ~100 MB (rest of disk) logical at beginning, use as swap area – bootable flag off,
* Finish partition and write changes to disk
* No proxy
* Install security updates automatically
* Install openSSH server and standard system utilities (use space to select)


### Once booted:
* Connect your Arduino 101 with LCD to your Gateway device  
* After you log in with your credentials enter following commands to download and run the script:  
  `nuc-user@ubuntu-nuc:~# git clone https://github.com/SSG-DRD-IOT/gateway-setup.git`  
  `nuc-user@ubuntu-nuc:~# cd gateway-setup`  
  `nuc-user@ubuntu-nuc:~/gateway-setup#sudo ./ubuntu-gateway-setup.sh`  
* After script completes your system will reboot
