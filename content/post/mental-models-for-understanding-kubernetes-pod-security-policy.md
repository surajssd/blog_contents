+++
author = "Suraj Deshmukh"
title = "Mental models for understanding Kubernetes Pod Security Policy"
description = "Getting the game of PSP right!"
date = "2021-01-16T13:10:51+05:30"
categories = ["kubernetes", "lokomotive"]
tags = ["kubernetes", "lokomotive", "security"]
+++

PodSecurityPolicy (PSP) is hard to get right in the first attempt. There has never been a situation when I haven't banged my head to get it working on the cluster. It is a frustrating experience, but it is one of the essential security features of Kubernetes. Some applications have started shipping the PSP configs with their helm charts, but if a helm chart does not ship a PSP config, it must be handcrafted by the **cluster-admin** to make the application work reliably in the cluster.

This post assumes that you already know what [Pod Security Policies](https://kubernetes.io/docs/concepts/policy/pod-security-policy) and [Role-based access control (RBAC)](https://kubernetes.io/docs/reference/access-authn-authz/rbac/) are. You can find the best explanation of the basics from the upstream documentation.

This post will define a nomenclature for PSP types, how a **cluster-admin** can create a PSP that is allowed for all workloads, and how a developer can generate PSP from scratch. This post won't try to define steps on achieving above but will give guidelines and point you into the right direction for securing your cluster with PSPs.

## Policy Order

Some PSPs also mutate the pod specification besides allowing or disallowing pods. The [policy order of Kubernetes documentation](https://kubernetes.io/docs/concepts/policy/pod-security-policy/#policy-order) states the following two ways a PSP is chosen for a pod:

1. If a PSP allows the pod specification as is without a mutation, then that PSP is used.
2. If the above condition fails, then the fist PSP is chosen from an allowed-PSP list, and the pod is mutated accordingly.

So from the above policy order, we can infer that we will need two sets of PSPs in a cluster:

1. **Application-Specific PSP:** This ensures that the pod passes as it is without a mutation. The application developers have to ensure that the PSP config they ship with the deployment manifests should match exactly otherwise their application could either be disallowed from working in a PSP enabled cluster or runs at reduced privileges (due to mutation) enforced by cluster-wide PSP.
2. **Cluster-wide PSP:** The cluster should have a "restrictive" policy which comes into the picture as per the second point in the policy order. Such a restrictive PSP should be allowed to all the workloads.

## Application-specific PSP

These are the general steps I take when crafting the PSP that is application-specific:

1. Lockdown the application with the help of pod's [security context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/). Explore each option in the security context and decide what is suitable for the application.
2. Ensure that the application is working fine in the above-restricted settings previously unknown to the application.
3. Start from [privileged PSP](https://kubernetes.io/docs/concepts/policy/pod-security-policy/#example-policies) (see below) and keep restricting it as per the application pod specification.

```yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: privileged
  annotations:
    seccomp.security.alpha.kubernetes.io/allowedProfileNames: '*'
spec:
  privileged: true
  allowPrivilegeEscalation: true
  allowedCapabilities:
  - '*'
  volumes:
  - '*'
  hostNetwork: true
  hostPorts:
  - min: 0
    max: 65535
  hostIPC: true
  hostPID: true
  runAsUser:
    rule: 'RunAsAny'
  seLinux:
    rule: 'RunAsAny'
  supplementalGroups:
    rule: 'RunAsAny'
  fsGroup:
    rule: 'RunAsAny'
```

[**source:** Kubernetes PSP documentaton, `privileged` PSP.](https://kubernetes.io/docs/concepts/policy/pod-security-policy/#example-policies)

Once the above conditions are satisfied, it does not matter what you name it, because this PSP will be given first priority over any other allowed PSP since it enables the pod created by your application to pass precisely without any mutation.

![Application-specific PSP not provided](/images/mental-models-for-understanding-kubernetes-pod-security-policy/looney.gif "Application-specific PSP not provided")

In the above gif, you can see that the wall has a hole (silhouette) of [Bugs Bunny](https://looneytunes.fandom.com/wiki/Bugs_Bunny), think of it as if the Kubernetes cluster only allows PSP with bunny properties lets call it `bunny-psp`. Now the [Elmer Fudd](https://looneytunes.fandom.com/wiki/Elmer_Fudd) tries to enter through it but cannot since no PSP allows his properties to pass through. So the cluster-admin has to either create a PSP that matches his profile, and he can pass through the wall without hitting it.

You can also use tools like [PSP advisor](https://github.com/sysdiglabs/kube-psp-advisor) from [sysdig](https://sysdig.com/), but please perform the above step 1 and step 2 from the above list before you use this tool. This tool basically automates the step 3 only.

## Cluster-wide PSP

These PSPs apply to the workloads that don't ship their own PSP manifests. You would want your clusters to have a catch-all PSP config. Such a generalised PSP should ideally be restrictive in nature. The PSP should have everything locked down like no root user, no privilege escalation using `privileged` field, all the host namespace fields are disallowed, etc.

```yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: aa-restricted
  annotations:
    seccomp.security.alpha.kubernetes.io/allowedProfileNames: 'docker/default,runtime/default'
    apparmor.security.beta.kubernetes.io/allowedProfileNames: 'runtime/default'
    seccomp.security.alpha.kubernetes.io/defaultProfileName:  'runtime/default'
    apparmor.security.beta.kubernetes.io/defaultProfileName:  'runtime/default'
spec:
  privileged: false
  # Required to prevent escalations to root.
  allowPrivilegeEscalation: false
  # This is redundant with non-root + disallow privilege escalation,
  # but we can provide it for defense in depth.
  requiredDropCapabilities:
    - ALL
  # Allow core volume types.
  volumes:
    - 'configMap'
    - 'emptyDir'
    - 'projected'
    - 'secret'
    - 'downwardAPI'
    # Assume that persistentVolumes set up by the cluster admin are safe to use.
    - 'persistentVolumeClaim'
  hostNetwork: false
  hostIPC: false
  hostPID: false
  runAsUser:
    # Require the container to run without root privileges.
    rule: 'MustRunAsNonRoot'
  seLinux:
    # This policy assumes the nodes are using AppArmor rather than SELinux.
    rule: 'RunAsAny'
  supplementalGroups:
    rule: 'MustRunAs'
    ranges:
      # Forbid adding the root group.
      - min: 1
        max: 65535
  fsGroup:
    rule: 'MustRunAs'
    ranges:
      # Forbid adding the root group.
      - min: 1
        max: 65535
  readOnlyRootFilesystem: false
```

[**source:** Kubernetes PSP documentaton, `restrictive` PSP](https://kubernetes.io/docs/concepts/policy/pod-security-policy/#example-policies)

Such a policy is allowed to every authenticated user (including service accounts) via the group `system:authenticated`. In the `ClusterRoleBinding`, when you provide `subjects` list the aforementioned group as one of them and the `ClusterRole` mentioned under the `roleRef` is bound to each and every authenticated user on the cluster.

```yaml
- kind: Group
  apiGroup: rbac.authorization.k8s.io
  name: system:authenticated
```

[**source:** Kubernetes PSP documentaton](https://kubernetes.io/docs/concepts/policy/pod-security-policy/#via-rbac)

Allowing this policy to every authenticated user (even workload users a.k.a. service accounts) is not enough. You also need to make sure that this policy is on the top of the alphabetically sorted list. Ensure that the policy name starts with `aa`, so it is always on the top of the list.

![Restrictive PSP mutating pods](/images/mental-models-for-understanding-kubernetes-pod-security-policy/cheese.gif "Restrictive PSP mutating pods")

[**source:** What Cheese Looks Like Around The World by Insider](https://youtu.be/2NutfCHAyNM).

A generic restrictive PSP that mutates the pods looks like above, cheese cutting/moulding machine. It is ensuring that whatever comes out is of fixed mould, in case of Kubernetes the pod has fixed security restrictions.

## Conclusion

I hope this blog gives you some mental models of understanding how PSPs works in general. Although PSP is being discussed in upstream for replacing with something robust like the OPA Gatekeeper, it is not official yet. It is not clear when will that materialise, but until then, PSP is the saviour we have.
If you are still confused about this, please reach out to me I will happy to explain.
