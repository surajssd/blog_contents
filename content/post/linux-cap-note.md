+++
author = "Suraj Deshmukh"
date = "2019-06-25T15:15:07+05:30"
title = "Capabilities on executables"
description = "Note on Linux Kernel capabilities"
categories = ["docker", "host", "containers", "security"]
tags = ["proc", "docker", "host", "containers", "security"]
+++

File capabilities allow users to execute programs with higher privileges. Best example is network utility `ping`.

A `ping` binary has capabilities `CAP_NET_ADMIN` and `CAP_NET_RAW`. A normal user doesn't have `CAP_NET_ADMIN` privilege, since the executable file `ping` has that capability you can run it.

```bash
$ getcap `which ping`
/usr/bin/ping = cap_net_admin,cap_net_raw+p
```

Which normally works as follows:

```bash
$ ping -c 1 1.1.1.1
PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
64 bytes from 1.1.1.1: icmp_seq=1 ttl=55 time=36.9 ms

--- 1.1.1.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 36.885/36.885/36.885/0.000 ms
```

If you copy file as a normal user the binary loses its privilege and the command ceases to work:

```bash
$ cp `which ping` /tmp/ping

$ /tmp/ping -c 1 1.1.1.1
ping: socket: Operation not permitted
```

## References

[Linux Capabilities: making them work](https://www.kernel.org/doc/ols/2008/ols2008v1-pages-163-172.pdf)
