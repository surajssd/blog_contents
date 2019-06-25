+++
author = "Suraj Deshmukh"
date = "2019-06-25T11:57:07+05:30"
title = "Root user inside container is root on the host"
description = "The easiest way to prove that root inside the container is also root on the host"
categories = ["docker", "host", "containers", "security"]
tags = ["proc", "docker", "host", "containers", "security"]
+++

Here are simple steps that you can follow to prove that the `root` user inside container is also `root` on the host. And how to mitigate this.


## Root in container, root on host

I have a host with docker daemon running on it. I start a normal container on it with `sleep` process as PID1. See in the following output that the container `clever_lalande` started with `sleep` process.

```bash
$ docker run -d --rm alpine sleep 9999
6c541cf8f7b315783d2315eebc2f7dddd1f7b26f427e182f8597b10f2746ab0b

$ docker ps
CONTAINER ID    IMAGE      COMMAND         CREATED             STATUS           PORTS   NAMES
6c541cf8f7b3    alpine     "sleep 9999"    12 seconds ago      Up 11 seconds            clever_lalande
```

Now let's find out the process `sleep` on the host. Here in the following output you can see that the process sleep is running as user `root`.

```bash
$ ps aufx | grep sleep
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root      4826  0.3  0.0   1552     4 ?        Ss   07:34   0:00      \_ sleep 9999
core      4864  0.0  0.0   6864   964 pts/0    S+   07:34   0:00          \_ grep --colour=auto sleep
```

Also the sleep process is root inside the container.

```bash
$ docker exec -it clever_lalande id
uid=0(root) gid=0(root)
```

## Non-root inside the container, non-root on host

The user I am logged into this machine is called `core` with user id 500.

```bash
$ whoami
core

$ id
uid=500(core) gid=500(core) groups=500(core),10(wheel),233(docker),248(systemd-journal),250(portage),251(rkt) context=system_u:system_r:kernel_t:s0
```

Let's start the container in the same way but with additional flag `--user`. Here I started a new container and forced it to run under the security context of the user `core`. Here I specify the UID same as the UID on the host. The documentation of the flag says that:

> -u, --user="".
>
> Sets the username or UID used and optionally the groupname or GID for the specified command.

Here is the container that is started with `sleep` process named `wonderful_proskuriakova`.

```bash
$ docker run -d --rm --user ${UID}:${UID} alpine sleep 9999
1cdc11a449e4e62a9557a4d7b586aa320f5512f2746f4a8e1cac7b9e6d2e1225

$ docker ps
CONTAINER ID    IMAGE     COMMAND        CREATED            STATUS          PORTS     NAMES
1cdc11a449e4    alpine    "sleep 9999"   25 seconds ago     Up 25 seconds             wonderful_proskuriakova
```

If I try to find the same process on the host here you can clearly see that the process is not running as `root` but as user `core`.

```bash
$ ps aufx | grep sleep
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
core      4607  0.0  0.0   1552     4 ?        Ss   07:30   0:00      \_ sleep 9999
core      4648  0.0  0.0   6864   900 pts/0    S+   07:30   0:00          \_ grep --colour=auto sleep
```

Also inside the container I am running as UID `500`.

```bash
$ docker exec -it wonderful_proskuriakova id
uid=500 gid=500
```

This is just one way to mitigate the user to be non-root. You should also drop all the capabilities and whitelist the capabilities that are absolutely needed. Also provide a seccomp profile that is locked down which only allows the syscalls that are needed by your application. There are many times where you want to run as root inside the container in such situations you should use user namespaces, which is what we are looking in the next section.

## Root inside container, non-root on host

Now I have docker daemon which is started with docker user namespace enabled. Look at the flag `--userns-remap=default` being used to start the docker daemon with user namespace. To know more about enabling user namespace, follow docs [here](https://docs.docker.com/engine/security/userns-remap/).

```bash
$ systemctl status docker-userns
● docker-userns.service - Docker Application Container Engine
   Loaded: loaded (/etc/systemd/system/docker-userns.service; disabled; vendor preset: disabled)
   Active: active (running) since Tue 2019-06-25 07:07:37 UTC; 1h 11min ago
     Docs: http://docs.docker.com
 Main PID: 4011 (dockerd)
    Tasks: 10
   Memory: 61.8M
   CGroup: /system.slice/docker-userns.service
           └─4011 /run/torcx/bin/dockerd --host=fd:// --host=tcp://127.0.0.1:2376 --containerd=/var/run/docker/libcontainerd/docker-containerd.sock --userns-remap=default --pidfile /var/run/docker-userns.pid --selinux-enabled=true
...
```

Now start the container like we did for the first time without any `--user` flag. In the following output you can see that the container started with name `sad_pasteur`.

```bash
$ docker run --rm -d alpine sleep 9999
05290a7088b3e7c0e4e80cbb3a63c0d63a49627b8d31ec9f75f44b9a57b717f4

$ docker ps
CONTAINER ID    IMAGE     COMMAND         CREATED            STATUS        PORTS    NAMES
05290a7088b3    alpine    "sleep 9999"    2 seconds ago      Up 1 second            sad_pasteur
```

Now if we see the `sleep` process on host, the process has started with different user `100000` on host.

```bash
$ ps aufx | grep sleep
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
100000    5467  0.2  0.0   1552     4 ?        Ss   08:16   0:00      \_ sleep 9999
core      5511  0.0  0.0   6864   988 pts/0    S+   08:16   0:00          \_ grep --colour=auto sleep
```

But inside the container the user is still `root`.

```bash
$ docker exec -it sad_pasteur id
uid=0(root) gid=0(root)
```

This is because of the user namespace enabled on the docker daemon that we see user `100000` on host. This mapping of the user id on host and inside the container can be found in the following files:

```
$ cat /etc/subuid
dockremap:100000:65536

$ cat /etc/subgid
dockremap:100000:65536
```

## References

- [Docker Lab: User Namespaces](https://github.com/docker/labs/blob/master/security/userns/README.md)
- [Isolate containers with a user namespace](https://docs.docker.com/engine/security/userns-remap/)
