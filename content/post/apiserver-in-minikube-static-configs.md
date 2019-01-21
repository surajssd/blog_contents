+++
author = "Suraj Deshmukh"
title = "Make static configs available for apiserver in minikube"
description = "Dealing with apiserver in minikube can be tricky"
date = "2019-01-20T01:00:51+05:30"
categories = ["kubernetes", "minikube", "notes"]
tags = ["kubernetes", "minikube"]
+++

If you want to provide extra flags to the `kube-apiserver` that runs inside minikube how do you do it? You can use the minikube's `--extra-config` flag with `apiserver.<apiserver flag>=<value>`, for e.g. if you want to enable `RBAC` authorization mode you do it as follows:

```bash
--extra-config=apiserver.authorization-mode=RBAC
```

So this is a no brainer when doing it for flags whose value can be given right away, like the one above. But what if you want to provide value which is a file path. Because you will have to make that file available for apiserver. And this apiserver runs as a static pod inside minikube. How do you make the file available to that process inside pod inside minikube?

The solution is little tricky and not very straight forward. The api-server pod mounts minikube's `/var/lib/minikube/certs/` directory in the pod at location `/var/lib/minikube/certs/`. Make the file available at this location. When enabling that flag for apiserver provide file location of this directory.

To make this step easier I have filed an issue in minikube upstream [kubernetes/minikube/3559](https://github.com/kubernetes/minikube/issues/3559).

Follow this tutorial on how to do this. In this tutorial I want to make the `EncryptionConfiguration` file available for apiserver to enable encryption of secret data at rest. This is the first step to the tasks from kubernetes docs as mentioned [here](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/#configuration-and-determining-whether-encryption-at-rest-is-already-enabled).

---

### Start minikube normally

To make the file needed available in the machine start minikube normally. For that run following command:

```bash
minikube start \
--vm-driver kvm2 \
--kubernetes-version v1.13.2 \
--cpus 3 --memory 3000  \
--extra-config=apiserver.authorization-mode=RBAC \
--v 10
```

You can make required changes to the above commmand lke change the `--vm-driver` or `--cpus` or `--memory`, as per your needs.

### Make file available inside minikube

Run following command to go into machine

```bash
minikube ssh
```

Once inside machine become root by running `sudo -i`. And then create the config file needed that will be passed to the apiserver. For my needs I wanted to create a `EncryptionConfiguration`.

Run following command to make the config file available.

```bash
echo "
kind: EncryptionConfiguration
apiVersion: apiserver.config.k8s.io/v1
resources:
  - resources:
    - secrets
    providers:
    - aescbc:
        keys:
        - name: key1
          secret: fPLrjJNkbuLmh2aqOsCR5sZV+/Wqhi8CdMrgceaKR3E=
    - identity: {}
" | tee /var/lib/minikube/certs/encryptionconfig.yaml
```

See the location of the file it is in `/var/lib/minikube/certs`. In above command you can change it to the config you would want to make available for apiserver.

### Restart minikube

Exit out of the minikube vm and get to your host machine and run following:

```bash
minikube stop

minikube start \
--vm-driver kvm2 \
--kubernetes-version v1.13.2 \
--cpus 3 --memory 3000  \
--extra-config=apiserver.authorization-mode=RBAC \
--extra-config=apiserver.encryption-provider-config=/var/lib/minikube/certs/encryptionconfig.yaml \
--v 10
```

Again make changes to the apiserver flag and file name if needed according to your needs. Now you should have apiserver started without problems.
