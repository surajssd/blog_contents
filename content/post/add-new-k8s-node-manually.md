+++
author = "Suraj Deshmukh"
title = "Adding new worker to existing Kubernetes cluster"
description = "Step by step guide to add new node"
date = "2018-09-23T01:00:51+05:30"
categories = ["kubernetes", "openshift"]
tags = ["kubernetes", "openshift", "notes"]
+++

To setup a multi-node Kubernetes cluster just run [this script](https://github.com/kinvolk/kubernetes-the-hard-way-vagrant#single-script) and you will have a cluster with 3 masters and 3 workers.

```bash
$ kubectl get nodes -o wide
NAME       STATUS    ROLES     AGE       VERSION   INTERNAL-IP      EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
worker-0   Ready     <none>    1h        v1.11.2   192.168.199.20   <none>        Ubuntu 18.04.1 LTS   4.15.0-33-generic   cri-o://1.11.2
worker-1   Ready     <none>    1h        v1.11.2   192.168.199.21   <none>        Ubuntu 18.04.1 LTS   4.15.0-33-generic   cri-o://1.11.2
worker-2   Ready     <none>    1h        v1.11.2   192.168.199.22   <none>        Ubuntu 18.04.1 LTS   4.15.0-33-generic   cri-o://1.11.2
```

Now to add a new node to this cluster you will need to bring up a VM, for this just use following `Vagrantfile`.

```bash
$ cat Vagrantfile 
# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|

  config.vm.define "ubuntu" do |ubuntu|
    ubuntu.vm.box = "ubuntu/bionic64"
    config.vm.hostname = "ubuntu"
    ubuntu.vm.network "private_network", ip: "192.168.199.23"
  end

  config.vm.provider "virtualbox" do |virtualbox, override|
    virtualbox.memory = 3000
    virtualbox.cpus = 3
  end
end
```

**Note**: This machine I have given IP address which is in the same subnet as other workers.

Bring up this machine using:

```bash
vagrant up
```

Now you can setup the node in one shot by running [this script](https://github.com/surajssd/scripts/blob/master/shell/add-node-to-k8s/add-node.sh).

# Download and install binaries

Let's go through this script and let me try to explain what each step does.

You can skip [the part](https://github.com/surajssd/scripts/blob/c7f5688e94b62e68c46719508badc911ee8ba518/shell/add-node-to-k8s/add-node.sh#L50-L76) where we are downloading tools, if you all the required binaries available, viz. `kubelet`, `kube-proxy`, `kubectl`, `cfssl`, `cni`, `runc`, etc.

Once you all the tools available install them following [this section](https://github.com/surajssd/scripts/blob/c7f5688e94b62e68c46719508badc911ee8ba518/shell/add-node-to-k8s/add-node.sh#L78-L106):

```bash
# install those tools
mkdir -p \
  /etc/containers \
  /etc/cni/net.d \
  /etc/crio \
  /opt/cni/bin \
  /usr/local/libexec/crio \
  /var/lib/kubelet \
  /var/lib/kube-proxy \
  /var/lib/kubernetes \
  /var/run/kubernetes

tar -xvf cni-plugins-amd64-v0.6.0.tgz -C /opt/cni/bin/

cp runc /usr/local/bin/
cp {crio,kube-proxy,kubelet,kubectl} /usr/local/bin/
cp {conmon,pause} /usr/local/libexec/crio/
cp {crio.conf,seccomp.json} /etc/crio/
cp policy.json /etc/containers/

curl -sSL \
  -O "https://pkg.cfssl.org/${cfssl_version}/cfssl_linux-amd64" \
  -O "https://pkg.cfssl.org/${cfssl_version}/cfssljson_linux-amd64"

chmod +x cfssl_linux-amd64 cfssljson_linux-amd64
mv -v cfssl_linux-amd64 /usr/local/bin/cfssl
mv -v cfssljson_linux-amd64 /usr/local/bin/cfssljson
```

# Generating configurations

Now that all the required tools are installed. Let's create the configuration that we need to make sure these tools work fine. But before that you will need the `ca.pem`, `ca-key.pem` & `ca-config.json` used for createing configs for `master` nodes.

### Configuration shared by all workers

Some of the configuration are same as other nodes which can be copied from other nodes. This includes following:

- `/etc/cni/net.d/99-loopback.conf`
- `/var/lib/kube-proxy/kubeconfig`
- `/etc/systemd/system/kube-proxy.service`

Following steps here help you re-create them if you can't access those from other nodes, follow them from [here](https://github.com/surajssd/scripts/blob/c7f5688e94b62e68c46719508badc911ee8ba518/shell/add-node-to-k8s/add-node.sh#L114-L186):

```bash
# generate the 99-loopback.conf common for all the workers, can be copied
cat > 99-loopback.conf <<EOF
{
    "cniVersion": "0.3.1",
    "type": "loopback"
}
EOF

# generate the kube-proxy cert common for all the workers, can be copied
cat > kube-proxy-csr.json <<EOF
{
  "CN": "system:kube-proxy",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:node-proxier",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF


cfssl gencert \
  -ca=${capem} \
  -ca-key=${cakeypem} \
  -config=${caconfig} \
  -profile=kubernetes \
  kube-proxy-csr.json | cfssljson -bare kube-proxy


kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority=${capem} \
  --embed-certs=true \
  --server=https://192.168.199.10:6443 \
  --kubeconfig="kube-proxy.kubeconfig"


kubectl config set-credentials kube-proxy \
  --client-certificate="kube-proxy.pem" \
  --client-key="kube-proxy-key.pem" \
  --embed-certs=true \
  --kubeconfig="kube-proxy.kubeconfig"


kubectl config set-context default \
  --cluster=kubernetes-the-hard-way \
  --user=kube-proxy \
  --kubeconfig="kube-proxy.kubeconfig"


kubectl config use-context default --kubeconfig="kube-proxy.kubeconfig"


# generate the kube-proxy.service common for all the workers, can be copied
cat > kube-proxy.service <<EOF
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-proxy \\
  --cluster-cidr=10.200.0.0/16 \\
  --kubeconfig=/var/lib/kube-proxy/kubeconfig \\
  --proxy-mode=iptables \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

### Configuration specific to workers

* The `cri-o` daemon's systemd service file.

```bash
# generate the service file for the crio daemon, specific to node
cat > ${hostname}-crio.service <<EOF
[Unit]
Description=CRI-O daemon
Documentation=https://github.com/kubernetes-incubator/cri-o

[Service]
ExecStart=/usr/local/bin/crio --stream-address ${ipaddr} --runtime /usr/local/bin/runc --registry docker.io
Restart=always
RestartSec=10s

[Install]
WantedBy=multi-user.target
EOF
```

Here IP address the daemon should bing to is to be specified and the only change.

* Generating `csr` file:

```bash
# generate the worker certs, specific to node
cat > ${hostname}-csr.json <<EOF
{
  "CN": "system:node:${hostname}",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:nodes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF
```

Make sure that the `CN` field in `csr` is of the format `system:node:<hostname>`, because this is used to register the name of the `worker` with `master`. This is the only changed field from other `worker` nodes.

* Generate `certs` and `kubeconfig`:

```bash
cfssl gencert \
  -ca=${capem} \
  -ca-key=${cakeypem} \
  -config=${caconfig} \
  -hostname="${hostname},${ipaddr}" \
  -profile=kubernetes \
  "${hostname}-csr.json" | cfssljson -bare "${hostname}"

# generate kubeconfig specific to the node
kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority=${capem} \
  --embed-certs=true \
  --server=https://192.168.199.40:6443 \
  --kubeconfig="${hostname}.kubeconfig"


kubectl config set-credentials system:node:${hostname} \
  --client-certificate="${hostname}.pem" \
  --client-key="${hostname}-key.pem" \
  --embed-certs=true \
  --kubeconfig="${hostname}.kubeconfig"


kubectl config set-context default \
  --cluster=kubernetes-the-hard-way \
  --user=system:node:${hostname} \
  --kubeconfig="${hostname}.kubeconfig"


kubectl config use-context default --kubeconfig="${hostname}.kubeconfig"
```


* Now create `kubelet` systemd service file:

```bash
cat > ${hostname}-kubelet.service <<EOF
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=crio.service
Requires=crio.service

[Service]
ExecStart=/usr/local/bin/kubelet \\
  --anonymous-auth=false \\
  --authorization-mode=Webhook \\
  --client-ca-file=/var/lib/kubernetes/ca.pem \\
  --allow-privileged=true \\
  --cluster-dns=10.32.0.10 \\
  --cluster-domain=cluster.local \\
  --container-runtime=remote \\
  --container-runtime-endpoint=unix:///var/run/crio/crio.sock \\
  --image-pull-progress-deadline=2m \\
  --image-service-endpoint=unix:///var/run/crio/crio.sock \\
  --kubeconfig=/var/lib/kubelet/kubeconfig \\
  --network-plugin=cni \\
  --register-node=true \\
  --runtime-request-timeout=10m \\
  --tls-cert-file=/var/lib/kubelet/${hostname}.pem \\
  --tls-private-key-file=/var/lib/kubelet/${hostname}-key.pem \\
  --node-ip=${ipaddr} \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

In above service file the things that changes are two flags: `--tls-cert-file` and `--tls-private-key-file`. And another flag value that is different from other nodes is `--node-ip`. Rest everything is same with other nodes. So just change the path to point to the right cert file and key file.

# Install configurations

Once all those configs are generated, copy all those to the appropriate location.

```bash
# install above generated config
cp 99-loopback.conf /etc/cni/net.d
cp kube-proxy.kubeconfig /var/lib/kube-proxy/kubeconfig
cp kube-proxy.service /etc/systemd/system/

cp "${hostname}-crio.service" /etc/systemd/system/crio.service
cp ${capem} /var/lib/kubernetes/
cp "${hostname}.pem" "${hostname}-key.pem" /var/lib/kubelet
cp "${hostname}.kubeconfig" /var/lib/kubelet/kubeconfig
cp "${hostname}-kubelet.service" /etc/systemd/system/kubelet.service
```

# Start processes

Now that all binaries and configs are in place, just restart the processes:

```bash
systemctl daemon-reload
systemctl enable crio kubelet kube-proxy
systemctl start crio kubelet kube-proxy
```

# Check nodes

```bash
$ kubectl get nodes -o wide
NAME       STATUS    ROLES     AGE       VERSION   INTERNAL-IP      EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
ubuntu     Ready     <none>    5m        v1.11.2   192.168.199.23   <none>        Ubuntu 18.04.1 LTS   4.15.0-34-generic   cri-o://1.11.2
worker-0   Ready     <none>    40m       v1.11.2   192.168.199.20   <none>        Ubuntu 18.04.1 LTS   4.15.0-34-generic   cri-o://1.11.2
worker-1   Ready     <none>    39m       v1.11.2   192.168.199.21   <none>        Ubuntu 18.04.1 LTS   4.15.0-34-generic   cri-o://1.11.2
worker-2   Ready     <none>    38m       v1.11.2   192.168.199.22   <none>        Ubuntu 18.04.1 LTS   4.15.0-34-generic   cri-o://1.11.2
```

Node has been added successfully.
