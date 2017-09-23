+++
author = "Suraj Deshmukh"
title = "Static Pods using Kubelet on Fedora"
description = "Extension to the Kelsey Hightower's tutorial on 'Standalone Kubelet'"
date = "2017-09-23T13:10:14+05:30"
categories = ["notes", "kubernetes"]
tags = ["kubernetes", "openshift"]
+++

I wanted to try out [*Standalone Kubelet Tutorial*](https://github.com/kelseyhightower/standalone-kubelet-tutorial)
of [**Kelsey Hightower**](https://twitter.com/kelseyhightower) by myself but I could not
follow it as it is, because it was firstly on [GCE](https://cloud.google.com/compute/) and
secondly it uses [CoreOS](https://en.wikipedia.org/wiki/Container_Linux_by_CoreOS),
but since I am very familiar to [Fedora](https://en.wikipedia.org/wiki/Fedora_(operating_system))
I thought of following that tutorial on it. To get a quick setup of a fresh Fedora machine
use [Vagrant](https://en.wikipedia.org/wiki/Vagrant_(software)). I have used Vagrantfile
available [here](https://github.com/surajssd/scripts/blob/master/Vagrantfiles/fedora/Vagrantfile).

This blog is only replacement of section [**Install the Standalone Kubelet**](https://github.com/kelseyhightower/standalone-kubelet-tutorial#install-the-standalone-kubelet)
in tutorial.

## Installing packages

Since the tutorial uses CoreOS VM it already has a [Kubelet](https://kubernetes.io/docs/admin/kubelet/)
binary available, on Fedora you can get one using [`dnf`](https://en.wikipedia.org/wiki/DNF_(software)).
In tutorial Kelsey has put in his custom systemd service file, we will also make some
changes to the default kubelet's service file packaged in Fedora.

```bash
sudo dnf -y install kubernetes-node
sudo systemctl enable docker --now
sudo systemctl enable kubelet --now
```

Since `docker` is a dependency of `kubelet` it is also installed, all we need to do is start
Docker manually alongwith Kubelet.

Verify if `kubelet` and `docker` are running

```bash
sudo systemctl status docker kubelet
```

## Editing kubelet systemd service file

Apply following changes to `/etc/kubernetes/config`

```diff
diff --git a/config b/config
index 8c0a284..cfccbee 100644
--- a/config
+++ b/config
@@ -16,7 +16,7 @@ KUBE_LOGTOSTDERR="--logtostderr=true"
 KUBE_LOG_LEVEL="--v=0"
 
 # Should this cluster be allowed to run privileged docker containers
-KUBE_ALLOW_PRIV="--allow-privileged=false"
+KUBE_ALLOW_PRIV="--allow-privileged=true"
 
 # How the controller-manager, scheduler, and proxy find the apiserver
 KUBE_MASTER="--master=http://127.0.0.1:8080"
```

By default in Fedora the Kubelet service won't be running privileged pods. Setting flag
`--allow-privileged` to `true` will allow you to do that. In Kelsey's tutorial you can
find it [here](https://github.com/kelseyhightower/standalone-kubelet-tutorial/blob/98b0b5b000cc687cc9c85c54ded7b39f4322d4ba/kubelet.service#L8).


Apply following changes to `/etc/kubernetes/kubelet`

```diff
diff --git a/kubelet b/kubelet
index cfd5686..07c11ab 100644
--- a/kubelet
+++ b/kubelet
@@ -14,4 +14,4 @@ KUBELET_HOSTNAME="--hostname-override=127.0.0.1"
 KUBELET_API_SERVER="--api-servers=http://127.0.0.1:8080"
 
 # Add your own!
-KUBELET_ARGS="--cgroup-driver=systemd"
+KUBELET_ARGS="--cgroup-driver=systemd --pod-manifest-path=/etc/kubernetes/manifests"
```

To Kubelet we have added one more flag called `--pod-manifest-path` which is explained in
docs as:

>Path to the directory containing pod manifest files to run, or the path to a single pod
manifest file.                                                                      

Above line can be found in tutorial in [here](https://github.com/kelseyhightower/standalone-kubelet-tutorial/blob/98b0b5b000cc687cc9c85c54ded7b39f4322d4ba/kubelet.service#L12).


## Make directory for pod manifests

```
sudo mkdir /etc/kubernetes/manifests
```


## Restart `kubelet` service

```bash
sudo systemctl restart kubelet
```

Now you can follow the rest of the tutorial as it is from section [**Static Pods**](https://github.com/kelseyhightower/standalone-kubelet-tutorial#static-pods).


References:

- [Static Pods](https://kubernetes.io/docs/tasks/administer-cluster/static-pod/)
- [Standalone Kubelet Tutorial - Kelsey Hightower](https://github.com/kelseyhightower/standalone-kubelet-tutorial)
