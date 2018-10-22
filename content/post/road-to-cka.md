+++
author = "Suraj Deshmukh"
title = "Road to CKA"
description = "My experience with CKA exam preparation"
date = "2018-10-21T00:00:51+05:30"
categories = ["kubernetes", "cka"]
tags = ["cka", "kubernetes"]
+++

I passed CKA exam with 92% marks on 19th October 2018.

![](/images/road-to-cka/cert.png "")

A lot of folks are curious about how to prepare and what resources to follow. Here is my list of things to do and list of resources that might help you on successful CKA exam.

The duration of exam is three hours, which is enough time if you do good practice. The exam is pretty straight forward and tests your Kubernetes hands-on knowledge, so whatever you read please try to do it on a real cluster.

You have access to Kubernetes docs during the exam so make sure you go through Kubernetes documentation thoroughly. Once you are familiar with the documentation you will know where to look at if you need to refer something.

**Note**: I have not read any book on Kubernetes or followed any professional training. Other people do recommend reading books which might be helpful but again do follow those books/courses with more preference to hands-on practice.


## Your Kubernetes cluster

For me the go-to place for a cluster has always been either Katacoda's [Kubernetes Playground](https://www.katacoda.com/courses/kubernetes/playground) or my local machine with [minikube](https://github.com/kubernetes/minikube/) installed on it. This sufficed most of my use cases but if you want to have a multi-node setup with networking and everything [kubeadm](https://kubernetes.io/docs/setup/independent/install-kubeadm/) is a quick way to setup a new cluster.


## Things you must do hands-on

- [**Kubernetes the hard way**](https://github.com/kelseyhightower/kubernetes-the-hard-way/) by Kelsey Hightower. This tutorial setup is on GCP, but if you want you can also do it locally by setting up machines using Vagrant or something similar. I personally always did this setup on my local machine using Vagrant(The explanation about my setup can go in another post though).

- [**Kubernetes Tasks**](https://kubernetes.io/docs/tasks/) from docs, just don't blindly do the tasks. Most tasks have link to the concepts of what is being done. Follow those links and read up.


## Things you must read

- [**Kubernetes Concepts**](https://kubernetes.io/docs/concepts/)
- [**Kubernetes Reference**](https://kubernetes.io/docs/reference/)
- Basics of `systemd`, like starting, restarting and enabling the service. And how to read the systemd service file.


## Other resources

- You should focus on [imperative style](https://kubernetes.io/docs/concepts/overview/object-management-kubectl/overview/#imperative-object-configuration) of using Kubernetes; for that thoroughly read up and practice following posts:

  * [Overview of kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)
  * [Managing Resources](https://kubernetes.io/docs/concepts/cluster-administration/manage-deployment/)
  * [Managing Kubernetes Objects Using Imperative Commands](https://kubernetes.io/docs/concepts/overview/object-management-kubectl/imperative-command/)
  * [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

- [This github repo](https://github.com/walidshaari/Kubernetes-Certified-Administrator) by [Walid Shaari](https://twitter.com/walidshaari) is a really good source of finding right resources to read according to the [syllabus distribution](https://github.com/cncf/curriculum/blob/master/certified_kubernetes_administrator_exam_v1.11.0.pdf).

- Learn to generate resouces on the fly with `kubectl create ...`. This will help you in not having to write entire kubernetes resouce yaml file by hand, which can be tedious and erroneous task. Whenever you are running those commands and are confused about it's usage `kubectl create -h` gives you examples of various usages of the command.

- You don't need to remember the location of systemd service files, the trick I use to find the location of service file is just try to see the status of service by running `systemctl status <service name>` and in there you will see the location to service file that is loaded.


## During exam

- Make yourself familiar with `tmux`, this helps if you like having split screen while working.

- Having a decent sized monitor for exam can help if you have problem with small font size and having to fit everything in one small laptop window, but then this will also imply that you will need external webcam.

- The exam is supported on Chrome only and if you are used to using the shortcut on terminal to delete word `Ctrl + W`, which also happens to close the chrome window tab then you might want to remove that shortcut. [Here is what I did](https://suraj.io/post/disable-ctrl-w/) on my system to disable the shortcut during the exam.

- The first thing to do after exam starts, enable `kubectl` auto-completion in exam terminal by running `source <(kubectl completion bash)`.

---

With all that said, I will try to keep this document alive by adding things if I remember any, otherwise always feel free to reach out to me on twitter [@surajd_](https://twitter.com/surajd_). Also join the [Kubernauts community](https://kubernauts-slack-join.herokuapp.com/) where people are really helpful with your queries.
