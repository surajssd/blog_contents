+++
author = "Suraj Deshmukh"
title = "Single node Kubernetes Cluster on Fedora with SELinux enabled"
description = "Kubeadm to install Single Node K8S with SELinux"
date = "2018-09-11T01:00:51+05:30"
categories = ["kubernetes", "selinux"]
tags = ["kubernetes", "openshift", "selinux", "security", "fedora"]
+++

Start a single node fedora machine, using whatever method but I have used [this Vagrantfile](https://github.com/surajssd/scripts/blob/master/Vagrantfiles/fedora/Vagrantfile) to do it:

```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|

  config.vm.define "fedora" do |fedora|
    fedora.vm.box = "fedora/28-cloud-base"
    config.vm.hostname = "fedora"
  end

  config.vm.provider "virtualbox" do |virtualbox, override|
    virtualbox.memory = 4096
    virtualbox.cpus = 4
  end

  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    echo '127.0.0.1 localhost' | cat - /etc/hosts > temp && sudo mv temp /etc/hosts
  SHELL
end
```

Now start it and ssh into it:

```bash
vagrant up
vagrant ssh
```

Once inside the machine, become root user and run [this script](https://github.com/surajssd/scripts/blob/master/shell/k8s-install-single-node/install.sh):

```bash
sudo -i
curl https://raw.githubusercontent.com/surajssd/scripts/master/shell/k8s-install-single-node/install.sh | sh
```

And you should have a running Kubernetes cluster.

# Understanding steps

Install and start `docker`:

```bash 
yum install -y docker
systemctl enable docker && systemctl start docker
```

Install `kubelet` and start it:

```bash
echo "
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kube*
" | tee /etc/yum.repos.d/kubernetes.repo

yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
systemctl enable kubelet && systemctl start kubelet
```

Set SELinux contexts:

```bash
# for kubernetes files
mkdir -p /etc/kubernetes/
chcon -R -t svirt_sandbox_file_t /etc/kubernetes/

# for etcd files
mkdir -p /var/lib/etcd
chcon -R -t svirt_sandbox_file_t /var/lib/etcd
```

Start `kubeadm`:

```bash
kubeadm config images pull
kubeadm init
```

Set the `kubectl` context:

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Install network, this step can be varied depending on which networking provider you want to install, here I have installed weave net. For other providers see [here](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#pod-network).

```bash 
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
```

Also use `master` node as `worker` node.

```bash
kubectl taint nodes --all node-role.kubernetes.io/master-
```

Finally list nodes or wait until node is ready.

```bash
kubectl get nodes
```

# Debugging the setup

- You can see logs of `kubelet` by running `journalctl -f -u kubelet`
- You can also see if there are any failing control plain containers by running `docker ps -a` and then check the logs of failed containers.

# References

- [Install Kubeadm](https://kubernetes.io/docs/setup/independent/install-kubeadm/)
- [Start Kubeadm cluster](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/)
- [Installation script](https://github.com/surajssd/scripts/blob/master/shell/k8s-install-single-node/install.sh)
