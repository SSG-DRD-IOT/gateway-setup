# Ubuntu on NUC


## Install Ubuntu Server

English all (default settings, just hit enter)

* Hostname: ubuntu-nuc
* Username: nuc-user
* Password: root
* Use weak password - YES
* Encryption - No
* Force UEFI Install -YES


### If 64GB or more:
* use guided partition: use entire disk
* No proxy
* Install security updates automatically
* Install openSSH server and standard system utilities (use space to select)


### If 4GB model:
* Manual partition:
* Delete all partitions 
* Create 150MB logical at beginning, use as EFI system partition area – bootable flag on
* Create 3.7 primary, use as Ext4, mount point /, bootable flag off
* Create ~100 MB (rest of disk) logical at beginning, use as swap area – bootable flag off,
* Finish partition and write changes to disk


### Once booted:
* After you log in with your credentials enter following commands:
  `cd ~`
  &#13;
  `sudo passwd root`
  &#13;
  `Enter: root`
  &#13;
  `su root`
  &#13;
  `password: root`
  &#13;
  `git clone https://github.com/SSG-DRD-IOT/gateway-setup.git`
  &#13;
  `cd gateway-setup`
  &#13;
  `\.ubuntu-gateway-setup.sh`
  &#13;
