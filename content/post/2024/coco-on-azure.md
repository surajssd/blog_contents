---
author: "Suraj Deshmukh"
date: "2024-04-05T09:21:07+05:30"
title: "Open Source Confidential Containers (CoCo) on Azure"
description: "Explore how Azure’s support for nested confidential compute unlocks a straightforward path to deploying Confidential Containers (CoCo), ensuring enhanced data security in the cloud with ease."
draft: false
categories: ["kubernetes", "security", "coco"]
tags: ["kubernetes", "security", "coco"]
cover:
  image: "/post/2024/images/coco-on-azure.png"
  alt: "CoCo on Azure"
---

## Introduction

In the realm of cloud computing, ensuring data privacy and security is paramount, yet profoundly challenging. One innovative solution to this challenge is [Confidential Containers (CoCo)](https://confidentialcontainers.org/)<cite>[^1]</cite>, designed to provide an extra layer of security for data in use. However, deploying CoCo requires access to specialized hardware, which adds complexity. Beyond just finding the right hardware, the setup involves navigating a maze of technical specifications – from BIOS configurations to kernel versions – making the process daunting.

[^1]: Official Confidential Containers Website: [https://confidentialcontainers.org/](https://confidentialcontainers.org/)

Enter Azure's [nested confidential compute](https://techcommunity.microsoft.com/t5/apps-on-azure-blog/public-preview-confidential-containers-on-aks/ba-p/3980871)<cite>[^2]</cite> for AMD SEV-SNP, a breakthrough in making CoCo more accessible and manageable. This blog post will guide you through leveraging Azure's support to deploy CoCo-based workloads with ease. You'll learn not only how to navigate the setup process but also how Azure simplifies the deployment. Whether you're a seasoned cloud professional or new to the concept of confidential computing, this post will provide valuable insights into making the most of CoCo on Azure.

[^2]: Public preview: Confidential containers on AKS [https://techcommunity.microsoft.com/t5/apps-on-azure-blog/public-preview-confidential-containers-on-aks/ba-p/3980871](https://techcommunity.microsoft.com/t5/apps-on-azure-blog/public-preview-confidential-containers-on-aks/ba-p/3980871)

Here is how we will achieve this installation:

1. Procure an Azure VM capable of running nested confidential compute
2. Install single-node Kubernetes cluster
3. Install CoCo
4. Run sample workload

## 1: Nested Confidential Compute Capable VM

### 1.1: Export Environment Variables

Export the following environment variables, you can make changes as you deem necessary:

```bash
export RESOURCE_GROUP="coco-on-azure"
export VM_NAME="${RESOURCE_GROUP}"
export SSH_PRIV_KEY="~/.ssh/id_rsa"
export SSH_KEY="${SSH_PRIV_KEY}.pub"
export USER_NAME="azure"
```

Export these environment variables as necessary:

> **Note**: You can choose a bigger machine type exported in the environment variable `VM_SIZE`. You can find other machine types [here](https://learn.microsoft.com/en-us/azure/virtual-machines/dcasccv5-dcadsccv5-series)<cite>[^3]</cite>.

```bash
export VM_IMAGE="/CommunityGalleries/cocopreview-91c44057-c3ab-4652-bf00-9242d5a90170/Images/ubuntu2004-snp-host/Versions/latest"
export LOCATION="eastus"
export VM_SIZE="Standard_DC8as_cc_v5"
```

[^3]: DCas_cc_v5 and DCads_cc_v5-series (Preview) [https://learn.microsoft.com/en-us/azure/virtual-machines/dcasccv5-dcadsccv5-series](https://learn.microsoft.com/en-us/azure/virtual-machines/dcasccv5-dcadsccv5-series)

> _Kudos 🎉 to [Jeremi Piotrowski](https://github.com/jepio) for building the worker node / host OS VM-image. You can find instructions to build this image here<cite>[^4]</cite>_

[^4]: Build Worker Node / host OS VM Image [https://github.com/jepio/AMDSEV/tree/sev-snp-devel/packer](https://github.com/jepio/AMDSEV/tree/sev-snp-devel/packer)

### 1.2: Create Azure Resource Group

> **Note**: You can skip this step if you already have a resource group you use.

```bash
az group create \
  --name "${RESOURCE_GROUP}" \
  --location "${LOCATION}"
```

### 1.3: Deploy the VM

```bash
az vm create \
  --resource-group "${RESOURCE_GROUP}" \
  --size "${VM_SIZE}" \
  --name "${VM_NAME}" \
  --location "${LOCATION}" \
  --admin-username "${USER_NAME}" \
  --ssh-key-values "${SSH_KEY}" \
  --authentication-type ssh \
  --image "${VM_IMAGE}" \
  --public-ip-address-dns-name "${VM_NAME}" \
  --os-disk-size-gb 300 \
  --accelerated-networking true \
  --security-type standard \
  --accept-term
```

### 1.4: SSH into the VM

```bash
eval "ssh -i ${SSH_PRIV_KEY} ${USER_NAME}@${VM_NAME}.${LOCATION}.cloudapp.azure.com"
```

## 2: Install Single-Node Kubernetes Cluster

Following instructions were created based on the official [Kubernetes documentation](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)<cite>[^5]</cite> and [Docker documentation](https://docs.docker.com/engine/install/ubuntu/)<cite>[^6]</cite>.

[^5]: Installing kubeadm [https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)
[^6]: Install Docker Engine on Ubuntu
 [https://docs.docker.com/engine/install/ubuntu/](https://docs.docker.com/engine/install/ubuntu/)

### 2.1: Install Prerequisites

```bash
sudo apt-get update
sudo apt-get install -y gdb binutils apt-transport-https ca-certificates curl gpg
```

### 2.2: Configure Docker Repository

```bash
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
  sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
```

### 2.3: Configure Kubernetes Repository

```bash
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

### 2.4: Install Docker & Kubernetes

```bash
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

### 2.5: Start Containerd Daemon

```bash
containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl restart containerd

sudo systemctl enable --now containerd
sudo systemctl enable --now docker
sudo docker run hello-world
```

### 2.6: Disable Swap

Since this machine is acting as both control-plane and the worker node, so disable swap.

```bash
sudo swapoff -a
sudo cp /etc/fstab /etc/fstab.bak
sudo sed -i '/\bswap\b/d' /etc/fstab
```

### 2.7: Ensure Networking is Configured

```bash
sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

echo '
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
' | sudo tee /etc/sysctl.d/k8s.conf

sudo sysctl --system
```

### 2.8: Initialize Kubeadm

```bash
echo '
kind: ClusterConfiguration
apiVersion: kubeadm.k8s.io/v1beta3
networking:
  podSubnet: "192.168.0.0/16"
---
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
cgroupDriver: systemd
podCIDR: "192.168.0.0/16"
' | tee kubeadm-config.yaml

sudo kubeadm config images pull
sudo kubeadm init --config kubeadm-config.yaml
```

### 2.9: Configure Kubernetes Config

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### 2.10: Install CNI

Following Calico installation steps were taken from the official [Calico documentation](https://docs.tigera.io/calico/latest/getting-started/kubernetes/quickstart#install-calico)<cite>[^7]</cite>.

[^7]: Quickstart for Calico on Kubernetes [https://docs.tigera.io/calico/latest/getting-started/kubernetes/quickstart#install-calico](https://docs.tigera.io/calico/latest/getting-started/kubernetes/quickstart#install-calico)

```bash
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.3/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.3/manifests/custom-resources.yaml
```

### 2.11: Ensure Single-Node Acts as Control Plane and Worker

```bash
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
```

## 3: Install Confidential Containers (CoCo) Using Operator

### 3.1: Install Operator

CoCo operator installation steps are taken from [this official documentation](https://github.com/confidential-containers/operator/blob/main/docs/INSTALL.md)<cite>[^8]<cite>.

[^8]: Confidential Containers Operator Installation: [https://github.com/confidential-containers/operator/blob/main/docs/INSTALL.md](https://github.com/confidential-containers/operator/blob/main/docs/INSTALL.md)

```bash
export COCO_OPERATOR_VERSION="0.8.0"
kubectl apply -k "github.com/confidential-containers/operator/config/release?ref=v${COCO_OPERATOR_VERSION}"
kubectl apply -k "github.com/confidential-containers/operator/config/samples/ccruntime/default?ref=v${COCO_OPERATOR_VERSION}"
kubectl label nodes --all node.kubernetes.io/worker=
```

> **Note**: Find the latest release of the Confidential Containers from the [project release page](https://github.com/confidential-containers/operator/releases)<cite>[^9]<cite>.

[^9]: Confidential Containers Operator Release Page [https://github.com/confidential-containers/operator/releases](https://github.com/confidential-containers/operator/releases)

### 3.2: Verify Runtimeclasses Availability

```bash
kubectl get runtimeclass
```

A sample output would look like the following:

```console
$ kubectl get runtimeclass
NAME            HANDLER         AGE
kata            kata-qemu       26s
kata-clh        kata-clh        37s
kata-clh-tdx    kata-clh-tdx    30s
kata-qemu       kata-qemu       30s
kata-qemu-sev   kata-qemu-sev   26s
kata-qemu-snp   kata-qemu-snp   26s
kata-qemu-tdx   kata-qemu-tdx   26s
```

## 4. Run Sample Application

### 4.1: Run Nginx in TEE

```bash {linenos=true,hl_lines=[17]}
echo '
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-snp
  namespace: default
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 1
  template:
    metadata:
      labels:
        app: nginx
    spec:
      runtimeClassName: kata-qemu-snp
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
        imagePullPolicy: Always
' | kubectl apply -f -
```

### 4.2: Verify Pod is Running

Ensure that the pod is running:

```bash
kubectl get pods
```

### 4.2: Verify Pod is Running in TEE

```bash
ps aux | grep qemu
```

## Wrapping Up

Today, we've learnt the deployment of Confidential Containers (CoCo) on Azure, moving beyond the limitations of specialized hardware and complex setups. By harnessing Azure's nested confidential compute capabilities, we've showcased an easier path to get started with CoCo. We started with setting up a conducive environment on Azure, configuring a single-node Kubernetes cluster, installing CoCo, and finally, deploying a sample application.

As we look forward, the natural progression is to delve into the possibilities with Azure Kubernetes Service (AKS) for deploying CoCo. This exploration is just the beginning. The realm of confidential computing is vast and full of potential. As you continue to experiment and learn, let this experience serve as a foundation for your future projects, driving home the importance of security in our increasingly cloud-centric world.

Happy hacking, and here's to elevating the security of your cloud workloads to new heights!
