+++
author = "Suraj Deshmukh"
title = "Add new Node to k8s cluster with Bootstrap token"
description = "Use this technique to add new node to the cluster without providing any certificates and without having to restart the kube-apiserver"
date = "2018-10-24T01:00:51+05:30"
categories = ["kubernetes"]
tags = ["kubernetes", "security"]
+++

> **NOTE**: There is an updated version of this blog [here](https://suraj.io/post/2021/02/k8s-bootstrap-token/).

Few days back I wrote a blog about [adding new node to the cluster](https://suraj.io/post/add-new-k8s-node-cert-rotate/) using the static token file. The problem with that approach is that you need to restart `kube-apiserver` providing it the path to the token file. Here we will see how to use the bootstrap token, which is very dynamic in nature and can be controlled by using Kubernetes resources like `secrets`.

So if you are following [Kubernetes the Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way/) to set up the cluster here are the changes you should do to adapt it to run with bootstrap token.

# Master Node changes

## kube-apiserver

Add this flag `--enable-bootstrap-token-auth=true` to your `kube-apiserver` service file. In the end your service file should look like following:

```
cat <<EOF | sudo tee /etc/systemd/system/kube-apiserver.service
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-apiserver \\
  --advertise-address=${INTERNAL_IP} \\
  --allow-privileged=true \\
  --apiserver-count=3 \\
  --audit-log-maxage=30 \\
  --audit-log-maxbackup=3 \\
  --audit-log-maxsize=100 \\
  --audit-log-path=/var/log/audit.log \\
  --authorization-mode=Node,RBAC \\
  --bind-address=0.0.0.0 \\
  --client-ca-file=/var/lib/kubernetes/ca.pem \\
  --enable-admission-plugins=Initializers,NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \\
  --enable-bootstrap-token-auth=true \\
  --enable-swagger-ui=true \\
  --etcd-cafile=/var/lib/kubernetes/ca.pem \\
  --etcd-certfile=/var/lib/kubernetes/kubernetes.pem \\
  --etcd-keyfile=/var/lib/kubernetes/kubernetes-key.pem \\
  --etcd-servers=https://192.168.50.10:2379 \\
  --event-ttl=1h \\
  --experimental-encryption-provider-config=/var/lib/kubernetes/encryption-config.yaml \\
  --kubelet-certificate-authority=/var/lib/kubernetes/ca.pem \\
  --kubelet-client-certificate=/var/lib/kubernetes/kubernetes.pem \\
  --kubelet-client-key=/var/lib/kubernetes/kubernetes-key.pem \\
  --kubelet-https=true \\
  --runtime-config=api/all \\
  --service-account-key-file=/var/lib/kubernetes/service-account.pem \\
  --service-cluster-ip-range=10.32.0.0/24 \\
  --service-node-port-range=30000-32767 \\
  --tls-cert-file=/var/lib/kubernetes/kubernetes.pem \\
  --tls-private-key-file=/var/lib/kubernetes/kubernetes-key.pem \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

## kube-controller-manager

Add following flag `--controllers=*,bootstrapsigner,tokencleaner` to the controller manager service file. So service file should look like following:

```
cat <<EOF | sudo tee /etc/systemd/system/kube-controller-manager.service
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-controller-manager \\
  --address=0.0.0.0 \\
  --cluster-cidr=10.200.0.0/16 \\
  --cluster-name=kubernetes \\
  --cluster-signing-cert-file=/var/lib/kubernetes/ca.pem \\
  --cluster-signing-key-file=/var/lib/kubernetes/ca-key.pem \\
  --controllers=*,bootstrapsigner,tokencleaner \\
  --kubeconfig=/var/lib/kubernetes/kube-controller-manager.kubeconfig \\
  --leader-elect=true \\
  --root-ca-file=/var/lib/kubernetes/ca.pem \\
  --service-account-private-key-file=/var/lib/kubernetes/service-account-key.pem \\
  --service-cluster-ip-range=10.32.0.0/24 \\
  --use-service-account-credentials=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

## Bootstrap secret

The bootstrap token that we are using to setup is `07401b.f395accd246ae52d`(You can generate one of yourself). This token has two parts `07401b` which is public id and private part `f395accd246ae52d` a secret. Read more about the token, what is allowed and what it should look like [here](https://kubernetes.io/docs/reference/access-authn-authz/bootstrap-tokens/#enabling-bootstrap-token-authentication). And about the bootstrap token secret format [here](https://kubernetes.io/docs/reference/access-authn-authz/bootstrap-tokens/#bootstrap-token-secret-format).

Create following secret which has certain requirements. The name of the secret should of the format `bootstrap-token-<token public id>` and should be available in `kube-system` namespace.

```
cat <<EOF | kubectl apply --kubeconfig admin.kubeconfig -f -
apiVersion: v1
kind: Secret
metadata:
  # Name MUST be of form "bootstrap-token-<token id>"
  name: bootstrap-token-07401b
  namespace: kube-system

# Type MUST be 'bootstrap.kubernetes.io/token'
type: bootstrap.kubernetes.io/token
stringData:
  # Human readable description. Optional.
  description: "Created for Kubernetes the Hard Way"

  # Token ID and secret. Required.
  token-id: 07401b
  token-secret: f395accd246ae52d

  # Allowed usages.
  usage-bootstrap-authentication: "true"
  usage-bootstrap-signing: "true"
EOF
```

## RBAC policies to enable bootstrapping

The user authenticated by that token belongs to the group `system:bootstrappers`, that is why following permissions are given to that group.

```bash
kubectl create clusterrolebinding kubelet-bootstrap \
  --clusterrole=system:node-bootstrapper \
  --group=system:bootstrappers

kubectl create clusterrolebinding node-autoapprove-bootstrap \
  --clusterrole=system:certificates.k8s.io:certificatesigningrequests:nodeclient \
  --group=system:bootstrappers

kubectl create clusterrolebinding node-autoapprove-certificate-rotation \
  --clusterrole=system:certificates.k8s.io:certificatesigningrequests:selfnodeclient \
  --group=system:nodes
```

# Worker node changes

## Kubelet

Add this flag `--bootstrap-kubeconfig`, it is a path to kubeconfig which we will generate shortly, it contains bootstrap token and information to talk to the `kube-apiserver`. And also you don't need to provide `--kubeconfig` but provide a path to it, this will be auto-generated and saved at that path.

Your kubelet service file should look like following:

```
cat <<EOF | sudo tee /etc/systemd/system/kubelet.service
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=containerd.service
Requires=containerd.service

[Service]
ExecStart=/usr/local/bin/kubelet \\
  --bootstrap-kubeconfig=/home/vagrant/bootstrap.kubeconfig \\
  --config=/var/lib/kubelet/kubelet-config.yaml \\
  --container-runtime=remote \\
  --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock \\
  --image-pull-progress-deadline=2m \\
  --kubeconfig=/home/vagrant/kubeconfig \\
  --network-plugin=cni \\
  --register-node=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

Now changes in kubelet configuration file

```
cat <<EOF | sudo tee /var/lib/kubelet/kubelet-config.yaml
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "/home/vagrant/ca.pem"
authorization:
  mode: Webhook
clusterDomain: "cluster.local"
clusterDNS:
  - "10.32.0.10"
podCIDR: "${POD_CIDR}"
rotateCertificates: true
runtimeRequestTimeout: "15m"
serverTLSBootstrap: true
EOF
```

Provide appropriate path to `clientCAFile`. And add two more fields `rotateCertificates: true` & `serverTLSBootstrap: true`, this will enable cert rotation.

## Create bootstrap kubeconfig

```bash
# I have used the ip address of my kube kube-apiserver use yours
kubectl config set-cluster kthwkinvolk \
  --certificate-authority=ca.pem \
  --embed-certs=true \
  --server=https://192.168.50.10:6443 \
  --kubeconfig=/home/vagrant/bootstrap.kubeconfig

# this token is above generated
kubectl config set-credentials kubelet-bootstrap \
  --token=07401b.f395accd246ae52d \
  --kubeconfig=/home/vagrant/bootstrap.kubeconfig

kubectl config set-context default \
  --cluster=kthwkinvolk \
  --user=kubelet-bootstrap \
  --kubeconfig=/home/vagrant/bootstrap.kubeconfig

kubectl config use-context default \
  --kubeconfig=/home/vagrant/bootstrap.kubeconfig
```

This is the bootstrap config file which we referred earlier in kubelet service file.

Now once you start `kubelet` service it will use the bootstrap token in the initial request and fetch the certificates.

# Trying it all in one go

Here is the [link to the gist](https://gist.github.com/surajssd/71892b7a9c5c2cb175fd050cee45d495) where you can start a master and a node using Vagrant and create cluster using above setup.

Hope that helps. Happy Hacking.
