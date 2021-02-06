+++
author = "Suraj Deshmukh"
title = "Enable TLS bootstrapping in a Kubernetes cluster"
description = "Add a new node using a bootstrap token to Kubernetes"
date = "2021-02-06T10:25:41+05:30"
categories = ["kubernetes", "notes", "certs"]
tags = ["kubernetes", "notes", "certs"]
+++

This blog is a recap of my old blog ["Add new node to Kubernetes cluster with bootstrap token"](https://suraj.io/post/add-new-k8s-node-bootstrap-token/). Like the aforementioned blog, we will look at how to enable TLS bootstrapping on an existing Kubernetes cluster at control plane level and add a new node (or modify existing ones) to the cluster using bootstrap tokens. At the end of this blog, you will learn what specific steps to take to enable TLS bootstrapping on any custom-built Kubernetes cluster.

# Textual

## 1. Kubernetes Cluster

If you have a cluster running, you can skip this step. To demonstrate how TLS bootstrap tokens work, I have brought up a cluster using [Kubernetes the Hard Way (Vagrant)](https://github.com/kinvolk/kubernetes-the-hard-way-vagrant/). This section shows how to bring up a multi-node, multi-worker Kubernetes cluster quickly.

### 1.1. Setup Machine

I am running this setup on a Ubuntu 20.04 machine. Install virtual-box and vagrant by executing the following commands as the `root` user:

```bash
apt-get update && \
apt-get -y upgrade && \
apt-get install -y make git byobu linux-generic

systemctl reboot

apt-get install -y linux-headers-`uname -r` && \
apt install -y virtualbox && \
apt-get install -y vagrant && \
dpkg-reconfigure virtualbox-dkms
```

### 1.2. Clone the Repository

```bash
mkdir -p git/kubernetes-the-hard-way-vagrant
git clone https://github.com/kinvolk/kubernetes-the-hard-way-vagrant git/kubernetes-the-hard-way-vagrant
cd git/kubernetes-the-hard-way-vagrant
```

### 1.3. Install the Cluster

```bash
./scripts/install-tools
./scripts/setup
```

### 1.4. Verify the Cluster Installation

```bash
kubectl get nodes
```

## 2. Prepare Control Plane

### 2.1. Setup RBAC

When a new node tries to authenticate to the control plane, the only credential used is a bootstrap token. Such a node client (kubelet) is a member of group `system:bootstrappers`, we need to ensure that such a client has permissions to create Certificate Signing Requests (CSRs), get them approved, renew them, etc. The following ClusterRoleBindings will ensure that these nodes join without authorisation issues. This setting needs to be done only once and does not change from node-to-node.

Run the following command to create the bindings that will allow the new nodes to connect to the cluster:

```yaml
cat <<EOF | kubectl apply -f -
# Enable bootstrapping nodes to create CSR.
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: create-bootstrapping-csr
subjects:
- kind: Group
  name: system:bootstrappers
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: system:node-bootstrapper
  apiGroup: rbac.authorization.k8s.io
---
# Approve all CSRs for the group "system:bootstrappers".
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: approve-csrs
subjects:
- kind: Group
  name: system:bootstrappers
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: system:certificates.k8s.io:certificatesigningrequests:nodeclient
  apiGroup: rbac.authorization.k8s.io
---
# Approve renewal CSRs for the group "system:nodes".
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: approve-node-renewals
subjects:
- kind: Group
  name: system:nodes
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: system:certificates.k8s.io:certificatesigningrequests:selfnodeclient
  apiGroup: rbac.authorization.k8s.io
EOF
```

### 2.2. Modify Kubernetes Apiserver

Add the following set of flags to the `kube-apiserver`:

```bash
--authorization-mode=Node,RBAC
--enable-bootstrap-token-auth=true
```

Above setting needs to be performed on each control plane node.

### 2.3. Modify Kubernetes Controller Manager

Add the following flag to the `kube-controller-manager`:

```bash
--controllers=*,tokencleaner,bootstrapsigner
```

Above setting needs to be performed on each control plane node.

## 3. Modify / Add Workers

### 3.1. Create the Bootstrap Token

Please note these tokens, we will need them in two places. One, while creating a bootstrap-token embedded Kubernetes Secret object and another in the bootstrap kubeconfig for the Kubelet:

```bash
TOKEN_ID=$(openssl rand -hex 3)
TOKEN_SECRET=$(openssl rand -hex 8)
```

### 3.2. Create Bootstrap Token Secret

Kubernetes apiserver will use this secret to identify the node that is joining the cluster. Execute the following command to create the secret embedding the previously generated tokens:

```yaml
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
type: bootstrap.kubernetes.io/token
metadata:
  name: bootstrap-token-$TOKEN_ID
  namespace: kube-system
stringData:
  description: "Manually generated bootstrap token."
  token-id: "$TOKEN_ID"
  token-secret: "$TOKEN_SECRET"
  usage-bootstrap-authentication: "true"
  usage-bootstrap-signing: "true"
EOF
```

### 3.3. Create Bootstrap Kubeconfig for Kubelets

Create bootstrap Kubeconfig for Kubelet(s):

```bash
SERVER=$(kubectl config view -ojsonpath='{.clusters[0].cluster.server}')
CA_CERT=$(kubectl config view --flatten -ojsonpath='{.clusters[0].cluster.certificate-authority-data}')
```

```yaml
cat <<EOF | tee kubeconfig
apiVersion: v1
kind: Config
clusters:
- name: local
  cluster:
    server: "$SERVER"
    certificate-authority-data: "$CA_CERT"
users:
- name: kubelet
  user:
    token: "$TOKEN_ID.$TOKEN_SECRET"
contexts:
- context:
    cluster: local
    user: kubelet
EOF
```

Keep this file around it will be needed to connect worker(s) node using bootstrap token to control plane.

### 3.4. Modify Kubelet

Copy the bootstrap kubeconfig created in step 3.3 to the worker node you want to connect to control plane using bootstrap tokens. Save the kubeconfig on the node and provide the path to that file to flag `--bootstrap-kubeconfig`. The path supplied to `--kubeconfig` will have newly downloaded kubeconfig once the kubelet authenticates with the kube-apiserver.

Add the following set of flags to the `kubelet`:

```bash
--kubeconfig=/var/lib/kubelet/kubeconfig
--bootstrap-kubeconfig=/etc/kubernetes/kubeconfig
--rotate-certificates
```

**NOTE:** You can remove the file in `/var/lib/kubelet/kubeconfig`, especially if you modify an existing worker node, to ensure that Kubelet downloads the new kubeconfig at that location.

You can have a separate token for each worker node to reduce the attack surface. To generate distinct token repeat steps 3.1 to 3.4 for each worker node. But if you wish to use the same token for each worker node, repeat step 3.4 on each worker.

## 4. Verify

Ensure that the node has joined the control plane using TLS bootstrap token by executing the following command:

```bash
kubectl get nodes
```

# Video

Watch this video to understand the same process explained in this blog. Unlike my previous blog videos, I am narrating, so you know what is going on.

{{<youtube RpBHoAmBBYY>}}

# References

- [Authenticating with Bootstrap Tokens](https://kubernetes.io/docs/reference/access-authn-authz/bootstrap-tokens/).
