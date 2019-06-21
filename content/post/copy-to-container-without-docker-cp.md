+++
author = "Suraj Deshmukh"
date = "2019-06-21T11:57:07+05:30"
title = "Copying files to container the generic way"
description = "No docker cp needed to copy files from host to your container"
categories = ["docker", "host", "containers"]
tags = ["proc", "docker", "host", "containers"]
+++

This blog shows you how you can copy stuff from your host machine to the running container without the `docker cp` command that we usually use.

# Steps in text

Here I have a script on the host, which looks following:

```bash
#!/bin/bash

tput bold
echo "OS Information:"
tput sgr0
echo

cat /etc/os-release
```

After running which looks like following:

```bash
$ ls
script.sh

$ ./script.sh
OS Information:

NAME="Flatcar Linux by Kinvolk"
ID=flatcar
ID_LIKE=coreos
VERSION=2079.6.0
VERSION_ID=2079.6.0
BUILD_ID=2019-06-18-0855
PRETTY_NAME="Flatcar Linux by Kinvolk 2079.6.0 (Rhyolite)"
ANSI_COLOR="38;5;75"
HOME_URL="https://flatcar-linux.org/"
BUG_REPORT_URL="https://issues.flatcar-linux.org"
FLATCAR_BOARD="amd64-usr"
```

And here is the running container in another tab to which I want to copy the file.

```bash
$ docker run -it fedora bash
[root@0d6d865626ff /]#
```

**Note**: All the console with shell prompt `[root@0d6d865626ff /]#` means that the command is run inside the container.

I can always run the `docker cp` command like following to copy file:

```bash
$ docker ps
CONTAINER ID        IMAGE                                     COMMAND                  CREATED              STATUS              PORTS               NAMES
0d6d865626ff        fedora                                    "bash"                   About a minute ago   Up About a minute                       hardcore_roentgen
$ docker cp script.sh hardcore_roentgen:/
```

Now if I check it from the container:

```bash
[root@0d6d865626ff /]# ls / | grep script
script.sh
```

Let's clean up the file and use another easier and container runtime agnostic method to do the same.

```bash
[root@0d6d865626ff /]# rm script.sh
rm: remove regular file 'script.sh'? y
[root@0d6d865626ff /]# ls /
bin  boot  dev  etc  home  lib  lib64  lost+found  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
```

To figure out the file system root of the container process let's start a `sleep` process.

```bash
[root@0d6d865626ff /]# sleep 3000

```

Now the `sleep` process will help us identify the PID of this process on the host.

```bash
$ ps aufx | grep sleep
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root      1668  0.0  0.0   5252   692 pts/0    S+   16:47   0:00          \_ sleep 3000
```

Since we figured out the PID of the process to be `1668`, now let's copy the file to the root of the container by running following command. Down here I have used the PID that I got output of above, replace it with the PID you get for your process.

```bash
$ sudo cp -v ./script.sh /proc/1668/root/
'./script.sh' -> '/proc/1668/root/script.sh'
```

Now we can stop the sleep process we started earlier in the container see in the root that the file has been copied successfully.

```bash
[root@0d6d865626ff /]# sleep 3000
^C
[root@0d6d865626ff /]# ls / | grep script
script.sh
```

---

# Video of above steps

{{< youtube dVUhpFjEyEE >}}

---

I learnt this trick while pair coding/learning things about container security with my colleague Alban, thanks [Alban](https://twitter.com/albcr)!.
