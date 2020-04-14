+++
author = "Suraj Deshmukh"
date = "2020-04-14T11:57:07+05:30"
title = "Enabling Seccomp on your Prometheus Operator and related Pods"
description = "This post shows how you can enable seccomp on all the Pods that are deployed with Prometheus Operator"
categories = ["kubernetes", "security"]
tags = ["seccomp", "kubernetes", "security"]
+++

[Seccomp](https://en.wikipedia.org/wiki/Seccomp) helps us limit the system calls the process inside container can make. And `PodSecurityPolicy` is the way to enable it on pods in Kubernetes.

# Prometheus Operator

Prometheus Operator makes it really easy to monitor your Kubernetes cluster. To deploy this behemoth, [helm chart](https://github.com/helm/charts/tree/master/stable/prometheus-operator) is the easiest way to do it.

Almost all the pods that run as a part of Prometheus Operator viz. **Prometheus Operator**, **Prometheus**, **Alertmanager**, **Grafana**, **Kube State Metrics** don’t need to run with elevated privileges except **Node Exporter**. In your Kubernetes cluster if you are using `PodSecurityPolicy` to make sure that your cluster is secure, then you would want your Prometheus Operator pods to run securely as well. And the good news is, Prometheus Operator chart ships `PodSecurityPolicy` for each sub-component. We will look at how to enable `seccomp` for all the sub-components.

Since these components have their own PSPs, to enable `seccomp` on the pods you only need to add specific **annotations** in `metadata.annotations`. These `annotations` can help you to select and set the `seccomp` profiles that is applied to the Pod which is mutated by that PSP. More information on seccomp with PSP is in the [Kubernetes docs](https://kubernetes.io/docs/concepts/policy/pod-security-policy/).

In examples below I assume that you are running your workloads on Docker, hence the annotation value is **`docker/default`**. If you are running your workloads on other runtimes then use the generic **`runtime/default`** policy as mentioned in the docs. There are ways to provide custom `seccomp` profiles, but it is out of scope of this post.

## Kube State Metrics

Using [Kube State Metrics](https://github.com/kubernetes/kube-state-metrics) is the best way to monitor your Kubernetes cluster **state**. Kube State Metrics chart supports custom PSP annotations which is little different from other components.

In the Prometheus Operator helm chart values file add following snippet to enable `seccomp` to the Kube State Metrics Pods:

```yaml
kube-state-metrics:
  podSecurityPolicy:
    annotations:
      seccomp.security.alpha.kubernetes.io/allowedProfileNames: 'docker/default'
      seccomp.security.alpha.kubernetes.io/defaultProfileName:  'docker/default'
```

Once this is added the resultant PSP will have following annotations:

```yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
 name: prometheus-operator-kube-state-metrics
 annotations:
   seccomp.security.alpha.kubernetes.io/allowedProfileNames: docker/default
   seccomp.security.alpha.kubernetes.io/defaultProfileName: docker/default
```

Now the Kube State Metrics pod that is mutated by the above PSP will have a `seccomp` profile that is shipped with Docker.

## Prometheus Operator

For workloads Prometheus, Prometheus Operator, Alertmanager here are steps to enable `seccomp` on those pods. Since Grafana chart already ships pods with seccomp enabled so we don't need any special provisions.

In the Prometheus Operator helm chart values file add following snippet:

```yaml
global:
  rbac:
    pspAnnotations:
      seccomp.security.alpha.kubernetes.io/allowedProfileNames: 'docker/default'
      seccomp.security.alpha.kubernetes.io/defaultProfileName:  'docker/default'
```

This will add above annotations to the PSP `metadata.annotations` of the aforementioned workloads.

## Verify if seccomp is enabled on a pod

To verify if the `seccomp` is enabled on a pod, you `kubectl exec` into the pod and run following command:

```bash
cat /proc/self/status | grep Seccomp:
```

If the output is `Seccomp:	2` then `seccomp` is enabled. If it is `Seccomp:	0` then `seccomp` is disabled.
