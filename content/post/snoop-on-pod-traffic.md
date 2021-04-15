+++
author = "Suraj Deshmukh"
date = "2020-06-06T20:30:07+05:30"
title = "Watch Container Traffic Without Exec"
description = "How to watch the traffic of a container or a pod without execing into the pod/contaienr?"
categories = ["kubernetes", "security", "containers"]
tags = ["kubernetes", "security", "containers"]
+++

## Introduction

For the reasons of security, many container deployments nowadays run their workloads in a scratch based image. This form of implementation helps reduce the attack surface since there is no shell to gain access to, especially if someone were to break out of the application.

But for the developers or operators of such applications, it is hard to debug. Since they lack essential tools or even `bash` for that matter, but the application's debugging ability should not dictate its production deployment and compromise its security posture.

This blog shows one of the many debugging requirements of any connected application, i.e. network snooping or network debugging. I won't emphasise the importance of network debugging in the world of microservices, where containers lead the deployment model.

Now imagine a scenario where you have an application, statically built based on scratch image and running inside a container. How do you watch the traffic of such an app? You don't have any terminal in that container. You are not allowed to make changes to the environment of the application because this is a production setup. This barebone container image deployment is the exact scenario that this post helps in debugging.

## Container Scenario

For the demo, I have a running application which is doing some networking.

```bash
$ docker ps
CONTAINER ID    IMAGE     COMMAND   CREATED         STATUS          PORTS    NAMES
241bf66c36c6    fedora    "bash"    14 minutes ago  Up 14 minutes            upbeat_heisenberg
```

The IP address of this application is `172.17.0.2` found using following command:

```bash
$ docker inspect upbeat_heisenberg | grep IPAddress | tail -1
                    "IPAddress": "172.17.0.2",
```

And on the server-side I have the following simple HTTP server running on the host machine:

```bash
$ python3 -m http.server
Serving HTTP on 0.0.0.0 port 8000 (http://0.0.0.0:8000/) ...
172.17.0.2 - - [06/Jun/2020 18:53:18] "GET / HTTP/1.1" 200 -
[REDACTED]
```

The IP address of the server is `172.17.0.1` found using the following command:

```bash
$ ip address show docker0 | grep 'inet '
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
```

## Debugging

Now I cannot exec into the container, but I want to see what traffic sent by the application inside the container. Let's find out the PID of the process running inside the container:

```bash
$ docker inspect --format '{{.State.Pid}}' 241bf66c36c6
1371226
```

Alright, now we know that the process running inside has PID `1371226`. Now lets us try to enter into this process's network namespace and use the good old tcpdump.

```bash
$ sudo nsenter -t 1371226 -n tcpdump -A -s 0 '(((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)'
dropped privs to tcpdump
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 262144 bytes
19:21:26.685275 IP thinkpad.36852 > _gateway.irdmi: Flags [P.], seq 2980991125:2980991212, ack 2001355994, win 502, options [nop,nop,TS val 3794513222 ecr 3920804277], length 87
E.....@.@..............@..P.wJD.....X......
.+.F....GET /file.txt HTTP/1.1
Host: 172.17.0.1:8000
User-Agent: curl/7.66.0
Accept: */*


19:21:26.686787 IP thinkpad.56338 > XiaoQiang.domain: 8019+ PTR? 1.0.17.172.in-addr.arpa. (41)
E..E..@.@..+...........5.1...S...........1.0.17.172.in-addr.arpa.....
19:21:26.686958 IP _gateway.irdmi > thinkpad.36852: Flags [P.], seq 1:186, ack 87, win 509, options [nop,nop,TS val 3920804279 ecr 3794513222], length 185
E.....@.@.9/.........@..wJD...P.....Y......
.....+.FHTTP/1.0 200 OK
Server: SimpleHTTP/0.6 Python/3.7.7
Date: Sat, 06 Jun 2020 13:51:26 GMT
Content-type: text/plain
Content-Length: 12
Last-Modified: Sat, 06 Jun 2020 13:22:34 GMT


19:21:26.687101 IP _gateway.irdmi > thinkpad.36852: Flags [P.], seq 186:198, ack 87, win 509, options [nop,nop,TS val 3920804279 ecr 3794513224], length 12
E..@..@.@.9..........@..wJE...P.....XX.....
.....+.HI am Server

[REDACTED]
```

There you go, the output shows that the target server `172.17.0.1:8000` is responding over `HTTP` protocol `I am Server`.

## With Kubernetes

The same can be achieved with Kubernetes as well. Follow these steps:

```
docker ps | grep <pod-initial>
ID= // take docker id by hand
PID=`docker inspect --format '{{.State.Pid}}' $ID`
sudo nsenter -t $PID -n tcpdump
```

## References and Credits

- Thanks to my colleague [Mauricio Vásquez Bernal](https://twitter.com/maurovasquezb), from whom I learnt this trick.
- Tweet about these steps in brief details https://twitter.com/surajd_/status/1152218150932365312.
- The complex tcpdump command used to decode the HTTP traffic: https://sites.google.com/site/jimmyxu101/testing/use-tcpdump-to-monitor-http-traffic.
