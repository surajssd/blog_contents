+++
author = "Suraj Deshmukh"
title = "How to backup and restore Prometheus?"
description = "Backing up Prometheus??!!"
date = "2020-07-31T19:00:51+05:30"
categories = ["prometheus", "backup", "notes", "kubernetes", "monitoring"]
tags = ["prometheus", "backup", "notes", "kubernetes", "monitoring"]
+++

This blog will show you how to take a backup from a running Prometheus and restore it in some other Prometheus instance. You might ask why would you even want to do something like that? Well, sometimes you want the Prometheus metrics because they were collected for some particular purpose and you want to do some analysis later.

## Prerequisites/Assumptions

This blog assumes that you have a Prometheus running that is deployed using  `prometheus-operator` in `monitoring` namespace. But even if you have deployed it in some other way modify the commands in few places.

## Steps

### Step: Enable Admin API.

Find out what is the name of your Prometheus object:

```bash
kubectl -n monitoring get prometheus
```

Set the value of `spec.enableAdminAPI` to `true`. Run the following command to do so:

```bash
kubectl -n monitoring patch prometheus prometheus-operator-prometheus \
  --type merge --patch '{"spec":{"enableAdminAPI":true}}'
```

### Step: Verify that the admin API is enabled.

```bash
$ kubectl -n monitoring get sts prometheus-prometheus-operator-prometheus \
  -o yaml | grep admin
        - --web.enable-admin-api
```

### Step: Verify that the pod is up.

Wait for the Prometheus pod to be up. It can take some time to be up if you have a lot of data. Move to next step once all the containers are in `READY` state.

```bash
$ kubectl -n monitoring get pods prometheus-prometheus-operator-prometheus-0
NAME                                          READY   STATUS    RESTARTS   AGE
prometheus-prometheus-operator-prometheus-0   3/3     Running   0          33m
```

### Step: Port Forward.

Open a separate window to port forward and keep it running in the foreground:

```bash
kubectl -n monitoring port-forward svc/prometheus-operator-prometheus 9090
```

### Step: Create a snapshot.

Run following command to

```
$ curl -XPOST http://localhost:9090/api/v2/admin/tsdb/snapshot
{"name":"20200731T123913Z-6e661e92759805f5"}
```

### Step: Locate snapshot.

Find the snapshot you have just created in the Prometheus pod. If you have provided the `--storage.tsdb.path` flag then the snapshot is under:

```bash
<tsdb-dir>/snapshots/<above-dir>
```

To figure out the path just exec into the pod:

```bash
$ kubectl -n monitoring exec -it prometheus-prometheus-operator-prometheus-0 \
  -c prometheus -- /bin/sh -c \
  "ls /prometheus/snapshots/20200731T123913Z-6e661e92759805f5"
01EE25G1ZTKBFBBHFPHNBF99KJ  01EEFF7TE5ENDAGDR5K7ERW3BX
...
```

### Step: Copy it locally.

Then copy the content from the `prometheus` container locally by running following command:

```bash
kubectl cp -n monitoring \
  prometheus-prometheus-operator-prometheus-0:/prometheus/snapshots/20200731T123913Z-6e661e92759805f5 \
  -c prometheus .
```

This might take a long time if you have a lot of data.

### Step: Upload it to new Prometheus pod.

Delete the data in the existing `--storage.tsdb.path`. By running following command:

```bash
kubectl -n newprom exec -it prometheus -- /bin/sh -c "rm -rf /prometheus/*"
```

Now upload the old data to the new pod:

```bash
kubectl -n newprom cp ./* prometheus:/prometheus/
```

**NOTE**: My new pod's `--storage.tsdb.path` points to `/prometheus`.

I hope this helps, happy hacking!
