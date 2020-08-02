+++
author = "Suraj Deshmukh"
title = "Being Productive with Kubectl"
description = "Tips and tricks to make your day to day usage easier"
date = "2020-08-02T16:00:51+05:30"
categories = ["kubernetes", "productivity", "bash", "notes"]
tags = ["kubernetes", "productivity", "notes"]
+++

This blog will showcase my productivity tips with `kubectl` . This does not venture into any plugins per se. But only using bash aliases to achieve it.

## Bash Aliases

```bash
# k8s alias
alias k=kubectl
alias kg="kubectl get"
alias kgp="kubectl get pods"
alias kgs="kubectl get services"
alias kge="kubectl get events"
alias kgpvc="kubectl get pvc"
alias kgpv="kubectl get pv"
alias kd="kubectl describe"
alias kl="kubectl logs -f"
alias kc="kubectl create -f"
```

I have above aliases setup in the `~/.bashrc` file. The beauty of the aliases is that you can append more flags and parameters to the existing smaller alias. For, e.g. I have an alias for `kubectl get pods` as `kgp`, but if I want to get pods from all the namespaces, I use `kgp -A`.

Most used of the above aliases are `kgp`, `kd`, `kl` and for anything else just `k` when I want some other command not aliased.

## Bash Auto-Completion

You might wonder with all those aliases how do I get the benefit of auto-completion? Well, I don't get the benefit with the aliases except for the alias of `kubectl` which is `k`. For that, I have following snippet added in `~/.bashrc` file. Take a note of the line `source <(kubectl completion bash | sed 's/kubectl/k/g')`.

```bash
which kubectl > /dev/null 2>&1
if [ $? -eq 0 ]; then
    source <(kubectl completion bash)
    source <(kubectl completion bash | sed 's/kubectl/k/g')
fi
```

**NOTE**: The above bash-completion has a check for the binary before sourcing its bash-completion code. This is done to avoid the errors like `bash: kubectl: command not found...` when starting the terminal.

## Changing namespaces

I have two functions for this, also added in the `~/.bashrc`.

```bash
# find what the current namespace on the cluster is
function current-ns() {
	kubectl get sa default -o jsonpath='{.metadata.namespace}'
	echo
}

# changing namespace
function change-ns() {
    namespace=$1
    if [ -z $namespace ]; then
        echo "Please provide the namespace name: 'change-ns mywebapp'"
        return 1
    fi

    kubectl config set-context $(kubectl config current-context) --namespace $namespace
}
```

For more information, read my other post on the topic of [changing namespace in Kubernetes](https://suraj.io/post/changing-k8s-ns/).

## Easy access scripts

For updating [`kubectl`](https://github.com/surajssd/dotfiles/blob/master/local-bin/update-kubectl.sh), [`minikube`](https://github.com/surajssd/dotfiles/blob/master/local-bin/update-minikube), [`helm`](https://github.com/surajssd/dotfiles/blob/master/local-bin/update-helm) or [`kustomize`](https://github.com/surajssd/dotfiles/blob/master/local-bin/update-kustomize.sh) I have scripts which update or download(if the binary is never downloaded) the binaries in place. I wrote a post a few weeks back explaining [how I manage my bespoke scripts and binaries](https://suraj.io/post/framework-for-scripts-and-binaries/).

There are other scripts for things that need many flags like [starting minikube](https://github.com/surajssd/dotfiles/blob/master/local-bin/start-minikube).

## Find the `jsonpath`

I use the JSON path a lot when trying to get a specific field from the YAML output. Now those of you who don't know what I am talking about, let's say you want to find out what time a pod was created. Then you can query it like this:

```bash
$ kgp kube-proxy-hp7kq -o jsonpath='{.metadata.creationTimestamp}'
2020-08-02T10:39:59Z
```

Here I am trying to find out when was the `kube-proxy` pod created. Now to even construct that JSON path of highly nested fields, it can become cumbersome. So I use a tool called [`jiq`](https://github.com/fiatjaf/jiq). See the following small video to understand how it is used:

{{<youtube MAQN2mcwmu8 >}}

## Conclusion

I hope this was helpful. I don't use any fancy plugins. But there are many ways out there if you are an Ops person dealing with Kubernetes in your diurnal life let me know what your productivity tips with Kubectl and Kubernetes in general are. Happy hacking!
