+++
author = "Suraj Deshmukh"
title = "Sharing Vagrant Box offline"
description = "Share Vagrant boxes like you shareed Operating System ISOs"
date = "2017-09-18T10:43:46+05:30"
categories = ["vagrant", "fedora", "centos"]
tags = ["vagrant", "fedora", "centos"]
+++

If you have some box that was downloaded on your machine from [Atlas](https://app.vagrantup.com/boxes/search)
but now you wanna share it on other machines and you don't have internet to download it,
how do you share it?

You will need to export the box from machine that has it downloaded already. So on machine
with boxes:

```bash
$ vagrant box list
centos/7             (libvirt, 1610.01)
centos/7             (libvirt, 1704.01)
fedora/25-cloud-base (libvirt, 20161122)
fedora/26-cloud-base (libvirt, 20170705)
```

I wanted to share `fedora/26-cloud-base` box to another machine. Run the following command:

```bash
$ vagrant box repackage fedora/26-cloud-base libvirt 20170705
```

If you deconstruct the above command you will find that the input to above command is all
seen in output of command `vagrant box list`, where `fedora/26-cloud-base` is the box name &
`libvirt` is the provider & `20170705` is the version.

Or find more help running:

```bash
$ vagrant box repackage -h
Usage: vagrant box repackage <name> <provider> <version>
```

Above command creates the file named `package.box`.

Now transfer this box file to another machine and there you will have to import this box.
Over there run command:

```bash
$ vagrant box add fedora/26-cloud-base package.box
==> box: Box file was not detected as metadata. Adding it directly...
==> box: Adding box 'fedora/26-cloud-base' (v0) for provider: 
    box: Unpacking necessary files from: file:///home/foobar/package.box
==> box: Successfully added box 'fedora/26-cloud-base' (v0) for 'libvirt'!
```

Now you can list the boxes and use it on this new machine.

Here is a list of [Vagrantfiles](https://github.com/surajssd/scripts/tree/master/Vagrantfiles)
I use for all my local setup.