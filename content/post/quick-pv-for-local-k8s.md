+++
author = "Suraj Deshmukh"
date = "2017-04-18T23:56:15+05:30"
title = "Quick PV for local Kubernetes cluster"
description = "A hostPath based local PV creation process for using via PVC"
categories = ["notes"]
tags = ["kubernetes", "openshift", "pv"]

+++

I do lot of [Kubernetes](https://kubernetes.io/) related work either on [minikube](https://kubernetes.io/docs/getting-started-guides/minikube/) or local [OpenShift cluster](https://github.com/openshift/origin/blob/master/docs/cluster_up_down.md#overview) setup in a VM. Often I need to create a `PersistentVolumeClaim` a.k.a. `pvc`. But to use `pvc` you have to have a `PersistentVolume` or `pv` defined.

### Enter into the machine running k8s

If using minikube you can do

```bash
minikube ssh
```

### Create a local directory for storage

```bash
mkdir /tmp/pv0001
chmod 777 /tmp/pv0001
```

If you are on a machine that has `SELinux` enabled do the following

```bash
sudo chcon -R -t svirt_sandbox_file_t /tmp/pv0001
```

### Creating `pv`

Create file with following content

```
$ cat pv.yaml
apiVersion: "v1"
kind: "PersistentVolume"
metadata:
  name: "pv0001"
spec:
  capacity:
    storage: "5Gi"
  accessModes:
    - "ReadWriteOnce"
  persistentVolumeReclaimPolicy: Recycle
  hostPath:
    path: /tmp/pv0001
```

Get to the terminal from where you can run `kubectl` commands.

```bash
kubectl create -f pv.yaml
```

If you are doing it for OpenShift cluster then run following command with privileged access.

```bash
oc create -f pv.yaml
```

There you have a `pv` now you can create `pvc`'s to use it.
