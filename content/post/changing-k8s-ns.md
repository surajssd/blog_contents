+++
author = "Suraj Deshmukh"
description = "Easy way to change namespace in Kubernetes"
date = "2018-07-02T08:00:51+05:30"
title = "Change namespaces in Kubernetes"
categories = ["cmd-line", "kubernetes"]
tags = ["openshift", "kubernetes", "notes"]
+++

There is no easy way to change namespace in Kubernetes using `kubectl` command line utility. But here are some commands that you can alias in your [`bashrc`](https://www.lifewire.com/bashrc-file-4101947) file so that it's just a single command that you can use to change the namespace in the Kubernetes cluster.

## Change namespace

Let's see step by step what goes in to change the namespace. So the first step is to find the context.

>A context element in a kubeconfig file is used to group access parameters under a convenient name. Each context has three parameters: cluster, namespace, and user. By default, the `kubectl` command-line tool uses parameters from the current context to communicate with the cluster.  [Read more](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/#context).

```bash
$ kubectl config current-context 
minikube
```

Now I have a namespace which I have created and want to switch to it.

```bash
$ kubectl create ns mywebapp
namespace "mywebapp" created
```

Now we have two needed information to change the current default namespace, context and namespace name.

```bash
$ kubectl config set-context minikube --namespace mywebapp
Context "minikube" modified.
```

Notice that we have put the context here as `minikube` and namespace name as we have created, `mywebapp`.

So this can be put in one command and used conveniently. Just copy following bash function into your `bashrc` file and you will have `change-ns` as a command available.

```bash
function change-ns() {
    namespace=$1
    if [ -z $namespace ]; then
        echo "Please provide the namespace name: 'change-ns mywebapp'"
        return 1
    fi

    kubectl config set-context $(kubectl config current-context) --namespace $namespace
}
```

## Verify change of namespace

How do you verify that the namespace is changed? How do you find what is the current namespace? Run following command:

```bash
kubectl get sa default -o jsonpath='{.metadata.namespace}'
```

Let's deconstruct that. Every namespace that is created has a `ServiceAccount` created by default with name `default` ([Read more](https://coreos.com/tectonic/docs/latest/users/creating-service-accounts.html#default-service-accounts)).

For any object/artifact in Kubernetes there is a field called `namespace` inside it's `metadata` field. Which tells you about what namespace a particular object is part of. If you don't set it while creating, Kubernetes will set it to the current default `namespace`. So this is a source of knowing what current `namespace` is.

Look at following pod object definition, the namespace for pod `storage-provisioner` is `kube-system`.

```bash
$ kubectl get pod storage-provisioner -o yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: 2018-06-10T09:56:24Z
  name: storage-provisioner
  namespace: kube-system
...
```

Now you can use the flag `-o` with `jsonpath` type of input to tell what specific object you would like to fetch information about, in our case we want `metadata.namespace`.

The above command can also be converted to one command, just add following snippet to `bashrc` and you will have a command `current-ns`.

```bash
function current-ns() {
	kubectl get sa default -o jsonpath='{.metadata.namespace}'
	echo
}
```

Hope that helps, you with being productive with Kubernetes. Happy hacking!
