+++
author = "Suraj Deshmukh"
title = "Kubernetes Cluster using Kubeadm on Flatcar Container Linux"
description = "Simple steps to install the cluster based on Flatcar Container Linux"
date = "2021-01-29T22:02:41+05:30"
categories = ["kubernetes", "flatcar", "container", "kubeadm"]
tags = ["kubernetes", "flatcar", "container", "kubeadm"]
+++

This blog shows a simple set of commands to install a Kubernetes cluster on [Flatcar Container Linux](https://www.flatcar-linux.org/) based machines using [Kubeadm](https://kubernetes.io/docs/reference/setup-tools/kubeadm/).

You might wonder why this blog when one can go to the official documentation and follow the steps? Yep, you are right. You can choose to do that. But this blog has a collection of actions specific to Flatcar Container Linux. These steps have been tried and tested on Flatcar, so you don't need to recreate and test them yourself. There are some nuances related to the read-only partitions of Flatcar, and this blog takes care of them at the control plane level and the CNI level both.

![Flatcar Container Linux](https://kinvolk.io/media/flatcar-linux-public-release_huff9ce14b9fc0c4cb57265a53fd2259cb_16308_900x0_resize_box_2.png "Flatcar Container Linux")

# Textual Steps

All the commands are run by becoming `root` using `sudo -i`.

## 1. Setup Nodes

All the following sub-steps should be run all the nodes.

### 1.1. Setup Networking

```
systemctl enable docker
modprobe br_netfilter

cat <<EOF | tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system
```

### 1.2. Download binaries and start Kubelet

```bash
CNI_VERSION="v0.8.2"
CRICTL_VERSION="v1.17.0"
RELEASE_VERSION="v0.4.0"
DOWNLOAD_DIR=/opt/bin
RELEASE="$(curl -sSL https://dl.k8s.io/release/stable.txt)"

mkdir -p /opt/cni/bin
mkdir -p /etc/systemd/system/kubelet.service.d

alias curl='curl -sSL'
curl "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-linux-amd64-${CNI_VERSION}.tgz" | tar -C /opt/cni/bin -xz
curl "https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-amd64.tar.gz" | tar -C $DOWNLOAD_DIR -xz
curl "https://raw.githubusercontent.com/kubernetes/release/${RELEASE_VERSION}/cmd/kubepkg/templates/latest/deb/kubelet/lib/systemd/system/kubelet.service" | sed "s:/usr/bin:${DOWNLOAD_DIR}:g" | tee /etc/systemd/system/kubelet.service
curl "https://raw.githubusercontent.com/kubernetes/release/${RELEASE_VERSION}/cmd/kubepkg/templates/latest/deb/kubeadm/10-kubeadm.conf" | sed "s:/usr/bin:${DOWNLOAD_DIR}:g" | tee /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
curl --remote-name-all https://storage.googleapis.com/kubernetes-release/release/${RELEASE}/bin/linux/amd64/{kubeadm,kubelet,kubectl}

chmod +x {kubeadm,kubelet,kubectl}
mv {kubeadm,kubelet,kubectl} $DOWNLOAD_DIR/

systemctl enable --now kubelet
systemctl status kubelet
```

### 1.3. Update Flatcar

Verify if you need to update Flatcar by running the following two commands:

```bash
curl -sSL https://stable.release.flatcar-linux.net/amd64-usr/current/version.txt | grep FLATCAR_VERSION
cat /etc/os-release | grep VERSION
```

If the output of the above two commands match, your Flatcar is already up to date, you don't need to run the following commands.

```bash
update_engine_client -update
systemctl reboot
```

## 2. Setup Controller Node

Run these steps only on the controller node.

### 2.1. Initialise Kubeadm

Here we are ensuring that the Kubelet volume-plugins directory is writable, the default path used is under `/usr` which is read-only on Flatcar, therefore we are setting it to writable path `/opt/libexec/kubernetes/kubelet-plugins/volume/exec/`.

From the [kubeadm docs](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/troubleshooting-kubeadm/#usr-mounted-read-only):

> On Linux distributions such as Flatcar Container Linux, the directory `/usr` is mounted as a read-only filesystem. For flex-volume support, Kubernetes components like the kubelet and kube-controller-manager use the default path of `/usr/libexec/kubernetes/kubelet-plugins/volume/exec/`, yet the flex-volume directory **must be writeable** for the feature to work.

```yaml
cat <<EOF | tee kubeadm-config.yaml
apiVersion: kubeadm.k8s.io/v1beta2
kind: InitConfiguration
nodeRegistration:
  kubeletExtraArgs:
    volume-plugin-dir: "/opt/libexec/kubernetes/kubelet-plugins/volume/exec/"
---
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
networking:
  podSubnet: 192.168.0.0/16
controllerManager:
  extraArgs:
    flex-volume-plugin-dir: "/opt/libexec/kubernetes/kubelet-plugins/volume/exec/"
EOF
```

```bash
kubeadm config images pull
kubeadm init --config kubeadm-config.yaml

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
```

### 2.2. Install CNI

Here I have chosen [Calico](https://www.projectcalico.org/) as the CNI to install because it is the one that I am familiar with, but you can choose to install any [other CNI](https://kubernetes.io/docs/concepts/cluster-administration/networking/#how-to-implement-the-kubernetes-networking-model).

```yaml
cat <<EOF | tee calico.yaml
# Source: https://docs.projectcalico.org/manifests/custom-resources.yaml
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  # Configures Calico networking.
  calicoNetwork:
    # Note: The ipPools section cannot be modified post-install.
    ipPools:
    - blockSize: 26
      cidr: 192.168.0.0/16
      encapsulation: VXLANCrossSubnet
      natOutgoing: Enabled
      nodeSelector: all()
  flexVolumePath: /opt/libexec/kubernetes/kubelet-plugins/volume/exec/
EOF
```

```bash
kubectl create -f https://docs.projectcalico.org/manifests/tigera-operator.yaml
kubectl apply -f calico.yaml
kubectl taint nodes --all node-role.kubernetes.io/master-
kubectl get pods -A
kubectl get nodes -o wide
```

### 2.3. Generate worker config

The general way to connect a worker to the control plane is by running the `kubeadm join` command generated at the end of the `kubeadm init` output. But you can run the following set of steps at any time to create a worker config.

```bash
URL=$(kubectl config view -ojsonpath='{.clusters[0].cluster.server}')
prefix="https://"
short_url=${URL#"$prefix"}
```

```yaml
cat <<EOF
apiVersion: kubeadm.k8s.io/v1beta2
kind: JoinConfiguration
discovery:
  bootstrapToken:
    apiServerEndpoint: $short_url
    token: $(kubeadm token create)
    caCertHashes:
    - sha256:$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //')
controlPlane:
nodeRegistration:
  kubeletExtraArgs:
    volume-plugin-dir: "/opt/libexec/kubernetes/kubelet-plugins/volume/exec/"
EOF
```

Copy the generated config to worker nodes and save it in a file named `worker-config.yaml`.

## 3. Join Workers to Controllers

Run the following steps only on worker nodes.

### 3.1. Connect to Control-Plane

```bash
kubeadm join --config worker-config.yaml
```

## 4. Verify

Go to the controller node and run the command `kubectl get nodes` to verify if the worker has joined the cluster.

# Video

{{<youtube wxa1fTDNcis>}}

# References

- [Installing kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/).
- [Creating a cluster with kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/).
- [Troubleshooting kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/troubleshooting-kubeadm/).
- [Kubeadm configuration reference](https://pkg.go.dev/k8s.io/kubernetes/cmd/kubeadm/app/apis/kubeadm/v1beta2).
- [Manually generating discovery-token-ca-cert-hash](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-join/#token-based-discovery-with-ca-pinning).
- [Quickstart for Calico on Kubernetes](https://docs.projectcalico.org/getting-started/kubernetes/quickstart).
