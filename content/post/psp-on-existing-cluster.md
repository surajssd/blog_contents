+++
author = "Suraj Deshmukh"
title = "PodSecurityPolicy on existing Kubernetes clusters"
description = "Burnt by enabling PSPs on existing Kubernetes and wondering why everything still works"
date = "2018-10-23T00:00:51+05:30"
categories = ["kubernetes", "security"]
tags = ["security", "kubernetes"]
+++

I enabled [PodSecurityPolicy](https://kubernetes.io/docs/concepts/policy/pod-security-policy/) on a minikube cluster by appending `PodSecurityPolicy` to the apiserver flag in minikube like this:

```bash
--extra-config=apiserver.enable-admission-plugins=Initializers,NamespaceLifecycle,\
    LimitRanger,ServiceAccount,DefaultStorageClass,DefaultTolerationSeconds,\
    NodeRestriction,MutatingAdmissionWebhook,ValidatingAdmissionWebhook,\
    ResourceQuota,PodSecurityPolicy
```

Ideally when you have PSP enabled and if you don't define any PSP and authorize it with right RBAC no pod will start in the cluster. But what I saw was that there were some pods still running in `kube-system` namespace.

```bash
$ kubectl -n kube-system get pods
NAME                                    READY   STATUS    RESTARTS   AGE
coredns-576cbf47c7-g2t8v                1/1     Running   4          5d11h
etcd-minikube                           1/1     Running   2          5d11h
heapster-bn5xp                          1/1     Running   2          5d11h
influxdb-grafana-qzpv4                  2/2     Running   4          5d11h
kube-addon-manager-minikube             1/1     Running   2          5d11h
kube-controller-manager-minikube        1/1     Running   1          4d20h
kube-scheduler-minikube                 1/1     Running   2          5d11h
kubernetes-dashboard-5bb6f7c8c6-9d564   1/1     Running   8          5d11h
storage-provisioner                     1/1     Running   7          5d11h
```

Which got me thinking what is wrong with the way PSPs work. So if you look closely only two pods are scheduled by a deployment.

```bash
$ kubectl get deploy
NAME                   DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
coredns                1         1         1            1           5d11h
kubernetes-dashboard   1         1         1            0           5d11h
```

These pods were already scheduled and worked fine before, Kubernetes was just trying to restart them. Now when I deleted them

```bash
$ kubectl delete pod kubernetes-dashboard-5bb6f7c8c6-9d564
pod "kubernetes-dashboard-5bb6f7c8c6-9d564" deleted

$ kubectl delete pod coredns-576cbf47c7-g2t8v
pod "coredns-576cbf47c7-g2t8v" deleted
```

Those pods won't come up anymore

```bash
$ kubectl get deploy
NAME                   DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
coredns                1         0         0            0           5d11h
kubernetes-dashboard   1         0         0            0           5d11h
```

And the reason they won't come up.

```bash
$ kubectl get deploy coredns -o jsonpath='{.status.conditions[-1:].message}'
pods "coredns-576cbf47c7-" is forbidden: no providers available to validate pod request
```

So to fix this I will have to define a PSP and then bind it to the service account that these controllers use.

Using PSP; if you enable it on a running cluster and if it had some workloads that were running already they won't be affected. But once a pod is deleted and is up for re-scheduling again it will fail with something like above.

So to enable it on the running cluster here is what the [Kubernetes documentation](https://kubernetes.io/docs/concepts/policy/pod-security-policy/#enabling-pod-security-policies) says:

> Since the pod security policy API (**`policy/v1beta1/podsecuritypolicy`**) is enabled independently of the admission controller, for existing clusters it is recommended that policies are added and authorized before enabling the admission controller.
