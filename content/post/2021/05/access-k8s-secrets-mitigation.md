---
author: "Suraj Deshmukh"
date: "2021-05-20T08:47:07+05:30"
title: "Mitigation of: Access Any Kubernetes Secret"
description: "A Validating Admission Webhook Server to deny anyone accessing forbidden Kubernetes Secrets!"
draft: false
categories: ["kubernetes", "security"]
tags: ["kubernetes", "security"]
cover:
  image: "/post/2021/05/access-k8s-secrets-mitigation/config.png"
  alt: "Config"
---

In [the previous blog](https://suraj.io/post/2021/05/access-k8s-secrets/), we discussed how any user without RBAC access to a Kubernetes secret can use a trick to access that secret. To mitigate that problem, we will use a validating admission webhook. But before looking at what sorcery this validating admission webhook server is, let us understand how Kubernetes handles the API requests.

## What are admission controllers?

All requests going to the Kubernetes API server go through the following four steps:

1) Authentication
2) Authorisation
3) Admission controllers
4) Etcd Server

![API Request flow](/post/2021/05/access-k8s-secrets-mitigation/access-control-overview.svg "API Request flow")

[Image Source: Controlling Access to the Kubernetes API](https://kubernetes.io/docs/concepts/security/controlling-access/)

Request denied at any step does not go to the next steps. Any request reaching the "Admission Controllers" has already been authenticated and authorised. There are the [standard set of admission controllers](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#imagepolicywebhook) shipped with the Kubernetes API server. You can enable or disable them using flags to the Kubernetes API server.

As the name suggests, the job of the admission controller is to perform certain business logic based on the request. For example, the [NodeRestriction](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#noderestriction) admission controller's role is to restrict a node's (Kubelet's) access on top of RBAC restrictions. When Kubelet requests secrets from the Kubernetes API server, the NodeRestriction admission controller ensures that Kubelet does not request secrets for pods, **not** on its node. This is especially helpful if a node is compromised, then the hacker cannot request all secrets from the cluster.

## What is a Validating Admission Webhooks?

For our situation, we are going to use an admission controller called [ValidatingAdmissionWebhook](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#validatingadmissionwebhook). This allows us to dynamically load any new webserver with logic to process the requests sent by the ValidatingAdmissionWebhook admission controller. The expectation from these dynamically loaded webservers is to only respond with yes or no.

This admission controller sends a webhook to the specified endpoints when a given condition is met. We can ask things like send all the requests to a particular URL after encountering a resource called `pods` of apiVersion `v1` when someone is trying to `CREATE` them. Now all the pod create requests will be sent to your webserver.

![Admission Controllers Zoomed in](/post/2021/05/access-k8s-secrets-mitigation/admission-controller-phases.png "Admission Controllers Zoomed in")

[Image Source: A Guide to Kubernetes Admission Controllers](https://kubernetes.io/blog/2019/03/21/a-guide-to-kubernetes-admission-controllers/)

## Kubernetes Secret Access Validator

With all that essential knowledge, we will employ it to stop an attacker from gaining access to the secret they don't have RBAC access to. We will create a simple webhook server that will intercept all the Pod, CronJob, DaemonSet, Deployment, Job, ReplicaSet, ReplicationController and Statefulset create and update requests. On these requests, we will first figure out who (user/group) is making the request and what kind of secrets they are asking for access to?

Once we have these two pieces of information, we will do a programmatic equivalent of the following kubectl command:

```bash
kubectl --as=<API requesting user> can-i get secret <secret being accessed>
```

If the answer to the above is no, we will reject the request to the user.

![Rejected](/post/2021/05/access-k8s-secrets-mitigation/rejected.gif "Rejected")

## Validating Webhook Server in Action

Install the [Kubernetes Secret Access Validator](https://github.com/surajssd/k8s-secret-access-validator) by following the steps mentioned [here](https://github.com/surajssd/k8s-secret-access-validator#install). Now let us try to recreate the hack situation mentioned in the [previous blog](https://suraj.io/post/2021/05/access-k8s-secrets/).

Create a test user that has access to pods, but not to secrets:

```bash
kubectl create role pod-all --verb=* --resource=pods --resource=pods/exec
kubectl create rolebinding pod-all:nastyuser --role=pod-all --user=nastyuser
kubectl create secret generic supersecret --from-literal data=supersecretvaluesinhere
alias kubectl='kubectl --as=nastyuser'
kubectl auth can-i --list
```

Save this pod config in a `pod.yaml`, and we will try to deploy it:

```yaml
apiVersion: v1
kind: Pod
metadata:
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
    volumeMounts:
    - name: hackedsecret
      mountPath: /access-secret/
  dnsPolicy: ClusterFirst
  restartPolicy: Always
  volumes:
  - name: hackedsecret
    secret:
      secretName: supersecret
```

Now trying to deploy it:

```bash
$ kubectl create -f pod.yaml
Error from server: error when creating "pod.yaml": admission webhook "validating.suraj.io" denied the
request: User "nastyuser" does not have access to the secret "supersecret" in the namespace "default".
```

## In Conclusion

[This project](https://github.com/surajssd/k8s-secret-access-validator) is in a nascent stage. Right now, it only supports pod creation and update. The support for other pod creating controllers will be added soon.

I haven't fully grasped the side effect of this webhook server running inside an operational cluster. But once I do that, I will learn the pros and cons of this approach. Ideally, this should be done at the Kubernetes API server level.

If you are aware of any other solution, please comment or let me know on [Twitter](https://twitter.com/surajd_).
