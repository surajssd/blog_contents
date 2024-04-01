---
author: "Suraj Deshmukh"
date: "2021-03-23T07:07:07+05:30"
title: "Kubernetes The Hard Way in \"Vagrant\"?"
description: "The first step in your CKA preparation!"
draft: false
categories: ["kubernetes", "cka"]
tags: ["kubernetes", "cka"]
cover:
  image: "/post/2021/03/kthw-vagrant/cert.png"
  alt: "CKA logo"
---

If you are studying for the [Certified Kubernetes Administrator (CKA)](https://suraj.io/post/road-to-cka/) exam, you might have come across folks recommending [Kelsey Hightower's](https://twitter.com/kelseyhightower) [Kubernetes the Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way/). It is an excellent first step for someone who has no idea about the [components that form a Kubernetes cluster](https://kubernetes.io/docs/concepts/overview/components/). As the name suggests, it is created so that you learn the Kubernetes building blocks the "hard way".

But all that can be intimidating to someone who hasn't played with Kubernetes ever. Also, [the guide](https://github.com/kelseyhightower/kubernetes-the-hard-way/) uses Google Cloud as a platform to install everything, which mandates you to have a Google Cloud account. But don't worry, there is a version of Kubernetes the Hard Way, which runs locally, hence free. Enter [Kubernetes the Hard Way Vagrant](https://github.com/surajssd/kubernetes-the-hard-way-vagrant)!

Kubernetes the Hard Way Vagrant, was started by folks at [Kinvolk](https://github.com/kinvolk/kubernetes-the-hard-way-vagrant). It is a set of scripts that does the exact same thing done in Kelsey's KTHW. The only difference is that it is automated with scripts and, at the same time, gives you the flexibility to do things manually if you like. These scripts help any newbie understand how a Kubernetes cluster can be brought up one node at a time. They can study each and every step of cluster creation and replicate those steps manually. Another minor difference is that this repository uses [cri-o](https://github.com/cri-o/cri-o) as a container runtime instead of [containerd](https://containerd.io/) used in Kelsey's tutorial.

To get started, all you need is a machine with 4.8 GB of spare memory and enough CPU to run seven small VMs. Install [Vagrant](https://www.vagrantup.com/docs/installation) and [VirtualBox](https://www.virtualbox.org/wiki/Downloads) to run these VMs. Once you have these prerequisites, all you need to do to get started is run the following steps:

```bash
git clone https://github.com/surajssd/kubernetes-the-hard-way-vagrant
cd kubernetes-the-hard-way-vagrant
./scripts/install-tools
./scripts/setup
```

That's all. And the `./scripts/setup` will start three controller machines and three worker machines, and a load balancer machine, install the Kubernetes components and run them. See the following image to understand what the architecture looks like:

![Kubernetes The Hard Way Arch](/post/2021/03/kthw-vagrant/kthw.png "Kubernetes The Hard Way Arch")

You can run individual script invoked by `./scripts/setup` manually to get an in-depth understanding of what is happening underneath. Find more explanation on each sub-script on the [README](https://github.com/surajssd/kubernetes-the-hard-way-vagrant#multiple-scripts).

[This repository](https://github.com/surajssd/kubernetes-the-hard-way-vagrant) is an excellent first step to doing Kelsey's KTHW on Vagrant. I hope you find this helpful.
