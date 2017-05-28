+++
title = "k8s on CRI-O - single node"
categories = ["notes", "kubernetes"]
author = "Suraj Deshmukh"
date = "2017-04-08T00:11:37+05:30"
description = "How to make kubernetes use CRI-O as container runtime"
tags = ["kubernetes", "notes", "crio"]

+++

Here is a single node Kubernetes on CRI-O. This setup is done on Fedora 25.

### Installing OS dependencies

```bash
dnf -y install \
  go \
  git \
  btrfs-progs-devel \
  device-mapper-devel \
  glib2-devel \
  glibc-devel \
  glibc-static \
  gpgme-devel \
  libassuan-devel \
  libgpg-error-devel \
  libseccomp-devel \
  libselinux-devel \
  pkgconfig \
  wget \
  etcd \
  iptables
```

### Creating go environment

```bash
cd ~
mkdir -p ~/go

export GOPATH=~/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOBIN

echo 'GOPATH=~/go' >> ~/.bashrc
echo 'GOBIN=$GOPATH/bin' >> ~/.bashrc
echo 'PATH=$PATH:$GOBIN' >> ~/.bashrc
```

### Pull all the code dependencies

```bash
go get -d k8s.io/kubernetes
go get -u github.com/cloudflare/cfssl/cmd/...
```

### Install runc

```bash
go get -d github.com/opencontainers/runc
cd $GOPATH/src/github.com/opencontainers/runc
git reset --hard v1.0.0-rc3
make BUILDTAGS='seccomp selinux' && make install
```

### Build `cri-o`

```bash
cd
go get -d github.com/kubernetes-incubator/cri-o
cd $GOPATH/src/github.com/kubernetes-incubator/cri-o
make install.tools
make && make install
make install.config
```

### Set up CNI

```bash
go get -d github.com/containernetworking/cni
cd $GOPATH/src/github.com/containernetworking/cni
./build.sh

mkdir -p /opt/cni/bin
cp bin/* /opt/cni/bin/

mkdir -p /etc/cni/net.d/
cat > /etc/cni/net.d/10-ocid-bridge.conf <<EOF
{
    "cniVersion": "0.2.0",
    "name": "ocid-bridge",
    "type": "bridge",
    "bridge": "cni0",
    "isGateway": true,
    "ipMasq": true,
    "ipam": {
        "type": "host-local",
        "subnet": "10.88.0.0/16",
        "routes": [
            { "dst": "0.0.0.0/0" }
        ]
    }
}
EOF

cat > /etc/cni/net.d/99-loopback.conf <<EOF
{
    "cniVersion": "0.2.0",
    "type": "loopback"
}
EOF
```

### Create `policy.json`

```bash
mkdir -p  /etc/containers

cat > /etc/containers/policy.json <<EOF
{
    "default": [
        {
            "type": "insecureAcceptAnything"
        }
    ]
}
EOF
```

### Make SELinux happy

```bash
mkdir -p /var/lib/containers/
chcon -Rt svirt_sandbox_file_t /var/lib/containers/
```

### Start ocid service

```bash
export PATH=$PATH:/usr/local/bin/
echo 'PATH=$PATH:/usr/local/bin/' >> ~/.bashrc
ocid --runtime /usr/local/sbin/runc --log /root/ocid.log --debug --selinux true
```

### Start k8s cluster with crio

```bash
cd $GOPATH/src/k8s.io/kubernetes/
CONTAINER_RUNTIME=remote CONTAINER_RUNTIME_ENDPOINT='/var/run/ocid.sock --runtime-request-timeout=15m' ./hack/local-up-cluster.sh
```

To use `kubectl` (in new terminal)

```bash
alias kubectl=$GOPATH/src/k8s.io/kubernetes/cluster/kubectl.sh
echo 'alias kubectl=$GOPATH/src/k8s.io/kubernetes/cluster/kubectl.sh'  >> ~/.bashrc
```

Ref:

- Bangalore Kubernetes Meetup - April 2017 - [Slides](https://docs.google.com/presentation/d/1tP7b1e1fy-n3_v5bilDLjOAheZGu602B3WK-1kxXkVo/edit?usp=sharing).
- [runcom's](https://twitter.com/runc0m) [Setup script](https://gist.github.com/runcom/ba58bf2f64e38d9f5d376d587751a0f9#file-fedora_25) for Fedora.
- [cri-o project](https://github.com/kubernetes-incubator/cri-o)
- cri-o [tutorial](https://github.com/kubernetes-incubator/cri-o/blob/master/tutorial.md)
- [Running cri-o on kubernetes cluster](https://github.com/kubernetes-incubator/cri-o/blob/master/kubernetes.md)
- CRI-O: A kubernetes runtime - [video](https://www.youtube.com/watch?v=R-p7BXhtodo)
