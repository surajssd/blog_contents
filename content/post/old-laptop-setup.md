+++
author = "Suraj Deshmukh"
title = "Old laptop setup reference"
description = "Links and things to do while setting up older Dell Inspiron 1525"
date = "2018-12-30T01:00:51+05:30"
categories = ["notes"]
tags = ["laptop", "dell"]
+++

I have this old PC Dell Inspiron 1525 with 2GB RAM and 32 bit dual core processor and I wanted to install fedora on it, but I cam accross few problems which I am documenting for further reference.

## Wifi device not detected

The wifi drivers are not loaded by default, so followed this blog, basically do following:

```
export FIRMWARE_INSTALL_DIR="/lib/firmware"
wget http://mirror2.openwrt.org/sources/broadcom-wl-5.100.138.tar.bz2
tar xjf broadcom-wl-5.100.138.tar.bz2
cd broadcom-wl-5.100.138/linux/

sudo b43-fwcutter -w /lib/firmware wl_apsta.o
```

## Slow boot problem

Since the boot process is very slow so add this line to `/etc/default/grub`

```
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash video=SVIDEO-1:d"
```

Update grub using 

```
grub2-mkconfig -o /boot/grub2/grub.cfg
```

## Continual reporting of issues

Disabled SELinux and it stopped reporting those issues. For which just change the line from `SELinux=enforcing` to `SELinux=disabled` in `/etc/sysconfig/selinux`. Need to figure out why those errors were reported in a loop.

Ref:

- [Update Grub](https://ask.fedoraproject.org/en/question/80362/how-do-i-update-grub-in-fedora-23/)
- [Boot very slow because of drm_kms_helper errors](https://askubuntu.com/questions/893817/boot-very-slow-because-of-drm-kms-helper-errors)
- [Firmware file "b43/ucode15.fw" not found](http://praveenkpal.blogspot.com/2010/05/firmware-file-b43ucode15fw-not-found.html)
- [How to Disable SELinux Temporarily or Permanently in RHEL/CentOS 7/6](https://www.tecmint.com/disable-selinux-temporarily-permanently-in-centos-rhel-fedora/)
