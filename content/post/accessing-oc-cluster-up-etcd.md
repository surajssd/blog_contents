+++
author = "Suraj Deshmukh"
title = "Access etcd in OpenShift origin"
description = "Access the etcd in OpenShift started by oc cluster up"
date = "2018-07-11T01:00:51+05:30"
categories = ["openshift", "etcd"]
tags = ["openshift", "kubernetes", "notes"]
+++

How do you access the etcd that is being used by the OpenShift started by `oc cluster up` or using [minishift](https://docs.openshift.org/latest/minishift/getting-started/index.html).

If you are using minishift then get docker environment access of the minishift VM by running following commands.

```bash
eval $(minishift docker-env) && eval $(minishift oc-env)
```

Exec into the container named `origin` that runs OpenShift and all the needed services.

```bash
$ docker exec -it origin bash
```

First install the `etcdctl` needed to talk to `etcd`.

```bash
[root@surajd origin]$ yum -y install etcd
```

Get into the directory where all the certs and keys are available.

```bash
[root@surajd origin]$ cd /var/lib/origin/openshift.local.config/master
```

Now run following to connect to the `etcd`.

```bash
[root@surajd master]$ export ETCDCTL_API=3
[root@surajd master]$ etcdctl --cacert ./ca.crt --cert ./master.etcd-client.crt \
 --key ./master.etcd-client.key \
 --endpoints=[https://127.0.0.1:4001] \
 get --prefix --keys-only=true /

/kubernetes.io/apiextensions.k8s.io/customresourcedefinitions/openshiftwebconsoleconfigs.webconsole.operator.openshift.io

/kubernetes.io/apiservices/v1.

/kubernetes.io/apiservices/v1.apps

/kubernetes.io/apiservices/v1.apps.openshift.io
...
```

Now you can try to read about a specific object by looking at a specific key.

```bash
[root@surajd master]$ etcdctl --cacert ./ca.crt --cert ./master.etcd-client.crt --key ./master.etcd-client.key --endpoints=[https://127.0.0.1:4001] get --prefix  /openshift.io/users/developer
/openshift.io/users/developer
k8s

user.openshift.io/v1Userb
G
        developer"*$a749b0bf-79ee-11e8-87db-507b9d785c9e2zanypassword:developer"
```

This is a rpc binary data. You can use tools like [`protoc`](https://github.com/golang/protobuf#installation) to decode it. There is some discussion about [decoding](https://groups.google.com/forum/#!topic/kubernetes-dev/GZuEOsYC95c) this data.
